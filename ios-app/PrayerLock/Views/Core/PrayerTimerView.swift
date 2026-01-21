import SwiftUI
import Combine

struct PrayerTimerView: View {
    let prayer: PrayerTemplate
    let duration: Int
    var onComplete: () -> Void
    
    @State private var timeRemaining: Int
    @State private var timer: Timer.Publisher = Timer.publish(every: 1, on: .main, in: .common)
    @State private var timerCancellable: Cancellable?
    
    init(prayer: PrayerTemplate, duration: Int, onComplete: @escaping () -> Void) {
        self.prayer = prayer
        self.duration = duration
        self.onComplete = onComplete
        self._timeRemaining = State(initialValue: duration)
    }
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all) // Dark mode feeling for focus
            
            VStack(spacing: 40) {
                Spacer()
                
                Text(prayer.text)
                    .font(.title)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding()
                
                Text(prayer.reference)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                
                Spacer()
                
                ZStack {
                    Circle()
                        .stroke(lineWidth: 10)
                        .opacity(0.3)
                        .foregroundColor(.blue)
                    
                    Circle()
                        .trim(from: 0.0, to: CGFloat(min(Double(timeRemaining) / Double(duration), 1.0)))
                        .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round, lineJoin: .round))
                        .foregroundColor(.blue)
                        .rotationEffect(Angle(degrees: 270.0))
                        .animation(.linear, value: timeRemaining)
                    
                    Text("\(timeRemaining)")
                        .font(.system(size: 50))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                .frame(width: 200, height: 200)
                
                Spacer()
                
                Text("Pause & Pray")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Spacer()
            }
        }
        .onAppear {
            // Ensure apps are blocked while we pray
            ScreenTimeManager.shared.activateShield()
            startTimer()
        }
        .onDisappear {
            stopTimer()
        }
    }
    
    func startTimer() {
        timerCancellable = timer.connect()
        _ = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                stopTimer()
                ScreenTimeManager.shared.deactivateShield()
                onComplete()
            }
        }
    }
    
    func stopTimer() {
        timerCancellable?.cancel()
    }
}
