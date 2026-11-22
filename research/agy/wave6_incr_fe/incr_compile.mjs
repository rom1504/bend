#!/usr/bin/env node
/**
 * Wave 6 Incremental Compiler CLI (`incr_compile.mjs`).
 *
 * Drop-in replacement for Wave 5 `incr_compile.mjs`.
 * If `--socket <path>` points to a running `incr_daemon.mjs`, dispatches the build
 * over Unix domain socket (eliminating ~600 ms Node/api.mjs/base-cache startup +
 * leveraging in-memory incremental frontend/lowering state!).
 */
import net from 'node:net';
import path from 'node:path';
import {fileURLToPath} from 'node:url';
import {IncrCompilerEngine} from './incr_engine.mjs';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const REPO = path.resolve(__dirname, '../../..');
const DEFAULT_RT = path.join(REPO, 'selfhost/build/agy/unified/runtime-agy.o');

function parseArgs(argv) {
  const opts = {
    api: null,
    src: null,
    out: null,
    rt: DEFAULT_RT,
    cacheDir: '/tmp/agy_w6_incr_fe/cache',
    shards: 4,
    socket: null,
    json: false,
  };
  for (let i = 2; i < argv.length; i++) {
    const a = argv[i];
    if (a === '--api') opts.api = path.resolve(argv[++i]);
    else if (a === '--src') opts.src = path.resolve(argv[++i]);
    else if (a === '--out') opts.out = path.resolve(argv[++i]);
    else if (a === '--rt') opts.rt = path.resolve(argv[++i]);
    else if (a === '--cache-dir') opts.cacheDir = path.resolve(argv[++i]);
    else if (a === '--shards') opts.shards = Math.max(1, parseInt(argv[++i], 10));
    else if (a === '--socket') opts.socket = path.resolve(argv[++i]);
    else if (a === '--json') opts.json = true;
    else throw new Error(`Unknown arg: ${a}`);
  }
  if (!opts.api || !opts.src || !opts.out) {
    throw new Error('Required: --api <api.mjs> --src <input.bend> --out <exe>');
  }
  return opts;
}

function callDaemon(socketPath, req) {
  return new Promise((resolve, reject) => {
    const conn = net.createConnection(socketPath);
    let buf = '';
    conn.setEncoding('utf8');
    conn.on('connect', () => {
      conn.write(JSON.stringify(req) + '\n');
    });
    conn.on('data', (chunk) => {
      buf += chunk;
      const nl = buf.indexOf('\n');
      if (nl !== -1) {
        const line = buf.slice(0, nl);
        conn.end();
        try {
          const resp = JSON.parse(line);
          if (!resp.ok) reject(new Error(resp.error));
          else resolve(resp.summary);
        } catch (e) {
          reject(e);
        }
      }
    });
    conn.on('error', reject);
  });
}

async function main() {
  const t0 = performance.now();
  const opts = parseArgs(process.argv);
  let summary;
  if (opts.socket) {
    summary = await callDaemon(opts.socket, {
      src: opts.src,
      out: opts.out,
      rt: opts.rt,
      cacheDir: opts.cacheDir,
      shards: opts.shards,
    });
    summary.cliWallMs = Math.round((performance.now() - t0) * 10) / 10;
  } else {
    const engine = new IncrCompilerEngine(opts.api);
    await engine.init();
    summary = await engine.compile(opts);
  }
  if (opts.json) process.stdout.write(JSON.stringify(summary) + '\n');
  else {
    console.log(
      `[W6-INCR:${summary.mode}] units=${summary.totalUnits} hits=${summary.hits} (${summary.hitRatePct}%) misses=${summary.misses} | ` +
      `plan=${summary.planMs}ms pw=${summary.pwMs}ms hash=${summary.hashMs}ms emit=${summary.emitMs}ms link=${summary.linkMs}ms total=${summary.totalMs}ms`
    );
  }
}

main().catch((e) => {
  console.error(e?.stack ?? String(e));
  process.exit(1);
});
