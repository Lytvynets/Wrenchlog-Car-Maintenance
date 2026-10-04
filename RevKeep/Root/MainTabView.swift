

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            GarageView()
                .tabItem { Label("Garage", systemImage: "speedometer") }

            ServiceLogView()
                .tabItem { Label("Log", systemImage: "wrench.and.screwdriver.fill") }

            StatisticsView()
                .tabItem { Label("Stats", systemImage: "chart.pie.fill") }

            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape.fill") }
        }
        .tint(Color.revAmber)
    }
}
