

import SwiftUI

struct RevRingShape: Shape {
    var progress: Double
    
    private let startAngle = Angle(degrees: 135)
    private let totalDegrees = 270.0
    
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        let clampedProgress = min(max(progress, 0), 1)
        let endAngle = Angle(degrees: startAngle.degrees + totalDegrees * clampedProgress)
        path.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        return path
    }
    
    var animatableData: Double {
        get { progress }
        set { progress = newValue }
    }
}

struct RevRingView: View {
    let value: Double
    var size: CGFloat = 220
    var lineWidth: CGFloat? = nil
    var centerValue: String? = nil
    var centerLabel: String? = nil
    
    private var resolvedLineWidth: CGFloat { lineWidth ?? max(size * 0.08, 4) }
    
    private var ringGradient: AngularGradient {
        let clamped = min(max(value, 0), 1)
        let startColor = Color.revStatusColor(for: max(clamped - 0.15, 0))
        let endColor = Color.revStatusColor(for: clamped)
        return AngularGradient(
            gradient: Gradient(colors: [startColor, endColor]),
            center: .center,
            startAngle: .degrees(135),
            endAngle: .degrees(135 + 270 * max(clamped, 0.02))
        )
    }
    
    var body: some View {
        ZStack {
            RevRingShape(progress: 1)
                .stroke(Color.revGraphiteLight, style: StrokeStyle(lineWidth: resolvedLineWidth, lineCap: .round))
            
            RevRingShape(progress: value)
                .stroke(ringGradient, style: StrokeStyle(lineWidth: resolvedLineWidth, lineCap: .round))
                .animation(.spring(response: 0.5, dampingFraction: 0.8), value: value)
            
            if let centerValue {
                VStack(spacing: RevSpacing.xs) {
                    Text(centerValue)
                        .font(.revLargeNumber.monospacedDigit())
                        .foregroundStyle(Color.revChalk)
                        .minimumScaleFactor(0.6)
                        .lineLimit(1)
                    if let centerLabel {
                        Text(centerLabel)
                            .font(.revSecondary)
                            .foregroundStyle(Color.revSlate)
                    }
                }
                .padding(RevSpacing.lg)
            }
        }
        .frame(width: size, height: size)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(accessibilityDescription)
    }
    
    private var accessibilityDescription: String {
        let percent = Int(value * 100)
        let status: String
        if value < 0.5 { status = "overdue" }
        else if value < 0.85 { status = "due soon" }
        else { status = "all good" }
        return "Vehicle health \(percent) percent, \(status)"
    }
}
