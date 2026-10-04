

import SwiftUI

struct SplashView: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var ringProgress: Double = 0
    @State private var needleOpacity: Double = 0
    @State private var needleScale: CGFloat = 1
    @State private var ticksOpacity: Double = 0
    @State private var titleOpacity: Double = 0
    @State private var titleOffset: CGFloat = 8
    @State private var glowOpacity: Double = 0

    var body: some View {
        ZStack {
            Color.revAsphalt.ignoresSafeArea()

            VStack(spacing: RevSpacing.xl) {
                ZStack {
                    RevRingShape(progress: 1)
                        .stroke(Color.revGraphiteLight, style: StrokeStyle(lineWidth: 12, lineCap: .round))

                    RevRingShape(progress: ringProgress)
                        .stroke(Color.revStatusColor(for: ringProgress), style: StrokeStyle(lineWidth: 12, lineCap: .round))
                        .shadow(color: Color.revAmber.opacity(glowOpacity), radius: 18)

                    GaugeTicks()
                        .opacity(ticksOpacity)

                    GaugeNeedle(angleDegrees: 225 + 270 * ringProgress)
                        .opacity(needleOpacity)
                        .scaleEffect(needleScale)
                        .shadow(color: Color.revAmber.opacity(glowOpacity * 0.8), radius: 10)
                }
                .frame(width: 180, height: 180)

                VStack(spacing: 2) {
                    Text("Wrenchlog")
                        .font(.system(.title2, design: .rounded, weight: .bold))
                        .foregroundStyle(Color.revChalk)
                    Text("Car Maintenance")
                        .font(.revSecondary)
                        .foregroundStyle(Color.revSlate)
                }
                .offset(y: titleOffset)
                .opacity(titleOpacity)
            }
        }
        .task {
            if reduceMotion {
                ringProgress = 0.7
                needleOpacity = 1
                ticksOpacity = 1
                titleOpacity = 1
                titleOffset = 0
                return
            }
            await playAnimation()
        }
    }

    private func playAnimation() async {
        withAnimation(.easeOut(duration: 0.25)) {
            ticksOpacity = 1
            needleOpacity = 1
        }

        try? await Task.sleep(nanoseconds: 300_000_000)
        withAnimation(.easeOut(duration: 0.8)) { ringProgress = 0.9 }

        try? await Task.sleep(nanoseconds: 800_000_000)
        withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) { ringProgress = 0.35 }

        try? await Task.sleep(nanoseconds: 500_000_000)
        withAnimation(.spring(response: 0.3, dampingFraction: 0.4)) { needleScale = 1.25 }
        withAnimation(.easeInOut(duration: 0.6)) { glowOpacity = 0.5 }

        try? await Task.sleep(nanoseconds: 150_000_000)
        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) { needleScale = 1.0 }

        try? await Task.sleep(nanoseconds: 150_000_000)
        withAnimation(.easeOut(duration: 0.4)) {
            titleOpacity = 1
            titleOffset = 0
        }

        try? await Task.sleep(nanoseconds: 500_000_000)
        withAnimation(.easeInOut(duration: 0.5)) { glowOpacity = 0 }
    }
}


private struct GaugeNeedle: View {
    let angleDegrees: Double

    var body: some View {
        ZStack {
            Capsule()
                .fill(
                    LinearGradient(
                        colors: [Color.revAmber, Color.revAmber.opacity(0.15)],
                        startPoint: .bottom,
                        endPoint: .top
                    )
                )
                .frame(width: 5, height: 46)
                .offset(y: -23)

            Circle()
                .fill(Color.revAmber)
                .frame(width: 16, height: 16)

            Circle()
                .fill(Color.revAsphalt)
                .frame(width: 6, height: 6)
        }
        .rotationEffect(.degrees(angleDegrees))
        .animation(.spring(response: 0.5, dampingFraction: 0.7), value: angleDegrees)
    }
}


private struct GaugeTicks: View {
    private let count = 5

    var body: some View {
        ZStack {
            ForEach(0..<count, id: \.self) { index in
                let fraction = Double(index) / Double(count - 1)
                let angle = 225 + 270 * fraction

                Rectangle()
                    .fill(Color.revSlate.opacity(0.5))
                    .frame(width: 2, height: 8)
                    .offset(y: -86)
                    .rotationEffect(.degrees(angle))
            }
        }
    }
}
