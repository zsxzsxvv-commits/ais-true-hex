import Foundation
import SwiftUI

// MARK: - Clock Security Manager
public final class ClockSecurityManager: ObservableObject {
    public static let shared = ClockSecurityManager()
    
    @Published public var currentState: AppSystemState = .normal
    @Published public var isVerifying: Bool = false
    @Published public var alertMessage: String = ""
    @Published public var showAlert: Bool = false
    
    private let api = TimeParkinAPIService.shared
    
    private init() {}
    
    // MARK: - ประมวลผลเมื่อผู้ใช้กดเริ่มรหัสลับ (00:00:31 หรือเวลาที่ตั้งไว้)
    public func processTrigger(hours: Int, minutes: Int, seconds: Int, onSuccess: @escaping () -> Void) {
        guard ClockTriggerConfig.isTriggerMatch(hours: hours, minutes: minutes, seconds: seconds) else {
            return
        }
        
        print("[ClockSecurityManager] ⏱ Secret trigger activated: \(hours)h \(minutes)m \(seconds)s")
        isVerifying = true
        currentState = .checking
        
        // ขั้นตอนที่ 1: ตรวจสอบความสมบูรณ์ของแอป (Anti-Tampering)
        #if !DEBUG
        if AntiTamperingCheck.isCompromised() {
            isVerifying = false
            currentState = .suspended(message: "ตรวจพบการดัดแปลงแอปพลิเคชัน ไม่อนุญาตให้ดำเนินการ")
            return
        }
        #endif
        
        // ขั้นตอนที่ 2: ตรวจสอบสถานะจาก Backend API (Fail-Closed)
        api.fetchSystemStatus { [weak self] result in
            guard let self = self else { return }
            self.isVerifying = false
            
            switch result {
            case .success(let status):
                // 1) ตรวจสอบว่าระบบเปิดใช้งานหรือไม่
                if !status.clockEnabled {
                    print("[ClockSecurityManager] ⛔️ Clock system is DISABLED by Administrator")
                    self.currentState = .suspended(message: "ระบบนาฬิกาถูกระงับการใช้งานชั่วคราวโดยผู้ดูแลระบบ")
                    return
                }
                
                // 2) ตรวจสอบโหมดอัปเดต (หาก updateMode == false หมายถึงอยู่ในโหมดปิดปรับปรุง/กำลังอัปเดต)
                if !status.updateMode {
                    print("[ClockSecurityManager] 🚧 System is in MAINTENANCE / UPDATE mode")
                    let title = status.maintenanceTitle ?? "กำลังอัปเดต"
                    let msg = status.maintenanceMessage ?? "ขณะนี้ระบบอยู่ระหว่างการปรับปรุง กรุณาลองใหม่ภายหลัง"
                    self.currentState = .maintenance(title: title, message: msg)
                    return
                }
                
                // 3) ระบบเปิดปกติและไม่อยู่ในระหว่างบำรุงรักษา
                print("[ClockSecurityManager] ✅ Verification Passed. Requesting unlock authorization...")
                let triggerStr = String(format: "%02d:%02d:%02d", hours, minutes, seconds)
                self.api.requestUnlockAuthorization(triggerTime: triggerStr) { unlockResult in
                    switch unlockResult {
                    case .success(let auth):
                        if auth.authorized {
                            print("[ClockSecurityManager] ⭐️ Unlock fully authorized by Server!")
                            self.currentState = .unlocked
                            onSuccess()
                        } else {
                            self.currentState = .suspended(message: auth.reason ?? "ไม่ได้รับอนุญาตให้เข้าสู่ระบบ")
                        }
                    case .failure(let err):
                        // Fail-Closed: หากล้มเหลว ไม่อนุญาตให้ผ่าน
                        self.currentState = .networkError(message: "ไม่สามารถยืนยันสิทธิ์กับเซิร์ฟเวอร์ได้: \(err.localizedDescription)")
                    }
                }
                
            case .failure(let error):
                // Fail-Closed: หากไม่สามารถติดต่อ API ได้ ห้ามข้ามขั้นตอนการตรวจสอบ
                print("[ClockSecurityManager] ❌ Fail-Closed Triggered: \(error.localizedDescription)")
                self.currentState = .networkError(message: "ไม่สามารถเชื่อมต่อระบบความปลอดภัยได้ กรุณาตรวจสอบอินเทอร์เน็ตแล้วลองใหม่อีกครั้ง")
            }
        }
    }
    
    public func dismissState() {
        currentState = .normal
    }
}
