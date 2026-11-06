import SwiftUI

public struct ClockRootView: View {
    @State private var selectedTab = 3 // เริ่มต้นที่แท็บ 4: นับถอยหลัง (Timer)
    public var onSecretUnlocked: () -> Void
    
    public init(onSecretUnlocked: @escaping () -> Void = {}) {
        self.onSecretUnlocked = onSecretUnlocked
    }
    
    public var body: some View {
        TabView(selection: $selectedTab) {
            WorldClockView()
                .tabItem {
                    Label("นาฬิกาโลก", systemImage: "globe")
                }
                .tag(0)
            
            AlarmsView()
                .tabItem {
                    Label("การปลุก", systemImage: "alarm.fill")
                }
                .tag(1)
            
            StopwatchView()
                .tabItem {
                    Label("นาฬิกาจับเวลา", systemImage: "stopwatch.fill")
                }
                .tag(2)
            
            TimerCountdownView(onSecretUnlocked: onSecretUnlocked)
                .tabItem {
                    Label("นับถอยหลัง", systemImage: "timer")
                }
                .tag(3)
        }
        .accentColor(.orange)
        .preferredColorScheme(.dark)
    }
}
