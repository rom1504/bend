// Direct JavaScript backend runtime. Generated output embeds this fragment.
// Runtime and effect scheduler ported from bend2/comp.ts at
// 9a4223d577ba56a0cb53d1fd952d2b481c38930f (Phase182).
// No TypeScript compiler/runtime dependency is used by ordinary compilation.
// Nat is Number internally and at the host edge; nat_in validates scalar input.
// Char preserves every U32 in a packed string; str_in/out bound host text.
// Local differences: NaN-payload-safe f32_bits, variadic direct-tail payloads,
// typed pure-main readback, and a default one-word Array.new cell layout.
// Foreign IO requires the host emitter to provide an ESM require binding.

function word_to_u32(w) {
  let x = 0;
  for (let i = 0; w.$ === "WCon"; i++) {
    x |= Number(w.head) << i;
    w = w.tail;
  }
  return x >>> 0;
}

function u32_to_word(x) {
  let w = {$: "WNil"};
  for (let i = 31; i >= 0; i--) {
    w = {$: "WCon", head: ((x >>> i) & 1) === 1, tail: w};
  }
  return w;
}

function cmp_new(a, b) {
  return {$: a < b ? "LT" : a === b ? "EQ" : "GT"};
}

function tup_new(a, b) {
  return {$: "Tuple", fst: a, snd: b};
}

function nat_divmod(a, b) {
  return tup_new(b && Math.trunc(a / b), b ? a % b : a);
}

function nat_chk(n) {
  if (n > 281474976710655) {
    throw "bend: a Nat past the largest immediate 2^48-1";
  }
  return n;
}

function nat_in(n) {
  if (!Number.isInteger(n) || n < 0 || n > 2 ** 53) {
    throw "bend: expected a Nat host number: an integer from 0 to 2^53";
  }
  return n;
}

function f32_show(x) {
  let s = "nan";
  for (let p = 1; x === x && p <= 9 && f32_round(s) !== x; p += 1) {
    s = String(Number(x.toExponential(p - 1)));
  }
  return (Object.is(x, -0) ? "-0" : s).replace("Infinity", "inf");
}

function f32_bits(x) {
  // Avoid an intermediate JS array: its cold element-kind transition can
  // canonicalize a Number NaN and discard a payload on only one conversion.
  // Fresh storage keeps nested host coercions independent; the store coerces once.
  const f = new Float32Array(1);
  f[0] = x;
  return new Uint32Array(f.buffer)[0];
}

function f32_from_bits(u) {
  return new Float32Array(new Uint32Array([u]).buffer)[0];
}

function f32_read(s) {
  const re = /^[\t\n\v\f\r ]*[+-]?((\d+(?:\.\d*)?|\.\d+)(e[+-]?\d+)?|inf(inity)?|nan)$/i;
  return re.test(s) ? {$: "Some", value: f32_round(
    s.replace(/inf\w*/i, "Infinity"))} : {$: "None"};
}

const f32_round = function f32_round(s) {
  const d = Number(s);
  const a = Math.abs(d);
  const f = Math.fround(a);
  const g = 2 * a - Math.min(f, 2 ** 128);
  if (g === f || Math.fround(g) !== g || g === Infinity) {
    return Math.sign(d) * f;
  }
  let k = 0;
  while (a * 2 ** k % 1 !== 0) {
    k += 1;
  }
  const [, i, r, e] = /(\d*)\.?(\d*)(?:e([+-]?\d+))?$/i.exec(s);
  const n = Number(e ?? 0) - r.length;
  const x = BigInt(i + r) * 2n ** BigInt(k) * 10n ** BigInt(Math.max(n, 0));
  const y = BigInt(a * 2 ** k) * 10n ** BigInt(Math.max(-n, 0));
  return Math.sign(d) * (x === y || x > y !== g > f ? f : g);
};

