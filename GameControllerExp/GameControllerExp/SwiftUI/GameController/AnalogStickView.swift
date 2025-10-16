//
//  AnalogStickView.swift
//  GameControllerExp
//
//  Created by Larry Zeng on 10/16/25.
//
import SwiftUI

struct AnalogStickView: View {
    private static let innerCircleDiameter: Double = 6

    let xValue: Float
    let yValue: Float

    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            let height = proxy.size.height
            let midWidth = width / 2
            let midHeight = height / 2

            let outerDiameter = min(width, height)
            let outerRadius = outerDiameter / 2

            ZStack(alignment: .center) {
                Circle()
                    .stroke(Color.gray, lineWidth: 2)
                    .frame(width: outerDiameter, height: outerDiameter)

                Path { path in
                    path.move(
                        to: CGPoint(
                            x: width / 2,
                            y: max(0, midHeight - outerRadius)
                        )
                    )
                    path.addLine(
                        to: CGPoint(
                            x: width / 2,
                            y: max(0, midHeight - outerRadius) + outerDiameter
                        )
                    )
                    path.move(
                        to: CGPoint(
                            x: max(0, midWidth - outerRadius),
                            y: height / 2
                        )
                    )
                    path.addLine(
                        to: CGPoint(
                            x: max(0, midWidth - outerRadius) + outerDiameter,
                            y: height / 2
                        )
                    )
                }
                .stroke(Color.gray, lineWidth: 1)

                Circle()
                    .fill(Color.blue)
                    .frame(width: Self.innerCircleDiameter, height: Self.innerCircleDiameter)
                    .offset(
                        x: CGFloat(xValue) * outerDiameter / 2,
                        y: CGFloat(-yValue) * outerDiameter / 2,
                    )
            }
        }
    }
}
