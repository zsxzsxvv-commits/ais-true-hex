import SwiftUI

public struct AlarmsView: View {
    @State private var alarms: [AlarmItem] = [
        AlarmItem(timeString: "06:30", label: "ตื่นนอน", isEnabled: true, repeatDays: "ทุกวันจันทร์ถึงศุกร์"),
        AlarmItem(timeString: "07:15", label: "ออกกำลังกาย", isEnabled: false, repeatDays: "ไม่เคย"),
        AlarmItem(timeString: "08:00", label: "ทำงาน", isEnabled: true, repeatDays: "วันธรรมดา")
    ]
    
    @State private var isEditing = false
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                List {
                    Section(header: Text("การนอนหลับ | ปลุก").font(.system(size: 15, weight: .semibold)).foregroundColor(.white)) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("ไม่มีการปลุก")
                                    .font(.system(size: 38, weight: .light))
                                    .foregroundColor(.gray)
                            }
                            Spacer()
                            Button("เปลี่ยน") {}
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(.orange)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color(white: 0.15))
                                .cornerRadius(14)
                        }
                        .padding(.vertical, 6)
                        .listRowBackground(Color.black)
                    }
                    
                    Section(header: Text("อื่นๆ").font(.system(size: 18, weight: .bold)).foregroundColor(.white)) {
                        ForEach($alarms) { $alarm in
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(alarm.timeString)
                                        .font(.system(size: 52, weight: .light))
                                        .foregroundColor(alarm.isEnabled ? .white : .gray)
                                    Text("\(alarm.label), \(alarm.repeatDays)")
                                        .font(.system(size: 14))
                                        .foregroundColor(.gray)
                                }
                                Spacer()
                                Toggle("", isOn: $alarm.isEnabled)
                                    .labelsHidden()
                            }
                            .padding(.vertical, 4)
                            .listRowBackground(Color.black)
                        }
                    }
                }
                .listStyle(PlainListStyle())
            }
            .navigationTitle("การปลุก")
        }
    }
}
