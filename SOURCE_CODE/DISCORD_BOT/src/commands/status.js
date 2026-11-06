const { SlashCommandBuilder } = require('discord.js');
const apiClient = require('../apiClient');
const { createStatusEmbed } = require('../embeds/statusEmbed');

module.exports = {
  data: new SlashCommandBuilder()
    .setName('status')
    .setDescription('ตรวจสอบสถานะระบบทั้งหมดของ TIME PARKIN'),

  async execute(interaction) {
    await interaction.deferReply();
    try {
      const response = await apiClient.getSystemStatus();
      if (response.statusCode === 200 && response.data.success) {
        const embed = createStatusEmbed({
          systemStatus: response.data.status,
          apiStatus: `200 OK (Uptime: ${response.data.uptimeSeconds}s, RAM: ${response.data.memoryUsageMB}MB)`,
          operator: interaction.user.tag
        });
        return interaction.editReply({ embeds: [embed] });
      } else {
        return interaction.editReply({
          content: '❌ ไม่สามารถดึงสถานะระบบได้จาก Backend API'
        });
      }
    } catch (err) {
      return interaction.editReply({
        content: `❌ เกิดข้อผิดพลาดในการติดต่อ Backend API: ${err.message}`
      });
    }
  }
};