function char_new(c) {
  return c < 0xD800 ? String.fromCharCode(c)
    : c >= 0xE000 && c <= 0x10FFFF ? String.fromCodePoint(c)
    : String.fromCharCode(0xDC00, c >>> 22, c >>> 11 & 0x7FF, c & 0x7FF);
}

function char_len(s, at = 0) {
  const c = s.codePointAt(at);
  return c === 0xDC00 ? 4 : c > 0xFFFF ? 2 : 1;
}

function char_code(s) {
  return s.length < 4 ? s.codePointAt(0)
    : (s.charCodeAt(1) << 22 | s.charCodeAt(2) << 11 | s.charCodeAt(3)) >>> 0;
}

function string_contains(s, p) {
  // A match starts at a Char, not inside a packed U32 code.
  for (let at = 0; at <= s.length; at += char_len(s, at)) {
    if (s.startsWith(p, at)) {
      return true;
    }
  }
  return false;
}

function str_out(s) {
  return s.replace(/\uDC00[^]{3}/gu, "\uFFFD");
}

function str_in(s) {
  return s.replace(/\p{Cs}/gu, "\uFFFD");
}

// Array
// =====

function array_new(d, v, lgs = 0) {
  if (d > 31 - lgs) {
    throw "bend: an array past the deepest block class 31 (depth + log2 words per cell)";
  }
  return Array(2 ** d).fill(v);
}

function array_node(a, b) {
  if (a.length !== b.length) {
    throw "bend: runtime fail-stop";
  }
  return a.concat(b);
}

function array_rmw(a, i, f) {
  const old = a[i %= a.length];
  a[i] = f(old);
  return tup_new(a, old);
}

// Run
// ===

function run_tail(f, x) {
  return {$: "$JMP", f: f.j?.f === f ? f.j : f, x: [x]};
}

function run_clo(j) {
  const f = (x) => run_loop(j(x));
  f.j = j;
  j.f = f;
  return f;
}

function run_loop(r) {
  while (r !== null && typeof r === "object" && r.$ === "$JMP") {
    r = r.f(...r.x);
  }
  return r;
}

function run_lib(f, n) {
  return (...a) => a.length < n ? run_lib((...b) => f(...a, ...b), n - a.length)
    : run_loop(f(...a));
}

// Effect
// ======

const $0eff = Object.create(null);
const io_file_append = new Set();

function io_eff(k, run) {
  if (arguments.length > 2) {
    throw new Error("bend: " + k + " takes no need: an effect that waits parks itself");
  }
  if (k in $0eff) {
    throw new Error("bend: two effects register " + k);
  }
  $0eff[k] = run;
}

// Cli
// ===

let cli_args = [];

function cli(argv) {
  let rts = false;
  cli_args.push(argv[0]);
  for (let i = 1; i < argv.length; i += 1) {
    const a = argv[i];
    if (a === "--RTS") {
      cli_args.push(...argv.slice(i + 1));
      break;
    } else if (a === "+RTS" || a === "-RTS") {
      rts = a === "+RTS";
    } else if (!rts) {
      cli_args.push(a);
    } else if (a === "--help" || a === "--gpu-build") {
      io_out(1, io_bytes(a === "--help" ? "usage: " + argv[0] + "\n" : ""));
      process.exit(0);
    } else {
      const re = a === "--threads" ? /^0*[1-9]\d*$/ : a === "--gpu"
        ? /^(on|off|(\d*(?:\.\d*)?)([GM])B)$/ : undefined;
      const m  = re?.exec(argv[++i]);
      if (!m || m[3]
        && !(m[2] * 2 ** (m[3] === "G" ? 30 : 20) >= 16384)) {
        io_errs("bend: " + (re === undefined ? "unknown runtime option " + a
          : a === "--gpu" ? "expected on, off or a size like 4GB after --gpu"
          : "expected a thread count of 1 or more after --threads"));
        process.exit(1);
      }
    }
  }
}

// Show
// ====

