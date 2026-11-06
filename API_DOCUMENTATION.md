# เอกสารอ้างอิง TIME PARKIN BACKEND API
## Version 1.0 (GitHub Ready / Production Standard)

ระบบ TIME PARKIN Backend API เป็นระบบหลังบ้านที่ออกแบบมาเพื่อความปลอดภัยขั้นสูง (Fail-Closed Architecture) สำหรับเชื่อมต่อระหว่าง Discord BOT และ iOS Client

---

### ข้อมูลพื้นฐาน

- **Protocol**: HTTPS (Production) / HTTP (Development)
- **Data Format**: `application/json`
- **Security Standard**: HMAC-SHA256 Response Signing, Rate Limiting, Bearer Authentication

---

### Endpoints สำหรับ iOS Client

#### 1. ตรวจสอบสถานะระบบ (`GET /api/v1/system/status`)
- คืนค่าสถานะ `clockEnabled`, `updateMode`, `maintenanceTitle`, `maintenanceMessage` และ `signature`
- แอป iOS ใช้ค่านี้ตัดสินใจเปิดหน้าต่างนาฬิกาหรือหน้าต่างบำรุงรักษา

#### 2. ร้องขอการปลดล็อก (`POST /api/v1/system/verify-unlock`)
- ตรวจสอบความถูกต้องของคีย์ลัดเวลา และสถานะการอนุญาตจากเซิร์ฟเวอร์
- คืนค่า `handoverToken` เมื่อผ่านเงื่อนไข

---

### Endpoints สำหรับ Discord BOT (Admin Only)

จำเป็นต้องแนบ Header: `Authorization: Bearer <ADMIN_API_TOKEN>`

| Endpoint | Method | คำอธิบาย |
| :--- | :--- | :--- |
| `/api/v1/admin/clock` | `POST` | สั่งเปิด/ปิดระบบนาฬิกา |
| `/api/v1/admin/update` | `POST` | สั่งเปิด/ปิดระบบอัปเดต (โหมดบำรุงรักษา) |
| `/api/v1/admin/restart` | `POST` | รีโหลดการตั้งค่าระบบอย่างปลอดภัย ไม่ลบข้อมูลเดิม |
| `/api/v1/admin/status` | `GET` | ดึงสถานะระบบ ทรัพยากร Uptime และ RAM |
| `/api/v1/admin/audit-logs` | `GET` | ตรวจสอบบันทึกความปลอดภัยย้อนหลัง |
