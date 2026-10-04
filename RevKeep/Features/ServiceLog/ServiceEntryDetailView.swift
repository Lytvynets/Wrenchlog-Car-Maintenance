
import SwiftUI
import SwiftData

struct ServiceEntryDetailView: View {
    let entry: ServiceEntry

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Vehicle.createdAt) private var vehicles: [Vehicle]
    @AppStorage(AppDefaults.DefaultsKey.currencyCode) private var currencyCode: String = Locale.current.currency?.identifier ?? "USD"

    @State private var showingEdit = false
    @State private var showingDeleteConfirmation = false

    var body: some View {
        ScrollView {
            VStack(spacing: RevSpacing.lg) {
                header

                VStack(alignment: .leading, spacing: RevSpacing.sm) {
                    infoRow(label: "Car", value: entry.vehicle?.displayName ?? "—")
                    infoRow(label: "Date", value: entry.date.formatted(date: .abbreviated, time: .omitted))
                    infoRow(label: "Mileage", value: "\(entry.mileageAtService.formatted()) \(entry.vehicle?.distanceUnit.shortLabel ?? "km")")
                    infoRow(label: "Cost", value: entry.cost.formatted(.currency(code: currencyCode)))
                    if let mileageInterval = entry.nextServiceMileageInterval {
                        infoRow(label: "Reminder", value: "\(mileageInterval.formatted()) km / \(entry.nextServiceMonthsInterval ?? 0) months")
                    }
                }
                .padding(RevSpacing.lg)
                .background(Color.revGraphite, in: RoundedRectangle(cornerRadius: RevRadius.card, style: .continuous))
                .padding(.horizontal, RevSpacing.lg)

                if let notes = entry.notes, !notes.isEmpty {
                    VStack(alignment: .leading, spacing: RevSpacing.sm) {
                        SectionHeader(title: "Notes")
                        Text(notes)
                            .font(.revBody)
                            .foregroundStyle(Color.revChalk)
                    }
                    .padding(RevSpacing.lg)
                    .background(Color.revGraphite, in: RoundedRectangle(cornerRadius: RevRadius.card, style: .continuous))
                    .padding(.horizontal, RevSpacing.lg)
                }

                if let data = entry.receiptPhotoData, let uiImage = UIImage(data: data) {
                    VStack(alignment: .leading, spacing: RevSpacing.sm) {
                        SectionHeader(title: "Receipt")
                            .padding(.horizontal, RevSpacing.lg)
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .clipShape(RoundedRectangle(cornerRadius: RevRadius.card, style: .continuous))
                            .padding(.horizontal, RevSpacing.lg)
                    }
                }

                Color.clear.frame(height: RevSpacing.xxl)
            }
            .padding(.top, RevSpacing.lg)
        }
        .background(Color.revAsphalt.ignoresSafeArea())
        .navigationTitle(entry.category?.name ?? "Service")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        showingEdit = true
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }
                    Button(role: .destructive) {
                        showingDeleteConfirmation = true
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showingEdit) {
            if let vehicle = entry.vehicle {
                AddServiceEntrySheet(vehicle: vehicle, vehicles: vehicles, existingEntry: entry)
            }
        }
        .confirmationDialog("Delete this entry?", isPresented: $showingDeleteConfirmation, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                modelContext.delete(entry)
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        }
    }

    private var header: some View {
        HStack(spacing: RevSpacing.base) {
            ZStack {
                Circle().fill(Color.revAmber.opacity(0.15)).frame(width: 56, height: 56)
                Image(systemName: entry.category?.symbolName ?? "wrench.and.screwdriver.fill")
                    .font(.system(size: 22, weight: .medium))
                    .foregroundStyle(Color.revAmber)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.category?.name ?? "Service")
                    .font(.revTitle)
                    .foregroundStyle(Color.revChalk)
                Text(entry.vehicle?.displayName ?? "")
                    .font(.revSecondary)
                    .foregroundStyle(Color.revSlate)
            }
            Spacer()
        }
        .padding(.horizontal, RevSpacing.lg)
    }

    private func infoRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.revSecondary)
                .foregroundStyle(Color.revSlate)
            Spacer()
            Text(value)
                .font(.revBody.weight(.medium))
                .foregroundStyle(Color.revChalk)
        }
    }
}
