//
//  ContentView.swift
//  GameControllerExp
//
//  Created by Larry Zeng on 9/30/25.
//

import GameController
import SwiftUI

struct ContentView: View {
    @Environment(GameControllerManager.self) private var gameControllerManager

    var body: some View {
        if gameControllerManager.connected == nil {
            GameControllerSelectView()
        } else if gameControllerManager.controllerState == nil {
            GameControllerNoStateView()
        } else {
            DualSenseControllerDebugView()
        }
    }
}

#Preview {
    ContentView()
}
