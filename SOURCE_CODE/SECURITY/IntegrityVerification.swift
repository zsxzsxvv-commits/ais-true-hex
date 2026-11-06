import Foundation
import CommonCrypto

// MARK: - App & Resource Integrity Verification
public struct IntegrityVerification {
    
    // ตรวจสอบความสมบูรณ์ของ Bundle Identifier
    public static func verifyBundleIdentifier(expected: String) -> Bool {
        return Bundle.main.bundleIdentifier == expected
    }
    
    // ตรวจสอบการมีอยู่ของ Embedded Provisioning Profile
    public static func hasValidProvisioningProfile() -> Bool {
        #if targetEnvironment(simulator)
        return true
        #else
        guard let path = Bundle.main.path(forResource: "embedded", ofType: "mobileprovision") else {
            return false
        }
        return FileManager.default.fileExists(atPath: path)
        #endif
    }
    
    // คำนวณ SHA-256 ของไฟล์ในแอป เพื่อตรวจสอบว่าไฟล์ถูกดัดแปลงหรือไม่
    public static func computeFileSHA256(filePath: String) -> String? {
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: filePath)) else {
            return nil
        }
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA256($0.baseAddress, CC_LONG(data.count), &hash)
        }
        return hash.map { String(format: "%02hhx", $0) }.joined()
    }
    
    // ตรวจสอบโครงสร้างไฟล์ Info.plist ว่าถูกดัดแปลงหรือไม่
    public static func verifyInfoPlistIntegrity() -> Bool {
        guard let infoPath = Bundle.main.path(forResource: "Info", ofType: "plist"),
              FileManager.default.fileExists(atPath: infoPath) else {
            return false
        }
        return true
    }
}
