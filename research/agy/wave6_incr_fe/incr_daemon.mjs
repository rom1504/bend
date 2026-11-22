#!/usr/bin/env node
/**
 * Wave 6 Persistent Incremental Compiler Daemon (`incr_daemon.mjs`).
 *
 * Loads `api.mjs` + `p88_cache_prepare` ONCE, keeps V8 JIT warm and per-file
 * incremental frontend/lowering sessions in memory, and serves JSON-line compile
 * requests over a Unix domain socket.
 *
 * Usage:
 *   taskset -c 0,1,4,5 bash research/agy/locked_node.sh research/agy/wave6_incr_fe/incr_daemon.mjs \
 *     --api selfhost/build/agy/wave5c_unified/api.mjs \
 *     --socket /tmp/agy_w6_incr_fe/daemon.sock
 */
import fs from 'node:fs';
import net from 'node:net';
import path from 'node:path';
import {IncrCompilerEngine} from './incr_engine.mjs';

function parseArgs(argv) {
  const opts = {
    api: null,
    socket: '/tmp/agy_w6_incr_fe/daemon.sock',
    idleSec: 0,
  };
  for (let i = 2; i < argv.length; i++) {
    const a = argv[i];
    if (a === '--api') opts.api = path.resolve(argv[++i]);
    else if (a === '--socket') opts.socket = path.resolve(argv[++i]);
    else if (a === '--idle-sec') opts.idleSec = parseInt(argv[++i], 10);
    else throw new Error(`Unknown arg: ${a}`);
  }
  if (!opts.api) throw new Error('Required: --api <api.mjs>');
  return opts;
}

async function main() {
  const opts = parseArgs(process.argv);
  const engine = new IncrCompilerEngine(opts.api);
  const startup = await engine.init();

  fs.mkdirSync(path.dirname(opts.socket), {recursive: true});
  try { fs.unlinkSync(opts.socket); } catch {}

  let active = 0;
  let idleTimer = null;
  function resetIdle() {
    if (idleTimer) clearTimeout(idleTimer);
    if (opts.idleSec > 0 && active === 0) {
      idleTimer = setTimeout(() => {
        server.close(() => process.exit(0));
      }, opts.idleSec * 1000);
    }
  }

  // Serialize requests inside the daemon so V8 heap / session state stays race-free
  let queue = Promise.resolve();

  const server = net.createServer((conn) => {
    let buf = '';
    conn.setEncoding('utf8');
    conn.on('data', (chunk) => {
      buf += chunk;
      let nl;
      while ((nl = buf.indexOf('\n')) !== -1) {
        const line = buf.slice(0, nl).trim();
        buf = buf.slice(nl + 1);
        if (!line) continue;
        let req;
        try {
          req = JSON.parse(line);
        } catch (e) {
          conn.write(JSON.stringify({ok: false, error: 'invalid json: ' + e.message}) + '\n');
          continue;
        }
        if (req.cmd === 'ping') {
          conn.write(JSON.stringify({ok: true, startup, pid: process.pid}) + '\n');
          continue;
        }
        if (req.cmd === 'shutdown') {
          conn.write(JSON.stringify({ok: true, shuttingDown: true}) + '\n');
          conn.end();
          server.close(() => {
            try { fs.unlinkSync(opts.socket); } catch {}
            process.exit(0);
          });
          return;
        }
        if (req.cmd === 'clear_sessions') {
          engine.sessions.clear();
          conn.write(JSON.stringify({ok: true}) + '\n');
          continue;
        }
        active++;
        if (idleTimer) clearTimeout(idleTimer);
        queue = queue.then(async () => {
          try {
            const summary = await engine.compile(req);
            conn.write(JSON.stringify({ok: true, summary}) + '\n');
          } catch (e) {
            conn.write(JSON.stringify({ok: false, error: e?.stack ?? String(e)}) + '\n');
          } finally {
            active--;
            resetIdle();
          }
        });
      }
    });
  });

  server.listen(opts.socket, () => {
    process.stdout.write(JSON.stringify({ready: true, socket: opts.socket, pid: process.pid, startup}) + '\n');
    resetIdle();
  });

  const cleanup = () => {
    try { fs.unlinkSync(opts.socket); } catch {}
    process.exit(0);
  };
  process.on('SIGINT', cleanup);
  process.on('SIGTERM', cleanup);
}

main().catch((e) => {
  console.error(e?.stack ?? String(e));
  process.exit(1);
});
