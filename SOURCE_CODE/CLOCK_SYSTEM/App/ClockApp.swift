import SwiftUI

@main
struct ClockApp: App {
    @StateObject private var securityManager = ClockSecurityManager.shared
    @State private var isUnlocked: Bool = false
    @State private var showPakinEpicEmbedded: Bool = false
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                // 1. หน้าต่างหลัก: แอปนาฬิกา 4 แท็บ สไตล์ iOS ดั้งเดิม
                ClockRootView(onSecretUnlocked: {
                    print("⭐️ TIME PARKIN: Secret Code Triggered & Verified!")
                    withAnimation(.easeInOut(duration: 0.35)) {
                        isUnlocked = true
                    }
                    
                    // สั่งเชื่อมต่อไปยังแอป PAKIN EPIC ผ่าน URL Scheme หรือเปิดหน้าต่างเชื่อมต่อ
                    PakinEpicAppBridge.shared.openPakinEpic { success in
                        if !success {
                            // กรณีแอป PAKIN EPIC ยังไม่ได้ติดตั้ง ให้เปิดหน้าต่าง License ในตัว
                            showPakinEpicEmbedded = true
                        }
                    }
                })
                
                // 2. หน้าต่างบำรุงรักษา (เมื่อผู้ดูแลปิดระบบอัปเดตผ่าน Discord)
                if case .maintenance(let title, let message) = securityManager.currentState {
                    MaintenanceView(title: title, message: message) {
                        withAnimation {
                            securityManager.dismissState()
                        }
                    }
                    .transition(.opacity)
                    .zIndex(100)
                }
                
                // 3. หน้าต่างระบบถูกระงับ (เมื่อผู้ดูแลปิดระบบนาฬิกาผ่าน Discord)
                if case .suspended(let message) = securityManager.currentState {
                    ZStack {
                        Color.black.ignoresSafeArea()
                        
                        VStack(spacing: 24) {
                            Image(systemName: "slash.circle.fill")
                                .font(.system(size: 72))
                                .foregroundColor(.red)
                            
                            Text("ระบบถูกระงับ")
                                .font(.system(size: 26, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text(message)
                                .font(.system(size: 15))
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 32)
                            
                            Button(action: {
                                withAnimation {
                                    securityManager.dismissState()
                                }
                            }) {
                                Text("ตกลง")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 32)
                                    .padding(.vertical, 14)
                                    .background(Color(white: 0.2))
                                    .cornerRadius(12)
                            }
                        }
                    }
                    .transition(.opacity)
                    .zIndex(101)
                }
                
                // 4. หน้าต่าง Network Error (Fail-Closed)
                if case .networkError(let message) = securityManager.currentState {
                    ZStack {
                        Color.black.opacity(0.85).ignoresSafeArea()
                        
                        VStack(spacing: 20) {
                            Image(systemName: "wifi.exclamationmark")
                                .font(.system(size: 60))
                                .foregroundColor(.orange)
                            
                            Text("ข้อผิดพลาดความปลอดภัย")
                                .font(.system(size: 22, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text(message)
                                .font(.system(size: 14))
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 30)
                            
                            Button(action: {
                                withAnimation {
                                    securityManager.dismissState()
                                }
                            }) {
                                Text("กลับไปหน้านาฬิกา")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 28)
                                    .padding(.vertical, 12)
                                    .background(Color.orange)
                                    .cornerRadius(10)
                            }
                        }
                        .padding(28)
                        .background(Color(white: 0.12))
                        .cornerRadius(18)
                        .padding(.horizontal, 24)
                    }
                    .transition(.opacity)
                    .zIndex(102)
                }
                
                // 5. หน้าต่างปลดล็อกสำเร็จ (เชื่อมต่อ PAKIN EPIC)
                if isUnlocked && showPakinEpicEmbedded {
                    PakinEpicIntegratedView(onBackToClock: {
                        withAnimation {
                            isUnlocked = false
                            showPakinEpicEmbedded = false
                            securityManager.dismissState()
                        }
                    })
                    .transition(.opacity)
                    .zIndex(50)
                }
            }
            .preferredColorScheme(.dark)
        }
    }
}
