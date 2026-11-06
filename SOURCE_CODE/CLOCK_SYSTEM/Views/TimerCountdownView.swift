import SwiftUI

public struct TimerCountdownView: View {
    // Pickers state (ค่าเริ่มต้นรหัสลับ: 0 ชม. 0 นาที 31 วินาที)
    @State private var selectedHours: Int = ClockTriggerConfig.triggerHours
    @State private var selectedMinutes: Int = ClockTriggerConfig.triggerMinutes
    @State private var selectedSeconds: Int = ClockTriggerConfig.triggerSeconds
    
    // Running state
    @State private var isRunning = false
    @State private var isPaused = false
    @State private var totalDuration: TimeInterval = 0
    @State private var remainingTime: TimeInterval = 0
    @State private var timer: Timer? = nil
    @State private var endDate: Date = Date()
    
    // Shortcut settings sheet
    @State private var showSettingsSheet: Bool = false
    
    // Security Manager
    @ObservedObject private var securityManager = ClockSecurityManager.shared
    
    // Secret unlock callback
    public var onSecretUnlocked: () -> Void
    
    public init(onSecretUnlocked: @escaping () -> Void = {}) {
        self.onSecretUnlocked = onSecretUnlocked
    }
    
    public var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Top Bar with Gear Icon for Shortcut Settings
                HStack {
                    Spacer()
                    Button(action: {
                        showSettingsSheet = true
                    }) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 20))
                            .foregroundColor(Color(white: 0.35))
                            .padding(12)
                    }
                }
                .padding(.horizontal, 16)
                
                if !isRunning {
                    // Wheel Picker แบบ iOS Native
                    wheelPickers
                        .frame(height: 240)
                } else {
                    // วงกลมนับถอยหลัง
                    countdownDisplay
                        .frame(height: 240)
                }
                
                // แถบข้อความเสียงเมื่อหมดเวลา
                whenTimerEndsCell
                    .padding(.horizontal, 20)
                
                Spacer().frame(height: 10)
                
                // ปุ่มควบคุม: ยกเลิก / เริ่ม / พัก
                controls
                    .padding(.horizontal, 32)
                
                Spacer()
            }
            
            // Loading Overlay when verifying with API
            if securityManager.isVerifying {
                ZStack {
                    Color.black.opacity(0.7).ignoresSafeArea()
                    VStack(spacing: 16) {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .orange))
                            .scaleEffect(1.5)
                        Text("กำลังตรวจสอบสถานะความปลอดภัย...")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundColor(.white)
                    }
                    .padding(24)
                    .background(Color(white: 0.15))
                    .cornerRadius(16)
                }
            }
        }
        .sheet(isPresented: $showSettingsSheet) {
            ShortcutSettingsSheet()
        }
        .onAppear {
            // โหลดค่าคีย์ลัดล่าสุดที่บันทึกไว้
            selectedHours = ClockTriggerConfig.triggerHours
            selectedMinutes = ClockTriggerConfig.triggerMinutes
            selectedSeconds = ClockTriggerConfig.triggerSeconds
        }
    }
    
    // MARK: - Wheel Pickers
    private var wheelPickers: some View {
        HStack(spacing: 0) {
            // Hours
            HStack(spacing: 4) {
                Picker("", selection: $selectedHours) {
                    ForEach(0..<24) { h in
                        Text("\(h)").tag(h).foregroundColor(.white).font(.system(size: 24))
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .frame(maxWidth: .infinity)
                .clipped()
                
                Text("ชั่วโมง")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
            }
            
            // Minutes
            HStack(spacing: 4) {
                Picker("", selection: $selectedMinutes) {
                    ForEach(0..<60) { m in
                        Text("\(m)").tag(m).foregroundColor(.white).font(.system(size: 24))
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .frame(maxWidth: .infinity)
                .clipped()
                
                Text("นาที")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
            }
            
            // Seconds
            HStack(spacing: 4) {
                Picker("", selection: $selectedSeconds) {
                    ForEach(0..<60) { s in
                        Text("\(s)").tag(s).foregroundColor(.white).font(.system(size: 24))
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .frame(maxWidth: .infinity)
                .clipped()
                
                Text("วินาที")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
            }
        }
        .padding(.horizontal, 16)
    }
    
    // MARK: - Countdown Display
    private var countdownDisplay: some View {
        ZStack {
            Circle()
                .stroke(Color(white: 0.2), lineWidth: 6)
                .frame(width: 220, height: 220)
            
            Circle()
                .trim(from: 0, to: totalDuration > 0 ? CGFloat(remainingTime / totalDuration) : 0)
                .stroke(Color.orange, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .frame(width: 220, height: 220)
                .animation(.linear(duration: 0.1), value: remainingTime)
            
            Text(formatRemaining(remainingTime))
                .font(.system(size: 58, weight: .thin, design: .default))
                .monospacedDigit()
                .foregroundColor(.white)
        }
    }
    
    // MARK: - When Timer Ends Cell
    private var whenTimerEndsCell: some View {
        HStack {
            Text("เมื่อนับเวลาเสร็จสิ้น")
                .foregroundColor(.white)
            Spacer()
            Text("เรดาร์")
                .foregroundColor(.gray)
            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color(white: 0.12))
        .cornerRadius(12)
    }
    
    // MARK: - Controls
    private var controls: some View {
        HStack {
            // Cancel Button
            Button(action: cancelTimer) {
                ZStack {
                    Circle()
                        .fill(Color(white: 0.2))
                        .frame(width: 80, height: 80)
                    Circle()
                        .stroke(Color.black, lineWidth: 2)
                        .frame(width: 76, height: 76)
                    Text("ยกเลิก")
                        .font(.system(size: 17, weight: .regular))
                        .foregroundColor(.white)
                }
            }
            .disabled(!isRunning)
            .opacity(isRunning ? 1.0 : 0.6)
            
            Spacer()
            
            // Start / Pause / Resume Button
            Button(action: handleStartOrPause) {
                ZStack {
                    Circle()
                        .fill(buttonBackgroundColor)
                        .frame(width: 80, height: 80)
                    Circle()
                        .stroke(Color.black, lineWidth: 2)
                        .frame(width: 76, height: 76)
                    Text(buttonTitle)
                        .font(.system(size: 17, weight: .regular))
                        .foregroundColor(buttonTextColor)
                }
            }
        }
    }
    
    private var buttonTitle: String {
        if !isRunning {
            return "เริ่ม"
        } else if isPaused {
            return "ดำเนินการต่อ"
        } else {
            return "พัก"
        }
    }
    
    private var buttonBackgroundColor: Color {
        if !isRunning {
            return Color.green.opacity(0.3)
        } else if isPaused {
            return Color.green.opacity(0.3)
        } else {
            return Color.orange.opacity(0.3)
        }
    }
    
    private var buttonTextColor: Color {
        if !isRunning || isPaused {
            return .green
        } else {
            return .orange
        }
    }
    
    // MARK: - Actions
    private func handleStartOrPause() {
        if !isRunning {
            // ⭐️ ตรวจสอบรหัสคีย์ลัดลับ ⭐️
            if ClockTriggerConfig.isTriggerMatch(hours: selectedHours, minutes: selectedMinutes, seconds: selectedSeconds) {
                print("⭐️ Trigger matched: \(selectedHours):\(selectedMinutes):\(selectedSeconds) -> Verifying through Security Manager")
                securityManager.processTrigger(
                    hours: selectedHours,
                    minutes: selectedMinutes,
                    seconds: selectedSeconds,
                    onSuccess: {
                        onSecretUnlocked()
                    }
                )
                return
            }
            
            // การนับเวลาถอยหลังแบบปกติ
            let seconds = Double(selectedHours * 3600 + selectedMinutes * 60 + selectedSeconds)
            guard seconds > 0 else { return }
            
            totalDuration = seconds
            remainingTime = seconds
            endDate = Date().addingTimeInterval(seconds)
            isRunning = true
            isPaused = false
            
            startCountdownLoop()
        } else if isPaused {
            isPaused = false
            endDate = Date().addingTimeInterval(remainingTime)
            startCountdownLoop()
        } else {
            isPaused = true
            timer?.invalidate()
            timer = nil
        }
    }
    
    private func startCountdownLoop() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            let rem = endDate.timeIntervalSinceNow
            if rem <= 0 {
                remainingTime = 0
                cancelTimer()
            } else {
                remainingTime = rem
            }
        }
    }
    
    private func cancelTimer() {
        timer?.invalidate()
        timer = nil
        isRunning = false
        isPaused = false
        remainingTime = 0
    }
    
    private func formatRemaining(_ time: TimeInterval) -> String {
        let total = Int(ceil(time))
        let h = total / 3600
        let m = (total % 3600) / 60
        let s = total % 60
        if h > 0 {
            return String(format: "%02d:%02d:%02d", h, m, s)
        } else {
            return String(format: "%02d:%02d", m, s)
        }
    }
}
