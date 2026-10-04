

import SwiftUI
import SwiftData
import Charts

private enum StatsRange: String, CaseIterable, Identifiable, Hashable {
    case month = "Month", year = "Year", all = "All time"
    var id: String { rawValue }
}

private struct CategorySpend: Identifiable {
    let id = UUID()
    let name: String
    let symbolName: String
    let cost: Decimal
}

struct StatisticsView: View {
    @Query(sort: \Vehicle.createdAt) private var vehicles: [Vehicle]
    @EnvironmentObject private var purchaseVM: InAppPurchaseViewModel
    @AppStorage(AppDefaults.DefaultsKey.currencyCode) private var currencyCode: String = Locale.current.currency?.identifier ?? "USD"
    @State private var range: StatsRange = .month
    @State private var showingPaywall = false

    private var allEntries: [ServiceEntry] {
        vehicles.flatMap { $0.serviceEntries }
    }

    private var filteredEntries: [ServiceEntry] {
        let calendar = Calendar.current
        switch range {
        case .month:
            return allEntries.filter { calendar.isDate($0.date, equalTo: .now, toGranularity: .month) }
        case .year:
            return allEntries.filter { calendar.isDate($0.date, equalTo: .now, toGranularity: .year) }
        case .all:
            return allEntries
        }
    }

    private var totalCost: Decimal {
        filteredEntries.reduce(Decimal(0)) { $0 + $1.cost }
    }

    private var byCategory: [CategorySpend] {
        let groups = Dictionary(grouping: filteredEntries, by: { $0.category?.id })
        return groups.map { _, entries in
            let category = entries.first?.category
            let total = entries.reduce(Decimal(0)) { $0 + $1.cost }
            return CategorySpend(
                name: category?.name ?? "Other",
                symbolName: category?.symbolName ?? "wrench.and.screwdriver.fill",
                cost: total
            )
        }
        .sorted { $0.cost > $1.cost }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.revAsphalt.ignoresSafeArea()

                if allEntries.isEmpty {
                    ScrollView {
                        EmptyStateView(
                            symbolName: "chart.pie.fill",
                            title: "No data yet",
                            subtitle: "Log a service to see your spending here.",
                            actionTitle: "Got it",
                            action: {}
                        )
                    }
                } else {
                    ScrollView {
                        VStack(spacing: RevSpacing.xl) {
                            Picker("Range", selection: $range) {
                                ForEach(StatsRange.allCases) { Text($0.rawValue).tag($0) }
                            }
                            .pickerStyle(.segmented)

                            VStack(spacing: RevSpacing.xs) {
                                Text(totalCost.formatted(.currency(code: currencyCode)))
                                    .font(.system(.largeTitle, design: .rounded, weight: .bold))
                                    .foregroundStyle(Color.revChalk)
                                Text("total spent")
                                    .font(.revSecondary)
                                    .foregroundStyle(Color.revSlate)
                            }

                            if purchaseVM.isPurchased {
                                breakdownChart
                                trendChart
                            } else {
                                ZStack {
                                    breakdownChart
                                        .blur(radius: 12)
                                        .disabled(true)
                                    lockedOverlay
                                }
                            }
                        }
                        .padding(RevSpacing.lg)
                    }
                }
            }
            .navigationTitle("Statistics")
            .sheet(isPresented: $showingPaywall) {
                PaywallView(onContinue: { showingPaywall = false })
            }
        }
    }

    private var breakdownChart: some View {
        VStack(alignment: .leading, spacing: RevSpacing.base) {
            SectionHeader(title: "By category")

            Chart(byCategory) { item in
                SectorMark(angle: .value("Cost", (item.cost as NSDecimalNumber).doubleValue), innerRadius: .ratio(0.6))
                    .foregroundStyle(by: .value("Category", item.name))
            }
            .frame(height: 200)

            VStack(alignment: .leading, spacing: RevSpacing.xs) {
                ForEach(byCategory) { item in
                    HStack {
                        Text(item.name)
                            .font(.revCaption)
                            .foregroundStyle(Color.revChalk)
                        Spacer()
                        Text(item.cost.formatted(.currency(code: currencyCode)))
                            .font(.revCaption)
                            .foregroundStyle(Color.revSlate)
                    }
                }
            }
        }
        .padding(RevSpacing.lg)
        .background(Color.revGraphite, in: RoundedRectangle(cornerRadius: RevRadius.card, style: .continuous))
    }

    private var trendChart: some View {
        VStack(alignment: .leading, spacing: RevSpacing.base) {
            SectionHeader(title: "Over time")

            let monthly: [(Date, Decimal)] = Dictionary(grouping: filteredEntries) { entry in
                Calendar.current.dateComponents([.year, .month], from: entry.date)
            }
            .map { key, entries in
                (Calendar.current.date(from: key) ?? .now, entries.reduce(Decimal(0)) { $0 + $1.cost })
            }
            .sorted { $0.0 < $1.0 }

            Chart(monthly, id: \.0) { date, cost in
                BarMark(x: .value("Month", date, unit: .month), y: .value("Cost", (cost as NSDecimalNumber).doubleValue))
                    .foregroundStyle(Color.revAmber.gradient)
            }
            .frame(height: 180)
        }
        .padding(RevSpacing.lg)
        .background(Color.revGraphite, in: RoundedRectangle(cornerRadius: RevRadius.card, style: .continuous))
    }

    private var lockedOverlay: some View {
        VStack(spacing: RevSpacing.base) {
            Image(systemName: "lock.fill")
                .font(.system(size: 28))
                .foregroundStyle(Color.revAmber)
            Text("Unlock full statistics")
                .font(.revBody.weight(.semibold))
                .foregroundStyle(Color.revChalk)
            Button("Wrenchlog Pro") { showingPaywall = true }
                .font(.revCaption.weight(.semibold))
                .foregroundStyle(Color.revAsphalt)
                .padding(.horizontal, RevSpacing.base)
                .padding(.vertical, RevSpacing.sm)
                .background(Color.revAmber, in: Capsule())
        }
        .padding(RevSpacing.lg)
        .background(Color.revAsphalt.opacity(0.85), in: RoundedRectangle(cornerRadius: RevRadius.card, style: .continuous))
    }
}
