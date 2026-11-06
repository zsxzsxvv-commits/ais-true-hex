require('dotenv').config();

module.exports = {
  // Discord Bot Credentials
  DISCORD_BOT_TOKEN: process.env.DISCORD_BOT_TOKEN || '',
  DISCORD_CLIENT_ID: process.env.DISCORD_CLIENT_ID || '',
  DISCORD_GUILD_ID: process.env.DISCORD_GUILD_ID || '',

  // Backend API Integration
  API_BASE_URL: process.env.API_BASE_URL || 'http://127.0.0.1:3000',
  ADMIN_API_TOKEN: process.env.ADMIN_API_TOKEN || 'TP_ADMIN_SECURE_TOKEN_99881122',

  // Whitelist Security Settings (เฉพาะ ID ที่ระบุเท่านั้นที่มีสิทธิ์เรียกคำสั่ง)
  ALLOWED_USER_IDS: (process.env.ALLOWED_USER_IDS || '').split(',').map(s => s.trim()).filter(Boolean),
  ALLOWED_ROLE_IDS: (process.env.ALLOWED_ROLE_IDS || '').split(',').map(s => s.trim()).filter(Boolean),

  // UI Theme
  THEME_COLOR: 0x1A1A1A, // ขาว-ดำ เรียบหรู (Monochrome Dark)
  SUCCESS_COLOR: 0x2ECC71,
  ERROR_COLOR: 0xE74C3C
};
