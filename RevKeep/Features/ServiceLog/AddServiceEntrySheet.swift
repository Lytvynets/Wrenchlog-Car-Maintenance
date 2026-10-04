

import SwiftUI
import PhotosUI
import SwiftData

struct AddServiceEntrySheet: View {
    let vehicle: Vehicle
    let vehicles: [Vehicle]
    var existingEntry: ServiceEntry? = nil
    var onSaved: (() -> Void)? = nil
    
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var purchaseVM: InAppPurchaseViewModel
    @Query(sort: \ServiceCategory.createdAt) private var categories: [ServiceCategory]
    @AppStorage(AppDefaults.DefaultsKey.remindersEnabled) private var remindersEnabled: Bool = true
    
    @State private var selectedVehicle: Vehicle
    @State private var selectedCategory: ServiceCategory?
    @State private var date: Date
    @State private var mileageText: String
    @State private var costText: String
    @State private var notes: String
    @State private var receiptPhotoItem: PhotosPickerItem?
    @State private var receiptPhotoData: Data?
    @State private var mileageInterval: Int
    @State private var monthsInterval: Int
    @State private var showingAddCategory = false
    @State private var showingCategoryPaywall = false
    
    private var isEditing: Bool { existingEntry != nil }
    
    init(vehicle: Vehicle, vehicles: [Vehicle], existingEntry: ServiceEntry? = nil, onSaved: (() -> Void)? = nil) {
        self.vehicle = vehicle
        self.vehicles = vehicles
        self.existingEntry = existingEntry
        self.onSaved = onSaved
        _selectedVehicle = State(initialValue: existingEntry?.vehicle ?? vehicle)
        _selectedCategory = State(initialValue: existingEntry?.category)
        _date = State(initialValue: existingEntry?.date ?? .now)
        _mileageText = State(initialValue: "\(existingEntry?.mileageAtService ?? vehicle.currentMileage)")
        _costText = State(initialValue: existingEntry.map { NSDecimalNumber(decimal: $0.cost).stringValue } ?? "")
        _notes = State(initialValue: existingEntry?.notes ?? "")
        _receiptPhotoData = State(initialValue: existingEntry?.receiptPhotoData)
        _mileageInterval = State(initialValue: existingEntry?.nextServiceMileageInterval ?? 10_000)
        _monthsInterval = State(initialValue: existingEntry?.nextServiceMonthsInterval ?? 6)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: RevSpacing.lg) {
                    if vehicles.count > 1 {
                        Picker("Car", selection: $selectedVehicle) {
                            ForEach(vehicles) { v in
                                Text(v.displayName).tag(v)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    
                    categorySelector
                    
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                        .foregroundStyle(Color.revChalk)
                    
                    labeledField(title: "Mileage") {
                        TextField("0", text: $mileageText)
                            .keyboardType(.numberPad)
                    }
                    
                    labeledField(title: "Cost") {
                        TextField("0.00", text: $costText)
                            .keyboardType(.decimalPad)
                    }
                    
                    labeledField(title: "Notes (optional)") {
                        TextField("e.g. mechanic also suggested...", text: $notes, axis: .vertical)
                            .lineLimit(3...6)
                    }
                    
                    receiptPicker
                    nextServiceSelector
                }
                .padding(RevSpacing.lg)
            }
            .background(Color.revAsphalt.ignoresSafeArea())
            .navigationTitle(isEditing ? "Edit entry" : "New entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Color.revSlate)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") { save() }
                        .foregroundStyle(Color.revAmber)
                        .disabled(mileageText.isEmpty || selectedCategory == nil)
                }
            }
            .sheet(isPresented: $showingAddCategory) {
                AddCategorySheet(onSaved: { newCategory in selectedCategory = newCategory })
            }
            .sheet(isPresented: $showingCategoryPaywall) {
                PaywallView(onContinue: { showingCategoryPaywall = false })
            }
            .task {
                if selectedCategory == nil { selectedCategory = categories.first }
            }
        }
    }
    
    private var categorySelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: RevSpacing.sm) {
                ForEach(categories) { category in
                    CategoryChip(
                        category: category,
                        isSelected: selectedCategory?.persistentModelID == category.persistentModelID
                    ) {
                        selectedCategory = category
                        if !isEditing {
                            mileageInterval = category.defaultMileageInterval
                            monthsInterval = category.defaultMonthsInterval
                        }
                    }
                }
                AddCategoryChip {
                    if purchaseVM.isPurchased {
                        showingAddCategory = true
                    } else {
                        showingCategoryPaywall = true
                    }
                }
            }
        }
    }
    
    private var receiptPicker: some View {
        PhotosPicker(selection: $receiptPhotoItem, matching: .images) {
            HStack {
                Image(systemName: "camera.fill")
                Text(receiptPhotoData == nil ? "Attach receipt photo" : "Receipt attached")
            }
            .font(.revSecondary)
            .foregroundStyle(Color.revSlate)
            .frame(maxWidth: .infinity)
            .padding(RevSpacing.base)
            .background(Color.revGraphite, in: RoundedRectangle(cornerRadius: RevRadius.chip, style: .continuous))
        }
        .onChange(of: receiptPhotoItem) { _, newItem in
            Task {
                guard let data = try? await newItem?.loadTransferable(type: Data.self) else { return }
                let compressed = await Task.detached(priority: .userInitiated) {
                    ImageCompressor.compressedJPEGData(from: data) ?? data
                }.value
                receiptPhotoData = compressed
            }
        }
    }
    
    private var nextServiceSelector: some View {
        VStack(alignment: .leading, spacing: RevSpacing.sm) {
            Text("Next service in")
                .font(.revCaption)
                .foregroundStyle(Color.revSlate)
            
            Stepper(
                "\(mileageInterval.formatted()) \(selectedVehicle.distanceUnit.shortLabel)",
                value: $mileageInterval, in: 0...200_000, step: 500
            )
            .font(.revBody)
            .foregroundStyle(Color.revChalk)
            .padding(RevSpacing.base)
            .background(Color.revGraphite, in: RoundedRectangle(cornerRadius: RevRadius.chip, style: .continuous))
            
            Stepper("\(monthsInterval) months", value: $monthsInterval, in: 0...60)
                .font(.revBody)
                .foregroundStyle(Color.revChalk)
                .padding(RevSpacing.base)
                .background(Color.revGraphite, in: RoundedRectangle(cornerRadius: RevRadius.chip, style: .continuous))
        }
    }
    
    private func labeledField<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: RevSpacing.xs) {
            Text(title)
                .font(.revCaption)
                .foregroundStyle(Color.revSlate)
            content()
                .font(.revBody)
                .foregroundStyle(Color.revChalk)
                .padding(RevSpacing.base)
                .background(Color.revGraphite, in: RoundedRectangle(cornerRadius: RevRadius.chip, style: .continuous))
        }
    }
    
    private func save() {
        guard let selectedCategory else { return }
        let mileageValue = Int(mileageText) ?? selectedVehicle.currentMileage
        let costValue = Decimal(string: costText) ?? 0
        
        if let existingEntry {
            existingEntry.vehicle = selectedVehicle
            existingEntry.category = selectedCategory
            existingEntry.date = date
            existingEntry.mileageAtService = mileageValue
            existingEntry.cost = costValue
            existingEntry.notes = notes.isEmpty ? nil : notes
            existingEntry.receiptPhotoData = receiptPhotoData
            existingEntry.nextServiceMileageInterval = mileageInterval
            existingEntry.nextServiceMonthsInterval = monthsInterval
            if remindersEnabled {
                ReminderNotificationScheduler.schedule(for: existingEntry, vehicle: selectedVehicle)
            } else {
                ReminderNotificationScheduler.cancel(for: existingEntry)
            }
            
            try? modelContext.save()
        } else {
            let entry = ServiceEntry(
                vehicle: selectedVehicle,
                category: selectedCategory,
                date: date,
                mileageAtService: mileageValue,
                cost: costValue,
                notes: notes.isEmpty ? nil : notes,
                receiptPhotoData: receiptPhotoData,
                nextServiceMileageInterval: mileageInterval,
                nextServiceMonthsInterval: monthsInterval
            )
            modelContext.insert(entry)
            if mileageValue > selectedVehicle.currentMileage {
                selectedVehicle.currentMileage = mileageValue
            }
            if remindersEnabled {
                ReminderNotificationScheduler.schedule(for: entry, vehicle: selectedVehicle)
            }
            try? modelContext.save()
            onSaved?()
        }
        dismiss()
    }
}
