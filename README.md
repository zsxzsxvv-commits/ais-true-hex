# TIME PARKIN: iOS CLOCK SECURITY SYSTEM + DISCORD BOT API
## สถาปัตยกรรมระบบความปลอดภัยนาฬิกา iOS และระบบควบคุมผ่าน Discord Bot

ยินดีต้อนรับสู่ **TIME PARKIN** ระบบความปลอดภัยหน้าด่าน (Frontline Security Shield) สำหรับเชื่อมต่อไปยังแอปพลิเคชัน **PAKIN EPIC** บนระบบปฏิบัติการ iOS พร้อมศูนย์บัญชาการควบคุมผ่าน Discord Bot (Discord.js v14) และ Backend API ประสิทธิภาพสูง

---

## สารบัญ

1. [ภาพรวมระบบและฟังก์ชันหลัก](#ภาพรวมระบบและฟังก์ชันหลัก)
2. [โครงสร้างโปรเจกต์](#โครงสร้างโปรเจกต์)
3. [วิธีติดตั้งและ Deploy Backend API](#วิธีติดตั้งและ-deploy-backend-api)
4. [วิธีตั้งค่าและการรัน Discord BOT](#วิธีตั้งค่าและการรัน-discord-bot)
5. [วิธี Build และ Integrate บน iOS](#วิธี-build-และ-integrate-บน-ios)
6. [คำสั่งควบคุมผ่าน Discord Slash Commands](#คำสั่งควบคุมผ่าน-discord-slash-commands)
7. [ระบบความปลอดภัยและการป้องกันการดัดแปลง](#ระบบความปลอดภัยและการป้องกันการดัดแปลง)
8. [ใบอนุญาตการใช้งาน (License)](#ใบอนุญาตการใช้งาน)

---

## ภาพรวมระบบและฟังก์ชันหลัก

- **iOS Clock Native UI**: จำลองและรักษารูปแบบแอปนาฬิกามาตรฐานของ iOS ไว้อย่างแนบเนียน 4 แท็บ (นาฬิกาโลก, การปลุก, นาฬิกาจับเวลา, นับถอยหลัง)
- **ค่าเริ่มต้น 31 วินาที**: ตัวนับเวลาเริ่มต้นล็อกไว้ที่ `00:00:31` พร้อมระบบป้องกันการเปลี่ยนแปลงค่าโดยพลการ
- **Fail-Closed Architecture**: หากไม่สามารถเชื่อมต่อเซิร์ฟเวอร์ หรือพบความผิดปกติของลายเซ็นดิจิทัล ระบบจะปฏิเสธการปลดล็อกทันที
- **โหมดบำรุงรักษา (Maintenance View)**: เมื่อผู้ดูแลปิดระบบอัปเดตผ่าน Discord หน้าแอปจะเปลี่ยนเป็นไอคอนก่อสร้างและข้อความภาษาไทย "กำลังอัปเดต / ขณะนี้ระบบอยู่ระหว่างการปรับปรุง กรุณาลองใหม่ภายหลัง"
- **การเชื่อมต่อ PAKIN EPIC**: เชื่อมต่อผ่าน Registered Deep Link URL Scheme `threeoneosfive://` ที่ลงทะเบียนไว้จริงในแพ็กเกจแอปหลัก พร้อมหน้าต่างระบบ License และปุ่มรูปเฟืองดั้งเดิม
- **Monochrome Premium Discord Panel**: ควบคุมสถานะแบบ Real-time ผ่าน Slash Commands และ Embed ธีมขาวดำระดับพรีเมียม

---

## โครงสร้างโปรเจกต์

```text
UP_TO_GITHUB/
├── README.md                  # เอกสารแนะนำและคู่มือภาษาไทย
├── .gitignore                 # กำหนดข้อยกเว้นไฟล์ที่ไม่ส่งขึ้น Git
├── .env.example               # แม่แบบตัวแปรสภาพแวดล้อมที่ปลอดภัย
├── LICENSE                    # สัญญาอนุญาต MIT
├── API_DOCUMENTATION.md       # เอกสารรายละเอียด API
└── SOURCE_CODE/
    ├── CLOCK_SYSTEM/          # ระบบนาฬิกา iOS (Swift / SwiftUI)
    ├── IOS_APP_INTEGRATION/   # ระบบเชื่อมต่อและ Deep Link PAKIN EPIC
    ├── BACKEND_API/           # API Server (Node.js)
    ├── DISCORD_BOT/           # Discord Bot (Discord.js v14)
    └── SECURITY/              # โมดูล Anti-Tampering & Integrity
```

---

## วิธีติดตั้งและ Deploy Backend API

### ข้อกำหนด
- Node.js เวอร์ชัน 18.0.0 หรือใหม่กว่า

### ขั้นตอน
1. เข้าสู่โฟลเดอร์ API:
   ```bash
   cd SOURCE_CODE/BACKEND_API
   ```
2. คัดลอกและแก้ไขไฟล์ `.env`:
   ```bash
   cp .env.example .env
   ```
   กำหนดค่า `ADMIN_API_TOKEN` และ `HMAC_SECRET` ด้วยรหัสที่มีความปลอดภัยสูง
3. เริ่มต้นรันเซิร์ฟเวอร์:
   ```bash
   node src/server.js
   ```
   หรือรันแบบ Background Service ด้วย PM2:
   ```bash
   pm2 start src/server.js --name "time-parkin-api"
   ```

---

## วิธีตั้งค่าและการรัน Discord BOT

1. เข้าสู่โฟลเดอร์ BOT:
   ```bash
   cd SOURCE_CODE/DISCORD_BOT
   ```
2. ติดตั้ง Dependencies:
   ```bash
   npm install discord.js dotenv
   ```
3. คัดลอกและแก้ไขไฟล์ `.env`:
   ```bash
   cp .env.example .env
   ```
   กำหนดค่า Token, Client ID, Whitelist User IDs และ Target API URL
4. ลงทะเบียนคำสั่ง Slash Commands ไปยัง Discord:
   ```bash
   node src/deploy-commands.js
   ```
5. สตาร์ทการทำงานของบอท:
   ```bash
   node src/bot.js
   ```

---

## วิธี Build และ Integrate บน iOS

1. นำโฟลเดอร์ `CLOCK_SYSTEM`, `IOS_APP_INTEGRATION`, และ `SECURITY` เข้าสู่โปรเจกต์ Xcode
2. เพิ่มการตั้งค่า URL Query Schemes ใน `Info.plist`:
   ```xml
   <key>LSApplicationQueriesSchemes</key>
   <array>
       <string>threeoneosfive</string>
   </array>
   ```
3. ตั้งค่า `baseURL` ใน `TimeParkinAPIService.swift` ให้ตรงกับ Domain ของ Backend API
4. เสียบสายอุปกรณ์ iOS จริง เลือก Signing Profile และกด Build & Run

---

## คำสั่งควบคุมผ่าน Discord Slash Commands

| คำสั่ง | คำอธิบาย |
| :--- | :--- |
| `/clock on` | เปิดระบบนาฬิกา (ผู้ใช้สามารถปลดล็อกได้ตามปกติ) |
| `/clock off` | ปิดระบบนาฬิกา (แอปแสดงข้อความ "ระบบถูกระงับ") |
| `/update on` | เปิดระบบอัปเดต (โหมดปกติ) |
| `/update off` | ปิดระบบอัปเดต (แอปแสดงหน้าต่างก่อสร้าง "กำลังอัปเดต") |
| `/status` | แสดงแดชบอร์ดสถานะระบบทั้งหมดแบบพรีเมียม |
| `/maintenance` | ตรวจสอบสถานะการบำรุงรักษาอย่างละเอียด |
| `/restart` | รีโหลดการตั้งค่าระบบอย่างปลอดภัย โดยไม่ลบข้อมูลเดิม |

---

## ใบอนุญาตการใช้งาน

โปรเจกต์นี้เผยแพร่ภายใต้สัญญาอนุญาต [MIT License](LICENSE)
