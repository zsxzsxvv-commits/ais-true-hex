const db = require('../database/dbManager');
const { generateSignature } = require('../middleware/security');
const auditLogger = require('../services/auditLogger');

function getSystemStatus(req, res) {
  const current = db.getSystemStatus();
  const timestamp = Date.now();
  
  // สร้าง HMAC signature เพื่อให้ Client ยืนยันความถูกต้องของข้อมูล ป้องกัน Tampering
  const signString = `${current.clockEnabled}:${current.updateMode}:${timestamp}`;
  const signature = generateSignature(signString);

  const payload = {
    success: true,
    clockEnabled: current.clockEnabled,
    updateMode: current.updateMode,
    maintenanceTitle: current.maintenanceTitle,
    maintenanceMessage: current.maintenanceMessage,
    timestamp,
    signature
  };

  res.writeHead(200, { 'Content-Type': 'application/json' });
  res.end(JSON.stringify(payload));
}

function verifyUnlock(req, res, body) {
  const current = db.getSystemStatus();
  const ip = req.headers['x-forwarded-for'] || req.socket.remoteAddress || '127.0.0.1';

  // ตรวจสอบสถานะระบบ (Fail-Closed)
  if (!current.clockEnabled) {
    auditLogger.log('UNLOCK_REJECTED_CLOCK_DISABLED', 'CLIENT', { triggerTime: body.triggerTime }, ip);
    res.writeHead(403, { 'Content-Type': 'application/json' });
    return res.end(JSON.stringify({
      success: false,
      authorized: false,
      reason: 'ระบบนาฬิกาถูกระงับการใช้งานชั่วคราว'
    }));
  }

  if (!current.updateMode) {
    auditLogger.log('UNLOCK_REJECTED_MAINTENANCE_MODE', 'CLIENT', { triggerTime: body.triggerTime }, ip);
    res.writeHead(403, { 'Content-Type': 'application/json' });
    return res.end(JSON.stringify({
      success: false,
      authorized: false,
      reason: 'ระบบอยู่ระหว่างการปรับปรุง (กำลังอัปเดต)'
    }));
  }

  // ปลดล็อกสำเร็จ
  const handoverToken = `TP-AUTH-${Date.now()}-${Math.random().toString(36).substr(2, 8).toUpperCase()}`;
  auditLogger.log('UNLOCK_AUTHORIZED_SUCCESS', 'CLIENT', { triggerTime: body.triggerTime, handoverToken }, ip);

  res.writeHead(200, { 'Content-Type': 'application/json' });
  res.end(JSON.stringify({
    success: true,
    authorized: true,
    handoverToken,
    reason: 'ยินดีต้อนรับสู่ระบบ PAKIN EPIC'
  }));
}

module.exports = {
  getSystemStatus,
  verifyUnlock
};
