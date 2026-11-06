const { SlashCommandBuilder } = require('discord.js');
const apiClient = require('../apiClient');
const { createStatusEmbed } = require('../embeds/statusEmbed');

module.exports = {
  data: new SlashCommandBuilder()
    .setName('update')
    .setDescription('ควบคุมระบบอัปเดต / ปรับปรุงบำรุงรักษา TIME PARKIN')
    .addSubcommand(sub =>
      sub.setName('on').setDescription('เปิดระบบอัปเดต (โหมดปกติ อนุญาตให้ใช้งาน)')
    )
    .addSubcommand(sub =>
      sub.setName('off').setDescription('ปิดระบบอัปเดต (เข้าสู่โหมดปรับปรุงบำรุงรักษา แสดงไอคอนก่อสร้าง)')
    ),

  async execute(interaction) {
    await interaction.deferReply();
    const subcommand = interaction.options.getSubcommand();
    const enable = subcommand === 'on';
    const operator = `${interaction.user.tag} (${interaction.user.id})`;

    try {
      const response = await apiClient.setUpdateMode(enable, operator);
      if (response.statusCode === 200 && response.data.success) {
        const embed = createStatusEmbed({
          systemStatus: response.data.status,
          apiStatus: '200 OK (สถานะอัปเดตเรียบร้อย)',
          operator: interaction.user.tag
        });
        return interaction.editReply({ embeds: [embed] });
      } else {
        return interaction.editReply({
          content: `❌ ดำเนินการไม่สำเร็จ: ${response.data.message || 'Server Error'}`
        });
      }
    } catch (err) {
      return interaction.editReply({
        content: `❌ เกิดข้อผิดพลาดในการติดต่อ Backend API: ${err.message}`
      });
    }
  }
};
