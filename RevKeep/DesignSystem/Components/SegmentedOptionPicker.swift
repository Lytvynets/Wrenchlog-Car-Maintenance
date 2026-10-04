

import SwiftUI

struct SegmentedOptionPicker<Option: Hashable>: View {
    let options: [Option]
    @Binding var selection: Option
    let label: (Option) -> String
    var icon: ((Option) -> String)? = nil

    var body: some View {
        HStack(spacing: 4) {
            ForEach(options, id: \.self) { option in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) { selection = option }
                } label: {
                    HStack(spacing: RevSpacing.xs) {
                        if let icon {
                            Image(systemName: icon(option))
                                .font(.system(size: 12, weight: .semibold))
                        }
                        Text(label(option))
                            .lineLimit(1)
                            .minimumScaleFactor(0.85)
                    }
                    .font(.revCaption.weight(.semibold))
                    .foregroundStyle(selection == option ? Color.revAsphalt : Color.revSlate)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, RevSpacing.sm)
                    .background(
                        selection == option ? Color.revAmber : Color.clear,
                        in: RoundedRectangle(cornerRadius: RevRadius.chip - 4, style: .continuous)
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(4)
        .background(Color.revGraphiteLight, in: RoundedRectangle(cornerRadius: RevRadius.chip, style: .continuous))
        .accessibilityElement(children: .contain)
    }
}
