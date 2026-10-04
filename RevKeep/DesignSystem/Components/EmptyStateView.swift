

import SwiftUI

struct EmptyStateView: View {
    let symbolName: String
    let title: String
    let subtitle: String
    let actionTitle: String
    let action: () -> Void

    var body: some View {
        VStack(spacing: RevSpacing.lg) {
            ZStack {
                Circle()
                    .fill(Color.revGraphite)
                    .frame(width: 96, height: 96)
                Image(systemName: symbolName)
                    .font(.system(size: 36))
                    .foregroundStyle(Color.revSlate)
            }
            VStack(spacing: RevSpacing.xs) {
                Text(title)
                    .font(.revTitle)
                    .foregroundStyle(Color.revChalk)
                Text(subtitle)
                    .font(.revSecondary)
                    .foregroundStyle(Color.revSlate)
                    .multilineTextAlignment(.center)
            }
            PrimaryButton(title: actionTitle, action: action)
                .frame(maxWidth: 220)
        }
        .padding(RevSpacing.xxl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