// show_val prints a pure main's value as term_show does (see show_main);
// chain is the bracket it continues, or 0. show_chr escapes as char_show.

function show_chr(s, q) {
  const c = char_code(s);
  const k = { 10: "n", 9: "t", 13: "r", 0: "0", 92: "\\" }[c]
    ?? (s === q ? q : null);
  return k !== null ? "\\" + k : c < 32 || c === 127
    || c > 0x10FFFF || (c >= 0xD800 && c <= 0xDFFF) ? "\\u{" + c.toString(16) + "}" : s;
}

function show_val(D, d, v, chain) {
  if (D[d] === 7) {
    const fs = Object.values(typeof v === "boolean"
      ? { $: v ? "True" : "False" } : v);
    let a = d + 3;
    for (; D[a + 1] !== fs[0]; a += 4 + 2 * D[a + 2]) {}
    const o = "{[("[D[a + 3]];
    let s = o === "{" ? D[a] + "{" : chain === o ? "" : o;
    for (const [j, f] of fs.slice(1).entries()) {
      if (o === "[" ? j === 0 && chain === o : j > 0) {
        s += ", ";
      }
      s += show_val(D, D[a + 5 + 2 * j], f, j === 1 && o !== "{" ? o : 0);
    }
    return o === "{" || chain !== o ? s + "}])"[D[a + 3]] : s;
  }
  return D[d] === 0 ? String(v)
    : D[d] === 1 ? f32_show(v).replace(/^-?\d+(?=e|$)/, "$&.0")
    : D[d] === 2 ? v + "n"
    : D[d] === 3 ? "'" + show_chr(v, "'") + "'"
    : D[d] === 4 ? "\"" + show_text(v) + "\""
    : D[d] === 5 ? "{==}"
    : "[" + v.map((x) => show_val(D, D[d + 1], x, 0)).join(", ") + "]";
}

function show_text(s) {
  let out = "";
  for (let at = 0; at < s.length; at += char_len(s, at)) {
    out += show_chr(s.slice(at, at + char_len(s, at)), "\"");
  }
  return out;
}

// Io
// ==

// Apple arm64 passes variadic fcntl flags on the stack, so io_sys passes
// them as the ninth argument. A parked effect waits for fd (a write when
// out) and/or until at; once due, io_wait calls more and resumes k with its
// value, or parks it again on undefined. Waits stay in deadline order.

function io_exit(main, show) {
  try {
    if (show !== null) {
      io_out(1, io_bytes(show_val(show, 0, run_loop(main()), 0) + "\n"));
      process.exit(0);
    }
    process.exit(io_run(main));
  } catch (e) {
    io_errs(String(e));
    process.exit(1);
  }
}

function io_out(fd, data) {
  const fs = require("fs");
  for (let at = 0; at < data.length;) {
    try {
      const n = fs.writeSync(fd, data.subarray(at));
      if (n === 0) {
        throw "no progress";
      }
      at += n;
    } catch (e) {
      if (e.code === "EAGAIN" || e.code === "EINTR") {
        continue;
      }
      // Bun ignores SIGPIPE until a listener comes and goes.
      if (e.code === "EPIPE") {
        process.on("SIGPIPE", () => {}).removeAllListeners("SIGPIPE")
          .kill(process.pid, "SIGPIPE");
      }
      try {
        fs.writeSync(2, "bend: a short write on a standard stream\n");
      } catch (o) {
      }
      process.exit(1);
    }
  }
}

// Non-TTY stdout flushes before waits, errors, exits, or at 64 KiB.

let io_held = null;

function io_std(data) {
  io_held ??= !require("tty").isatty(1) && [];
  if (!io_held) {
    return io_out(1, data);
  }
  io_held.push(data);
  io_held.n = (io_held.n ?? 0) + data.length;
  if (io_held.n >= 65536) {
    io_sync();
  }
}

function io_sync() {
  if (io_held?.length > 0) {
    io_held.n = 0;
    io_out(1, Buffer.concat(io_held.splice(0)));
  }
}

