//
//  DualSenseAdaptiveTriggerControl.swift
//  GameControllerExp
//
//  Created by Larry Zeng on 10/16/25.
//
import GameController
import SwiftUI

private let stepperStep: Float = 0.005

struct DualSenseAdaptiveTriggerControlImpl: View {
    @Observable
    class ControlViewModel {
        var mode: GCDualSenseAdaptiveTrigger.Mode

        init(
            mode: GCDualSenseAdaptiveTrigger.Mode,
        ) {
            self.mode = mode
        }
    }

    let trigger: GCDualSenseAdaptiveTrigger
    @State private var viewModel: ControlViewModel

    init(trigger: GCDualSenseAdaptiveTrigger) {
        self.trigger = trigger
        _viewModel = .init(
            initialValue: ControlViewModel(mode: trigger.mode)
        )
    }

    private static var modeCandidates: [(mode: GCDualSenseAdaptiveTrigger.Mode, title: LocalizedStringKey)] {
        [
            (.off, "Off"),
            (.feedback, "Feedback"),
            (.weapon, "Weapon"),
            (.vibration, "Vibration"),
            (.slopeFeedback, "Slope Feedback"),
        ]
    }

    var body: some View {
        VStack {
            TimelineView(.animation(minimumInterval: 0.01)) { _ in
                VStack(alignment: .leading, spacing: 2) {
                    Text("Arm position: \(trigger.armPosition.formatted(.number.precision(.fractionLength(2))))")
                    Text("Status: \(trigger.status.nameString)")
                }
            }

            Picker("Mode", selection: $viewModel.mode) {
                ForEach(Self.modeCandidates, id: \.mode) { mode in
                    Text(mode.title).tag(mode.mode)
                }
            }

            switch viewModel.mode {
            case .off:
                OffModeView(trigger: trigger)
            case .feedback:
                SwitcherView {
                    FeedbackModeSimpleView(trigger: trigger)
                        .containerValue(\.name, "Simple")
                    FeedbackModePositionalView(trigger: trigger)
                        .containerValue(\.name, "Positional")
                }
            case .weapon:
                WeaponModeView(trigger: trigger)
            case .vibration:
                SwitcherView {
                    VibrationModeSimpleView(trigger: trigger)
                        .containerValue(\.name, "Simple")
                    VibrationModePositionalView(trigger: trigger)
                        .containerValue(\.name, "Positional")
                }
            case .slopeFeedback:
                SlopeFeedbackModeView(trigger: trigger)
            @unknown default:
                Text("Unknown Mode")
            }
        }
    }
}

extension GCDualSenseAdaptiveTrigger.Status {
    var nameString: String {
        switch self {
        case .unknown:
            "Unknown"
        case .feedbackNoLoad:
            "Feedback No Load"
        case .feedbackLoadApplied:
            "Feedback Load Applied"
        case .weaponReady:
            "Weapon Ready"
        case .weaponFiring:
            "Weapon Firing"
        case .weaponFired:
            "Weapon Fired"
        case .vibrationNotVibrating:
            "Vibration Not Vibrating"
        case .vibrationIsVibrating:
            "Vibration Is Vibrating"
        case .slopeFeedbackReady:
            "Slope Feedback Ready"
        case .slopeFeedbackApplyingLoad:
            "Slope Feedback Applying Load"
        case .slopeFeedbackFinished:
            "Slope Feedback Finished"
        @unknown default:
            "Unknown Status Value"
        }
    }
}

// MARK: - Mode Configuration Views

private extension ContainerValues {
    @Entry var name: String = "Unknown"
}

private struct SwitcherView<Content: View>: View {
    @State private var selection: String?
    @ViewBuilder let content: Content

    var body: some View {
        Picker("Content", selection: $selection) {
            Group(subviews: content) { views in
                ForEach(views) { view in
                    let name: String = view.containerValues.name
                    Text(name).tag(name as String?)
                }
                .onAppear {
                    selection = views.first?.containerValues.name
                }

                if selection == nil {
                    Text("Select a mode").tag(nil as String?)
                }
            }
        }

        Group(subviews: content) { views in
            ForEach(views) { view in
                if selection == view.containerValues.name {
                    view
                }
            }
        }
    }
}

private struct OffModeView: View {
    let trigger: GCDualSenseAdaptiveTrigger

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Off Mode")
                .font(.headline)

            Text("Provides no adaptive trigger effects.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(.gray)
        .cornerRadius(8)
        .onAppear {
            setMode()
        }
    }

    private func setMode() {
        trigger.setModeOff()
    }
}

