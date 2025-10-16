//
//  GameControllerSelectView.swift
//  GameControllerExp
//
//  Created by Larry Zeng on 10/12/25.
//

import GameController
import SwiftUI

struct GameControllerSelectView: View {
    @State private var selectedController: GCController?
    @State private var controllers: [GCController] = []
    @Environment(\.scenePhase) private var scenePhase
    @Environment(GameControllerManager.self) var gameControllerManager

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Picker("Select a game controller", selection: $selectedController) {
                    ForEach(controllers, id: \.self) { controller in
                        Text(controller.vendorName ?? "Unknown Controller")
                            .tag(controller as GCController?)
                    }
                    Text("None")
                        .tag(nil as GCController?)
                }
                Button {
                    refresh()
                } label: {
                    Text("Refresh")
                }
            }

            Button {
                select()
            } label: {
                Text("Use")
            }
            .disabled(selectedController == nil)
        }
    }

    private func refresh() {
        controllers = gameControllerManager.list()
        if !controllers.contains(where: { $0 == selectedController }) {
            selectedController = controllers.first
        }
    }

    private func select() {
        guard let selectedController else {
            return
        }

        gameControllerManager.connect(selectedController)
    }
}
