

import SwiftUI

extension Font {
    static var revLargeNumber: Font { .system(.largeTitle, design: .rounded, weight: .bold) }
    
    static var revTitle: Font { .system(.title2, design: .rounded, weight: .semibold) }
    
    static var revSectionTitle: Font { .system(.title3, design: .default, weight: .semibold) }
    
    static var revBody: Font { .system(.body, design: .default, weight: .regular) }
    
    static var revSecondary: Font { .system(.subheadline, design: .default, weight: .regular) }
    
    static var revCaption: Font { .system(.caption, design: .default, weight: .medium) }
    
    static var revMono: Font { .system(.subheadline, design: .monospaced, weight: .medium) }
}
