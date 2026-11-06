import Foundation
import UIKit

// MARK: - Pakin Epic App Bridge
public final class PakinEpicAppBridge {
    public static let shared = PakinEpicAppBridge()
    
    // URL Scheme ที่ลงทะเบียนไว้ใน Info.plist ของ PAKIN EPIC
    // (อ้างอิงจาก CFBundleURLSchemes ใน Payload/PAKIN_EPIC.app/Info.plist)
    public let registeredScheme = "threeoneosfive"
    
    private init() {}
    
    // MARK: - สั่งเปิดแอป PAKIN EPIC พร้อมส่ง Handover Token
    public func openPakinEpic(completion: @escaping (Bool) -> Void) {
        let timestamp = Int(Date().timeIntervalSince1970)
        let nonce = UUID().uuidString.prefix(8)
        let handoverToken = "TP-\(timestamp)-\(nonce)"
        
        // รูปแบบ Deep link: threeoneosfive://launch?token=...&source=timeparkin
        guard let url = URL(string: "\(registeredScheme)://launch?token=\(handoverToken)&source=timeparkin") else {
            completion(false)
            return
        }
        
        DispatchQueue.main.async {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:]) { success in
                    print("[PakinEpicAppBridge] Open app result: \(success)")
                    completion(success)
                }
            } else {
                print("[PakinEpicAppBridge] Application with scheme \(self.registeredScheme):// is not installed or query scheme not registered.")
                completion(false)
            }
        }
    }
}
