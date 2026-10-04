

import SwiftUI
import GoogleMobileAds
import Combine

@MainActor
final class AdManager: NSObject, ObservableObject {

    static let shared = AdManager()
    private let bannerAdUnitID = "ca-app-pub-4749079164629106/4655780434"
    private let interstitialAdUnitID = "ca-app-pub-4749079164629106/7505305056"


    @Published private(set) var isSDKStarted = false
    @Published private(set) var isInterstitialReady = false
    @Published var adsEnabled = true

    private var interstitialAd: InterstitialAd?

    private override init() {
        super.init()
    }


    func start() {
        guard !isSDKStarted else { return }
        MobileAds.shared.start()
        isSDKStarted = true
        Task { await loadInterstitial() }
    }


    func updateEntitlement(isPro: Bool) {
        adsEnabled = !isPro
    }


    func loadInterstitial() async {
        guard adsEnabled else { return }
        do {
            let ad = try await InterstitialAd.load(with: interstitialAdUnitID, request: Request())
            ad.fullScreenContentDelegate = self
            interstitialAd = ad
            isInterstitialReady = true
        } catch {
            print("AdManager: failed to load interstitial — \(error.localizedDescription)")
            isInterstitialReady = false
        }
    }


    func presentInterstitial() {
        guard adsEnabled else { return }
        guard let interstitialAd else {
            Task { await loadInterstitial() }
            return
        }
        interstitialAd.present(from: nil)
    }


    @ViewBuilder
    func bannerView(width: CGFloat = UIScreen.main.bounds.width - 40) -> some View {
        if adsEnabled {
            BannerAdView(adUnitID: bannerAdUnitID, width: width)
        } else {
            EmptyView()
        }
    }
}


extension AdManager: FullScreenContentDelegate {
    func ad(_ ad: FullScreenPresentingAd, didFailToPresentFullScreenContentWithError error: Error) {
        print("AdManager: failed to present interstitial — \(error.localizedDescription)")
        interstitialAd = nil
        isInterstitialReady = false
        Task { await loadInterstitial() }
    }

    func adDidDismissFullScreenContent(_ ad: FullScreenPresentingAd) {
        interstitialAd = nil
        isInterstitialReady = false
        Task { await loadInterstitial() }
    }
}


private struct BannerAdView: View {
    let adUnitID: String
    let width: CGFloat

    private var adSize: AdSize { largeAnchoredAdaptiveBanner(width: width) }

    var body: some View {
        BannerViewRepresentable(adUnitID: adUnitID, adSize: adSize)
            .frame(width: adSize.size.width, height: adSize.size.height)
            .background(Color.revGraphite, in: RoundedRectangle(cornerRadius: RevRadius.chip, style: .continuous))
    }
}

private struct BannerViewRepresentable: UIViewRepresentable {
    let adUnitID: String
    let adSize: AdSize

    func makeUIView(context: Context) -> BannerView {
        let banner = BannerView(adSize: adSize)
        banner.adUnitID = adUnitID
        banner.delegate = context.coordinator
        banner.load(Request())
        return banner
    }

    func updateUIView(_ uiView: BannerView, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator() }

    final class Coordinator: NSObject, BannerViewDelegate {
        func bannerViewDidReceiveAd(_ bannerView: BannerView) {
            print("AdManager: banner loaded")
        }
        func bannerView(_ bannerView: BannerView, didFailToReceiveAdWithError error: Error) {
            print("AdManager: banner failed to load — \(error.localizedDescription)")
        }
    }
}
