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
    @State private var showAlert: Bool = false
    
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
                
                Button(action: { showAlert = true }, label: {
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
            
            let start = flaskController.flasks.startIndex
            let half = start.advanced(by: flaskController.flasks.count / 2)
            let end = flaskController.flasks.endIndex
            
            let firstHalf = flaskController.flasks[start..<half]
            let secondHalf = flaskController.flasks[half..<end]
            
            Spacer()
            
            HStack {
                ForEach(firstHalf) { flask in
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
                ForEach(secondHalf) { flask in
                    FlaskView(flask: flask)
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
        .alert(isPresented: $showAlert, content: {
            Alert(title: Text("Select level difficulty:"), primaryButton: .default(Text("12")) {
                flaskController.newGame()
            }, secondaryButton: .default(Text("14")) {
                flaskController.newGame(flaskCount: 14)
            })
        })
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
