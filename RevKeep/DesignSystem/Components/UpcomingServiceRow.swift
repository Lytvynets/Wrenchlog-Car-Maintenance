

import SwiftUI

struct UpcomingServiceRow: View {
    let entry: ServiceEntry
    let status: ServiceStatus

    var body: some View {
        HStack(spacing: RevSpacing.base) {
            RoundedRectangle(cornerRadius: 2)
                .fill(statusColor)
                .frame(width: 4)

            ZStack {
                Circle()
                    .fill(statusColor.opacity(0.15))
                    .frame(width: 40, height: 40)
                Image(systemName: entry.category?.symbolName ?? "wrench.and.screwdriver.fill")
                    .foregroundStyle(statusColor)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(entry.category?.name ?? "Service")
                    .font(.revBody.weight(.medium))
                    .foregroundStyle(Color.revChalk)
                Text(subtitleText)
                    .font(.revCaption)
                    .foregroundStyle(Color.revSlate)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color.revSlate)
        }
        .padding(RevSpacing.base)
        .background(Color.revGraphite, in: RoundedRectangle(cornerRadius: RevRadius.card, style: .continuous))
    }

    private var statusColor: Color {
        switch status {
        case .ok: return .revGreen
        case .dueSoon: return .revAmber
        case .overdue: return .revRed
        }
    }

    private var subtitleText: String {
        switch status {
        case .ok: return "On track"
        case .dueSoon: return "Due soon"
        case .overdue: return "Overdue"
        }
    }
}
