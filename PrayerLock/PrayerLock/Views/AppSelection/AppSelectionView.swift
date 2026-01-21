import SwiftUI
import FamilyControls

/// View for selecting which apps to block
struct AppSelectionView: View {
    @StateObject private var screenTimeManager = ScreenTimeManager.shared
    @Environment(\.dismiss) private var dismiss
    
    @State private var isPickerPresented = false
    @State private var showConfirmation = false
    
    var onSelectionComplete: ((FamilyActivitySelection) -> Void)?
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color(UIColor.systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Header
                        headerSection
                        
                        // Selection status
                        selectionStatusCard
                        
                        // Select apps button
                        selectAppsButton
                        
                        // Tips section
                        tipsSection
                        
                        // Permission warning if needed
                        if !screenTimeManager.authorizationStatus.isAuthorized {
                            permissionWarning
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Select Apps")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        onSelectionComplete?(screenTimeManager.selectedApps)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(!screenTimeManager.hasSelection)
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .familyActivityPicker(
                isPresented: $isPickerPresented,
                selection: $screenTimeManager.selectedApps
            )
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "apps.iphone")
                .font(.system(size: 50))
                .foregroundColor(.indigo)
            
            Text("Choose Your Prayer Triggers")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Select apps that distract you most. Before opening them, you'll pause for prayer.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 20)
    }
    
    // MARK: - Selection Status Card
    private var selectionStatusCard: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Selected Items")
                        .font(.headline)
                    
                    Text("\(screenTimeManager.selectedCount) app(s) and categories")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                ZStack {
                    Circle()
                        .fill(screenTimeManager.hasSelection ? Color.green.opacity(0.2) : Color.gray.opacity(0.2))
                        .frame(width: 60, height: 60)
                    
                    Text("\(screenTimeManager.selectedCount)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(screenTimeManager.hasSelection ? .green : .gray)
                }
            }
            
            Divider()
            
            // Show selection breakdown
            if screenTimeManager.hasSelection {
                HStack(spacing: 24) {
                    StatItem(
                        icon: "app.fill",
                        value: "\(screenTimeManager.selectedApps.applicationTokens.count)",
                        label: "Apps"
                    )
                    
                    StatItem(
                        icon: "folder.fill",
                        value: "\(screenTimeManager.selectedApps.categoryTokens.count)",
                        label: "Categories"
                    )
                }
            } else {
                Text("No apps selected yet")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(16)
    }
    
    // MARK: - Select Apps Button
    private var selectAppsButton: some View {
        Button(action: {
            isPickerPresented = true
        }) {
            HStack {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                
                Text(screenTimeManager.hasSelection ? "Modify Selection" : "Select Apps to Block")
                    .font(.headline)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    colors: [.indigo, .purple],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(12)
        }
        .disabled(!screenTimeManager.authorizationStatus.isAuthorized)
    }
    
    // MARK: - Tips Section
    private var tipsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("💡 Tips")
                .font(.headline)
            
            TipRow(
                icon: "hand.raised.fill",
                title: "Start Small",
                description: "Begin with 2-3 apps you use most mindlessly"
            )
            
            TipRow(
                icon: "clock.fill",
                title: "Social Media",
                description: "Great choices: Instagram, TikTok, Twitter, Facebook"
            )
            
            TipRow(
                icon: "gamecontroller.fill",
                title: "Games & Entertainment",
                description: "Include games that consume your attention"
            )
            
            TipRow(
                icon: "arrow.triangle.2.circlepath",
                title: "Adjust Anytime",
                description: "You can always change your selection in settings"
            )
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(16)
    }
    
    // MARK: - Permission Warning
    private var permissionWarning: some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.largeTitle)
                .foregroundColor(.orange)
            
            Text("Screen Time Permission Required")
                .font(.headline)
            
            Text("Please grant Screen Time access in your device settings to select apps.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button(action: {
                Task {
                    await screenTimeManager.requestAuthorization()
                }
            }) {
                Text("Grant Permission")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.orange)
                    .cornerRadius(10)
            }
        }
        .padding()
        .background(Color.orange.opacity(0.1))
        .cornerRadius(16)
    }
}

// MARK: - Supporting Views

struct StatItem: View {
    let icon: String
    let value: String
    let label: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(.indigo)
            
            VStack(alignment: .leading) {
                Text(value)
                    .font(.headline)
                Text(label)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct TipRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.indigo)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

// MARK: - Preview
#Preview {
    AppSelectionView()
}
