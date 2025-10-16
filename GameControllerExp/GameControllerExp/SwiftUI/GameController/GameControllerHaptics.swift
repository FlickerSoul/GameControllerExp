//
//  GameControllerHaptics.swift
//  GameControllerExp
//
//  Created by Larry Zeng on 10/17/25.
//

import CoreHaptics
import GameController
import SwiftUI

struct GameControllerHaptics: View {
    let controller: GCController
    @State private var hapticLocalityChoice: GCHapticsLocality?
    @State private var hapticEngine: CHHapticEngine?

    private var hapticsChoices: Set<GCHapticsLocality> {
        controller.haptics?.supportedLocalities ?? []
    }

    private var supportsHaptics: Bool {
        hapticsChoices.isEmpty
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text(hapticEngine == nil ? "Engine Not Ready" : "Engine Ready")
            Picker("Haptics Locality", selection: $hapticLocalityChoice) {
                ForEach(hapticsChoices.sorted(by: { $0.rawValue < $1.rawValue }), id: \.self) { choice in
                    Text(choice.rawValue)
                        .tag(choice as GCHapticsLocality?)
                }
                if hapticLocalityChoice == nil {
                    Text("None")
                        .tag(nil as GCHapticsLocality?)
                }
            }
            .onChange(of: hapticLocalityChoice) {
                guard let hapticLocalityChoice else {
                    return
                }

                hapticEngine = controller.haptics?.createEngine(withLocality: hapticLocalityChoice)
            }

            Button {
                playHaptics()
            } label: {
                Text("Play Haptic")
            }
            .disabled(hapticEngine == nil)
        }
        .onAppear {
            hapticLocalityChoice = hapticsChoices.first
        }
    }

    private func playHaptics() {
        guard let hapticEngine else {
            return
        }
        let intensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0)
        let sharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)

        let event = CHHapticEvent(
            eventType: .hapticContinuous,
            parameters: [intensity, sharpness],
            relativeTime: 0,
            duration: 1.0
        )

        do {
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try hapticEngine.makePlayer(with: pattern)

            try hapticEngine.start()
            try player.start(atTime: 0)
        } catch {
            print("Failed to play haptics: \(error)")
        }
    }
}
