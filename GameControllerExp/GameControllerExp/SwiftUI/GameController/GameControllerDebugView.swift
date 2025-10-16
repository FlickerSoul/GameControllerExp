//
//  GameControllerDebugView.swift
//  GameControllerExp
//
//  Created by Larry Zeng on 10/12/25.
//

import GameController
import SwiftUI

struct DualSenseControllerDebugView: View {
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                BasicInfoView()
                HapticsView()
            }

            VStack(spacing: 50) {
                VStack(spacing: 20) {
                    HStack(alignment: .top) {
                        DualSenseAdaptiveTriggerControl.left()
                        ButtonValuesGrid()
                        DualSenseAdaptiveTriggerControl.right()
                    }

                    HStack {
                        StickView.left()
                        StickView.right()
                    }
                }
            }
            .padding()

            ControllerMotion()
        }
        .padding()
    }
}

private struct HapticsView: View {
    @Environment(GameControllerManager.self) private var gameControllerManager

    var body: some View {
        if let controller = gameControllerManager.connected {
            GameControllerHaptics(controller: controller)
        }
    }
}

private struct BasicInfoView: View {
    @Environment(GameControllerManager.self) private var gameControllerManager

    var body: some View {
        if let controller = gameControllerManager.connected {
            GameControllerBasicInfo(controller: controller)
        }
    }
}

private struct DualSenseAdaptiveTriggerControl: View {
    @Environment(GameControllerManager.self) private var gameControllerManager
    let keyPath: KeyPath<GCDualSenseGamepad, GCDualSenseAdaptiveTrigger>

    static func left() -> DualSenseAdaptiveTriggerControl {
        DualSenseAdaptiveTriggerControl(keyPath: \.leftTrigger)
    }

    static func right() -> DualSenseAdaptiveTriggerControl {
        DualSenseAdaptiveTriggerControl(keyPath: \.rightTrigger)
    }

    private var gamepad: GCDualSenseGamepad? {
        gameControllerManager.connected?.extendedGamepad as? GCDualSenseGamepad
    }

    private var trigger: GCDualSenseAdaptiveTrigger? {
        gamepad?[keyPath: keyPath]
    }

    var body: some View {
        if let trigger {
            DualSenseAdaptiveTriggerControlImpl(trigger: trigger)
        }
    }
}

private struct StickView: View {
    @Environment(GameControllerManager.self) private var gameControllerManager

    let stick: GCDirectionPadElementName

    static func left() -> StickView {
        StickView(stick: .leftThumbstick)
    }

    static func right() -> StickView {
        StickView(stick: .rightThumbstick)
    }

    var x: Float {
        gameControllerManager.controllerState?.dpads[stick]?.xAxis.value ?? 0
    }

    var y: Float {
        gameControllerManager.controllerState?.dpads[stick]?.yAxis.value ?? 0
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(stick.rawValue)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.gray)
            HStack(spacing: 20) {
                VStack(alignment: .leading) {
                    Text("X AXIS")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                    Text(x, format: .number.sign(strategy: .always()).precision(.fractionLength(5)))
                        .font(.system(size: 16, weight: .medium))
                        .fontDesign(.monospaced)
                    Text("Y AXIS")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                        .padding(.top, 5)
                    Text(y, format: .number.sign(strategy: .always()).precision(.fractionLength(5)))
                        .font(.system(size: 16, weight: .medium))
                        .fontDesign(.monospaced)
                }

                AnalogStickView(xValue: x, yValue: y)
                    .frame(width: 180, height: 180)
            }
        }
    }
}

private struct ButtonValuesGrid: View {
    @Environment(GameControllerManager.self) private var gameControllerManager

    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                ControllerElementCell(key: .leftShoulder, defaultValue: 0.0)
                ControllerElementCell(key: .leftTrigger, defaultValue: 0.0)
                ControllerElementCell(key: .rightTrigger, defaultValue: 0.0)
                ControllerElementCell(key: .rightShoulder, defaultValue: 0.0)
            }

            HStack(spacing: 8) {
                ControllerElementCell(key: .a, defaultValue: 0.0)
                ControllerElementCell(key: .b, defaultValue: 0.0)
                ControllerElementCell(key: .x, defaultValue: 0.0)
                ControllerElementCell(key: .y, defaultValue: 0.0)
            }

            HStack(spacing: 8) {
                ControllerElementCell(key: .directionPad, dPadDirection: .up, defaultValue: 0)
                ControllerElementCell(key: .directionPad, dPadDirection: .left, defaultValue: 0)
                ControllerElementCell(key: .directionPad, dPadDirection: .right, defaultValue: 0)
                ControllerElementCell(key: .directionPad, dPadDirection: .down, defaultValue: 0)
            }

            HStack(spacing: 8) {
                ControllerElementCell(key: .options, defaultValue: 0.0)
                ControllerElementCell(key: .menu, defaultValue: 0.0)
                ControllerElementCell(key: .home, defaultValue: 0.0)
            }
        }
    }
}

private struct ControllerMotion: View {
    @Environment(GameControllerManager.self) private var gameControllerManager

    var body: some View {
        if gameControllerManager.motion != nil {
            VStack {
                GameControllerDirection(orientation: gameControllerManager.pointer)
                    .frame(width: 200, height: 200)

                Button {
                    gameControllerManager.resetOrientation()
                } label: {
                    Text("Reset")
                }
            }
        }
    }
}

#Preview {
    DualSenseControllerDebugView()
        .frame(width: 1000, height: 700)
        .environment(GameControllerManager())
}
