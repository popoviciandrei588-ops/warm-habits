import SwiftUI

struct VerseView: View {
    let verse: VerseOfDay
    
    var body: some View {
        VStack {
            Spacer()
            
            Text(verse.text)
                .font(.custom("Georgia", size: 24))
                .italic()
                .multilineTextAlignment(.center)
                .padding()
            
            Text(verse.reference)
                .font(.headline)
                .foregroundColor(.secondary)
                .padding(.top, 8)
            
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
    }
}