function io_errs(message) {
  io_sync();
  io_out(2, io_bytes(message + "\n"));
}

function io_sys() {
  if (globalThis.BEND_SYS === undefined) {
    const ffi = require("bun:ffi");
    const mac = process.platform === "darwin";
    const err = mac ? "__error" : "__errno_location";
    const sel = mac ? "select$DARWIN_EXTSN" : "select";
    const T = { i: "i32", u: "u32", U: "u64", I: "i64", p: "ptr",
      c: "cstring" };
    const vari = mac && process.arch === "arm64";
    const lib = ffi.dlopen(mac ? "libSystem.dylib" : "libc.so.6",
      Object.fromEntries(("socket:iii>i bind:ipu>i listen:ii>i connect:ipu>i"
        + " accept:ipp>i send:ipUi>I recv:ipUi>I read:ipU>I"
        + " sendto:ipUipu>I recvfrom:ipUipp>I close:i>i setsockopt:iiipu>i"
        + " " + sel + ":ipppp>i"
        + " fcntl:iii" + (vari ? "iiiiii" : "") + ">i getsockopt:iiipp>i"
        + " strerror:i>c " + err + ":>p").split(" ").map((s) => {
        const [name, args, ret] = s.split(/[:>]/);
        return [name, { args: [...args].map((a) => T[a]), returns: T[ret] }];
      }))).symbols;
    const fcntl = vari ? (fd, cmd, arg) => lib.fcntl(fd, cmd, 0, 0, 0, 0, 0,
      0, arg) : lib.fcntl;
    globalThis.BEND_SYS = { ...lib, fcntl, select: lib[sel],
      ptr: ffi.ptr, mac,
      errno: () => ffi.read.i32(lib[err](), 0) };
  }
  return globalThis.BEND_SYS;
}

// Without bun:ffi, errors use bare errno.
function io_fail(code, ...rest) {
  let text = "errno " + code;
  try {
    text = String(io_sys().strerror(code));
  } catch (_) {
  }
  return { $: "Fail", error: io_tup(io_tup(code >>> 0, text), ...rest) };
}

function io_done(value) {
  return { $: "Done", value };
}

function io_until(ms) {
  return performance.now() + Number(ms);
}

function io_late(at) {
  return at !== undefined && performance.now() >= at;
}

function io_ready(at, r) {
  return at === undefined ? r : { $: "Ready", value: r };
}

function io_tup(...xs) {
  return xs.reduceRight((b, a) => tup_new(a, b));
}

const io_enc = new TextEncoder();

function io_bytes(text) {
  return io_enc.encode(str_out(text));
}

function io_text(b, n) {
  return new TextDecoder("utf-8", { ignoreBOM: true }).decode(b.subarray(0, n));
}

function io_list(b, n) {
  let xs = { $: "Nil" };
  while (n > 0) {
    xs = { $: "Con", head: b[--n], tail: xs };
  }
  return xs;
}

function io_unlist(xs) {
  const b = [];
  for (; xs.$ === "Con"; xs = xs.tail) {
    b.push(xs.head);
  }
  return b.some((x) => x > 255) ? null : Uint8Array.from(b);
}

function io_addr(host, port) {
  const part = host.split(".");
  const deci = (p) => /^(0|[1-9]\d{0,2})$/.test(p) && Number(p) < 256;
  if (port > 65535 || part.length !== 4 || !part.every(deci)) {
    return null;
  }
  const b = new Uint8Array(16);
  b.set([...io_sys().mac ? [16, 2] : [2, 0], port >> 8, port & 255,
    ...part.map(Number)]);
  return b;
}

let io_active;

function io_push(fun, arg, fresh, io = io_active) {
  io.runs.push({ fun, arg });
  io.live += fresh ? 1 : 0;
}

