# รายงานการวิเคราะห์โครงสร้าง IPA และสถาปัตยกรรมเชื่อมต่อ
## PAKIN-EPIC-BUILD19-unsigned (1).ipa -> TIME PARKIN INTEGRATION

---

### 1. ผลการตรวจสอบไฟล์ IPA ต้นฉบับ

| คุณลักษณะ | รายละเอียดที่ตรวจสอบพบ |
| :--- | :--- |
| **ชื่อไฟล์ต้นฉบับ** | `PAKIN-EPIC-BUILD19-unsigned (1).ipa` |
| **ขนาดไฟล์** | 4,442,605 ไบต์ (~4.2 MB) |
| **Executable Name** | `PAKIN_EPIC` (ขนาด Mach-O ไบนารี 9,651,864 ไบต์) |
| **สถาปัตยกรรม CPU** | Apple Silicon ARM64 (`arm64`) |
| **Target iOS** | iOS 16.0 หรือใหม่กว่า |
| **Bundle Display Name** | `PAKIN EPIC` |
| **Bundle Identifier** | `com.apple.mobile.MobileHouseArrest` |
| **Version / Build** | Version 1.1.6 (Build 19) |
| **URL Schemes** | `threeoneosfive://` (`com.yangjiii.3105.patch-import`) |
| **External License API** | `https://hightapi.netlify.app` |
| **Package Catalog URL** | `https://hightapi.netlify.app/api/v4/packages` |
| **Custom Document Type** | `.3105` Patch Package (`application/x-3105-patch`) |

---

### 2. ข้อจำกัดทางเทคนิคและสถาปัตยกรรมความปลอดภัยของ iOS (Apple Sandbox)

1. **การเข้าถึง Source Code**:
   ไฟล์ IPA ต้นฉบับถูกคอมไพล์เป็น Machine Code ภาษา ARM64 ไม่มีไฟล์ Swift / SwiftUI ดั้งเดิมอยู่ภายในแพ็กเกจ การดีคอมไพล์โค้ดที่ถูกคอมไพล์แล้วกลับมาเป็น Source Code สมบูรณ์ 100% ไม่สามารถทำได้ทางเทคนิคโดยไม่สูญเสียโครงสร้างดั้งเดิม

2. **Apple Application Sandboxing Boundary**:
   ตามมาตรฐานความปลอดภัยของระบบปฏิบัติการ iOS:
   - แอปหนึ่งไม่สามารถเปิดอ่านไฟล์หรือรันโปรเซสข้าม Container ของอีกแอปหนึ่งได้โดยตรง (Sandbox Isolation)
   - การสั่งเปิดแอปพลิเคชันอื่นจากภายในแอป iOS ต้องใช้กลไกของระบบที่ Apple รับรอง ได้แก่ **Custom URL Schemes** หรือ **Universal Links**

---

### 3. โซลูชันการเชื่อมต่อที่ทำงานได้จริง (Practical Implementation)

เราได้ออกแบบสถาปัตยกรรมการเชื่อมต่อเป็น 2 ระดับ:

#### ระดับที่ 1: Deep Linking ข้ามแอปผ่าน Custom URL Scheme
- TIME PARKIN ใช้ URL Scheme ที่ลงทะเบียนไว้จริงใน `Info.plist` ของแอปหลัก: `threeoneosfive://`
- เมื่อเงื่อนไขเวลาคีย์ลัดถูกต้อง (เริ่มต้น 31 วินาที) และ Backend API อนุญาต ระบบจะส่งคำขอเปิด `threeoneosfive://launch?token=...` ไปยัง SpringBoard ของ iOS เพื่อเปิดแอป PAKIN EPIC ทันที

#### ระดับที่ 2: ระบบหน้าต่าง License และปุ่มเฟืองในตัว (Native Fallback & Embedded Interface)
- เพื่อรองรับทั้งกรณีที่ติดตั้ง PAKIN EPIC ไว้ในเครื่อง และกรณีที่ต้องการทดสอบหรือรวมระบบเข้าด้วยกัน เราได้สร้างหน้าต่าง `PakinEpicIntegratedView` ซึ่งรักษาระบบเดิมไว้ครบถ้วน:
  - ช่องกรอก License Key พร้อมระบบล้างข้อความ
  - ระบบตรวจสอบ Key และแยกแยะ VIP License
  - ปุ่มรูปฟันเฟืองด้านขวามือสำหรับตั้งค่าคีย์ลัดเวลา
  - การเชื่อมต่อกับฐานข้อมูลการตั้งค่าความปลอดภัยที่เข้ารหัส
