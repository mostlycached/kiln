import SwiftUI
import AVFoundation

/// Timer view for the Empty Heat phase meditation
struct EmptyHeatTimerView: View {
    @Binding var isPresented: Bool
    @Binding var elapsedDuration: TimeInterval
    
    @State private var timeRemaining: TimeInterval = 300  // 5 minutes default
    @State private var selectedDuration: TimeInterval = 300
    @State private var isRunning = false
    @State private var timer: Timer?
    
    let durations: [(String, TimeInterval)] = [
        ("2 min", 120),
        ("5 min", 300),
        ("10 min", 600),
        ("15 min", 900),
        ("20 min", 1200)
    ]
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Spacer()
                
                // Timer display
                Text(timeString(from: timeRemaining))
                    .font(.system(size: 72, weight: .thin, design: .monospaced))
                    .foregroundStyle(isRunning ? .primary : .secondary)
                
                // Progress ring
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 8)
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(Color.accentColor, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 1), value: progress)
                }
                .frame(width: 200, height: 200)
                
                Spacer()
                
                // Duration picker (only when not running)
                if !isRunning && timeRemaining == selectedDuration {
                    VStack(spacing: 12) {
                        Text("Duration")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        HStack(spacing: 12) {
                            ForEach(Array(durations), id: \.1) { duration in
                                DurationButton(
                                    title: duration.0,
                                    isSelected: selectedDuration == duration.1,
                                    action: { selectDuration(duration.1) }
                                )
                            }
                        }
                    }
                }
                
                // Controls
                HStack(spacing: 32) {
                    // Reset
                    Button(action: resetTimer) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.title2)
                            .foregroundStyle(.secondary)
                            .frame(width: 60, height: 60)
                            .background(Color(.systemGray5))
                            .clipShape(Circle())
                    }
                    .disabled(timeRemaining == selectedDuration && !isRunning)
                    
                    // Play/Pause
                    Button(action: toggleTimer) {
                        Image(systemName: isRunning ? "pause.fill" : "play.fill")
                            .font(.title)
                            .foregroundStyle(.white)
                            .frame(width: 80, height: 80)
                            .background(Color.accentColor)
                            .clipShape(Circle())
                    }
                    
                    // Complete
                    Button(action: completeSession) {
                        Image(systemName: "checkmark")
                            .font(.title2)
                            .foregroundStyle(.secondary)
                            .frame(width: 60, height: 60)
                            .background(Color(.systemGray5))
                            .clipShape(Circle())
                    }
                }
                
                Spacer()
                
                // Guidance text
                Text("Sit in the gap. Resist the urge to resolve.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Empty Heat")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        stopTimer()
                        isPresented = false
                    }
                }
            }
        }
        .onDisappear {
            stopTimer()
        }
    }
    
    private var progress: Double {
        guard selectedDuration > 0 else { return 0 }
        return 1 - (timeRemaining / selectedDuration)
    }
    
    private func timeString(from interval: TimeInterval) -> String {
        let minutes = Int(interval) / 60
        let seconds = Int(interval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func selectDuration(_ duration: TimeInterval) {
        selectedDuration = duration
        timeRemaining = duration
    }
    
    private func toggleTimer() {
        if isRunning {
            pauseTimer()
        } else {
            startTimer()
        }
    }
    
    private func startTimer() {
        isRunning = true
        triggerHaptic()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                completeSession()
            }
        }
    }
    
    private func pauseTimer() {
        isRunning = false
        timer?.invalidate()
        timer = nil
    }
    
    private func stopTimer() {
        pauseTimer()
    }
    
    private func resetTimer() {
        stopTimer()
        timeRemaining = selectedDuration
    }
    
    private func completeSession() {
        stopTimer()
        elapsedDuration = selectedDuration - timeRemaining
        triggerHaptic()
        isPresented = false
    }
    
    private func triggerHaptic() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}

struct DurationButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(isSelected ? .semibold : .regular)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(isSelected ? Color.accentColor : Color(.systemGray5))
                .foregroundStyle(isSelected ? .white : .primary)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    EmptyHeatTimerView(isPresented: .constant(true), elapsedDuration: .constant(0))
}
