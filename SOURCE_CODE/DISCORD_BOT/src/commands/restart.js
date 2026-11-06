const { SlashCommandBuilder } = require('discord.js');
const apiClient = require('../apiClient');
const { createStatusEmbed } = require('../embeds/statusEmbed');

module.exports = {
  data: new SlashCommandBuilder()
    .setName('restart')
    .setDescription('รีโหลดการตั้งค่าระบบอย่างปลอดภัย โดยไม่ลบข้อมูลเดิม'),

  async execute(interaction) {
    await interaction.deferReply();
    const operator = `${interaction.user.tag} (${interaction.user.id})`;

    try {
      const response = await apiClient.restartSystem(operator);
      if (response.statusCode === 200 && response.data.success) {
        const embed = createStatusEmbed({
          systemStatus: response.data.status,
          apiStatus: '200 OK (ปลอดภัย - รีโหลดสำเร็จโดยไม่สูญเสียข้อมูล)',
          operator: interaction.user.tag
        });
        return interaction.editReply({
          content: '🔄 **ดำเนินการรีโหลดการตั้งค่าระบบเรียบร้อยแล้ว** ข้อมูลการใช้งานและบันทึกความปลอดภัยยังคงอยู่ครบถ้วน',
          embeds: [embed]
        });
      } else {
        return interaction.editReply({
          content: `❌ ดำเนินการไม่สำเร็จ: ${response.data.message || 'Error'}`
        });
      }
    } catch (err) {
      return interaction.editReply({
        content: `❌ เกิดข้อผิดพลาดในการติดต่อ Backend API: ${err.message}`
      });
    }
  }
};
