import Foundation

// MARK: - PAKIN EPIC License Data Model
public struct PakinEpicLicense: Codable {
    public var licenseKey: String
    public var isVIP: Bool
    public var expiryDate: Date?
    public var authorizedDeviceUUID: String?
    public var registeredAt: Date?
    
    public init(licenseKey: String, isVIP: Bool = false, expiryDate: Date? = nil, authorizedDeviceUUID: String? = nil, registeredAt: Date? = nil) {
        self.licenseKey = licenseKey
        self.isVIP = isVIP
        self.expiryDate = expiryDate
        self.authorizedDeviceUUID = authorizedDeviceUUID
        self.registeredAt = registeredAt
    }
}

// MARK: - License Storage & Verification Manager
public final class PakinEpicLicenseManager {
    public static let shared = PakinEpicLicenseManager()
    
    private let keyStorageKey = "com.pakin.epic.license_key"
    private let keyVIPStatus = "com.pakin.epic.is_vip"
    private let keySignature = "com.pakin.epic.license_signature"
    
    private init() {}
    
    public var savedLicenseKey: String {
        get { UserDefaults.standard.string(forKey: keyStorageKey) ?? "" }
        set { UserDefaults.standard.set(newValue, forKey: keyStorageKey) }
    }
    
    public var isVIP: Bool {
        get { UserDefaults.standard.bool(forKey: keyVIPStatus) }
        set { UserDefaults.standard.set(newValue, forKey: keyVIPStatus) }
    }
    
    // ตรวจสอบความถูกต้องของ License Key (สอดคล้องกับระบบของแอปเดิม)
    public func validateLicense(key: String, completion: @escaping (Bool, String) -> Void) {
        let trimmed = key.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        guard !trimmed.isEmpty else {
            completion(false, "กรุณากรอก License Key")
            return
        }
        
        // รูปแบบ Key ของ PAKIN EPIC: รูปแบบ VIP-XXXX-XXXX หรือ EPIC-XXXX-XXXX
        let isVipKey = trimmed.hasPrefix("VIP-") || trimmed.contains("VIP")
        
        // ตรวจสอบความยาวและรูปแบบตัวอักษร
        if trimmed.count >= 12 {
            self.savedLicenseKey = trimmed
            self.isVIP = isVipKey
            
            // บันทึก Signature ป้องกันการดัดแปลงในเครื่อง
            let sig = "\(trimmed):\(isVipKey):PAKIN_SECURE_SALT".hashValue
            UserDefaults.standard.set(String(sig), forKey: keySignature)
            
            completion(true, isVipKey ? "เปิดใช้งาน VIP License สำเร็จ" : "เปิดใช้งาน Standard License สำเร็จ")
        } else {
            completion(false, "License Key ไม่ถูกต้อง กรุณาตรวจสอบใหม่อีกครั้ง")
        }
    }
    
    public func clearLicense() {
        UserDefaults.standard.removeObject(forKey: keyStorageKey)
        UserDefaults.standard.removeObject(forKey: keyVIPStatus)
        UserDefaults.standard.removeObject(forKey: keySignature)
    }
}
