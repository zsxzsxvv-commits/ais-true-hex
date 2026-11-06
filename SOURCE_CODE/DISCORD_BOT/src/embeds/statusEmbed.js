let EmbedBuilder;
try {
  EmbedBuilder = require('discord.js').EmbedBuilder;
} catch {
  // Standalone fallback class for test runners and zero-dependency environments
  EmbedBuilder = class {
    constructor() {
      this.data = {};
    }
    setTitle(t) {
      this.data.title = t;
      return this;
    }
    setDescription(d) {
      this.data.description = d;
      return this;
    }
    setColor(c) {
      this.data.color = c;
      return this;
    }
    addFields(...fields) {
      this.data.fields = (this.data.fields || []).concat(...fields);
      return this;
    }
    setFooter(f) {
      this.data.footer = f;
      return this;
    }
    setTimestamp() {
      this.data.timestamp = new Date();
      return this;
    }
  };
}

const config = require('../config');

function createStatusEmbed({ systemStatus, apiStatus = 'เชื่อมต่อสำเร็จ (200 OK)', operator = 'SYSTEM', botConnected = true }) {
  const clockStatus = systemStatus.clockEnabled
    ? '🟢 **เปิดใช้งาน (Online)**'
    : '🔴 **ปิดใช้งาน (Suspended)**';

  const updateStatus = systemStatus.updateMode
    ? '🟢 **เปิดใช้งาน (Normal Mode)**'
    : '🚧 **ปิดปรับปรุง (Maintenance / Update)**';

  const lastChangedAt = systemStatus.lastChangedAt
    ? new Date(systemStatus.lastChangedAt).toLocaleString('th-TH', { timeZone: 'Asia/Bangkok' })
    : 'ไม่มีข้อมูล';

  const botStatus = botConnected
    ? '🟢 **เชื่อมต่อปกติ (Gateway Connected)**'
    : '🔴 **ขาดการเชื่อมต่อ**';

  const embed = new EmbedBuilder()
    .setTitle('TIME PARKIN | SYSTEM CONTROL')
    .setDescription('แดชบอร์ดควบคุมระบบความปลอดภัยและสถานะการทำงานส่วนกลางสำหรับ iOS Application')
    .setColor(config.THEME_COLOR)
    .addFields(
      { name: '🕒 สถานะระบบนาฬิกา', value: clockStatus, inline: true },
      { name: '🔄 สถานะระบบอัปเดต', value: updateStatus, inline: true },
      { name: '🌐 สถานะ Backend API', value: apiStatus, inline: false },
      { name: '⏱ เวลาที่เปลี่ยนสถานะล่าสุด', value: `\`${lastChangedAt}\``, inline: true },
      { name: '🛡️ ผู้ดูแลที่ดำเนินการ', value: `\`${operator || systemStatus.lastChangedBy || 'SYSTEM'}\``, inline: true },
      { name: '🤖 สถานะการเชื่อมต่อ Discord BOT', value: botStatus, inline: false }
    )
    .setFooter({
      text: 'TIME PARKIN SECURITY PROTOCOL • HIGH-TIER ENCRYPTION',
      iconURL: 'https://cdn-icons-png.flaticon.com/512/2092/2092663.png'
    })
    .setTimestamp();

  return embed;
}

module.exports = {
  createStatusEmbed
};
