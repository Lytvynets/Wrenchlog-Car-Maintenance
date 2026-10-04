

import SwiftUI
import UIKit

extension Color {
    
    fileprivate init(light: (r: Double, g: Double, b: Double), dark: (r: Double, g: Double, b: Double)) {
        self.init(uiColor: UIColor { traits in
            let c = traits.userInterfaceStyle == .dark ? dark : light
            return UIColor(red: c.r, green: c.g, blue: c.b, alpha: 1)
        })
    }
    
    
    static let revAsphalt       = Color(light: (246/255, 244/255, 239/255), dark: (20/255, 22/255, 27/255))
    static let revGraphite      = Color(light: (255/255, 255/255, 255/255), dark: (30/255, 34/255, 42/255))
    static let revGraphiteLight = Color(light: (232/255, 230/255, 224/255), dark: (42/255, 47/255, 58/255))
    static let revChalk         = Color(light: (20/255, 22/255, 27/255),    dark: (244/255, 242/255, 237/255))
    static let revSlate         = Color(light: (107/255, 114/255, 128/255), dark: (139/255, 144/255, 156/255))
    static let revAmber         = Color(light: (224/255, 147/255, 15/255),  dark: (245/255, 166/255, 35/255))
    
    static let revGreen = Color(red: 52/255, green: 211/255, blue: 153/255)
    static let revRed   = Color(red: 255/255, green: 75/255, blue: 79/255)
    
    
    static func revStatusColor(for value: Double) -> Color {
        let clamped = min(max(value, 0), 1)
        if clamped < 0.5 {
            return mix(.revRed, .revAmber, clamped / 0.5)
        } else {
            return mix(.revAmber, .revGreen, (clamped - 0.5) / 0.5)
        }
    }
    
    private static func mix(_ a: Color, _ b: Color, _ t: Double) -> Color {
        let t = min(max(t, 0), 1)
        let ua = UIColor(a), ub = UIColor(b)
        var ar: CGFloat = 0, ag: CGFloat = 0, ab: CGFloat = 0, aa: CGFloat = 0
        var br: CGFloat = 0, bg: CGFloat = 0, bb: CGFloat = 0, ba: CGFloat = 0
        ua.getRed(&ar, green: &ag, blue: &ab, alpha: &aa)
        ub.getRed(&br, green: &bg, blue: &bb, alpha: &ba)
        return Color(
            red: Double(ar) + (Double(br) - Double(ar)) * t,
            green: Double(ag) + (Double(bg) - Double(ag)) * t,
            blue: Double(ab) + (Double(bb) - Double(ab)) * t
        )
    }
}
