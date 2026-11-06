const config = require('../config');
const auditLogger = require('../services/auditLogger');

function authenticateAdmin(req) {
  const authHeader = req.headers['authorization'];
  if (!authHeader) {
    return { authorized: false, reason: 'Missing Authorization header' };
  }

  const parts = authHeader.split(' ');
  if (parts.length !== 2 || parts[0].toLowerCase() !== 'bearer') {
    return { authorized: false, reason: 'Invalid Authorization header format' };
  }

  const token = parts[1];
  if (token !== config.ADMIN_API_TOKEN) {
    const ip = req.headers['x-forwarded-for'] || req.socket.remoteAddress || '127.0.0.1';
    auditLogger.log('UNAUTHORIZED_ACCESS_ATTEMPT', 'UNKNOWN', { tokenProvided: token.substr(0, 4) + '***' }, ip);
    return { authorized: false, reason: 'Invalid Admin API Token' };
  }

  return { authorized: true };
}

module.exports = {
  authenticateAdmin
};
