import SwiftUI
import UIKit

struct PermissionsFixCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Permission needed")
                .font(.headline)
            Text("Enable Family Controls in Settings so PrayerLock can block selected apps.")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Button("Open Settings") {
                guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
                UIApplication.shared.open(url)
            }
            .font(.subheadline.weight(.semibold))
            .padding(.top, 2)
        }
        .padding(14)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

