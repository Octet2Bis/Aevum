/**
 * Serveur statique du simulateur Aevum — développement local, sans cache.
 * N'écoute que sur 127.0.0.1 sauf HOST explicite ; ne sert que ce dossier.
 */
const http = require('http');
const fs = require('fs');
const path = require('path');

const PORT = process.env.PORT || 3000;
const PUBLIC_DIR = __dirname;

const MIME_TYPES = {
  '.html': 'text/html; charset=utf-8',
  '.css': 'text/css; charset=utf-8',
  '.js': 'application/javascript; charset=utf-8',
  '.json': 'application/json; charset=utf-8',
  '.png': 'image/png',
  '.jpg': 'image/jpeg',
  '.svg': 'image/svg+xml'
};

function send(res, status, body) {
  res.writeHead(status, { 'Content-Type': 'text/plain; charset=utf-8' });
  res.end(body);
}

/** Chemin disque de la requête, ou null s'il sort du dossier public. */
function resolveRequest(url) {
  let pathname;
  try {
    pathname = decodeURIComponent(new URL(url, 'http://localhost').pathname);
  } catch {
    return null;
  }
  if (pathname.includes('\0')) return null;
  if (pathname === '/') pathname = '/index.html';
  const filePath = path.resolve(PUBLIC_DIR, '.' + pathname);
  return filePath.startsWith(PUBLIC_DIR + path.sep) ? filePath : null;
}

const server = http.createServer((req, res) => {
  const filePath = resolveRequest(req.url);
  if (!filePath) return send(res, 404, '404 Not Found');

  fs.readFile(filePath, (err, content) => {
    if (err) {
      const missing = err.code === 'ENOENT' || err.code === 'EISDIR' || err.code === 'ENOTDIR';
      return missing ? send(res, 404, '404 Not Found') : send(res, 500, '500 Server Error');
    }
    // Zéro cache pour le développement local
    res.writeHead(200, {
      'Content-Type': MIME_TYPES[path.extname(filePath).toLowerCase()] || 'text/plain; charset=utf-8',
      'Cache-Control': 'no-cache, no-store, must-revalidate',
      'Pragma': 'no-cache',
      'Expires': '0'
    });
    res.end(content);
  });
});

server.listen(PORT, process.env.HOST || '127.0.0.1', () => {
  const { address, port } = server.address();
  console.log(`Simulateur Aevum : http://${address}:${port}`);
});
