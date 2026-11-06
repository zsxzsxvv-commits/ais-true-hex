const db = require('../database/dbManager');
const auditLogger = require('../services/auditLogger');

function toggleClock(req, res, body) {
  const { enabled, operator = 'DISCORD_BOT' } = body;
  const ip = req.headers['x-forwarded-for'] || req.socket.remoteAddress || '127.0.0.1';

  if (typeof enabled !== 'boolean') {
    res.writeHead(400, { 'Content-Type': 'application/json' });
    return res.end(JSON.stringify({ success: false, message: 'Invalid "enabled" parameter (boolean required)' }));
  }

  const updated = db.setClock(enabled, operator);
  auditLogger.log(enabled ? 'CLOCK_SYSTEM_ENABLED' : 'CLOCK_SYSTEM_DISABLED', operator, { enabled }, ip);

  res.writeHead(200, { 'Content-Type': 'application/json' });
  res.end(JSON.stringify({
    success: true,
    message: `ระบบนาฬิกาถูก${enabled ? 'เปิดใช้งาน' : 'ปิดการใช้งาน'}เรียบร้อยแล้ว`,
    status: updated
  }));
}

function toggleUpdateMode(req, res, body) {
  const { enabled, operator = 'DISCORD_BOT' } = body;
  const ip = req.headers['x-forwarded-for'] || req.socket.remoteAddress || '127.0.0.1';

  if (typeof enabled !== 'boolean') {
    res.writeHead(400, { 'Content-Type': 'application/json' });
    return res.end(JSON.stringify({ success: false, message: 'Invalid "enabled" parameter (boolean required)' }));
  }

  const updated = db.setUpdateMode(enabled, operator);
  auditLogger.log(enabled ? 'UPDATE_MODE_ENABLED' : 'UPDATE_MODE_DISABLED_MAINTENANCE_ACTIVE', operator, { enabled }, ip);

  res.writeHead(200, { 'Content-Type': 'application/json' });
  res.end(JSON.stringify({
    success: true,
    message: `ระบบอัปเดตถูก${enabled ? 'เปิดใช้งาน (โหมดปกติ)' : 'ปิดการใช้งาน (เข้าสู่โหมดปรับปรุงบำรุงรักษา)'}เรียบร้อยแล้ว`,
    status: updated
  }));
}

function restartSystem(req, res, body) {
  const { operator = 'DISCORD_BOT' } = body;
  const ip = req.headers['x-forwarded-for'] || req.socket.remoteAddress || '127.0.0.1';

  // รีโหลดการตั้งค่าระบบอย่างปลอดภัย โดยไม่ลบข้อมูลเดิม
  const reloaded = db.reload();
  auditLogger.log('SYSTEM_SAFE_RESTART_RELOAD', operator, { message: 'Config reloaded safely without data loss' }, ip);

  res.writeHead(200, { 'Content-Type': 'application/json' });
  res.end(JSON.stringify({
    success: true,
    message: 'รีโหลดการตั้งค่าระบบอย่างปลอดภัยเรียบร้อยแล้ว (ข้อมูลทั้งหมดยังคงเดิม)',
    status: reloaded
  }));
}

function getFullStatus(req, res) {
  const current = db.getSystemStatus();
  res.writeHead(200, { 'Content-Type': 'application/json' });
  res.end(JSON.stringify({
    success: true,
    status: current,
    uptimeSeconds: Math.floor(process.uptime()),
    nodeVersion: process.version,
    memoryUsageMB: Math.round(process.memoryUsage().heapUsed / 1024 / 1024)
  }));
}

function getAuditLogs(req, res) {
  const logs = db.getAuditLogs(100);
  res.writeHead(200, { 'Content-Type': 'application/json' });
  res.end(JSON.stringify({
    success: true,
    count: logs.length,
    logs
  }));
}

module.exports = {
  toggleClock,
  toggleUpdateMode,
  restartSystem,
  getFullStatus,
  getAuditLogs
};
