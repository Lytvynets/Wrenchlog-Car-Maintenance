
import SwiftUI
import SwiftData

struct GarageView: View {
    @Query(sort: \Vehicle.createdAt) private var vehicles: [Vehicle]
    @EnvironmentObject private var purchaseVM: InAppPurchaseViewModel
    @Environment(\.modelContext) private var modelContext
    @AppStorage(AppDefaults.DefaultsKey.currencyCode) private var currencyCode: String = Locale.current.currency?.identifier ?? "USD"
    
    @State private var selectedVehicleID: PersistentIdentifier?
    @State private var showingAddVehicle = false
    @State private var showingAddService = false
    @State private var showingPaywall = false
    @State private var pendingInterstitial = false
    
    private var selectedVehicle: Vehicle? {
        vehicles.first(where: { $0.persistentModelID == selectedVehicleID }) ?? vehicles.first
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                Color.revAsphalt.ignoresSafeArea()
                
                if vehicles.isEmpty {
                    ScrollView {
                        EmptyStateView(
                            symbolName: "car.side.fill",
                            title: "Add your first car",
                            subtitle: "Start tracking service in under a minute.",
                            actionTitle: "Add car",
                            action: handleAddVehicleTap
                        )
                    }
                } else {
                    ScrollView {
                        VStack(spacing: RevSpacing.xl) {
                            vehicleSwitcher
                            
                            if let vehicle = selectedVehicle {
                                dashboard(for: vehicle)
                                upcomingServices(for: vehicle)
                            }
                            
                            Color.clear.frame(height: 72)
                        }
                        .padding(.top, RevSpacing.base)
                    }
                }
                
                if !vehicles.isEmpty {
                    Button {
                        showingAddService = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundStyle(Color.revAsphalt)
                            .frame(width: 56, height: 56)
                            .background(Color.revAmber, in: Circle())
                            .shadow(color: Color.revAmber.opacity(0.4), radius: 12, y: 4)
                    }
                    .padding(RevSpacing.lg)
                }
            }
            .safeAreaInset(edge: .bottom) {
                AdManager.shared.bannerView()
                    .padding(.horizontal, RevSpacing.lg)
                    .padding(.bottom, RevSpacing.sm)
            }
            .navigationTitle("Garage")
            .navigationDestination(for: Vehicle.self) { vehicle in
                VehicleDetailView(vehicle: vehicle)
            }
            .sheet(isPresented: $showingAddVehicle) {
                AddVehicleFlowView()
            }
            .sheet(isPresented: $showingAddService, onDismiss: {
                if pendingInterstitial {
                    pendingInterstitial = false
                    AdManager.shared.presentInterstitial()
                }
            }) {
                if let vehicle = selectedVehicle {
                    AddServiceEntrySheet(vehicle: vehicle, vehicles: vehicles, onSaved: { pendingInterstitial = true })
                }
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallView(onContinue: { showingPaywall = false })
            }
        }
    }
    

    private func handleAddVehicleTap() {
        if vehicles.isEmpty || purchaseVM.isPurchased {
            showingAddVehicle = true
        } else {
            showingPaywall = true
        }
    }
    
    private var vehicleSwitcher: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: RevSpacing.base) {
                ForEach(vehicles) { vehicle in
                    VehicleCardView(vehicle: vehicle)
                        .opacity(selectedVehicle?.persistentModelID == vehicle.persistentModelID ? 1 : 0.55)
                        .onTapGesture { selectedVehicleID = vehicle.persistentModelID }
                }
                Button(action: handleAddVehicleTap) {
                    AddVehicleCardView()
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, RevSpacing.lg)
        }
    }
    
    private func dashboard(for vehicle: Vehicle) -> some View {
        VStack(spacing: RevSpacing.lg) {
            NavigationLink(value: vehicle) {
                HStack(spacing: RevSpacing.xs) {
                    Text(vehicle.displayName)
                        .font(.revSectionTitle)
                        .foregroundStyle(Color.revChalk)
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(Color.revSlate)
                }
            }
            .buttonStyle(.plain)
            
            RevRingView(
                value: ReminderCalculator.healthValue(for: vehicle),
                size: 220,
                centerValue: vehicle.currentMileage.formatted(),
                centerLabel: vehicle.distanceUnit.shortLabel
            )
            
            HStack(spacing: RevSpacing.base) {
                statChip(symbol: "clock.fill", text: daysUntilText(for: vehicle))
                statChip(symbol: "creditcard.fill", text: monthlySpendText(for: vehicle))
            }
        }
    }
    
    private func statChip(symbol: String, text: String) -> some View {
        HStack(spacing: RevSpacing.xs) {
            Image(systemName: symbol)
                .foregroundStyle(Color.revAmber)
            Text(text)
                .font(.revSecondary.weight(.medium))
                .foregroundStyle(Color.revChalk)
                .lineLimit(1)
        }
        .padding(.horizontal, RevSpacing.base)
        .padding(.vertical, RevSpacing.sm)
        .background(Color.revGraphite, in: Capsule())
    }
    
    private func upcomingServices(for vehicle: Vehicle) -> some View {
        VStack(alignment: .leading, spacing: RevSpacing.base) {
            SectionHeader(title: "Upcoming service")
                .padding(.horizontal, RevSpacing.lg)
            
            let sortedEntries = vehicle.serviceEntries.sorted {
                ReminderCalculator.status(for: $0, vehicle: vehicle).healthValue <
                    ReminderCalculator.status(for: $1, vehicle: vehicle).healthValue
            }
            
            if sortedEntries.isEmpty {
                Text("No service logged yet for this car.")
                    .font(.revSecondary)
                    .foregroundStyle(Color.revSlate)
                    .padding(.horizontal, RevSpacing.lg)
            } else {
                VStack(spacing: RevSpacing.sm) {
                    ForEach(sortedEntries.prefix(5)) { entry in
                        UpcomingServiceRow(entry: entry, status: ReminderCalculator.status(for: entry, vehicle: vehicle))
                    }
                }
                .padding(.horizontal, RevSpacing.lg)
            }
        }
    }
    
    private func daysUntilText(for vehicle: Vehicle) -> String {
        guard let days = ReminderCalculator.daysUntilNextService(for: vehicle) else { return "No reminders set" }
        if days <= 0 { return "Service overdue" }
        return "\(days) days to service"
    }
    
    private func monthlySpendText(for vehicle: Vehicle) -> String {
        let calendar = Calendar.current
        let total = vehicle.serviceEntries
            .filter { calendar.isDate($0.date, equalTo: .now, toGranularity: .month) }
            .reduce(Decimal(0)) { $0 + $1.cost }
        return total.formatted(.currency(code: currencyCode))
    }
}
