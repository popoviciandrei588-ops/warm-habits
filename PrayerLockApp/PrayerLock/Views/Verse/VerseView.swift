import SwiftUI

struct VerseView: View {
    @State private var appear = false
    @State private var verse = Verse.verseOfTheDay()
    @State private var parallaxOffset: CGFloat = 0
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [
                        Color(hex: "0F172A"),
                        Color(hex: "1E3A5F"),
                        Color(hex: "1E40AF").opacity(0.6)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                // Floating orbs with parallax
                FloatingOrbs()
                    .offset(y: parallaxOffset * 0.1)
                
                // Content
                ScrollView {
                    VStack(spacing: PLSpacing.xxl) {
                        Spacer(minLength: geo.size.height * 0.15)
                        
                        // Header
                        VStack(spacing: PLSpacing.sm) {
                            Text("VERSE OF THE DAY")
                                .font(PLTypography.labelLarge)
                                .tracking(2)
                                .foregroundColor(.white.opacity(0.5))
                                .opacity(appear ? 1 : 0)
                                .offset(y: appear ? 0 : 20)
                            
                            Text(formattedDate)
                                .font(PLTypography.labelMedium)
                                .foregroundColor(.white.opacity(0.4))
                                .opacity(appear ? 1 : 0)
                                .offset(y: appear ? 0 : 20)
                        }
                        
                        // Verse text
                        VStack(spacing: PLSpacing.xl) {
                            Text("\"")
                                .font(.system(size: 80, weight: .ultraLight, design: .serif))
                                .foregroundColor(.white.opacity(0.3))
                                .offset(y: 20)
                                .opacity(appear ? 1 : 0)
                            
                            Text(verse.text)
                                .font(PLTypography.verseText)
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .lineSpacing(12)
                                .padding(.horizontal, PLSpacing.lg)
                                .opacity(appear ? 1 : 0)
                                .offset(y: appear ? 0 : 30)
                            
                            Text("— \(verse.reference)")
                                .font(PLTypography.verseReference)
                                .foregroundColor(Color(hex: "3B82F6"))
                                .opacity(appear ? 1 : 0)
                                .offset(y: appear ? 0 : 20)
                        }
                        
                        Spacer(minLength: geo.size.height * 0.15)
                        
                        // Share button
                        Button {
                            shareVerse()
                        } label: {
                            HStack(spacing: PLSpacing.xs) {
                                Image(systemName: "square.and.arrow.up")
                                Text("Share")
                            }
                            .font(PLTypography.labelLarge)
                            .foregroundColor(.white.opacity(0.7))
                            .padding(.horizontal, PLSpacing.lg)
                            .padding(.vertical, PLSpacing.sm)
                            .background(.ultraThinMaterial)
                            .clipShape(Capsule())
                        }
                        .opacity(appear ? 1 : 0)
                        
                        Spacer(minLength: PLSpacing.xxl)
                    }
                    .frame(minHeight: geo.size.height)
                    .background(
                        GeometryReader { scrollGeo in
                            Color.clear.preference(
                                key: ScrollOffsetPreferenceKey.self,
                                value: scrollGeo.frame(in: .named("scroll")).minY
                            )
                        }
                    )
                }
                .coordinateSpace(name: "scroll")
                .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                    parallaxOffset = value
                }
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1).delay(0.2)) {
                appear = true
            }
        }
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter.string(from: Date())
    }
    
    private func shareVerse() {
        let shareText = "\"\(verse.text)\"\n\n— \(verse.reference)\n\nShared via Prayer Lock"
        
        let activityVC = UIActivityViewController(
            activityItems: [shareText],
            applicationActivities: nil
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootVC = window.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
    }
}

// MARK: - Scroll Offset Preference Key
struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

#Preview {
    VerseView()
}
