#!/usr/bin/env node
/**
 * Minimal Bend IO trampoline for running `selfhost/build/agy/wave10_unified/api.mjs`
 * CLI entrypoints (`w8_dispatch_args`: `x86-iface`, `x86-module`, `x86-merge-obj`, `--trace`, ...).
 * Zero compiler logic in JS — 100% of `x86-iface`, `x86-module`, and `x86-merge-obj` executes
 * inside the pure-Bend compiled `api.mjs`.
 */
import fs from 'node:fs';
import path from 'node:path';
import {pathToFileURL} from 'node:url';

const apiPath = process.argv[2];
const cliArgs = process.argv.slice(3);
if (!apiPath) {
  fs.writeSync(2, 'usage: run_w10_cli.mjs <api.mjs> <compiler args...>\n');
  process.exit(2);
}

const mod = await import(pathToFileURL(path.resolve(apiPath)).href);
const api = mod.default ?? mod;

function toBendList(arr) {
  let xs = {$: 'Nil'};
  for (let i = arr.length - 1; i >= 0; i--) {
    xs = {$: 'Con', head: arr[i], tail: xs};
  }
  return xs;
}

function unlistBytes(xs) {
  const out = [];
  let cur = xs;
  while (cur && cur.$ === 'Con') {
    out.push(cur.head & 255);
    cur = cur.tail;
  }
  return Buffer.from(out);
}

const done = (v) => ({$: 'Done', value: v});
const fail = (code, msg = '') => ({$: 'Fail', error: {$: 'Tuple', fst: code >>> 0, snd: msg}});
const tup = (a, b) => ({$: 'Tuple', fst: a, snd: b});
const unit = {$: 'Unit'};

// Run the CPS IO thunk produced by api.w8_dispatch_args(toBendList(cliArgs))
const ioThunk = api.w8_dispatch_args(toBendList(cliArgs));
let step = typeof ioThunk === 'function' ? ioThunk((v) => ({$: 'PureDone', value: v})) : ioThunk;

while (step && typeof step === 'object') {
  if (step.$ === 'PureDone') {
    process.exit(typeof step.value === 'number' ? step.value : 0);
  }
  if (step.$ === 'Halt') {
    const msg = typeof step.message === 'string' ? step.message : String(step.message ?? '');
    if (msg) fs.writeSync(2, msg + '\n');
    process.exit((step.code >>> 0) || 1);
  }
  let res;
  switch (step.$) {
    case 'File.open': {
      const [p, mode] = step.args;
      try {
        const fd = fs.openSync(p, mode === 'x' ? 'wx' : mode, 0o644);
        res = done(fd);
      } catch (e) {
        res = fail(Math.abs(e.errno ?? 5), e.message ?? '');
      }
      break;
    }
    case 'File.size': {
      const [fd] = step.args;
      try {
        const sz = fs.fstatSync(fd).size;
        res = tup(fd, done(sz >>> 0));
      } catch (e) {
        res = tup(fd, fail(Math.abs(e.errno ?? 5), e.message ?? ''));
      }
      break;
    }
    case 'File.read': {
      const [fd, max] = step.args;
      try {
        const len = Math.min(max, 2147483647);
        let room = 65536;
        try {
          const st = fs.fstatSync(fd);
          if (st.isFile()) room = Math.max(room, st.size + 1);
        } catch {}
        let buf = Buffer.allocUnsafe(Math.max(Math.min(len, room), 1));
        let got = 0;
        while (got < len) {
          if (got === buf.length) {
            const next = Buffer.allocUnsafe(Math.min(len, buf.length * 2));
            buf.copy(next, 0, 0, got);
            buf = next;
          }
          const n = fs.readSync(fd, buf, got, Math.min(buf.length, len) - got, null);
          if (n === 0) break;
          got += n;
        }
        res = tup(fd, done(buf.subarray(0, got).toString('utf8')));
      } catch (e) {
        res = tup(fd, fail(Math.abs(e.errno ?? 5), e.message ?? ''));
      }
      break;
    }
    case 'File.write': {
      const [fd, data] = step.args;
      try {
        const buf = Buffer.from(data, 'utf8');
        let at = 0;
        while (at < buf.length) {
          const n = fs.writeSync(fd, buf, at, buf.length - at);
          if (n === 0) throw Object.assign(new Error('short write'), {errno: 5});
          at += n;
        }
        res = tup(fd, done(unit));
      } catch (e) {
        res = tup(fd, fail(Math.abs(e.errno ?? 5), e.message ?? ''));
      }
      break;
    }
    case 'File.write_bytes': {
      const [fd, data] = step.args;
      try {
        const buf = unlistBytes(data);
        let at = 0;
        while (at < buf.length) {
          const n = fs.writeSync(fd, buf, at, buf.length - at);
          if (n === 0) throw Object.assign(new Error('short write'), {errno: 5});
          at += n;
        }
        res = tup(fd, done(unit));
      } catch (e) {
        res = tup(fd, fail(Math.abs(e.errno ?? 5), e.message ?? ''));
      }
      break;
    }
    case 'File.close': {
      const [fd] = step.args;
      try { fs.closeSync(fd); } catch {}
      res = unit;
      break;
    }
    case 'IO.print_err': {
      const [text] = step.args;
      fs.writeSync(2, text);
      res = unit;
      break;
    }
    case 'IO.now': {
      res = Math.floor(Date.now());
      break;
    }
    default:
      fs.writeSync(2, `run_w10_cli: unhandled effect ${step.$}\n`);
      process.exit(1);
  }
  step = step.kont(res);
}
process.exit(typeof step === 'number' ? step : 0);
