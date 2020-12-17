//
//  GameView.swift
//  FlaskGame
//
//  Created by Jordan Christensen on 12/16/20.
//

import SwiftUI

struct GameView: View {
    @ObservedObject private var flaskController: FlaskController
    
    init(flaskController: FlaskController = FlaskController()) {
        self.flaskController = flaskController
    }
    
    var body: some View {
        VStack {
            let split = flaskController.flasks.count / 2
            
            Spacer()
            
            HStack {
                ForEach(0..<split) { i in
                    FlaskView(flask: flaskController.flasks[i])
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 50)
            .padding(.top, 20)
            
            HStack {
                ForEach(split..<flaskController.flasks.count) { i in
                    FlaskView(flask: flaskController.flasks[i])
                }
            }
            .padding(.horizontal)
            .padding(.top, 50)
            .padding(.bottom, 20)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        GameView()
    }
}
