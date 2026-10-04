

import SwiftUI
import SwiftData

struct AddCategorySheet: View {
    var onSaved: ((ServiceCategory) -> Void)? = nil

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var symbolName = "wrench.and.screwdriver.fill"
    @State private var mileageInterval = 10_000
    @State private var monthsInterval = 6

    private let iconOptions = [
        "wrench.and.screwdriver.fill", "drop.fill", "bolt.fill", "gearshape.fill",
        "car.side.fill", "flame.fill", "snowflake", "speedometer",
        "shield.fill", "sparkles", "wind", "bubbles.and.sparkles.fill"
    ]

    private let columns = Array(repeating: GridItem(.flexible(), spacing: RevSpacing.sm), count: 6)

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: RevSpacing.lg) {
                    VStack(alignment: .leading, spacing: RevSpacing.xs) {
                        Text("Name")
                            .font(.revCaption)
                            .foregroundStyle(Color.revSlate)
                        TextField("e.g. Air conditioning", text: $name)
                            .font(.revBody)
                            .foregroundStyle(Color.revChalk)
                            .padding(RevSpacing.base)
                            .background(Color.revGraphite, in: RoundedRectangle(cornerRadius: RevRadius.chip, style: .continuous))
                    }

                    VStack(alignment: .leading, spacing: RevSpacing.xs) {
                        Text("Icon")
                            .font(.revCaption)
                            .foregroundStyle(Color.revSlate)
                        LazyVGrid(columns: columns, spacing: RevSpacing.sm) {
                            ForEach(iconOptions, id: \.self) { symbol in
                                Button {
                                    symbolName = symbol
                                } label: {
                                    Image(systemName: symbol)
                                        .font(.system(size: 18, weight: .medium))
                                        .foregroundStyle(symbolName == symbol ? Color.revAsphalt : Color.revSlate)
                                        .frame(width: 44, height: 44)
                                        .background(
                                            symbolName == symbol ? Color.revAmber : Color.revGraphite,
                                            in: RoundedRectangle(cornerRadius: RevRadius.iconContainer, style: .continuous)
                                        )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    VStack(alignment: .leading, spacing: RevSpacing.sm) {
                        Text("Default reminder")
                            .font(.revCaption)
                            .foregroundStyle(Color.revSlate)

                        Stepper("\(mileageInterval.formatted()) km", value: $mileageInterval, in: 0...200_000, step: 500)
                            .foregroundStyle(Color.revChalk)
                            .padding(RevSpacing.base)
                            .background(Color.revGraphite, in: RoundedRectangle(cornerRadius: RevRadius.chip, style: .continuous))

                        Stepper("\(monthsInterval) months", value: $monthsInterval, in: 0...60)
                            .foregroundStyle(Color.revChalk)
                            .padding(RevSpacing.base)
                            .background(Color.revGraphite, in: RoundedRectangle(cornerRadius: RevRadius.chip, style: .continuous))
                    }
                }
                .padding(RevSpacing.lg)
            }
            .background(Color.revAsphalt.ignoresSafeArea())
            .navigationTitle("New category")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(Color.revSlate)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add") { save() }
                        .foregroundStyle(Color.revAmber)
                        .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private func save() {
        let category = ServiceCategory(
            name: name.trimmingCharacters(in: .whitespaces),
            symbolName: symbolName,
            defaultMileageInterval: mileageInterval,
            defaultMonthsInterval: monthsInterval,
            isBuiltIn: false
        )
        modelContext.insert(category)
        onSaved?(category)
        dismiss()
    }
}
