const crypto = require('crypto');
const config = require('../config');

// In-memory rate limiting map
const ipRequestCounts = new Map();

function rateLimiter(req, res) {
  const ip = req.headers['x-forwarded-for'] || req.socket.remoteAddress || '127.0.0.1';
  const now = Date.now();
  
  let record = ipRequestCounts.get(ip);
  if (!record || now - record.startTime > config.RATE_LIMIT_WINDOW_MS) {
    record = { count: 1, startTime: now };
    ipRequestCounts.set(ip, record);
    return true;
  }

  record.count++;
  if (record.count > config.RATE_LIMIT_MAX_REQUESTS) {
    return false;
  }
  return true;
}

function generateSignature(payloadString) {
  return crypto
    .createHmac('sha256', config.HMAC_SECRET)
    .update(payloadString)
    .digest('hex');
}

function verifySignature(payloadString, signature) {
  const expected = generateSignature(payloadString);
  return crypto.timingSafeEqual(Buffer.from(expected, 'hex'), Buffer.from(signature, 'hex'));
}

function applySecurityHeaders(res) {
  res.setHeader('X-Content-Type-Options', 'nosniff');
  res.setHeader('X-Frame-Options', 'DENY');
  res.setHeader('X-XSS-Protection', '1; mode=block');
  res.setHeader('Strict-Transport-Security', 'max-age=31536000; includeSubDomains');
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization, X-Request-Nonce, X-Request-Timestamp');
}

module.exports = {
  rateLimiter,
  generateSignature,
  verifySignature,
  applySecurityHeaders
};
