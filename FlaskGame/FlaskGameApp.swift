//
//  FlaskGameApp.swift
//  FlaskGame
//
//  Created by Jordan Christensen on 12/16/20.
//

import SwiftUI

@main
struct FlaskGameApp: App {
    @StateObject private var flaskController = FlaskController()
    
    var body: some Scene {
        WindowGroup {
            GameView(flaskController: flaskController)
        }
    }
}
