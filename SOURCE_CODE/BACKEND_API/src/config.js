const path = require('path');

// โหลดค่า Environment Variables หรือใช้ค่าความปลอดภัยเริ่มต้น
module.exports = {
  PORT: process.env.PORT || 3000,
  HOST: process.env.HOST || '0.0.0.0',
  ENV: process.env.NODE_ENV || 'production',
  
  // API Token สำหรับผู้ดูแลระบบ / Discord Bot (ห้ามเผยแพร่)
  ADMIN_API_TOKEN: process.env.ADMIN_API_TOKEN || 'TP_ADMIN_SECURE_TOKEN_99881122',
  
  // Secret Key สำหรับสร้าง HMAC-SHA256 Response Signature
  HMAC_SECRET: process.env.HMAC_SECRET || 'TIME_PARKIN_HMAC_MASTER_KEY_2026',
  
  // ค่าเริ่มต้นระบบ (Fail-Closed)
  DEFAULT_CLOCK_ENABLED: true,
  DEFAULT_UPDATE_MODE: true, // true = โหมดปกติ, false = ปิดปรับปรุง (กำลังอัปเดต)
  
  // ที่อยู่ไฟล์ฐานข้อมูล
  DB_PATH: path.join(__dirname, '../data/db.json'),
  LOGS_PATH: path.join(__dirname, '../data/audit.log'),
  
  // Rate Limiting
  RATE_LIMIT_WINDOW_MS: 60 * 1000, // 1 นาที
  RATE_LIMIT_MAX_REQUESTS: 120 // 120 คำขอต่อนาที
};
