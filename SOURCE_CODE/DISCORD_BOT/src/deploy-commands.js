const { REST, Routes } = require('discord.js');
const fs = require('fs');
const path = require('path');
const config = require('./config');

const commands = [];
const commandsPath = path.join(__dirname, 'commands');
const commandFiles = fs.readdirSync(commandsPath).filter(file => file.endsWith('.js'));

for (const file of commandFiles) {
  const filePath = path.join(commandsPath, file);
  const command = require(filePath);
  if ('data' in command) {
    commands.push(command.data.toJSON());
  }
}

if (!config.DISCORD_BOT_TOKEN || !config.DISCORD_CLIENT_ID) {
  console.error('❌ DISCORD_BOT_TOKEN and DISCORD_CLIENT_ID are required in .env');
  process.exit(1);
}

const rest = new REST({ version: '10' }).setToken(config.DISCORD_BOT_TOKEN);

(async () => {
  try {
    console.log(`[DEPLOY] Started refreshing ${commands.length} application (/) commands.`);

    let data;
    if (config.DISCORD_GUILD_ID) {
      data = await rest.put(
        Routes.applicationGuildCommands(config.DISCORD_CLIENT_ID, config.DISCORD_GUILD_ID),
        { body: commands }
      );
      console.log(`[DEPLOY] Successfully registered ${data.length} commands to Guild: ${config.DISCORD_GUILD_ID}`);
    } else {
      data = await rest.put(
        Routes.applicationCommands(config.DISCORD_CLIENT_ID),
        { body: commands }
      );
      console.log(`[DEPLOY] Successfully registered ${data.length} Global commands.`);
    }
  } catch (error) {
    console.error('[DEPLOY ERROR]', error);
  }
})();
