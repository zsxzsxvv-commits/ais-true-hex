import SwiftUI

public struct PakinEpicIntegratedView: View {
    @State private var licenseKeyInput: String = ""
    @State private var statusMessage: String = ""
    @State private var isSuccess: Bool = false
    @State private var showGearSettings: Bool = false
    @State private var isVIP: Bool = false
    
    public var onBackToClock: () -> Void
    
    public init(onBackToClock: @escaping () -> Void = {}) {
        self.onBackToClock = onBackToClock
    }
    
    public var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Top Bar with Gear Icon on the Right
                HStack {
                    Button(action: onBackToClock) {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                            Text("นาฬิกา")
                        }
                        .foregroundColor(.orange)
                        .font(.system(size: 16))
                    }
                    
                    Spacer()
                    
                    // ปุ่มรูปเฟืองด้านขวามือ (Gear Icon Button) ตามข้อกำหนดระบบ
                    Button(action: {
                        showGearSettings = true
                    }) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 22))
                            .foregroundColor(.orange)
                            .padding(8)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 12)
                
                Spacer()
                
                // App Logo & Branding
                VStack(spacing: 12) {
                    Image(systemName: isVIP ? "crown.fill" : "shield.checkered")
                        .font(.system(size: 64))
                        .foregroundColor(isVIP ? .yellow : .orange)
                    
                    Text("PAKIN EPIC")
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    
                    Text(isVIP ? "VIP PRIVILEGE ACTIVATED" : "SECURITY VERIFICATION")
                        .font(.system(size: 12, weight: .semibold, design: .monospaced))
                        .foregroundColor(isVIP ? .yellow : .gray)
                }
                
                // License Input Box
                VStack(spacing: 16) {
                    HStack {
                        Image(systemName: "key.fill")
                            .foregroundColor(.gray)
                        TextField("ป้อน License Key ของคุณ", text: $licenseKeyInput)
                            .autocapitalization(.allCharacters)
                            .disableAutocorrection(true)
                            .foregroundColor(.white)
                        
                        if !licenseKeyInput.isEmpty {
                            Button(action: { licenseKeyInput = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                    .padding()
                    .background(Color(white: 0.12))
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isVIP ? Color.yellow.opacity(0.6) : Color.white.opacity(0.1), lineWidth: 1)
                    )
                    
                    if !statusMessage.isEmpty {
                        Text(statusMessage)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(isSuccess ? .green : .red)
                            .multilineTextAlignment(.center)
                    }
                    
                    // Activate Button
                    Button(action: activateKey) {
                        Text("ยืนยัน License Key")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.orange)
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 28)
                
                // Features / Status Info
                VStack(spacing: 10) {
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("ระบบรักษาความปลอดภัยระดับองค์กร")
                            .font(.system(size: 13))
                            .foregroundColor(.gray)
                    }
                    HStack {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("รองรับคีย์ลัดอัตโนมัติ 00:00:31")
                            .font(.system(size: 13))
                            .foregroundColor(.gray)
                    }
                }
                .padding(.top, 16)
                
                Spacer()
            }
        }
        .sheet(isPresented: $showGearSettings) {
            ShortcutSettingsSheet()
        }
        .onAppear {
            let manager = PakinEpicLicenseManager.shared
            self.licenseKeyInput = manager.savedLicenseKey
            self.isVIP = manager.isVIP
        }
    }
    
    private func activateKey() {
        PakinEpicLicenseManager.shared.validateLicense(key: licenseKeyInput) { success, message in
            self.isSuccess = success
            self.statusMessage = message
            self.isVIP = PakinEpicLicenseManager.shared.isVIP
        }
    }
}