function io_wait(io, block) {
  const soon = io.waits[0]?.at ?? Infinity;
  const ms = !block ? 0 : soon === Infinity ? -1
    : Math.max(0, Math.ceil(soon - performance.now()));
  const fds = io.waits.filter((w) => w.fd !== undefined);
  const top = fds.reduce((m, w) => Math.max(m, w.fd), 0);
  const len = (top >> 6 << 3) + 8;
  const set = new Uint8Array(2 * len);
  const at = (w) => (w.out ? len : 0) + (w.fd >> 3);
  for (const w of fds) {
    set[at(w)] |= 1 << (w.fd & 7);
  }
  const tv = new BigInt64Array([BigInt(ms / 1000 | 0),
    BigInt(ms % 1000 * 1000)]);
  io_sync();
  const sys = fds.length > 0 ? io_sys() : null;
  // Timers need no FFI.
  if (!sys && ms !== 0) {
    Atomics.wait(new Int32Array(new SharedArrayBuffer(4)), 0, 0,
      ms < 0 ? Infinity : ms);
  }
  if (sys?.select(top + 1, sys.ptr(set), sys.ptr(set, len), null,
    ms < 0 ? null : sys.ptr(tv)) < 0) {
    if (sys.errno() !== 4) {
      throw "bend: the poller failed";
    }
    set.fill(0);
  }
  const now = performance.now();
  const due = (w) => w.at <= now || w.fd !== undefined
    && set[at(w)] & 1 << (w.fd & 7);
  const todo = io.waits;
  io.waits = todo.filter((w) => !due(w));
  for (const w of todo.filter(due)) {
    const x = w.more();
    if (x !== undefined) {
      io_push(w.k, x, false, io);
    }
  }
}

function io_park_on(fd, out, k, more, at = Infinity) {
  const ws = io_active.waits;
  const t = { fd, out, k, more, at };
  ws.splice(ws.findLastIndex((w) => w.at <= at) + 1, 0, t);
  return t;
}

function io_run(m) {
  const io = { runs: [], live: 0, waits: [] };
  const parent = io_active;
  io_active = io;
  try {
    io_push(run_loop(m()), (x) => ({ $: "Emit", value: x }), true);
    let look = 0;
    for (let n = 0;; n += 1) {
      if (io.runs.length === 0) {
        if (io.live === 0) {
          return 0;
        }
        if (io.waits.length === 0) {
          io_errs("bend: deadlock: every computation waits on a channel");
          return 1;
        }
        io_wait(io, true);
        continue;
      }
      if ((n & 63) === 0 && io.waits.length > 0) {
        const now = performance.now();
        if (now >= look || io.waits[0].at <= now) {
          look = now + 10;
          io_wait(io, false);
        }
      }
      const s = io.runs.shift();
      let op = s.fun(s.arg);
      for (let left = 64; op !== undefined; left -= 1) {
        if (op.$ === "Emit") {
          io.live -= 1;
          break;
        }
        if (op.$ === "Halt" || op.$ === "Exit") {
          if (op.$ === "Halt") io_errs(op.message);
          if (op.code > 255) {
            io_errs("bend: exit code must be in 0..255");
            return 1;
          }
          return op.code;
        }
        const run = $0eff[op.$];
        if (run === undefined) {
          throw "bend: no effect registers " + op.$;
        }
        const x = run(...op.args, op.kont);
        if (x === undefined) {
          break;
        }
        if (left === 1) {
          io_push(op.kont, x, false, io);
          break;
        }
        op = op.kont(x);
      }
    }
  } catch (e) {
    throw e instanceof RangeError ? "bend: memory fault (machine stack overflow?)" : e;
  } finally {
    io_sync();
    io.done = true;
    io_active = parent;
  }
}

// Direct core names. A named tail call carries all already-evaluated arguments;
// run_tail above retains the upstream unary native-closure protocol unchanged.
const jd_run = run_loop;
const jd_clo = run_clo;
function jd_tail(f, args) {
  return {$: "$JMP", f, x: args};
}
