//
//  SkeletonView.swift
//  Tracker
//
//  Created by Александр Зиновьев on 3/19/26.
//

import Foundation
import SwiftUI

struct SkeletonView<S: Shape>: View {
    var shape: S
    var color = Color(.strokeLightGrey)
    var animationDuration: CGFloat = 1

    @State private var isAnimating = false

    var body: some View {
        shape
            .fill(color)
            .overlay {
                GeometryReader {
                    let size = $0.size
                    let skeletonWidth = size.width / 2
                    let blurRadius = max(skeletonWidth / 2, 30)
                    let blurDiameter = blurRadius * 2

                    let minX = -(skeletonWidth + blurDiameter)
                    let maxX = size.width + skeletonWidth + blurDiameter

                    Rectangle()
                        .fill(Color(.strokeLightGrayShimmer))
                        .frame(width: skeletonWidth, height: size.height * 2)
                        .frame(height: size.height)
                        .blur(radius: blurRadius)
                        .rotationEffect(.degrees(rotation))
                        .blendMode(.lighten)
                        .offset(x: isAnimating ? maxX : minX)
                }
            }
            .clipShape(shape)
            .compositingGroup()
            .onAppear {
                guard !isAnimating else {
                    return
                }

                withAnimation(animation) {
                    isAnimating = true
                }
            }
            .onDisappear {
                isAnimating = false
            }
            .transaction {
                if $0.animation != animation {
                    $0.animation = .none
                }
            }
    }

    private var rotation: Double {
        5
    }

    private var animation: Animation {
        .easeInOut(duration: animationDuration).repeatForever(autoreverses: false)
    }
}

#Preview {
    SkeletonView(shape: .rect)
        .frame(width: 300, height: 300, alignment: .leading)
}
