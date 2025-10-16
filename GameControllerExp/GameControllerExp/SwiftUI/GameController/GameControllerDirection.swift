//
//  GameControllerDirection.swift
//  GameControllerExp
//
//  Created by Larry Zeng on 10/16/25.
//

import GameController
import simd
import SwiftUI

struct GameControllerDirection: View {
    private static let innerCircleDiameter: Double = 8

    let orientation: Pointer

    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let height = proxy.size.height
            let midWidth = width / 2
            let midHeight = height / 2

            let squareSize = min(width, height)
            let halfSquare = squareSize / 2

            ZStack(alignment: .center) {
                Circle()
                    .stroke(Color.gray, lineWidth: 2)
                    .frame(width: squareSize, height: squareSize)

                Path { path in
                    path.move(
                        to: CGPoint(
                            x: midWidth,
                            y: max(0, midHeight - halfSquare)
                        )
                    )
                    path.addLine(
                        to: CGPoint(
                            x: midWidth,
                            y: max(0, midHeight - halfSquare) + squareSize
                        )
                    )
                    path.move(
                        to: CGPoint(
                            x: max(0, midWidth - halfSquare),
                            y: midHeight
                        )
                    )
                    path.addLine(
                        to: CGPoint(
                            x: max(0, midWidth - halfSquare) + squareSize,
                            y: midHeight
                        )
                    )
                }
                .stroke(Color.gray, lineWidth: 1)
                .rotationEffect(.radians(orientation.roll))

                Circle()
                    .fill(Color.blue)
                    .frame(width: Self.innerCircleDiameter, height: Self.innerCircleDiameter)
                    .offset(
                        x: CGFloat(orientation.yaw) * halfSquare,
                        y: CGFloat(orientation.pitch) * halfSquare
                    )
            }
        }
    }
}
