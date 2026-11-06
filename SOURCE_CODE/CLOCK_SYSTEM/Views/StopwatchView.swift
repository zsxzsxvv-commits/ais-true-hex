import SwiftUI

public struct StopwatchView: View {
    @State private var elapsedTime: TimeInterval = 0
    @State private var isRunning = false
    @State private var laps: [StopwatchLap] = []
    @State private var timer: Timer? = nil
    
    public init() {}
    
    public var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 20) {
                Spacer().frame(height: 60)
                
                // Digital Time Display
                Text(formatTime(elapsedTime))
                    .font(.system(size: 82, weight: .thin, design: .default))
                    .monospacedDigit()
                    .foregroundColor(.white)
                    .frame(height: 120)
                
                // Lap & Start/Stop Controls
                HStack {
                    // Left Button: Lap / Reset
                    Button(action: lapOrReset) {
                        ZStack {
                            Circle()
                                .fill(Color(white: 0.2))
                                .frame(width: 80, height: 80)
                            Circle()
                                .stroke(Color.black, lineWidth: 2)
                                .frame(width: 76, height: 76)
                            Text(isRunning ? "รอบ" : "รีเซ็ต")
                                .font(.system(size: 17, weight: .regular))
                                .foregroundColor(.white)
                        }
                    }
                    .disabled(elapsedTime == 0 && !isRunning)
                    .opacity(elapsedTime == 0 && !isRunning ? 0.6 : 1.0)
                    
                    Spacer()
                    
                    // Right Button: Start / Stop
                    Button(action: startOrStop) {
                        ZStack {
                            Circle()
                                .fill(isRunning ? Color.red.opacity(0.3) : Color.green.opacity(0.3))
                                .frame(width: 80, height: 80)
                            Circle()
                                .stroke(Color.black, lineWidth: 2)
                                .frame(width: 76, height: 76)
                            Text(isRunning ? "หยุด" : "เริ่ม")
                                .font(.system(size: 17, weight: .regular))
                                .foregroundColor(isRunning ? .red : .green)
                        }
                    }
                }
                .padding(.horizontal, 32)
                
                Divider().background(Color.white.opacity(0.1)).padding(.top, 10)
                
                // Laps Table
                List {
                    ForEach(laps.reversed()) { lap in
                        HStack {
                            Text("รอบที่ \(lap.lapNumber)")
                                .foregroundColor(.white)
                            Spacer()
                            Text(formatTime(lap.lapTime))
                                .monospacedDigit()
                                .foregroundColor(.white)
                        }
                        .listRowBackground(Color.black)
                    }
                }
                .listStyle(PlainListStyle())
            }
        }
    }
    
    private func startOrStop() {
        if isRunning {
            timer?.invalidate()
            timer = nil
            isRunning = false
        } else {
            isRunning = true
            let startDate = Date().addingTimeInterval(-elapsedTime)
            timer = Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true) { _ in
                elapsedTime = Date().timeIntervalSince(startDate)
            }
        }
    }
    
    private func lapOrReset() {
        if isRunning {
            let currentTotal = elapsedTime
            let previousLapsTotal = laps.reduce(0) { $0 + $1.lapTime }
            let lapDuration = currentTotal - previousLapsTotal
            let newLap = StopwatchLap(lapNumber: laps.count + 1, lapTime: lapDuration, totalTime: currentTotal)
            laps.append(newLap)
        } else {
            elapsedTime = 0
            laps.removeAll()
        }
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        let fraction = Int((time.truncatingRemainder(dividingBy: 1)) * 100)
        return String(format: "%02d:%02d.%02d", minutes, seconds, fraction)
    }
}
