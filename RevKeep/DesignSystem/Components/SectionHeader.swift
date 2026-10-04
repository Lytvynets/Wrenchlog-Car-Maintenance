

import SwiftUI

struct SectionHeader: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.revSectionTitle)
            .foregroundStyle(Color.revChalk)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}
