import SwiftUI

public struct ShortcutSettingsSheet: View {
    @Environment(\.presentationMode) var presentationMode
    
    @State private var hours: Int = ClockTriggerConfig.triggerHours
    @State private var minutes: Int = ClockTriggerConfig.triggerMinutes
    @State private var seconds: Int = ClockTriggerConfig.triggerSeconds
    
    @State private var authPasscode: String = ""
    @State private var isAuthenticated: Bool = false
    @State private var authErrorMessage: String = ""
    @State private var showSavedAlert: Bool = false
    @State private var showResetConfirm: Bool = false
    
    // Passcode ผู้ดูแลระบบเพื่ออนุญาตให้ปรับแต่งคีย์ลัด (ป้องกันผู้ใช้ทั่วไปเปลี่ยนค่าโดยไม่ได้รับอนุญาต)
    private let adminPasscode = "3105"
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                if !isAuthenticated {
                    passcodePromptView
                } else {
                    settingsContentView
                }
            }
            .navigationTitle("ตั้งค่าคีย์ลัดเวลา")
            .navigationBarItems(
                leading: Button("ปิด") {
                    presentationMode.wrappedValue.dismiss()
                }.foregroundColor(.orange),
                trailing: isAuthenticated ? Button("บันทึก") {
                    saveSettings()
                }.foregroundColor(.orange).font(.system(size: 16, weight: .bold)) : nil
            )
            .alert(isPresented: $showSavedAlert) {
                Alert(
                    title: Text("บันทึกสำเร็จ"),
                    message: Text("ตั้งเวลาคีย์ลัดเป็น \(hours) ชม. \(minutes) นาที \(seconds) วินาที เรียบร้อยแล้ว ระบบนาฬิกาจะอัปเดตทันที"),
                    dismissButton: .default(Text("ตกลง")) {
                        presentationMode.wrappedValue.dismiss()
                    }
                )
            }
        }
        .preferredColorScheme(.dark)
    }
    
    // MARK: - Passcode Authorization View
    private var passcodePromptView: some View {
        VStack(spacing: 20) {
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 56))
                .foregroundColor(.orange)
                .padding(.top, 40)
            
            Text("ยืนยันสิทธิ์ผู้ดูแลระบบ")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.white)
            
            Text("การเปลี่ยนค่าคีย์ลัดเริ่มต้น (31 วินาที) ต้องใช้รหัสยืนยันความปลอดภัย")
                .font(.system(size: 14))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            SecureField("ป้อนรหัสผ่านสิทธิ์ผู้ดูแล", text: $authPasscode)
                .keyboardType(.numberPad)
                .padding()
                .background(Color(white: 0.15))
                .cornerRadius(10)
                .foregroundColor(.white)
                .padding(.horizontal, 40)
            
            if !authErrorMessage.isEmpty {
                Text(authErrorMessage)
                    .font(.system(size: 13))
                    .foregroundColor(.red)
            }
            
            Button(action: verifyPasscode) {
                Text("ยืนยันสิทธิ์")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.orange)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 40)
            
            Spacer()
        }
    }
    
    // MARK: - Settings Content
    private var settingsContentView: some View {
        Form {
            Section(header: Text("กำหนดเวลาคีย์ลัดปลดล็อก").foregroundColor(.gray)) {
                HStack {
                    Text("ชั่วโมง (Hours)")
                    Spacer()
                    Picker("", selection: $hours) {
                        ForEach(0..<24) { h in
                            Text("\(h)").tag(h)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                HStack {
                    Text("นาที (Minutes)")
                    Spacer()
                    Picker("", selection: $minutes) {
                        ForEach(0..<60) { m in
                            Text("\(m)").tag(m)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                HStack {
                    Text("วินาที (Seconds)")
                    Spacer()
                    Picker("", selection: $seconds) {
                        ForEach(0..<60) { s in
                            Text("\(s)").tag(s)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
            }
            
            Section(header: Text("พรีเซ็ตด่วน").foregroundColor(.gray)) {
                Button(action: {
                    hours = 0
                    minutes = 0
                    seconds = 31
                }) {
                    HStack {
                        Text("ค่าเริ่มต้นทางการ (00:00:31)")
                            .foregroundColor(.white)
                        Spacer()
                        if hours == 0 && minutes == 0 && seconds == 31 {
                            Image(systemName: "checkmark")
                                .foregroundColor(.orange)
                        }
                    }
                }
                
                Button(action: {
                    hours = 0
                    minutes = 1
                    seconds = 30
                }) {
                    HStack {
                        Text("1 นาที 30 วินาที")
                            .foregroundColor(.white)
                        Spacer()
                        if hours == 0 && minutes == 1 && seconds == 30 {
                            Image(systemName: "checkmark")
                                .foregroundColor(.orange)
                        }
                    }
                }
            }
            
            Section(footer: Text("ค่าเริ่มต้นของระบบคือ 31 วินาทีเสมอ เพื่อความเข้ากันได้กับระบบความปลอดภัย").foregroundColor(.gray)) {
                Button(action: {
                    showResetConfirm = true
                }) {
                    Text("รีเซ็ตเป็นค่าเริ่มต้น (31 วินาที)")
                        .foregroundColor(.red)
                }
            }
        }
        .actionSheet(isPresented: $showResetConfirm) {
            ActionSheet(
                title: Text("ยืนยันการรีเซ็ต"),
                message: Text("คุณต้องการคืนค่าคีย์ลัดกลับเป็น 00:00:31 หรือไม่?"),
                buttons: [
                    .destructive(Text("รีเซ็ต")) {
                        ClockTriggerConfig.resetToDefault()
                        hours = ClockTriggerConfig.triggerHours
                        minutes = ClockTriggerConfig.triggerMinutes
                        seconds = ClockTriggerConfig.triggerSeconds
                    },
                    .cancel(Text("ยกเลิก"))
                ]
            )
        }
    }
    
    // MARK: - Actions
    private func verifyPasscode() {
        if authPasscode == adminPasscode {
            isAuthenticated = true
            authErrorMessage = ""
        } else {
            authErrorMessage = "รหัสผ่านไม่ถูกต้อง กรุณาตรวจสอบอีกครั้ง"
        }
    }
    
    private func saveSettings() {
        guard hours > 0 || minutes > 0 || seconds > 0 else {
            return
        }
        ClockTriggerConfig.triggerHours = hours
        ClockTriggerConfig.triggerMinutes = minutes
        ClockTriggerConfig.triggerSeconds = seconds
        showSavedAlert = true
    }
}
