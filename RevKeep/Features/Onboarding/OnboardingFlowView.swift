

import SwiftUI

struct OnboardingFlowView: View {
    let onFinished: () -> Void
    @State private var pageIndex = 0
    private let totalPages = 4
    
    private let pageTexts: [(title: String, subtitle: String)] = [
        ("Easy to miss what matters", "Oil changes, brakes, tires — everything gets lost in notes and memory."),
        ("Log every service in seconds", "Date, mileage, cost, receipt photo — all in one place."),
        ("See what your car really costs", "Timely reminders and complete spending stats for every car."),
        ("Never miss a reminder again", "Allow notifications — we'll remind you about service a few days in advance.")
    ]
    
    var body: some View {
        ZStack(alignment: .top) {
            Color.revAsphalt.ignoresSafeArea()
            
            TabView(selection: $pageIndex) {
                OnboardingIllustration1().tag(0)
                OnboardingIllustration2().tag(1)
                OnboardingIllustration3().tag(2)
                OnboardingIllustration4().tag(3)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            
            HStack {
                Spacer()
                if pageIndex < totalPages - 1 {
                    Button("Skip") { finish() }
                        .font(.revSecondary)
                        .foregroundStyle(Color.revSlate)
                        .padding(RevSpacing.lg)
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            bottomCard
            
        }
        .padding(.top, 35)
        .ignoresSafeArea()
        
    }
    
    private var bottomCard: some View {
        VStack(spacing: RevSpacing.lg) {
            VStack(spacing: RevSpacing.sm) {
                Text(pageTexts[pageIndex].title)
                    .font(.system(.title2, design: .rounded, weight: .semibold))
                    .foregroundStyle(Color.revChalk)
                    .multilineTextAlignment(.center)
                Text(pageTexts[pageIndex].subtitle)
                    .font(.revBody)
                    .foregroundStyle(Color.revSlate)
                    .multilineTextAlignment(.center)
            }
            .id(pageIndex)
            .transition(.opacity)
            .animation(.easeInOut(duration: 0.2), value: pageIndex)
            
            
            HStack(spacing: RevSpacing.xs) {
                ForEach(0..<totalPages, id: \.self) { index in
                    Capsule()
                        .fill(index == pageIndex ? Color.revAmber : Color.revGraphiteLight)
                        .frame(width: index == pageIndex ? 20 : 8, height: 8)
                        .animation(.easeInOut(duration: 0.25), value: pageIndex)
                }
            }
            
            if pageIndex == totalPages - 1 {
                VStack(spacing: RevSpacing.base) {
                    PrimaryButton(title: "Next") { finish() }
       
                }
            } else {
                PrimaryButton(title: "Next") {
                    withAnimation { pageIndex += 1 }
                }
            }
        }
        .padding(.bottom)
        .padding(.horizontal, RevSpacing.lg)
        .padding(.top, RevSpacing.xl)
        .padding(.bottom, RevSpacing.lg)
        .frame(maxWidth: .infinity)
        .background(
            Color.revGraphite,
            in: UnevenRoundedRectangle(topLeadingRadius: 32, bottomLeadingRadius: 0, bottomTrailingRadius: 0, topTrailingRadius: 32, style: .continuous)
            
        )
        
    }
    
    private func finish() {
        NotificationPermissionRequester.requestIfNeeded()
        onFinished()
    }
}


private struct OnboardingGlow: View {
    let color: Color
    
    var body: some View {
        RadialGradient(
            colors: [color.opacity(0.2), color.opacity(0.08), Color.clear],
            center: .center,
            startRadius: 20,
            endRadius: 260
        )
        .blur(radius: 24)
        .allowsHitTesting(false)
    }
}


private struct OnboardingIllustration1: View {
    var body: some View {
        ZStack {
            OnboardingGlow(color: .revRed)
            VStack {
                Spacer()
                ZStack {
                    Image(systemName: "car.side")
                        .font(.system(size: 90))
                        .foregroundStyle(Color.revSlate.opacity(0.3))
                    RevRingView(value: 0.2, size: 270)
                }
                Spacer()
            }
        }
    }
}


private struct OnboardingSampleRow: View {
    let symbolName: String
    let color: Color
    let title: String
    let subtitle: String
    let price: String
    
    var body: some View {
        HStack(spacing: RevSpacing.base) {
            ZStack {
                Circle().fill(color.opacity(0.15)).frame(width: 40, height: 40)
                Image(systemName: symbolName).foregroundStyle(color)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.revBody.weight(.medium))
                    .foregroundStyle(Color.revChalk)
                Text(subtitle)
                    .font(.revCaption)
                    .foregroundStyle(Color.revSlate)
            }
            Spacer()
            Text(price)
                .font(.revBody.weight(.semibold))
                .foregroundStyle(Color.revChalk)
        }
        .padding(RevSpacing.base)
        .background(Color.revGraphite, in: RoundedRectangle(cornerRadius: RevRadius.card, style: .continuous))
    }
}

private struct OnboardingIllustration2: View {
    var body: some View {
        ZStack {
            OnboardingGlow(color: .revAmber)
            VStack {
                Spacer()
                VStack(spacing: RevSpacing.sm) {
                    OnboardingSampleRow(symbolName: "drop.fill", color: .revAmber, title: "Oil Change", subtitle: "May 12 · 125,300 km", price: "$89.00")
                    OnboardingSampleRow(symbolName: "octagon.fill", color: .revGreen, title: "Brake Pads", subtitle: "Apr 3 · 123,400 km", price: "$210.00")
                    OnboardingSampleRow(symbolName: "circle.dashed", color: .revAmber, title: "Tires", subtitle: "Mar 18 · 120,900 km", price: "$540.00")
                }
                .padding(.horizontal, RevSpacing.lg)
                Spacer()
            }
        }
    }
}


private struct OnboardingStatRow: View {
    let color: Color
    let label: String
    let percent: String
    
    var body: some View {
        HStack(spacing: RevSpacing.xs) {
            Circle().fill(color).frame(width: 8, height: 8)
            Text(label)
                .font(.revCaption)
                .foregroundStyle(Color.revSlate)
            Spacer()
            Text(percent)
                .font(.revCaption.weight(.semibold))
                .foregroundStyle(Color.revChalk)
        }
    }
}

private struct OnboardingIllustration3: View {
    var body: some View {
        ZStack {
            OnboardingGlow(color: .revGreen)
            VStack {
                Spacer()
                VStack(spacing: RevSpacing.lg) {
                    RevRingView(value: 0.85, size: 170, centerValue: "$1,246", centerLabel: "TOTAL")
                        .shadow(color: Color.revGreen.opacity(0.4), radius: 24)
                    VStack(spacing: RevSpacing.xs) {
                        OnboardingStatRow(color: .revGreen, label: "Maintenance", percent: "52%")
                        OnboardingStatRow(color: .revAmber, label: "Repairs", percent: "28%")
                        OnboardingStatRow(color: .revSlate, label: "Tires", percent: "15%")
                        OnboardingStatRow(color: .revGraphiteLight, label: "Other", percent: "5%")
                    }
                    .padding(.horizontal, RevSpacing.xxl)
                }
                Spacer()
            }
        }
    }
}


private struct OnboardingIllustration4: View {
    var body: some View {
        ZStack {
            OnboardingGlow(color: .revAmber)
            VStack {
                Spacer()
                ZStack {
                    RevRingView(value: 0.75, size: 250)
                    Image(systemName: "bell")
                        .font(.system(size: 115, weight: .thin))
                        .foregroundStyle(Color.revAmber)
                }
                Spacer()
            }
        }
    }
}


#Preview {
    OnboardingFlowView(onFinished: {
        print("")
    })
}
