//
//  GameControllerBasicInfo.swift
//  GameControllerExp
//
//  Created by Larry Zeng on 10/17/25.
//

import GameController
import SwiftUI

struct GameControllerBasicInfo: View {
    let controller: GCController

    @State private var changeControllerColor: Bool = false
    @State private var pickedColor: Color = .clear
    @Environment(\.self) private var environment

    var body: some View {
        VStack(alignment: .leading) {
            infoText
            HStack {
                battery
                light
            }
        }
    }

    @ViewBuilder
    private var infoText: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Vendor: \(controller.vendorName ?? "Unknown")")
            Text("Product Category: \(controller.productCategory)")
        }
    }

    @ViewBuilder
    private var battery: some View {
        if let battery = controller.battery {
            TimelineView(.animation(minimumInterval: 5)) { _ in
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 2) {
                        let batteryIcon = switch battery.batteryState {
                        case .unknown:
                            "battery.100percent"
                        case .discharging:
                            "battery.100percent"
                        case .charging:
                            "battery.100percent.bolt"
                        case .full:
                            "battery.100percent"
                        @unknown default:
                            "battery.100percent"
                        }
                        let batteryColor: Color = switch battery.batteryState {
                        case .unknown:
                            .secondary
                        case .discharging, .charging:
                            switch battery.batteryLevel {
                            case 0.0 ..< 0.25:
                                .red
                            case 0.25 ..< 0.5:
                                .orange
                            case 0.5 ..< 0.75:
                                .yellow
                            case 0.75 ... 1.0:
                                .green
                            default:
                                .primary
                            }
                        case .full:
                            .green
                        @unknown default:
                            .primary
                        }

                        Image(systemName: batteryIcon, variableValue: Double(battery.batteryLevel))
                            .foregroundStyle(batteryColor)
                        Text(battery.batteryLevel, format: .percent.precision(.fractionLength(2)))
                    }

                    let batteryStatusText: LocalizedStringKey = switch battery.batteryState {
                    case .unknown:
                        "Battery Status Unknown"
                    case .discharging:
                        "Discharging"
                    case .charging:
                        "Charging"
                    case .full:
                        "Full"
                    @unknown default:
                        "Battery Status Missing"
                    }

                    Text(batteryStatusText)
                }
            }
        }
    }

    @ViewBuilder
    private var light: some View {
        if let light = controller.light {
            ColorPicker("Controller Light Color", selection: $pickedColor)
                .onAppear {
                    pickedColor = Color(light.color)
                }
                .onChange(of: pickedColor) {
                    if pickedColor != Color(light.color) {
                        light.color = pickedColor.resolve(in: environment).toGCColor()
                    }
                }
        }
    }
}

extension Color {
    nonisolated init(_ color: GCColor) {
        self.init(red: Double(color.red), green: Double(color.green), blue: Double(color.blue))
    }
}

extension Color.Resolved {
    nonisolated func toGCColor() -> GCColor {
        GCColor(
            red: red,
            green: green,
            blue: blue
        )
    }
}
