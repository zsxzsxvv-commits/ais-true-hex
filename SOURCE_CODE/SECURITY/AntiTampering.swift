import Foundation
import MachO

// MARK: - Production-Grade Anti-Tampering Check
public struct AntiTamperingCheck {
    
    // ตรวจสอบความปลอดภัยโดยรวม
    public static func isCompromised() -> Bool {
        return isJailbroken() || isDebuggerAttached() || isDynamicLibraryInjected()
    }
    
    // 1. Jailbreak Detection
    public static func isJailbroken() -> Bool {
        #if targetEnvironment(simulator)
        return false
        #else
        // ตรวจสอบไฟล์ระบบที่มักพบในเครื่อง Jailbroken
        let suspiciousPaths = [
            "/Applications/Cydia.app",
            "/Library/MobileSubstrate/MobileSubstrate.dylib",
            "/bin/bash",
            "/usr/sbin/sshd",
            "/etc/apt",
            "/private/var/lib/apt/",
            "/usr/bin/ssh",
            "/var/jb",
            "/var/binpack"
        ]
        
        for path in suspiciousPaths {
            if FileManager.default.fileExists(atPath: path) {
                return true
            }
        }
        
        // ทดสอบเขียนไฟล์นอก Sandbox
        let testPath = "/private/jailbreak_test_\(UUID().uuidString).txt"
        do {
            try "test".write(toFile: testPath, atomically: true, encoding: .utf8)
            try? FileManager.default.removeItem(atPath: testPath)
            return true
        } catch {
            // เขียนไม่สำเร็จ = อยู่ใน Sandbox ปกติ
        }
        
        return false
        #endif
    }
    
    // 2. Debugger Detection (Anti-Debugging via sysctl)
    public static func isDebuggerAttached() -> Bool {
        var info = kinfo_proc()
        var mib: [Int32] = [CTL_KERN, KERN_PROC, KERN_PROC_PID, getpid()]
        var size = MemoryLayout<kinfo_proc>.stride
        let junk = sysctl(&mib, UInt32(mib.count), &info, &size, nil, 0)
        if junk != 0 {
            return false
        }
        return (info.kp_proc.p_flag & P_TRACED) != 0
    }
    
    // 3. Dynamic Library Injection Detection (Frida, Cycript, Substrate)
    public static func isDynamicLibraryInjected() -> Bool {
        let count = _dyld_image_count()
        let blacklistedLibs = [
            "frida",
            "cydia",
            "substrate",
            "substitute",
            "cycript",
            "sslkillswitch",
            "shadow"
        ]
        
        for i in 0..<count {
            if let imageName = _dyld_get_image_name(i) {
                let name = String(cString: imageName).lowercased()
                for blacklisted in blacklistedLibs {
                    if name.contains(blacklisted) {
                        return true
                    }
                }
            }
        }
        return false
    }
}
