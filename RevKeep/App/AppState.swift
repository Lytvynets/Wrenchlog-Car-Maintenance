

import Foundation
import Combine

@MainActor
final class AppState: ObservableObject {
    @Published var hasCompletedOnboarding: Bool {
        didSet {
            UserDefaults.standard.set(hasCompletedOnboarding, forKey: AppDefaults.DefaultsKey.hasCompletedOnboarding)
        }
    }

    init() {
        self.hasCompletedOnboarding = UserDefaults.standard.bool(forKey: AppDefaults.DefaultsKey.hasCompletedOnboarding)
    }
}

