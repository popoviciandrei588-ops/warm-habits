import SwiftUI

struct MoodSelectionView: View {
    @State private var selectedMood: Mood = .anxious
    @State private var freeText: String = ""

    var body: some View {
        VStack(spacing: 16) {
            VStack(spacing: 8) {
                Text("Tell God how you feel today")
                    .font(.title2.weight(.semibold))
                    .multilineTextAlignment(.center)
                Text("Choose a feeling — add a word or two if you want.")
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 8)

            List {
                Section("Mood") {
                    ForEach(Mood.allCases) { mood in
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(mood.title)
                                Text(mood.subtitle).font(.footnote).foregroundStyle(.secondary)
                            }
                            Spacer()
                            if mood == selectedMood {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundStyle(.tint)
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture { selectedMood = mood }
                    }
                }

                Section("Optional") {
                    TextField("What’s on your heart?", text: $freeText, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .listStyle(.insetGrouped)

            NavigationLink {
                PrayerTimerView(mood: selectedMood, freeText: freeText.isEmpty ? nil : freeText)
            } label: {
                Text("Continue")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .padding(.horizontal, 20)
            .padding(.bottom, 8)
        }
        .navigationTitle("Mood")
        .navigationBarTitleDisplayMode(.inline)
    }
}

