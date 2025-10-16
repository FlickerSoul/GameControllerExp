//
//  ControllerElementCell.swift
//  GameControllerExp
//
//  Created by Larry Zeng on 10/16/25.
//
import GameController
import SwiftUI

struct ControllerElementCell<Key: RawRepresentable, Element: GCPhysicalInputElement, Value>: View
    where Key.RawValue == String {
    enum DPadDirectionSide {
        case up
        case down
        case left
        case right

        var keyPath: KeyPath<any GCDirectionPadElement, GCLinearInput & GCPressedStateInput> {
            switch self {
            case .up: \.up
            case .down: \.down
            case .left: \.left
            case .right: \.right
            }
        }

        var icon: String {
            switch self {
            case .up:
                "dpad.up.filled"
            case .down:
                "dpad.down.filled"
            case .left:
                "dpad.left.filled"
            case .right:
                "dpad.right.filled"
            }
        }
    }

    let key: Key
    let icon: String?
    let valueKeyPath: KeyPath<Element, Value>
    let defaultValue: Value
    @Environment(GameControllerManager.self) private var gameControllerManager

    init(
        key: GCButtonElementName,
        defaultValue: Value
    ) where Element == any GCButtonElement, Value == Bool, Key == GCButtonElementName {
        self.key = key
        icon = nil
        valueKeyPath = \.pressedInput.isPressed
        self.defaultValue = defaultValue
    }

    init(
        key: GCButtonElementName,
        defaultValue: Value
    ) where Element == any GCButtonElement, Value == Float, Key == GCButtonElementName {
        self.key = key
        icon = nil
        valueKeyPath = \.pressedInput.value
        self.defaultValue = defaultValue
    }

    init(
        key: GCDirectionPadElementName,
        dPadDirection: DPadDirectionSide,
        defaultValue: Value
    ) where Element == any GCDirectionPadElement, Key == GCDirectionPadElementName, Value == Float {
        self.key = key
        icon = dPadDirection.icon
        valueKeyPath = dPadDirection.keyPath.appending(path: \.value)
        self.defaultValue = defaultValue
    }

    var element: Element? {
        switch key {
        case let key as GCButtonElementName:
            return gameControllerManager.controllerState?.buttons[key] as? Element
        case let key as GCDirectionPadElementName:
            return gameControllerManager.controllerState?.dpads[key] as? Element
        default:
            return nil
        }
    }

    var elementValue: Value {
        element?[keyPath: valueKeyPath] ?? defaultValue
    }

    var elementName: String {
        element?.localizedName ?? key.rawValue
    }

    var elementSymbol: String {
        icon ?? element?.sfSymbolsName ?? "questionmark.square"
    }

    var body: some View {
        HStack(spacing: 2) {
            Image(systemName: elementSymbol)
                .resizable()
                .foregroundStyle(.gray)
                .frame(width: 16, height: 16)

            VStack(alignment: .leading, spacing: 2) {
                Text(elementName)
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
                valueText(for: elementValue)
                    .font(.body)
            }
            .frame(width: 60)
        }
    }

    @ViewBuilder
    private func valueText(for value: Value) -> some View {
        switch value {
        case let boolValue as Bool:
            Text(boolValue ? "On" : "Off")
                .fontWeight(boolValue ? .regular : .bold)
                .foregroundColor(boolValue ? .primary : .accentColor)

        case let floatValue as Float:
            Text(floatValue, format: .number.precision(.fractionLength(2)))
                .fontWeight(floatValue == 0 ? .regular : .bold)
                .foregroundColor(floatValue == 0 ? .primary : .accentColor.opacity(0.3 + 0.7 * Double(floatValue)))

        default:
            Text("Unknown Value: \(String(describing: value))")
        }
    }
}