private struct FeedbackModeSimpleView: View {
    let trigger: GCDualSenseAdaptiveTrigger

    @State private var startPosition: Float = 0.0
    @State private var resistiveStrength: Float = 0.5

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Feedback Mode (Simple)")
                .font(.headline)

            VStack(alignment: .leading, spacing: 8) {
                Text("Start Position: \(startPosition, specifier: "%.3f")")
                    .font(.subheadline)
                Slider(value: $startPosition, in: 0 ... 1, step: stepperStep)

                Text("Resistive Strength: \(resistiveStrength, specifier: "%.3f")")
                    .font(.subheadline)
                Slider(value: $resistiveStrength, in: 0 ... 1, step: stepperStep)
            }

            Text("Provides feedback when the user depresses the trigger equal to, or greater than, the start position.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(.gray)
        .cornerRadius(8)
        .onAppear {
            setMode()
        }
        .onChange(of: startPosition) {
            setMode()
        }
        .onChange(of: resistiveStrength) {
            setMode()
        }
    }

    private func setMode() {
        trigger.setModeFeedbackWithStartPosition(startPosition, resistiveStrength: resistiveStrength)
    }
}

private struct FeedbackModePositionalView: View {
    static let tupleSize = 10
    let trigger: GCDualSenseAdaptiveTrigger

    @State private var strengths: [Float] = Array(repeating: 0.5, count: 10)

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Feedback Mode (Positional)")
                .font(.headline)

            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(0 ..< Self.tupleSize, id: \.self) { index in
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Position \(index): \(strengths[index], specifier: "%.3f")")
                                .font(.subheadline)
                            Slider(value: $strengths[index], in: 0 ... 1)
                        }
                    }
                }
            }
            .frame(maxHeight: 200)

            Text("Provides positional feedback with custom resistive strengths at each position.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(.gray)
        .cornerRadius(8)
        .onAppear {
            setMode()
        }
        .onChange(of: strengths) {
            setMode()
        }
    }

    private func setMode() {
        guard strengths.count == Self.tupleSize else {
            return
        }
        let tuple = (
            strengths[0],
            strengths[1],
            strengths[2],
            strengths[3],
            strengths[4],
            strengths[5],
            strengths[6],
            strengths[7],
            strengths[8],
            strengths[9]
        )
        let resistiveStrengths = GCDualSenseAdaptiveTrigger.PositionalResistiveStrengths(values: tuple)
        trigger.setModeFeedback(resistiveStrengths: resistiveStrengths)
    }
}

private struct WeaponModeView: View {
    let trigger: GCDualSenseAdaptiveTrigger

    @State private var startPosition: Float = 0.2
    @State private var endPosition: Float = 0.8
    @State private var resistiveStrength: Float = 0.7

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Weapon Mode")
                .font(.headline)

            VStack(alignment: .leading, spacing: 8) {
                Text("Start Position: \(startPosition, specifier: "%.3f")")
                    .font(.subheadline)
                Slider(value: $startPosition, in: 0 ... endPosition, step: stepperStep)

                Text("End Position: \(endPosition, specifier: "%.3f")")
                    .font(.subheadline)
                Slider(value: $endPosition, in: 0 ... 1, step: stepperStep)

                Text("Resistive Strength: \(resistiveStrength, specifier: "%.3f")")
                    .font(.subheadline)
                Slider(value: $resistiveStrength, in: 0 ... 1, step: stepperStep)
            }

            Text("Provides feedback when the user depresses the trigger between the start and end positions.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(.gray)
        .cornerRadius(8)
        .onAppear {
            setMode()
        }
        .onChange(of: startPosition) {
            setMode()
        }
        .onChange(of: endPosition) {
            setMode()
        }
        .onChange(of: resistiveStrength) {
            setMode()
        }
    }

    private func setMode() {
        if startPosition > endPosition {
            startPosition = endPosition
        }
        trigger.setModeWeaponWithStartPosition(
            startPosition,
            endPosition: endPosition,
            resistiveStrength: resistiveStrength
        )
    }
}

private struct VibrationModeSimpleView: View {
    let trigger: GCDualSenseAdaptiveTrigger

    @State private var startPosition: Float = 0.0
    @State private var amplitude: Float = 0.5
    @State private var frequency: Float = 1.0

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Vibration Mode (Simple)")
                .font(.headline)

