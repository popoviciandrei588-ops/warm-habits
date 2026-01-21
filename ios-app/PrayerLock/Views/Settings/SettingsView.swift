import SwiftUI
import FamilyControls

struct SettingsView: View {
    @StateObject private var screenTimeManager = ScreenTimeManager.shared
    @State private var showFamilyActivityPicker = false
    @State private var lockDuration: Double = 60
    
    var body: some View {
        Form {
            Section(header: Text("Blocking")) {
                Toggle("Enable Blocking", isOn: Binding(
                    get: { screenTimeManager.isBlockingEnabled },
                    set: { screenTimeManager.toggleBlocking($0) }
                ))
                
                Button("Edit Blocked Apps") {
                    showFamilyActivityPicker = true
                }
            }
            .familyActivityPicker(isPresented: $showFamilyActivityPicker, selection: $screenTimeManager.activitySelection)
            .onChange(of: screenTimeManager.activitySelection) { _ in
                screenTimeManager.saveSelection()
            }
            
            Section(header: Text("Lock Settings")) {
                VStack(alignment: .leading) {
                    Text("Prayer Duration: \(Int(lockDuration)) seconds")
                    Slider(value: $lockDuration, in: 10...300, step: 10)
                }
            }
            
            Section(header: Text("Account")) {
                NavigationLink("Subscription", destination: PaywallView(isPresented: .constant(true)))
            }
            
            Section(header: Text("About")) {
                Text("Version 1.0.0")
            }
        }
        .navigationTitle("Settings")
    }
}
