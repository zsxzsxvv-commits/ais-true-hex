const http = require('http');
const https = require('https');
const url = require('url');
const config = require('./config');

class ApiClient {
  constructor() {
    this.baseURL = config.API_BASE_URL;
    this.adminToken = config.ADMIN_API_TOKEN;
  }

  request(endpoint, method = 'GET', body = null) {
    return new Promise((resolve, reject) => {
      const fullUrl = `${this.baseURL}${endpoint}`;
      const parsed = url.parse(fullUrl);
      const isHttps = parsed.protocol === 'https:';
      const transport = isHttps ? https : http;

      const payload = body ? JSON.stringify(body) : null;

      const options = {
        hostname: parsed.hostname,
        port: parsed.port || (isHttps ? 443 : 80),
        path: parsed.path,
        method: method,
        timeout: 5000,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${this.adminToken}`,
          'User-Agent': 'TIME_PARKIN_DISCORD_BOT_v14'
        }
      };

      if (payload) {
        options.headers['Content-Length'] = Buffer.byteLength(payload);
      }

      const req = transport.request(options, (res) => {
        let data = '';
        res.on('data', chunk => data += chunk);
        res.on('end', () => {
          try {
            const json = JSON.parse(data);
            resolve({ statusCode: res.statusCode, data: json });
          } catch (err) {
            resolve({ statusCode: res.statusCode, raw: data });
          }
        });
      });

      req.on('timeout', () => {
        req.destroy();
        reject(new Error('API Request timed out (5s)'));
      });

      req.on('error', (err) => {
        reject(err);
      });

      if (payload) {
        req.write(payload);
      }
      req.end();
    });
  }

  getSystemStatus() {
    return this.request('/api/v1/admin/status', 'GET');
  }

  setClock(enabled, operator) {
    return this.request('/api/v1/admin/clock', 'POST', { enabled, operator });
  }

  setUpdateMode(enabled, operator) {
    return this.request('/api/v1/admin/update', 'POST', { enabled, operator });
  }

  restartSystem(operator) {
    return this.request('/api/v1/admin/restart', 'POST', { operator });
  }
}

module.exports = new ApiClient();
