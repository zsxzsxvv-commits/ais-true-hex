import SwiftUI

public struct MaintenanceView: View {
    public let title: String
    public let message: String
    public var onDismiss: () -> Void
    
    public init(
        title: String = "กำลังอัปเดต",
        message: String = "ขณะนี้ระบบอยู่ระหว่างการปรับปรุง กรุณาลองใหม่ภายหลัง",
        onDismiss: @escaping () -> Void = {}
    ) {
        self.title = title
        self.message = message
        self.onDismiss = onDismiss
    }
    
    public var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 24) {
                Spacer()
                
                // ไอคอนรูปก่อสร้าง (Construction Icon)
                ZStack {
                    Circle()
                        .fill(Color(white: 0.12))
                        .frame(width: 140, height: 140)
                    
                    Image(systemName: "wrench.and.screwdriver.fill")
                        .font(.system(size: 64))
                        .foregroundColor(.orange)
                }
                
                // ข้อความหัวข้อหลัก: กำลังอัปเดต
                Text(title)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                // ข้อความรอง
                Text(message)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(Color(white: 0.7))
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
                    .padding(.horizontal, 36)
                
                // ข้อมูลระบบเพิ่มเติมในรูปแบบ Dark Minimal
                VStack(spacing: 8) {
                    HStack(spacing: 8) {
                        Circle()
                            .fill(Color.orange)
                            .frame(width: 8, height: 8)
                        Text("สถานะ: ระบบกำลังอยู่ระหว่างการบำรุงรักษา")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(Color(white: 0.5))
                    }
                    Text("TIME PARKIN SECURITY SHIELD")
                        .font(.system(size: 11, weight: .semibold, design: .monospaced))
                        .foregroundColor(Color(white: 0.3))
                }
                .padding(.top, 12)
                
                Spacer()
                
                // ปุ่มกลับไปหน้านาฬิกา
                Button(action: onDismiss) {
                    Text("กลับไปหน้านาฬิกา")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color(white: 0.18))
                        .cornerRadius(14)
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 36)
            }
        }
        .preferredColorScheme(.dark)
    }
}

#if DEBUG
struct MaintenanceView_Previews: PreviewProvider {
    static var previews: some View {
        MaintenanceView()
    }
}
#endif
