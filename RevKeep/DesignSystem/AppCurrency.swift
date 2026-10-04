
import Foundation

enum AppCurrency: String, CaseIterable, Identifiable, Hashable {
    case usd = "USD"
    case eur = "EUR"
    case uah = "UAH"
    case gbp = "GBP"
    case pln = "PLN"
    case cad = "CAD"
    case aud = "AUD"
    case jpy = "JPY"
    case chf = "CHF"
    case czk = "CZK"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .usd: return "USD — US Dollar"
        case .eur: return "EUR — Euro"
        case .uah: return "UAH — Ukrainian Hryvnia"
        case .gbp: return "GBP — British Pound"
        case .pln: return "PLN — Polish Zloty"
        case .cad: return "CAD — Canadian Dollar"
        case .aud: return "AUD — Australian Dollar"
        case .jpy: return "JPY — Japanese Yen"
        case .chf: return "CHF — Swiss Franc"
        case .czk: return "CZK — Czech Koruna"
        }
    }
}
