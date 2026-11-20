/**
 * Test du serveur du simulateur Aevum — sans dépendance.
 *   node web_preview/tests/server.test.js
 * Lance le vrai server.js sur un port libre, adresse d'écoute par défaut.
 * Code de sortie 1 au premier échec.
 */
const { spawn } = require('node:child_process');
const http = require('node:http');
const path = require('node:path');
const assert = require('node:assert');

const SERVER = path.join(__dirname, '..', 'server.js');

function start() {
  const env = { ...process.env, PORT: '0' };
  delete env.HOST;
  const child = spawn(process.execPath, [SERVER], { env, stdio: ['ignore', 'pipe', 'pipe'] });
  return new Promise((resolve, reject) => {
    let out = '';
    const timer = setTimeout(() => reject(new Error(`serveur muet : ${out}`)), 5000);
    child.stdout.on('data', (c) => {
      out += c;
      const m = out.match(/http:\/\/([^\s:]+):(\d+)/);
      if (m) { clearTimeout(timer); resolve({ child, host: m[1], port: Number(m[2]) }); }
    });
    child.on('exit', (code) => reject(new Error(`serveur arrêté (code ${code}) : ${out}`)));
  });
}

// Chemin envoyé tel quel, sans normalisation (équivalent de curl --path-as-is).
function get(port, rawPath) {
  return new Promise((resolve, reject) => {
    const req = http.request({ host: '127.0.0.1', port, path: rawPath, method: 'GET' }, (res) => {
      let body = '';
      res.on('data', (c) => { body += c; });
      res.on('end', () => resolve({ status: res.statusCode, body }));
    });
    req.on('error', reject);
    req.end();
  });
}

(async () => {
  let failed = 0;
  let srv;
  try {
    srv = await start();
  } catch (e) {
    console.error(`❌ Démarrage : ${e.message}`);
    process.exit(1);
  }
  const { child, host, port } = srv;

  const cases = [
    ["L'adresse d'écoute par défaut est 127.0.0.1", async () => assert.strictEqual(host, '127.0.0.1')],
    ['GET / sert index.html', async () => {
      const r = await get(port, '/');
      assert.strictEqual(r.status, 200);
      assert.ok(r.body.includes('<html'));
    }],
    ['Un fichier du dossier public est servi', async () => {
      assert.strictEqual((await get(port, '/data/longevity_catalog.json')).status, 200);
    }],
    ['Traversée ../ -> 404', async () => {
      assert.strictEqual((await get(port, '/../product.json')).status, 404);
      assert.strictEqual((await get(port, '/data/../../product.json')).status, 404);
    }],
    ['Traversée encodée %2e%2e et %2f -> 404', async () => {
      assert.strictEqual((await get(port, '/%2e%2e/product.json')).status, 404);
      assert.strictEqual((await get(port, '/..%2fproduct.json')).status, 404);
      assert.strictEqual((await get(port, '/%2e%2e%2f%2e%2e%2fproduct.json')).status, 404);
    }],
    ['Traversée par antislash -> 404', async () => {
      assert.strictEqual((await get(port, '/..\\product.json')).status, 404);
      assert.strictEqual((await get(port, '/..%5cproduct.json')).status, 404);
    }],
    ['Octet nul et encodage invalide -> 404', async () => {
      assert.strictEqual((await get(port, '/index.html%00.js')).status, 404);
      assert.strictEqual((await get(port, '/%E0%A4%A')).status, 404);
    }],
    ['/career n\'existe plus -> 404', async () => {
      assert.strictEqual((await get(port, '/career')).status, 404);
      assert.strictEqual((await get(port, '/career/gitbook')).status, 404);
      assert.strictEqual((await get(port, '/career/acme/CV_acme.txt')).status, 404);
    }],
    ['Ancien tracking retiré -> 404', async () => {
      assert.strictEqual((await get(port, '/t/click?target=https://example.com')).status, 404);
      assert.strictEqual((await get(port, '/api/tracking/events')).status, 404);
    }],
    ['Le process répond encore ensuite', async () => {
      assert.strictEqual(child.exitCode, null);
      assert.strictEqual((await get(port, '/')).status, 200);
    }],
  ];

  for (const [name, fn] of cases) {
    try {
      await fn();
      console.log(`✅ ${name}`);
    } catch (e) {
      failed += 1;
      console.error(`❌ ${name} : ${e.message}`);
    }
  }

  child.removeAllListeners('exit');
  child.kill();
  console.log(failed ? `\n${failed} test(s) en échec` : `\n${cases.length} tests verts`);
  process.exit(failed ? 1 : 0);
})();
