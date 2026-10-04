

import SwiftUI
import SwiftData

@main
struct RevKeepApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var purchaseVM = InAppPurchaseViewModel()

    @AppStorage(AppDefaults.DefaultsKey.appTheme) private var appThemeRaw: String = AppTheme.system.rawValue

    private var sharedModelContainer: ModelContainer = {
        let schema = Schema([Vehicle.self, ServiceEntry.self, ServiceCategory.self])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            let container = try ModelContainer(for: schema, configurations: [configuration])
            CategorySeeder.seedIfNeeded(context: container.mainContext)
            return container
        } catch {
            fatalError("Wrenchlog: could not create SwiftData ModelContainer — \(error)")
        }
    }()

    init() {
        AdManager.shared.start()
    }

    var body: some Scene {
        WindowGroup {
            RootFlowView()
                .environmentObject(appState)
                .environmentObject(purchaseVM)
                .preferredColorScheme((AppTheme(rawValue: appThemeRaw) ?? .system).colorScheme)
        }
        .modelContainer(sharedModelContainer)
    }
}
