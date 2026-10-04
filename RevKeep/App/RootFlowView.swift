

import SwiftUI

private enum AppStage {
    case splash, onboarding, paywall, main
}

struct RootFlowView: View {
    @EnvironmentObject private var appState: AppState
    @EnvironmentObject private var purchaseVM: InAppPurchaseViewModel
    @State private var stage: AppStage = .splash

    var body: some View {
        Group {
            switch stage {
            case .splash:
                SplashView()
            case .onboarding:
                OnboardingFlowView(onFinished: advanceFromOnboarding)
            case .paywall:
                PaywallView(onContinue: { stage = .main })
            case .main:
                MainTabView()
            }
        }
        .task {
            async let productLoad: Void = purchaseVM.fetchProduct()
            try? await Task.sleep(nanoseconds: 3_400_000_000)
            await productLoad
            AdManager.shared.updateEntitlement(isPro: purchaseVM.isPurchased)
            advanceFromSplash()
        }
        .onChange(of: purchaseVM.isPurchased) { _, isPro in
            AdManager.shared.updateEntitlement(isPro: isPro)
        }
    }

    private func advanceFromSplash() {
        withAnimation(.easeInOut(duration: 0.4)) {
            if appState.hasCompletedOnboarding {
                stage = purchaseVM.isPurchased ? .main : .paywall
            } else {
                stage = .onboarding
            }
        }
    }

    private func advanceFromOnboarding() {
        appState.hasCompletedOnboarding = true
        withAnimation(.easeInOut(duration: 0.4)) {
            stage = purchaseVM.isPurchased ? .main : .paywall
        }
    }
}
