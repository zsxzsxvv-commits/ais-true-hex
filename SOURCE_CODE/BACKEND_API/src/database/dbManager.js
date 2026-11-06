const fs = require('fs');
const path = require('path');
const config = require('../config');

class DBManager {
  constructor() {
    this.dbPath = config.DB_PATH;
    this.ensureDirectory();
    this.state = this.load();
  }

  ensureDirectory() {
    const dir = path.dirname(this.dbPath);
    if (!fs.existsSync(dir)) {
      fs.mkdirSync(dir, { recursive: true });
    }
  }

  load() {
    try {
      if (fs.existsSync(this.dbPath)) {
        const raw = fs.readFileSync(this.dbPath, 'utf8');
        return JSON.parse(raw);
      }
    } catch (err) {
      console.error('[DBManager] Error reading DB file, recreating with defaults:', err.message);
    }

    const defaultState = {
      system: {
        clockEnabled: config.DEFAULT_CLOCK_ENABLED,
        updateMode: config.DEFAULT_UPDATE_MODE,
        maintenanceTitle: 'กำลังอัปเดต',
        maintenanceMessage: 'ขณะนี้ระบบอยู่ระหว่างการปรับปรุง กรุณาลองใหม่ภายหลัง',
        lastChangedBy: 'SYSTEM_INIT',
        lastChangedAt: new Date().toISOString()
      },
      auditLogs: []
    };
    this.save(defaultState);
    return defaultState;
  }

  save(data = this.state) {
    try {
      // เขียนแบบ Atomic โดยใช้ temp file เพื่อป้องกันไฟดับหรือ crash กลางคัน
      const tempPath = `${this.dbPath}.tmp`;
      fs.writeFileSync(tempPath, JSON.stringify(data, null, 2), 'utf8');
      fs.renameSync(tempPath, this.dbPath);
      this.state = data;
      return true;
    } catch (err) {
      console.error('[DBManager] Error writing DB:', err.message);
      return false;
    }
  }

  getSystemStatus() {
    return { ...this.state.system };
  }

  setClock(enabled, operator = 'UNKNOWN_ADMIN') {
    this.state.system.clockEnabled = Boolean(enabled);
    this.state.system.lastChangedBy = operator;
    this.state.system.lastChangedAt = new Date().toISOString();
    this.save();
    return this.getSystemStatus();
  }

  setUpdateMode(enabled, operator = 'UNKNOWN_ADMIN') {
    this.state.system.updateMode = Boolean(enabled);
    this.state.system.lastChangedBy = operator;
    this.state.system.lastChangedAt = new Date().toISOString();
    this.save();
    return this.getSystemStatus();
  }

  addAuditLog(entry) {
    const record = {
      id: Date.now().toString(36) + Math.random().toString(36).substr(2, 5),
      timestamp: new Date().toISOString(),
      ...entry
    };
    if (!Array.isArray(this.state.auditLogs)) {
      this.state.auditLogs = [];
    }
    this.state.auditLogs.unshift(record);
    if (this.state.auditLogs.length > 500) {
      this.state.auditLogs = this.state.auditLogs.slice(0, 500);
    }
    this.save();
    return record;
  }

  getAuditLogs(limit = 50) {
    return (this.state.auditLogs || []).slice(0, limit);
  }

  reload() {
    this.state = this.load();
    return this.getSystemStatus();
  }
}

module.exports = new DBManager();
