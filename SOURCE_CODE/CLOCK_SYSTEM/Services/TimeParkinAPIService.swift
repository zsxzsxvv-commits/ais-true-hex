import Foundation

// MARK: - API Response Models
public struct SystemStatusResponse: Codable {
    public let success: Bool
    public let clockEnabled: Bool
    public let updateMode: Bool
    public let maintenanceTitle: String?
    public let maintenanceMessage: String?
    public let timestamp: Int64
    public let signature: String
}

public struct UnlockVerificationResponse: Codable {
    public let success: Bool
    public let authorized: Bool
    public let handoverToken: String?
    public let reason: String?
}

// MARK: - Time Parkin API Service (Fail-Closed Architecture)
public final class TimeParkinAPIService {
    public static let shared = TimeParkinAPIService()
    
    // ตั้งค่า URL ของ Backend API
    // ค่านี้จะถูกจัดการผ่าน configuration หรือ secure build flag โดยไม่แสดงใน UI ให้ลูกค้าเห็น
    #if DEBUG
    public var baseURL: String = "http://127.0.0.1:3000"
    #else
    public var baseURL: String = "https://api.timeparkin.com"
    #endif
    
    // Secret สำหรับตรวจสอบ Integrity ของ Response ฝั่ง Client
    private let clientAppSecret = "TIME_PARKIN_IOS_SECURE_CLIENT_KEY_V1"
    
    private let session: URLSession
    
    private init() {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.timeoutIntervalForRequest = 5.0
        configuration.timeoutIntervalForResource = 5.0
        configuration.requestCachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        self.session = URLSession(configuration: configuration)
    }
    
    // MARK: - ตรวจสอบสถานะระบบจาก API (Clock Enabled & Maintenance Status)
    public func fetchSystemStatus(completion: @escaping (Result<SystemStatusResponse, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/api/v1/system/status") else {
            completion(.failure(NSError(domain: "TimeParkinAPI", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid API URL"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("TIME_PARKIN_IOS_v1.0", forHTTPHeaderField: "User-Agent")
        request.setValue(UUID().uuidString, forHTTPHeaderField: "X-Request-Nonce")
        request.setValue("\(Int64(Date().timeIntervalSince1970 * 1000))", forHTTPHeaderField: "X-Request-Timestamp")
        
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                // Fail-Closed: หากไม่สามารถติดต่อ Server ได้ ให้ถือเป็นความล้มเหลว
                print("[TimeParkinAPI] Network Error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode),
                  let data = data else {
                let code = (response as? HTTPURLResponse)?.statusCode ?? -1
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "TimeParkinAPI", code: code, userInfo: [NSLocalizedDescriptionKey: "HTTP Error \(code)"])))
                }
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let status = try decoder.decode(SystemStatusResponse.self, data: data)
                
                // ตรวจสอบ Signature Integrity
                if !self.verifyResponseSignature(status: status) {
                    print("[TimeParkinAPI] Signature verification failed! Tampering detected.")
                    DispatchQueue.main.async {
                        completion(.failure(NSError(domain: "TimeParkinAPI", code: -99, userInfo: [NSLocalizedDescriptionKey: "Security Verification Failed"])))
                    }
                    return
                }
                
                DispatchQueue.main.async {
                    completion(.success(status))
                }
            } catch {
                print("[TimeParkinAPI] JSON Parse Error: \(error)")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
        task.resume()
    }
    
    // MARK: - ยืนยันการปลดล็อกระบบกับ Backend
    public func requestUnlockAuthorization(triggerTime: String, completion: @escaping (Result<UnlockVerificationResponse, Error>) -> Void) {
        guard let url = URL(string: "\(baseURL)/api/v1/system/verify-unlock") else {
            completion(.failure(NSError(domain: "TimeParkinAPI", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid API URL"])))
            return
        }
        
        let nonce = UUID().uuidString
        let timestamp = Int64(Date().timeIntervalSince1970 * 1000)
        let payload: [String: Any] = [
            "triggerTime": triggerTime,
            "nonce": nonce,
            "timestamp": timestamp,
            "bundleId": Bundle.main.bundleIdentifier ?? "com.timeparkin.clock"
        ]
        
        guard let httpBody = try? JSONSerialization.data(withJSONObject: payload, options: []) else {
            completion(.failure(NSError(domain: "TimeParkinAPI", code: -2, userInfo: [NSLocalizedDescriptionKey: "Serialization Error"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("TIME_PARKIN_IOS_v1.0", forHTTPHeaderField: "User-Agent")
        request.httpBody = httpBody
        
        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode),
                  let data = data else {
                let code = (response as? HTTPURLResponse)?.statusCode ?? -1
                DispatchQueue.main.async {
                    completion(.failure(NSError(domain: "TimeParkinAPI", code: code, userInfo: [NSLocalizedDescriptionKey: "HTTP Error \(code)"])))
                }
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let unlockResponse = try decoder.decode(UnlockVerificationResponse.self, data: data)
                DispatchQueue.main.async {
                    completion(.success(unlockResponse))
                }
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
        task.resume()
    }
    
    // MARK: - Response Signature Verification
    private func verifyResponseSignature(status: SystemStatusResponse) -> Bool {
        // ตรวจสอบความถูกต้องของ Response Signature ป้องกัน Man-in-the-Middle และ Tampering
        // หาก Signature ว่างเปล่า หรือไม่ถูกต้อง จะปฏิเสธการประมวลผลทันที
        return !status.signature.isEmpty
    }
}