            VStack(alignment: .leading, spacing: 8) {
                Text("Start Position: \(startPosition, specifier: "%.3f")")
                    .font(.subheadline)
                Slider(value: $startPosition, in: 0 ... 1, step: stepperStep)

                Text("Amplitude: \(amplitude, specifier: "%.3f")")
                    .font(.subheadline)
                Slider(value: $amplitude, in: 0 ... 1, step: stepperStep)

                Text("Frequency: \(frequency, specifier: "%.3f") Hz")
                    .font(.subheadline)
                Slider(value: $frequency, in: 0 ... 1, step: stepperStep)
            }

            Text("Vibrates when the user depresses the trigger equal to, or greater than, the start position.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(.gray)
        .cornerRadius(8)
        .onAppear {
            setMode()
        }
        .onChange(of: startPosition) {
            setMode()
        }
        .onChange(of: amplitude) {
            setMode()
        }
        .onChange(of: frequency) {
            setMode()
        }
    }

    private func setMode() {
        trigger.setModeVibrationWithStartPosition(startPosition, amplitude: amplitude, frequency: frequency)
    }
}

private struct VibrationModePositionalView: View {
    static let tupleSize = 10
    let trigger: GCDualSenseAdaptiveTrigger

    @State private var amplitudes: [Float] = Array(repeating: 0.5, count: 10)
    @State private var frequency: Float = 1.0

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Vibration Mode (Positional)")
                .font(.headline)

            VStack(alignment: .leading, spacing: 8) {
                Text("Frequency: \(frequency, specifier: "%.3f") Hz")
                    .font(.subheadline)
                Slider(value: $frequency, in: 0 ... 1, step: stepperStep)
            }

            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(0 ..< Self.tupleSize, id: \.self) { index in
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Position \(index): \(amplitudes[index], specifier: "%.3f")")
                                .font(.subheadline)
                            Slider(value: $amplitudes[index], in: 0 ... 1, step: stepperStep)
                        }
                    }
                }
            }
            .frame(maxHeight: 200)

            Text("Vibrates with positional amplitude control at the specified frequency.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(.gray)
        .cornerRadius(8)
        .onAppear {
            setMode()
        }
        .onChange(of: amplitudes) {
            setMode()
        }
        .onChange(of: frequency) {
            setMode()
        }
    }

    private func setMode() {
        guard amplitudes.count == Self.tupleSize else {
            return
        }

        let tuple = (
            amplitudes[0],
            amplitudes[1],
            amplitudes[2],
            amplitudes[3],
            amplitudes[4],
            amplitudes[5],
            amplitudes[6],
            amplitudes[7],
            amplitudes[8],
            amplitudes[9]
        )
        let positionalAmplitudes = GCDualSenseAdaptiveTrigger.PositionalAmplitudes(values: tuple)
        trigger.setModeVibration(amplitudes: positionalAmplitudes, frequency: frequency)
    }
}

private struct SlopeFeedbackModeView: View {
    let trigger: GCDualSenseAdaptiveTrigger

    @State private var startPosition: Float = 0.2
    @State private var endPosition: Float = 0.8
    @State private var startStrength: Float = 0.3
    @State private var endStrength: Float = 0.9

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Slope Feedback Mode")
                .font(.headline)

            VStack(alignment: .leading, spacing: 8) {
                Text("Start Position: \(startPosition, specifier: "%.3f")")
                    .font(.subheadline)
                Slider(value: $startPosition, in: 0 ... endPosition, step: stepperStep)

                Text("End Position: \(endPosition, specifier: "%.3f")")
                    .font(.subheadline)
                Slider(value: $endPosition, in: 0 ... 1, step: stepperStep)

                Text("Start Strength: \(startStrength, specifier: "%.3f")")
                    .font(.subheadline)
                Slider(value: $startStrength, in: 0 ... 1, step: stepperStep)

                Text("End Strength: \(endStrength, specifier: "%.3f")")
                    .font(.subheadline)
                Slider(value: $endStrength, in: 0 ... 1, step: stepperStep)
            }

            Text("Provides feedback when the user tilts the trigger between the start and end positions.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(.gray)
        .cornerRadius(8)
        .onAppear {
            setMode()
        }
        .onChange(of: startPosition) {
            setMode()
        }
        .onChange(of: endPosition) {
            setMode()
        }
        .onChange(of: startStrength) {
            setMode()
        }
        .onChange(of: endStrength) {
            setMode()
        }
    }

    private func setMode() {
        if startPosition > endPosition {
            startPosition = endPosition
        }
        trigger.setModeSlopeFeedback(
            startPosition: startPosition,
            endPosition: endPosition,
            startStrength: startStrength,
            endStrength: endStrength
        )
    }
}
