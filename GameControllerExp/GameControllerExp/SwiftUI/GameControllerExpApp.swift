//
//  GameControllerExpApp.swift
//  GameControllerExp
//
//  Created by Larry Zeng on 9/30/25.
//

import SwiftUI

@main
struct GameControllerExpApp: App {
    @State private var gameControllerManager = GameControllerManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .environment(gameControllerManager)
    }
}
