//
//  GameView.swift
//  FlaskGame
//
//  Created by Jordan Christensen on 12/16/20.
//

import SwiftUI

struct GameView: View {
    @ObservedObject private var flaskController: FlaskController
    
    @State private var selectedFlask: Flask? = nil
    
    private var flaskHeight: CGFloat = UIScreen.main.bounds.height / 4
    
    init(flaskController: FlaskController = FlaskController()) {
        self.flaskController = flaskController
    }
    
    var body: some View {
        VStack {
            HStack {
                Button(action: { flaskController.undo() }, label: {
                    Image(systemName: "arrow.uturn.backward.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                })
                
                Spacer()
                
                Button(action: { flaskController.newGame() }, label: {
                    Image(systemName: "plus.square.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                })
                
                Spacer()
                
                Button(action: { flaskController.restart() }, label: {
                    Image(systemName: "repeat")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                })
            }
            .frame(height: 30)
            .padding(.top, 16)
            
            let split = flaskController.flasks.count / 2
            
            Spacer()
            
            HStack {
                ForEach(0..<split) { i in
                    let flask = flaskController.flasks[i]
                    
                    FlaskView(flask: flask)
                        .offset(y: selectedFlask == flask ? -20 : 0)
                        .onTapGesture {
                            flaskTapped(flask)
                        }
                }
            }
            .frame(height: flaskHeight)
            
            Spacer()
            
            HStack {
                ForEach(split..<flaskController.flasks.count) { i in
                    let flask = flaskController.flasks[i]
                    
                    FlaskView(flask: flaskController.flasks[i])
                        .offset(y: selectedFlask == flask ? -20 : 0)
                        .onTapGesture {
                            flaskTapped(flask)
                        }
                }
            }
            .frame(height: flaskHeight)
            
            Spacer()
        }
        .padding(.horizontal, 20)
    }
    
    func flaskTapped(_ flask: Flask) {
        if let firstFlask = selectedFlask {
            if firstFlask == flask {
                animate {
                    selectedFlask = nil
                }
            } else {
                flaskController.dumpFlask(firstFlask.index, into: flask.index)
                
                animate {
                    selectedFlask = nil
                }
            }
        } else {
            withAnimation {
                selectedFlask = flask
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        GameView()
    }
}

func animate(_ body: () throws -> Void) rethrows {
    try withAnimation(.spring(response: 0.5, dampingFraction: 0.7, blendDuration: 0.5), body)
}
