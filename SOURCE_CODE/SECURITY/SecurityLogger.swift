import Foundation

// MARK: - Client Security Event Logger
public struct SecurityEvent: Codable {
    public let eventType: String
    public let details: String
    public let timestamp: Date
    public let deviceModel: String
    public let osVersion: String
}

public final class SecurityLogger {
    public static let shared = SecurityLogger()
    
    private var events: [SecurityEvent] = []
    private let queue = DispatchQueue(label: "com.timeparkin.security.logger", qos: .utility)
    
    private init() {}
    
    public func logViolation(type: String, details: String) {
        queue.async {
            let event = SecurityEvent(
                eventType: type,
                details: details,
                timestamp: Date(),
                deviceModel: "iOS Device",
                osVersion: ProcessInfo.processInfo.operatingSystemVersionString
            )
            self.events.append(event)
            print("[SECURITY VIOLATION] [\(type)] \(details)")
        }
    }
    
    public func getRecentEvents() -> [SecurityEvent] {
        return queue.sync {
            return self.events
        }
    }
}
