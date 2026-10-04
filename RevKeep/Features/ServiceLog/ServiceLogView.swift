

import SwiftUI
import SwiftData

struct ServiceLogView: View {
    @Query(sort: \Vehicle.createdAt) private var vehicles: [Vehicle]
    @Environment(\.modelContext) private var modelContext
    @State private var selectedVehicleFilter: Vehicle?
    @State private var showingAddService = false
    @State private var showingAddCarAlert = false
    @State private var editingEntry: ServiceEntry?
    @State private var pendingInterstitial = false

    private var allEntries: [ServiceEntry] {
        vehicles.flatMap { $0.serviceEntries }
    }

    private var filteredEntries: [ServiceEntry] {
        let entries = selectedVehicleFilter == nil
            ? allEntries
            : allEntries.filter { $0.vehicle?.persistentModelID == selectedVehicleFilter?.persistentModelID }
        return entries.sorted { $0.date > $1.date }
    }

    private var groupedByMonth: [(String, [ServiceEntry])] {
        let groups = Dictionary(grouping: filteredEntries) { entry in
            entry.date.formatted(.dateTime.month(.wide).year())
        }
        return groups.sorted { lhs, rhs in
            (lhs.value.first?.date ?? .distantPast) > (rhs.value.first?.date ?? .distantPast)
        }
    }

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                Color.revAsphalt.ignoresSafeArea()

                if allEntries.isEmpty {
                    ScrollView {
                        EmptyStateView(
                            symbolName: "wrench.and.screwdriver.fill",
                            title: "No entries yet",
                            subtitle: "Add your first service record.",
                            actionTitle: "Add entry",
                            action: {
                                if !vehicles.isEmpty {
                                    showingAddService = true
                                }else{
                                    showingAddCarAlert = true
                                }
                            }
                        )
                    }
                } else {
                    List {
                        filterChipsRow

                        ForEach(groupedByMonth, id: \.0) { month, entries in
                            Section {
                                ForEach(entries) { entry in
                                    ZStack {
                                        UpcomingServiceRow(
                                            entry: entry,
                                            status: entry.vehicle.map { ReminderCalculator.status(for: entry, vehicle: $0) } ?? .ok
                                        )
                                        NavigationLink(value: entry) { EmptyView() }
                                            .opacity(0)
                                    }
                                    .listRowBackground(Color.clear)
                                    .listRowSeparator(.hidden)
                                    .listRowInsets(EdgeInsets(top: 4, leading: RevSpacing.lg, bottom: 4, trailing: RevSpacing.lg))
                                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                        Button(role: .destructive) {
                                            modelContext.delete(entry)
                                        } label: {
                                            Label("Delete", systemImage: "trash")
                                        }
                                        Button {
                                            editingEntry = entry
                                        } label: {
                                            Label("Edit", systemImage: "pencil")
                                        }
                                        .tint(Color.revAmber)
                                    }
                                }
                            } header: {
                                Text(month.uppercased())
                                    .font(.revCaption)
                                    .foregroundStyle(Color.revSlate)
                            }
                        }

                        Color.clear.frame(height: 72)
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
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
            .navigationTitle("Log")
            .navigationDestination(for: ServiceEntry.self) { entry in
                ServiceEntryDetailView(entry: entry)
            }
            .alert("Alert", isPresented: $showingAddCarAlert) {
                  Button("OK", role: .cancel) {
                      
                  }
              } message: {
                  Text("First, you need to add a vehicle")
              }
            .sheet(isPresented: $showingAddService, onDismiss: {
                if pendingInterstitial {
                    pendingInterstitial = false
                    AdManager.shared.presentInterstitial()
                }
            }) {
                if let vehicle = selectedVehicleFilter ?? vehicles.first {
                    AddServiceEntrySheet(vehicle: vehicle, vehicles: vehicles, onSaved: { pendingInterstitial = true })
                }
            }
            .sheet(item: $editingEntry) { entry in
                if let vehicle = entry.vehicle {
                    AddServiceEntrySheet(vehicle: vehicle, vehicles: vehicles, existingEntry: entry)
                }
            }
        }
    }

    private var filterChipsRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: RevSpacing.sm) {
                filterChip(title: "All", isSelected: selectedVehicleFilter == nil) {
                    selectedVehicleFilter = nil
                }
                ForEach(vehicles) { vehicle in
                    filterChip(
                        title: vehicle.displayName,
                        isSelected: selectedVehicleFilter?.persistentModelID == vehicle.persistentModelID
                    ) {
                        selectedVehicleFilter = vehicle
                    }
                }
            }
        }
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
        .listRowInsets(EdgeInsets())
    }

    private func filterChip(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.revCaption)
                .foregroundStyle(isSelected ? Color.revAsphalt : Color.revSlate)
                .padding(.horizontal, RevSpacing.base)
                .padding(.vertical, RevSpacing.sm)
                .background(isSelected ? Color.revAmber : Color.revGraphite, in: Capsule())
        }
        .buttonStyle(.plain)
    }
}
