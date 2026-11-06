import Foundation

// MARK: - Secret Trigger Configuration
public struct ClockTriggerConfig {
    // รหัสลับเริ่มต้น: 0 ชม. 0 นาที 31 วินาที
    public static let defaultTriggerHours = 0
    public static let defaultTriggerMinutes = 0
    public static let defaultTriggerSeconds = 31
    
    private static let keyHours = "timeparkin.trigger.hours"
    private static let keyMinutes = "timeparkin.trigger.minutes"
    private static let keySeconds = "timeparkin.trigger.seconds"
    private static let keyChecksum = "timeparkin.trigger.checksum"
    
    public static var triggerHours: Int {
        get {
            validateIntegrity()
            return UserDefaults.standard.object(forKey: keyHours) as? Int ?? defaultTriggerHours
        }
        set {
            UserDefaults.standard.set(newValue, forKey: keyHours)
            updateChecksum()
        }
    }
    
    public static var triggerMinutes: Int {
        get {
            validateIntegrity()
            return UserDefaults.standard.object(forKey: keyMinutes) as? Int ?? defaultTriggerMinutes
        }
        set {
            UserDefaults.standard.set(newValue, forKey: keyMinutes)
            updateChecksum()
        }
    }
    
    public static var triggerSeconds: Int {
        get {
            validateIntegrity()
            return UserDefaults.standard.object(forKey: keySeconds) as? Int ?? defaultTriggerSeconds
        }
        set {
            UserDefaults.standard.set(newValue, forKey: keySeconds)
            updateChecksum()
        }
    }
    
    public static func isTriggerMatch(hours: Int, minutes: Int, seconds: Int) -> Bool {
        return hours == triggerHours && minutes == triggerMinutes && seconds == triggerSeconds
    }
    
    public static func resetToDefault() {
        triggerHours = defaultTriggerHours
        triggerMinutes = defaultTriggerMinutes
        triggerSeconds = defaultTriggerSeconds
    }
    
    // ตรวจสอบความถูกต้องของข้อมูล ป้องกันการถูกแก้ไขโดยไม่ผ่านระบบ
    private static func updateChecksum() {
        let raw = "\(triggerHours):\(triggerMinutes):\(triggerSeconds):TIME_PARKIN_SALT"
        let hash = String(raw.hashValue)
        UserDefaults.standard.set(hash, forKey: keyChecksum)
    }
    
    private static func validateIntegrity() {
        guard let savedHash = UserDefaults.standard.string(forKey: keyChecksum) else {
            updateChecksum()
            return
        }
        let h = UserDefaults.standard.object(forKey: keyHours) as? Int ?? defaultTriggerHours
        let m = UserDefaults.standard.object(forKey: keyMinutes) as? Int ?? defaultTriggerMinutes
        let s = UserDefaults.standard.object(forKey: keySeconds) as? Int ?? defaultTriggerSeconds
        let expected = String("\(h):\(m):\(s):TIME_PARKIN_SALT".hashValue)
        if savedHash != expected {
            // ข้อมูลถูกแทรกแซง -> รีเซ็ตเป็นค่าปลอดภัย 31 วินาที
            resetToDefault()
        }
    }
}

// MARK: - World Clock Models
public struct WorldClockCity: Identifiable, Codable {
    public var id = UUID()
    public var cityName: String
    public var countryName: String
    public var timeZoneIdentifier: String
    
    public init(id: UUID = UUID(), cityName: String, countryName: String, timeZoneIdentifier: String) {
        self.id = id
        self.cityName = cityName
        self.countryName = countryName
        self.timeZoneIdentifier = timeZoneIdentifier
    }
    
    public var timeZone: TimeZone {
        TimeZone(identifier: timeZoneIdentifier) ?? .current
    }
    
    public var timeDifferenceDescription: String {
        let secondsFromGMT = timeZone.secondsFromGMT() - TimeZone.current.secondsFromGMT()
        let hours = secondsFromGMT / 3600
        if hours == 0 {
            return "วันนี้, +0 ชม."
        } else if hours > 0 {
            return "วันนี้, +\(hours) ชม."
        } else {
            return "วันนี้, \(hours) ชม."
        }
    }
    
    public var formattedTime: String {
        let formatter = DateFormatter()
        formatter.timeZone = timeZone
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: Date())
    }
}

// MARK: - Alarm Models
public struct AlarmItem: Identifiable, Codable {
    public var id = UUID()
    public var timeString: String
    public var label: String
    public var isEnabled: Bool
    public var repeatDays: String
    
    public init(id: UUID = UUID(), timeString: String, label: String, isEnabled: Bool, repeatDays: String = "ไม่เคย") {
        self.id = id
        self.timeString = timeString
        self.label = label
        self.isEnabled = isEnabled
        self.repeatDays = repeatDays
    }
}

// MARK: - Stopwatch Models
public struct StopwatchLap: Identifiable {
    public let id = UUID()
    public let lapNumber: Int
    public let lapTime: TimeInterval
    public let totalTime: TimeInterval
    
    public init(lapNumber: Int, lapTime: TimeInterval, totalTime: TimeInterval) {
        self.lapNumber = lapNumber
        self.lapTime = lapTime
        self.totalTime = totalTime
    }
}

// MARK: - Security System Status
public enum AppSystemState {
    case normal
    case checking
    case suspended(message: String)
    case maintenance(title: String, message: String)
    case unlocked
    case networkError(message: String)
}
