const http = require('http');
const url = require('url');
const config = require('./config');
const { rateLimiter, applySecurityHeaders } = require('./middleware/security');
const { authenticateAdmin } = require('./middleware/auth');
const systemController = require('./controllers/systemController');
const adminController = require('./controllers/adminController');

function parseBody(req) {
  return new Promise((resolve, reject) => {
    let body = '';
    req.on('data', chunk => {
      body += chunk;
      if (body.length > 1e6) { // 1MB limit
        req.connection.destroy();
        reject(new Error('Payload too large'));
      }
    });
    req.on('end', () => {
      if (!body) return resolve({});
      try {
        resolve(JSON.parse(body));
      } catch (err) {
        resolve({});
      }
    });
    req.on('error', err => reject(err));
  });
}

const server = http.createServer(async (req, res) => {
  // 1. ใส่ Security Headers และ CORS
  applySecurityHeaders(res);

  if (req.method === 'OPTIONS') {
    res.writeHead(204);
    return res.end();
  }

  // 2. ตรวจสอบ Rate Limiting
  if (!rateLimiter(req, res)) {
    res.writeHead(429, { 'Content-Type': 'application/json' });
    return res.end(JSON.stringify({ success: false, message: 'Too Many Requests' }));
  }

  const parsedUrl = url.parse(req.url, true);
  const pathname = parsedUrl.pathname;
  const method = req.method;

  try {
    const body = ['POST', 'PUT', 'PATCH'].includes(method) ? await parseBody(req) : {};

    // MARK: - Health Check
    if (pathname === '/health' && method === 'GET') {
      res.writeHead(200, { 'Content-Type': 'application/json' });
      return res.end(JSON.stringify({ status: 'ok', service: 'time-parkin-api', time: new Date().toISOString() }));
    }

    // MARK: - Public Endpoints (iOS Client)
    if (pathname === '/api/v1/system/status' && method === 'GET') {
      return systemController.getSystemStatus(req, res);
    }

    if (pathname === '/api/v1/system/verify-unlock' && method === 'POST') {
      return systemController.verifyUnlock(req, res, body);
    }

    // MARK: - Admin Endpoints (Discord BOT Only)
    if (pathname.startsWith('/api/v1/admin/')) {
      const auth = authenticateAdmin(req);
      if (!auth.authorized) {
        res.writeHead(401, { 'Content-Type': 'application/json' });
        return res.end(JSON.stringify({ success: false, message: auth.reason }));
      }

      if (pathname === '/api/v1/admin/clock' && method === 'POST') {
        return adminController.toggleClock(req, res, body);
      }

      if (pathname === '/api/v1/admin/update' && method === 'POST') {
        return adminController.toggleUpdateMode(req, res, body);
      }

      if (pathname === '/api/v1/admin/restart' && method === 'POST') {
        return adminController.restartSystem(req, res, body);
      }

      if (pathname === '/api/v1/admin/status' && method === 'GET') {
        return adminController.getFullStatus(req, res);
      }

      if (pathname === '/api/v1/admin/audit-logs' && method === 'GET') {
        return adminController.getAuditLogs(req, res);
      }
    }

    // Fallthrough 404
    res.writeHead(404, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ success: false, message: 'Endpoint not found' }));

  } catch (err) {
    console.error('[Server Error]', err);
    res.writeHead(500, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ success: false, message: 'Internal Server Error' }));
  }
});

server.listen(config.PORT, config.HOST, () => {
  console.log(`=================================================`);
  console.log(` TIME PARKIN - BACKEND API SERVER RUNNING       `);
  console.log(` Listening on: http://${config.HOST}:${config.PORT}`);
  console.log(` Environment: ${config.ENV}                     `);
  console.log(` Fail-Closed: ACTIVE                             `);
  console.log(`=================================================`);
});

module.exports = server;
