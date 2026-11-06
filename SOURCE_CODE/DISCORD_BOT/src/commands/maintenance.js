const { SlashCommandBuilder, EmbedBuilder } = require('discord.js');
const apiClient = require('../apiClient');
const config = require('../config');

module.exports = {
  data: new SlashCommandBuilder()
    .setName('maintenance')
    .setDescription('ตรวจสอบสถานะการบำรุงรักษาและข้อความแจ้งเตือน'),

  async execute(interaction) {
    await interaction.deferReply();
    try {
      const response = await apiClient.getSystemStatus();
      if (response.statusCode === 200 && response.data.success) {
        const sys = response.data.status;
        const isMaintenance = !sys.updateMode;

        const embed = new EmbedBuilder()
          .setTitle('TIME PARKIN | MAINTENANCE STATUS')
          .setColor(isMaintenance ? 0xE67E22 : 0x2ECC71)
          .setDescription(isMaintenance ? 'ขณะนี้ระบบอยู่ในสถานะ **ปิดปรับปรุง (บำรุงรักษา)**' : 'ขณะนี้ระบบอยู่ในสถานะ **เปิดให้บริการตามปกติ**')
          .addFields(
            { name: '🚧 โหมดบำรุงรักษา', value: isMaintenance ? '⚠️ เปิดอยู่ (ผู้ใช้จะเห็นหน้าก่อสร้าง)' : '✅ ปิดอยู่ (ผู้ใช้เข้าใช้งานได้)', inline: true },
            { name: '📌 หัวข้อแจ้งเตือนบน iOS', value: `\`${sys.maintenanceTitle || 'กำลังอัปเดต'}\``, inline: true },
            { name: '💬 ข้อความแจ้งเตือนรอง', value: `\`${sys.maintenanceMessage || 'ขณะนี้ระบบอยู่ระหว่างการปรับปรุง กรุณาลองใหม่ภายหลัง'}\``, inline: false },
            { name: '🛡️ แก้ไขล่าสุดโดย', value: `\`${sys.lastChangedBy}\``, inline: true },
            { name: '⏱ เวลาที่แก้ไข', value: `\`${new Date(sys.lastChangedAt).toLocaleString('th-TH')}\``, inline: true }
          )
          .setFooter({ text: 'TIME PARKIN MAINTENANCE DISPATCH' })
          .setTimestamp();

        return interaction.editReply({ embeds: [embed] });
      } else {
        return interaction.editReply({ content: '❌ ไม่สามารถดึงสถานะการบำรุงรักษาได้' });
      }
    } catch (err) {
      return interaction.editReply({ content: `❌ Error: ${err.message}` });
    }
  }
};
