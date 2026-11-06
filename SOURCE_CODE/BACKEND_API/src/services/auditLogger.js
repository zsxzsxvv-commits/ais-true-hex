const fs = require('fs');
const config = require('../config');
const db = require('../database/dbManager');

class AuditLogger {
  log(action, operator, details = {}, ip = 'INTERNAL') {
    const entry = {
      action,
      operator,
      details,
      ip,
      timestamp: new Date().toISOString()
    };

    // บันทึกลงฐานข้อมูล memory/json
    db.addAuditLog(entry);

    // บันทึกลง audit.log text file
    try {
      const line = `[${entry.timestamp}] [${action}] by ${operator} (IP: ${ip}) - ${JSON.stringify(details)}\n`;
      fs.appendFileSync(config.LOGS_PATH, line, 'utf8');
    } catch (err) {
      console.error('[AuditLogger] File append error:', err.message);
    }

    console.log(`[AUDIT] ${action} by ${operator}:`, details);
  }
}

module.exports = new AuditLogger();
