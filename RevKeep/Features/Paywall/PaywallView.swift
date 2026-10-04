

import SwiftUI
import StoreKit

struct PaywallView: View {
    @EnvironmentObject private var purchaseVM: InAppPurchaseViewModel
    let onContinue: () -> Void
    @State private var pulse = false
    
    private let benefits: [(symbol: String, text: String, color: Color)] = [
        ("infinity", "Unlimited vehicles", .revGreen),
        ("chart.pie.fill", "Detailed spending stats", .revAmber),
        ("eye.slash.fill", "No ads, ever", .revRed)
//        ("apps.iphone.badge.plus", "Home screen widget", .revSlate)
    ]
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            Color.revAsphalt.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: RevSpacing.xl) {
                    Spacer(minLength: RevSpacing.xxxl)
                    
                    RevRingView(value: 1.0, size: 180)
                        .overlay {
                            VStack(spacing: 2) {
                                Image(systemName: "car.side.fill")
                                    .font(.system(size: 28))
                                    .foregroundStyle(Color.revSlate.opacity(0.6))
                                Text("100%")
                                    .font(.revLargeNumber.monospacedDigit())
                                    .foregroundStyle(Color.revChalk)
                                Text("ALL SERVICES\nUNDER CONTROL")
                                    .font(.revCaption)
                                    .foregroundStyle(Color.revGreen)
                                    .multilineTextAlignment(.center)
                                    .lineLimit(2)
                            }
                        }
                    
                    VStack(spacing: RevSpacing.md) {
                        HStack(spacing: RevSpacing.xs) {
                            Image(systemName: "checkmark.seal.fill")
                            Text("No subscription — pay once")
                        }
                        .font(.revCaption)
                        .foregroundStyle(Color.revAmber)
                        .padding(.horizontal, RevSpacing.base)
                        .padding(.vertical, RevSpacing.xs)
                        .background(Color.revAmber.opacity(0.15), in: Capsule())
                        
                        Text("Unlock Wrenchlog Pro")
                            .font(.system(.title, design: .rounded, weight: .bold))
                            .foregroundStyle(Color.revChalk)
                            .multilineTextAlignment(.center)
                    }
                    
                    VStack(alignment: .leading, spacing: RevSpacing.base) {
                        ForEach(benefits, id: \.text) { benefit in
                            HStack(spacing: RevSpacing.base) {
                                ZStack {
                                    Circle().fill(benefit.color.opacity(0.15)).frame(width: 32, height: 32)
                                    Image(systemName: benefit.symbol)
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundStyle(benefit.color)
                                }
                                Text(benefit.text)
                                    .font(.revBody)
                                    .foregroundStyle(Color.revChalk)
                                Spacer()
                            }
                        }
                    }
                    .padding(.horizontal, RevSpacing.lg)
                    
                    VStack(spacing: RevSpacing.xs) {
                        Text(purchaseVM.product?.displayPrice ?? AppDefaults.lifetimePrice)
                            .font(.system(.largeTitle, design: .rounded, weight: .bold))
                            .foregroundStyle(Color.revChalk)
                        Text("One-time payment. No hidden fees.")
                            .font(.revCaption)
                            .foregroundStyle(Color.revSlate)
                    }
                    .padding(RevSpacing.lg)
                    .frame(maxWidth: .infinity)
                    .background(Color.revGraphite, in: RoundedRectangle(cornerRadius: RevRadius.card, style: .continuous))
                    .padding(.horizontal, RevSpacing.lg)
                    
                    VStack(spacing: RevSpacing.base) {
                        PrimaryButton(
                            title: purchaseTitle,
                            isLoading: purchaseVM.isLoading,
                            isEnabled: purchaseVM.product != nil,
                            action: purchase
                        )
                        .scaleEffect(pulse ? 1.02 : 1.0)
                        .animation(.easeInOut(duration: 1.4).repeatForever(autoreverses: true), value: pulse)
                        .onAppear { pulse = true }
                        
                        SecondaryButton(title: "Restore purchase") {
                            Task { await purchaseVM.restorePurchases() }
                        }
                    }
                    .padding(.horizontal, RevSpacing.lg)
                    
                    HStack(spacing: RevSpacing.xs) {
                        Link("Terms of Use", destination: AppDefaults.termsOfUseURL)
                        Text("·").foregroundStyle(Color.revSlate)
                        Link("Privacy Policy", destination: AppDefaults.privacyPolicyURL)
                    }
                    .font(.system(size: 12))
                    .foregroundStyle(Color.revSlate)
                    .padding(.bottom, RevSpacing.xl)
                }
            }
            
            Button {
                onContinue()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.revChalk)
                    .frame(width: 32, height: 32)
                    .background(Color.revGraphite.opacity(0.8), in: Circle())
            }
            .padding(RevSpacing.base)
        }
        .alert("Something went wrong", isPresented: $purchaseVM.presentErrorAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(purchaseVM.errorMessage)
        }
        .onChange(of: purchaseVM.isPurchased) { _, isPurchased in
            if isPurchased { onContinue() }
        }
    }
    
    private var purchaseTitle: String {
        "Unlock for \(purchaseVM.product?.displayPrice ?? AppDefaults.lifetimePrice)"
    }
    
    private func purchase() {
        Task { await purchaseVM.purchase() }
    }
}
