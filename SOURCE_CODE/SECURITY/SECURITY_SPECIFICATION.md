# สเปกระบบรักษาความปลอดภัยระดับ Production
## TIME PARKIN SECURITY SPECIFICATION

เอกสารนี้ระบุการออกแบบและมาตรการป้องกันความปลอดภัย 10 หัวข้อหลักของโปรเจกต์ TIME PARKIN เพื่อป้องกันการดัดแปลง แก้ไข หรือละเมิดลิขสิทธิ์

---

### 1. App Integrity Verification (การตรวจสอบความสมบูรณ์ของแอป)
- ตรวจสอบ Hash (SHA-256) ของไฟล์รีซอร์สและไฟล์ไบนารีที่สำคัญก่อนเริ่มประมวลผล
- ตรวจสอบ Bundle Identifier (`Bundle.main.bundleIdentifier`) ให้ตรงกับค่าที่ลงทะเบียนอย่างถูกต้อง
- ตรวจสอบความถูกต้องของ `embedded.mobileprovision`

### 2. Code Signing Validation (การตรวจสอบลายเซ็นโค้ด)
- ตรวจสอบ Code Signature บน iOS ผ่าน Security Framework
- ปฏิเสธการรันบนสภาพแวดล้อมที่ลายเซ็นถูกปลดออกหรือเซ็นใหม่ด้วย Entitlements ปลอม (Re-signing Detection)

### 3. Resource Integrity (การรักษาความถูกต้องของไฟล์และทรัพยากร)
- ป้องกันการแก้ไข Assets, Plist หรือโครงสร้างภายในแอป
- หากไฟล์ถูกดัดแปลง ระบบจะตรวจพบความแตกต่างของ Hash และปฏิเสธการปลดล็อกเข้าสู่ PAKIN EPIC

### 4. Anti-Tampering (การป้องกันการดัดแปลงแอป)
- **Jailbreak Detection**: ตรวจหา Cydia, Substrate, Frida, Substitute, Shadow และทดสอบเขียนไฟล์นอก Sandbox
- **Anti-Debugging**: ใช้ `sysctl` ตรวจสอบแฟล็ก `P_TRACED` และใช้ `ptrace(PT_DENY_ATTACH, 0, 0, 0)` ใน Release Build
- **Dynamic Library Hooking Detection**: วนลูปผ่าน `_dyld_image_count()` เพื่อตรวจจับการแทรก dylib แปลกปลอม

### 5. Secure API Authentication (การยืนยันตัวตน API ที่ปลอดภัย)
- การสื่อสารระหว่าง iOS Client และ Backend ทำงานผ่าน HTTPS
- คำขอทั้งหมดมี `X-Request-Nonce` และ `X-Request-Timestamp` เพื่อป้องกัน Replay Attack
- คำสั่งควบคุมจาก Discord BOT ไปยัง Backend ใช้ Bearer Token เฉพาะสำหรับผู้ดูแลระบบ

### 6. License Validation (การตรวจสอบสิทธิ์การใช้งาน)
- รักษาระบบ License Key เดิมของ PAKIN EPIC
- รองรับการแยกแยะสิทธิ์ Standard และ VIP License
- มีการคำนวณ Checksum ของข้อมูล License ฝั่ง Client ร่วมกับ Secret Salt ป้องกันการแก้ไข Keychain หรือ UserDefaults ตรงๆ

### 7. Secure Configuration (การจัดการการตั้งค่าอย่างปลอดภัย)
- ไม่ฝัง Admin Token, Bot Token หรือ Database Password ลงใน Client Binary หรือ IPA
- ไม่แสดงหน้าต่างตั้งค่า API URL ให้ผู้ใช้ทั่วไปเห็นใน UI
- จัดเก็บข้อมูลผ่าน Environment Variables (.env) ฝั่ง Server

### 8. Server-Side Authorization & Fail-Closed (การตัดสินใจฝั่งเซิร์ฟเวอร์และสถาปัตยกรรมปิด)
- การปลดล็อกต้องได้รับการยืนยันและอนุมัติจาก Backend API เสมอ
- หาก API ไม่สามารถติดต่อได้ มีข้อผิดพลาดทางเครือข่าย หรือเซิร์ฟเวอร์ส่งข้อมูลที่ไม่ถูกต้อง ให้ใช้หลักการ **Fail-Closed** (ล็อกระบบทันที ไม่อนุญาตให้ผ่านเข้าแอปหลัก)

### 9. Security Event Logging & Audit Trail (การบันทึกเหตุการณ์ความปลอดภัย)
- บันทึกการพยายามเข้าถึงที่ผิดพลาด, การใช้ Token ไม่ถูกต้อง, และการปลดล็อกที่สำเร็จลงใน `data/audit.log`
- บันทึก IP Address, วันเวลา, และรายละเอียดของคำขอ เพื่อการตรวจสอบย้อนหลัง

### 10. Detection of Modified Application Packages (การตรวจจับแพ็กเกจที่ถูกดัดแปลง)
- มีระบบตรวจสอบขนาดและความสมบูรณ์ของแพ็กเกจ
- ตรวจสอบความถูกต้องของการเชื่อมต่อไปยัง Scheme `threeoneosfive://` ของ PAKIN EPIC
