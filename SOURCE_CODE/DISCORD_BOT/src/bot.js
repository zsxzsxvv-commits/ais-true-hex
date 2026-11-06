const { Client, GatewayIntentBits, Collection } = require('discord.js');
const fs = require('fs');
const path = require('path');
const config = require('./config');

const client = new Client({
  intents: [
    GatewayIntentBits.Guilds,
    GatewayIntentBits.GuildMessages
  ]
});

client.commands = new Collection();

// โหลดคำสั่งทั้งหมดใน src/commands
const commandsPath = path.join(__dirname, 'commands');
if (fs.existsSync(commandsPath)) {
  const commandFiles = fs.readdirSync(commandsPath).filter(file => file.endsWith('.js'));
  for (const file of commandFiles) {
    const filePath = path.join(commandsPath, file);
    const command = require(filePath);
    if ('data' in command && 'execute' in command) {
      client.commands.set(command.data.name, command);
      console.log(`[BOT] Loaded Slash Command: /${command.data.name}`);
    }
  }
}

// ตรวจสอบสิทธิ์ผู้ใช้งาน (Whitelist Enforcement)
function isAuthorized(interaction) {
  const userId = interaction.user.id;
  
  // 1. ตรวจสอบ User ID
  if (config.ALLOWED_USER_IDS.length > 0 && config.ALLOWED_USER_IDS.includes(userId)) {
    return true;
  }

  // 2. ตรวจสอบ Role ID
  if (interaction.member && interaction.member.roles) {
    const userRoleIds = interaction.member.roles.cache ? Array.from(interaction.member.roles.cache.keys()) : [];
    const hasRole = config.ALLOWED_ROLE_IDS.some(rId => userRoleIds.includes(rId));
    if (hasRole) return true;
  }

  // หากไม่มีการระบุ Whitelist ใดๆ ใน Config ให้ถือว่ายังไม่มีใครได้รับอนุญาต (Secure by Default)
  return false;
}

client.once('ready', () => {
  console.log(`=================================================`);
  console.log(` TIME PARKIN DISCORD BOT ONLINE`);
  console.log(` Logged in as: ${client.user.tag}`);
  console.log(` Commands Loaded: ${client.commands.size}`);
  console.log(` Backend Target: ${config.API_BASE_URL}`);
  console.log(`=================================================`);
});

client.on('interactionCreate', async interaction => {
  if (!interaction.isChatInputCommand()) return;

  const command = client.commands.get(interaction.commandName);
  if (!command) return;

  // ตรวจสอบสิทธิ์ก่อนอนุญาตให้เรียกใช้คำสั่งระบบ
  if (!isAuthorized(interaction)) {
    console.warn(`[UNAUTHORIZED] User ${interaction.user.tag} (${interaction.user.id}) tried to execute /${interaction.commandName}`);
    return interaction.reply({
      content: '⛔ **ปฏิเสธการเข้าถึง**: คุณไม่มีสิทธิ์ควบคุมระบบความปลอดภัย TIME PARKIN (เฉพาะ Discord User ID หรือ Role ID ที่กำหนดเท่านั้น)',
      ephemeral: true
    });
  }

  try {
    await command.execute(interaction);
  } catch (error) {
    console.error(`[COMMAND_ERROR] /${interaction.commandName}:`, error);
    const replyContent = { content: '❌ เกิดข้อผิดพลาดร้ายแรงขณะประมวลผลคำสั่งนี้', ephemeral: true };
    if (interaction.replied || interaction.deferred) {
      await interaction.followUp(replyContent);
    } else {
      await interaction.reply(replyContent);
    }
  }
});

// เริ่มต้นบอทหากมีการระบุ Token
if (config.DISCORD_BOT_TOKEN) {
  client.login(config.DISCORD_BOT_TOKEN).catch(err => {
    console.error('[BOT LOGIN ERROR]', err.message);
  });
} else {
  console.log('[BOT] No DISCORD_BOT_TOKEN configured. Run with valid token in .env');
}

module.exports = client;
