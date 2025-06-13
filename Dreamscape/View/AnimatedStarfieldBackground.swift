//
//  AnimatedStarfieldBackground.swift
//  Dreamscape
//
//  Created by 卓柏辰 on 2025/6/13.
//

import SwiftUI

// MARK: - Animated Starfield Background(Dynamic)
struct AnimatedStarfieldBackground: View {
    let starCount: Int

    struct Star: Identifiable {
        let id = UUID()
        var x: CGFloat
        var y: CGFloat
        var radius: CGFloat
        var baseOpacity: Double
        var flickerSpeed: Double
        var driftX: CGFloat
        var driftY: CGFloat
        var driftSpeed: CGFloat
    }

    struct StarRenderInfo: Identifiable {
        let id: UUID
        let x: CGFloat
        let y: CGFloat
        let radius: CGFloat
        let opacity: Double
    }

    @State private var stars: [Star] = []
    @State private var viewSize: CGSize = .zero

    var body: some View {
        GeometryReader { geo in
            TimelineView(.animation) { timeline in
                let date = timeline.date.timeIntervalSinceReferenceDate

                // Precompute star positions and opacities based on the current time
                let renderStars: [StarRenderInfo] = stars.map { star in
                    let opacity = star.baseOpacity + 0.5 * sin(Double(date) * Double(star.flickerSpeed) + Double(star.x) + Double(star.y))
                    let dx = star.driftX * CGFloat(sin(date * star.driftSpeed + star.y))
                    let dy = star.driftY * CGFloat(cos(date * star.driftSpeed + star.x))
                    let xPos = (star.x + dx).truncatingRemainder(dividingBy: geo.size.width + 40)
                    let yPos = (star.y + dy).truncatingRemainder(dividingBy: geo.size.height + 40)
                    let clampedOpacity = opacity.clamped(to: 0.3...1.0)
                    return StarRenderInfo(
                        id: star.id,
                        x: xPos,
                        y: yPos,
                        radius: star.radius,
                        opacity: clampedOpacity
                    )
                }

                ZStack {
                    LinearGradient(
                        gradient: Gradient(colors: [Color.purple.opacity(0.92), Color.black]),
                        startPoint: .top, endPoint: .bottom
                    )
                    .ignoresSafeArea()

                    ForEach(renderStars) { info in
                        Circle()
                            .fill(Color.white.opacity(info.opacity))
                            .frame(width: info.radius * 2, height: info.radius * 2)
                            .position(x: info.x, y: info.y)
                    }
                }
                .onAppear {
                    // Only generate stars if they are empty or the view size has changed
                    if stars.isEmpty || geo.size != viewSize {
                        stars = (0..<starCount).map { _ in
                            Star(
                                x: CGFloat.random(in: 0...geo.size.width),
                                y: CGFloat.random(in: 0...geo.size.height),
                                radius: CGFloat.random(in: 0.7...2.1),
                                baseOpacity: Double.random(in: 0.4...0.85),
                                flickerSpeed: Double.random(in: 0.7...2.2),
                                driftX: CGFloat.random(in: -6...6),
                                driftY: CGFloat.random(in: -10...10),
                                driftSpeed: CGFloat.random(in: 0.06...0.18)
                            )
                        }
                        viewSize = geo.size
                    }
                }
            }
        }
    }
}

// MARK: - Clamping Extension
extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        min(max(self, range.lowerBound), range.upperBound)
    }
}