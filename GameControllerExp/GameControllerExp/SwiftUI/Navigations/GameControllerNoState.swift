//
//  GameControllerNoState.swift
//  GameControllerExp
//
//  Created by Larry Zeng on 10/16/25.
//

import SwiftUI

struct GameControllerNoStateView: View {
    var body: some View {
        HStack {
            Text("Waiting for Game Controller Input")
            ProgressView()
                .progressViewStyle(.circular)
        }
    }
}
