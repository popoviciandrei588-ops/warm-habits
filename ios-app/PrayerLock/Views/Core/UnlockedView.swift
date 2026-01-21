import SwiftUI

struct UnlockedView: View {
    var onDismiss: () -> Void
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Image(systemName: "lock.open.fill")
                .font(.system(size: 80))
                .foregroundColor(.green)
            
            Text("Apps Unlocked")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("Go with God's peace.")
                .font(.title3)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Button(action: onDismiss) {
                Text("Continue")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            
            Spacer().frame(height: 50)
        }
    }
}
