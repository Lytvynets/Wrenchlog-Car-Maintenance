
import SwiftUI

struct CategoryChip: View {
    let category: ServiceCategory
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: RevSpacing.xs) {
                Image(systemName: category.symbolName)
                    .font(.system(size: 20, weight: .medium))
                Text(category.name)
                    .font(.revCaption)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .frame(width: 72, height: 64)
            .foregroundStyle(isSelected ? Color.revAsphalt : Color.revSlate)
            .background(
                isSelected ? Color.revAmber : Color.revGraphite,
                in: RoundedRectangle(cornerRadius: RevRadius.chip, style: .continuous)
            )
        }
        .buttonStyle(.plain)
    }
}


struct AddCategoryChip: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: RevSpacing.xs) {
                Image(systemName: "plus")
                    .font(.system(size: 20, weight: .medium))
                Text("New")
                    .font(.revCaption)
            }
            .frame(width: 72, height: 64)
            .foregroundStyle(Color.revAmber)
            .background(
                RoundedRectangle(cornerRadius: RevRadius.chip, style: .continuous)
                    .strokeBorder(Color.revAmber, style: StrokeStyle(lineWidth: 1.5, dash: [4, 3]))
            )
        }
        .buttonStyle(.plain)
    }
}
