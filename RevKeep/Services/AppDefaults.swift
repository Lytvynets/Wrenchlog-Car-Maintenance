

import Foundation

enum AppDefaults {
    
    static let lifetimeProductId = "wrenchlog.premium"
    static var lifetimePrice: String = "-.-"
    
    static let otherAppsURL     = URL(string: "https://apps.apple.com/us/developer/vladyslav-lytvynets/id1660079103")!
    static let termsOfUseURL    = URL(string: "https://docs.google.com/document/d/1faJ6Kxi_kFd0liIvoBmLR7ktrQ1KWQ8z/edit?usp=share_link&ouid=114599015370342281433&rtpof=true&sd=true")!
    static let privacyPolicyURL = URL(string: "https://docs.google.com/document/d/1dq5ZRWuBu5F--wV1KXewxgaOQc7PRMZa/edit?usp=share_link&ouid=114599015370342281433&rtpof=true&sd=true")!
    static let supportURL       = URL(string: "https://docs.google.com/document/d/1Z6nkH5_U7PYy3qTV7vciRaqplajR3aJh/edit?usp=share_link&ouid=114599015370342281433&rtpof=true&sd=true")!
    static let appStoreURL      = URL(string: "https://apps.apple.com/app/id6808948744")!
    static let supportEmail     = "vladlytvynets7@gmail.com"
    
    
    enum DefaultsKey {
        static let isPro = "isPremiumUser"
        static let hasCompletedOnboarding = "hasCompletedOnboarding"
        static let distanceUnit = "distanceUnit"
        static let appTheme = "appTheme"
        static let currencyCode = "currencyCode"
        static let remindersEnabled = "remindersEnabled"
    }
}
