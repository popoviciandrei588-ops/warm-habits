import SwiftUI

struct MoodSelectionView: View {
    let moods = PrayerComposer.shared.getAllMoods()
    var onMoodSelected: (String) -> Void
    
    @State private var customMood: String = ""
    
    var body: some View {
        NavigationView {
            VStack {
                Text("How are you feeling today?")
                    .font(.title2)
                    .padding(.top)
                
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 140))], spacing: 16) {
                    ForEach(moods, id: \.self) { mood in
                        Button(action: {
                            onMoodSelected(mood)
                        }) {
                            Text(mood)
                                .font(.headline)
                                .foregroundColor(.primary)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                        }
                    }
                }
                .padding()
                
                Divider()
                    .padding(.vertical)
                
                VStack(alignment: .leading) {
                    Text("Or type something else:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack {
                        TextField("e.g. Hopeful, Confused...", text: $customMood)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        
                        Button("Go") {
                            if !customMood.isEmpty {
                                onMoodSelected(customMood)
                            }
                        }
                        .disabled(customMood.isEmpty)
                    }
                }
                .padding()
                
                Spacer()
            }
            .navigationTitle("Prayer Lock")
        }
    }
}
