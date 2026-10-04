

import SwiftUI
import PhotosUI
import SwiftData

struct AddVehicleFlowView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var step = 1
    private let totalSteps = 4
    
    @State private var photoItem: PhotosPickerItem?
    @State private var photoData: Data?
    
    @State private var make = ""
    @State private var model = ""
    @State private var year = Calendar.current.component(.year, from: .now)
    
    @State private var licensePlate = ""
    @State private var mileageText = ""
    @State private var distanceUnit: DistanceUnit = .km
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ProgressView(value: Double(step), total: Double(totalSteps))
                    .tint(Color.revAmber)
                    .padding(.horizontal, RevSpacing.lg)
                    .padding(.top, RevSpacing.sm)
                
                ScrollView {
                    VStack(spacing: RevSpacing.xl) {
                        switch step {
                        case 1: photoStep
                        case 2: detailsStep
                        case 3: plateAndMileageStep
                        default: confirmationStep
                        }
                    }
                    .padding(RevSpacing.lg)
                }
                
                if step < totalSteps {
                    PrimaryButton(title: step == totalSteps - 1 ? "Add car" : "Continue", isEnabled: canContinue) {
                        withAnimation {
                            if step == totalSteps - 1 {
                                saveVehicle()
                            }
                            step += 1
                        }
                    }
                    .padding(RevSpacing.lg)
                }
            }
            .background(Color.revAsphalt.ignoresSafeArea())
            .navigationTitle("Add car")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Color.revSlate)
                }
            }
        }
    }
    
    private var canContinue: Bool {
        switch step {
        case 2: return !make.isEmpty && !model.isEmpty
        default: return true
        }
    }
    
    private var photoStep: some View {
        VStack(spacing: RevSpacing.lg) {
            PhotosPicker(selection: $photoItem, matching: .images) {
                ZStack {
                    Circle().fill(Color.revGraphite).frame(width: 140, height: 140)
                    if let photoData, let uiImage = UIImage(data: photoData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 140, height: 140)
                            .clipShape(Circle())
                    } else {
                        Image(systemName: "camera.fill")
                            .font(.system(size: 32))
                            .foregroundStyle(Color.revSlate)
                    }
                }
            }
            .onChange(of: photoItem) { _, newItem in
                Task {
                    guard let data = try? await newItem?.loadTransferable(type: Data.self) else { return }
                    let compressed = await Task.detached(priority: .userInitiated) {
                        ImageCompressor.compressedJPEGData(from: data) ?? data
                    }.value
                    photoData = compressed
                }
            }
            
            Text("Add a photo (optional)")
                .font(.revSecondary)
                .foregroundStyle(Color.revSlate)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, RevSpacing.xxl)
    }
    
    private var detailsStep: some View {
        VStack(spacing: RevSpacing.base) {
            RevTextField(title: "Make", text: $make, placeholder: "Toyota")
            RevTextField(title: "Model", text: $model, placeholder: "Camry")
            
            Stepper(
                "Year: \(year.formatted(.number.grouping(.never)))",
                value: $year,
                in: 1980...(Calendar.current.component(.year, from: .now) + 1)
            )
            .foregroundStyle(Color.revChalk)
            .padding(RevSpacing.base)
            .background(Color.revGraphite, in: RoundedRectangle(cornerRadius: RevRadius.chip, style: .continuous))
        }
    }
    
    private var plateAndMileageStep: some View {
        VStack(spacing: RevSpacing.base) {
            RevTextField(title: "License plate", text: $licensePlate, placeholder: "AA1234BB")
            
            VStack(alignment: .leading, spacing: RevSpacing.xs) {
                Text("Current mileage")
                    .font(.revCaption)
                    .foregroundStyle(Color.revSlate)
                HStack {
                    TextField("0", text: $mileageText)
                        .keyboardType(.numberPad)
                        .font(.revBody)
                        .foregroundStyle(Color.revChalk)
                    
                    Picker("Unit", selection: $distanceUnit) {
                        Text("km").tag(DistanceUnit.km)
                        Text("mi").tag(DistanceUnit.mi)
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 120)
                }
                .padding(RevSpacing.base)
                .background(Color.revGraphite, in: RoundedRectangle(cornerRadius: RevRadius.chip, style: .continuous))
            }
        }
    }
    
    private var confirmationStep: some View {
        VStack(spacing: RevSpacing.lg) {
            ZStack {
                Circle().fill(Color.revGreen.opacity(0.15)).frame(width: 96, height: 96)
                Image(systemName: "checkmark")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundStyle(Color.revGreen)
            }
            Text("Car added!")
                .font(.revTitle)
                .foregroundStyle(Color.revChalk)
            
            PrimaryButton(title: "Go to Garage") { dismiss() }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, RevSpacing.xxl)
    }
    
    private func saveVehicle() {
        let vehicle = Vehicle(
            make: make,
            model: model,
            year: year,
            licensePlate: licensePlate.isEmpty ? nil : licensePlate,
            photoData: photoData,
            currentMileage: Int(mileageText) ?? 0,
            distanceUnit: distanceUnit
        )
        modelContext.insert(vehicle)
        try? modelContext.save()
    }
}

private struct RevTextField: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: RevSpacing.xs) {
            Text(title)
                .font(.revCaption)
                .foregroundStyle(Color.revSlate)
            TextField(placeholder, text: $text)
                .font(.revBody)
                .foregroundStyle(Color.revChalk)
                .padding(RevSpacing.base)
                .background(Color.revGraphite, in: RoundedRectangle(cornerRadius: RevRadius.chip, style: .continuous))
        }
    }
}
