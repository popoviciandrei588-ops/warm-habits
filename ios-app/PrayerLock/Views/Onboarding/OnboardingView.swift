import SwiftUI
import FamilyControls

struct OnboardingView: View {
    @Binding var isOnboardingCompleted: Bool
    @StateObject private var screenTimeManager = ScreenTimeManager.shared
    @State private var showFamilyActivityPicker = false
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            Text("Prayer Lock")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Pause. Pray. Unlock.")
                .font(.title3)
                .foregroundColor(.secondary)
            
            Text("Before you scroll, take a moment to connect with God. Select the apps that distract you the most.")
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Spacer()
            
            Button(action: {
                Task {
                    await screenTimeManager.requestAuthorization()
                }
            }) {
                Text("Grant Permissions")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            
            Button(action: {
                showFamilyActivityPicker = true
            }) {
                Text("Select Apps to Block")
                    .font(.headline)
                    .foregroundColor(.blue)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            .familyActivityPicker(isPresented: $showFamilyActivityPicker, selection: $screenTimeManager.activitySelection)
            .onChange(of: screenTimeManager.activitySelection) { _ in
                screenTimeManager.saveSelection()
            }
            
            Button(action: {
                // Save onboarding state
                isOnboardingCompleted = true
            }) {
                Text("Get Started")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            .disabled(screenTimeManager.activitySelection.applicationTokens.isEmpty && screenTimeManager.activitySelection.categoryTokens.isEmpty)
            .opacity((screenTimeManager.activitySelection.applicationTokens.isEmpty && screenTimeManager.activitySelection.categoryTokens.isEmpty) ? 0.5 : 1.0)
            
            Spacer().frame(height: 20)
        }
        .padding()
    }
}
