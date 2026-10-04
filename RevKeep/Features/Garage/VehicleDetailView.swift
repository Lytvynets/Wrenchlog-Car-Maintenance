

import SwiftUI
import SwiftData

struct VehicleDetailView: View {
    let vehicle: Vehicle

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var showingDeleteConfirmation = false

    var body: some View {
        ScrollView {
            VStack(spacing: RevSpacing.lg) {
                photoHeader

                VStack(alignment: .leading, spacing: RevSpacing.sm) {
                    infoRow(label: "License plate", value: vehicle.licensePlate ?? "—")
                    infoRow(label: "VIN", value: vehicle.vin ?? "—", monospaced: true)
                    infoRow(label: "Mileage", value: "\(vehicle.currentMileage.formatted()) \(vehicle.distanceUnit.shortLabel)")
                }
                .padding(RevSpacing.lg)
                .background(Color.revGraphite, in: RoundedRectangle(cornerRadius: RevRadius.card, style: .continuous))
                .padding(.horizontal, RevSpacing.lg)

                RevRingView(
                    value: ReminderCalculator.healthValue(for: vehicle),
                    size: 180,
                    centerValue: vehicle.currentMileage.formatted(),
                    centerLabel: vehicle.distanceUnit.shortLabel
                )

                VStack(alignment: .leading, spacing: RevSpacing.base) {
                    SectionHeader(title: "Service history")
                        .padding(.horizontal, RevSpacing.lg)

                    if vehicle.serviceEntries.isEmpty {
                        Text("No service logged yet.")
                            .font(.revSecondary)
                            .foregroundStyle(Color.revSlate)
                            .padding(.horizontal, RevSpacing.lg)
                    } else {
                        VStack(spacing: RevSpacing.sm) {
                            ForEach(vehicle.serviceEntries.sorted(by: { $0.date > $1.date })) { entry in
                                UpcomingServiceRow(entry: entry, status: ReminderCalculator.status(for: entry, vehicle: vehicle))
                            }
                        }
                        .padding(.horizontal, RevSpacing.lg)
                    }
                }

                Color.clear.frame(height: RevSpacing.xxl)
            }
        }
        .background(Color.revAsphalt.ignoresSafeArea())
        .navigationTitle(vehicle.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button(role: .destructive) {
                        showingDeleteConfirmation = true
                    } label: {
                        Label("Delete car", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .confirmationDialog("Delete this car?", isPresented: $showingDeleteConfirmation, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                modelContext.delete(vehicle)
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        }
    }

    private var photoHeader: some View {
        ZStack {
            if let data = vehicle.photoData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            } else {
                Rectangle()
                    .fill(Color.revGraphite)
                Image(systemName: "car.side.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(Color.revSlate)
            }
        }
        .frame(height: 220)
        .clipped()
    }

    private func infoRow(label: String, value: String, monospaced: Bool = false) -> some View {
        HStack {
            Text(label)
                .font(.revSecondary)
                .foregroundStyle(Color.revSlate)
            Spacer()
            Text(value)
                .font(monospaced ? .revMono : .revBody.weight(.medium))
                .foregroundStyle(Color.revChalk)
        }
    }
}
