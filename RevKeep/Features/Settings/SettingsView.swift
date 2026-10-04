

import SwiftUI
import SwiftData

struct SettingsView: View {
    @EnvironmentObject private var purchaseVM: InAppPurchaseViewModel
    @Query(sort: \Vehicle.createdAt) private var vehicles: [Vehicle]
    @Environment(\.modelContext) private var modelContext
    @State private var showingPaywall = false
    @State private var exportedFileURL: URL?

    @AppStorage(AppDefaults.DefaultsKey.distanceUnit) private var distanceUnitRaw: String = DistanceUnit.km.rawValue
    @AppStorage(AppDefaults.DefaultsKey.appTheme) private var appThemeRaw: String = AppTheme.system.rawValue
    @AppStorage(AppDefaults.DefaultsKey.currencyCode) private var currencyCode: String = Locale.current.currency?.identifier ?? "USD"
    @AppStorage(AppDefaults.DefaultsKey.remindersEnabled) private var remindersEnabled: Bool = true

    private var selectedTheme: Binding<AppTheme> {
        Binding(
            get: { AppTheme(rawValue: appThemeRaw) ?? .system },
            set: { appThemeRaw = $0.rawValue }
        )
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Pro") {
                    if purchaseVM.isPurchased {
                        HStack {
                            Text("Wrenchlog Pro")
                            Spacer()
                            Label("Active", systemImage: "checkmark.seal.fill")
                                .foregroundStyle(Color.revGreen)
                        }
                    } else {
                        Button {
                            showingPaywall = true
                        } label: {
                            HStack {
                                Text("Unlock Wrenchlog Pro")
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                        }
                        .foregroundStyle(Color.revAmber)
                    }
                }

                Section("Notifications") {
                    Toggle("Service reminders", isOn: $remindersEnabled)
                        .onChange(of: remindersEnabled) { _, isOn in
                            if isOn {
                                NotificationPermissionRequester.requestIfNeeded()
                                ReminderNotificationScheduler.rescheduleAll(vehicles: vehicles)
                            } else {
                                ReminderNotificationScheduler.cancelAll()
                            }
                        }
                }

                Section("Preferences") {
                    Picker("Distance unit", selection: $distanceUnitRaw) {
                        Text("Kilometers").tag(DistanceUnit.km.rawValue)
                        Text("Miles").tag(DistanceUnit.mi.rawValue)
                    }

                    Picker("Currency", selection: $currencyCode) {
                        ForEach(AppCurrency.allCases) { currency in
                            Text(currency.displayName).tag(currency.rawValue)
                        }
                    }

                    VStack(alignment: .leading, spacing: RevSpacing.sm) {
                        Text("Appearance")
                        SegmentedOptionPicker(
                            options: AppTheme.allCases,
                            selection: selectedTheme,
                            label: { $0.title },
                            icon: { $0.symbolName }
                        )
                    }
                    .padding(.vertical, RevSpacing.xs)
                }

                Section("My cars") {
                    if vehicles.isEmpty {
                        Text("No cars added yet")
                            .foregroundStyle(Color.revSlate)
                    } else {
                        ForEach(vehicles) { vehicle in
                            Text(vehicle.displayName)
                        }
                        .onDelete(perform: deleteVehicles)
                    }
                }

                Section("Data") {
                    if purchaseVM.isPurchased {
                        Button("Export data (CSV)") {
                            exportedFileURL = ExportService.writeCSVFile(vehicles: vehicles)
                        }
                        if let exportedFileURL {
                            ShareLink(item: exportedFileURL) {
                                Label("Share exported file", systemImage: "square.and.arrow.up")
                            }
                        }
                    } else {
                        Button {
                            showingPaywall = true
                        } label: {
                            HStack {
                                Text("Export data (CSV)")
                                Spacer()
                                Image(systemName: "lock.fill")
                                    .foregroundStyle(Color.revSlate)
                            }
                        }
                    }
                }

                Section {
                    Text("CSV opens directly as a table in Excel, Numbers, and Google Sheets — no separate Excel export needed.")
                        .font(.revCaption)
                        .foregroundStyle(Color.revSlate)
                }

                Section("About") {
                    Link("Rate Wrenchlog", destination: AppDefaults.appStoreURL)
                    Link("Contact support", destination: URL(string: "mailto:\(AppDefaults.supportEmail)")!)
                    Button("Restore purchase") {
                        Task { await purchaseVM.restorePurchases() }
                    }
                }

                Section("Legal") {
                    Link("Terms of Use", destination: AppDefaults.termsOfUseURL)
                    Link("Privacy Policy", destination: AppDefaults.privacyPolicyURL)
                }
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showingPaywall) {
                PaywallView(onContinue: { showingPaywall = false })
            }
        }
    }

    private func deleteVehicles(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(vehicles[index])
        }
    }
}
