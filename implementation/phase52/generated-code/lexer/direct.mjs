// Direct JavaScript backend runtime. Generated output embeds this fragment.
// Ported from bend2/comp.ts NATIVE.JS, RUNTIME and RUNTIME_MAIN, and
// bend2/bend.ts f32_round at fixed upstream commit
// 018751270e800bc222a93dad7f257083ee53a5f7. The reference files stay unchanged.
// No TypeScript compiler/runtime dependency is used by ordinary compilation.
// Number is the internal Nat representation; nat_host handles typed host input.
// Node foreign IO requires the host emitter to provide an ESM require binding.
// Bun/system calls remain lazy, exactly as in the pinned upstream runtime.

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
  return {$: a < b ? "LT"
    : a === b ? "EQ" : "GT"};
}

function nat_divmod(a, b) {
  return b === 0 ? {$: "Tuple", fst: 0, snd: a}
    : {$: "Tuple", fst: Math.trunc(a / b), snd: a % b};
}

function nat_chk(n) {
  if (n > 281474976710655) {
    throw "bend: a Nat past the largest immediate 2^48-1";
  }
  return n;
}

function nat_host(n) {
  const int = typeof n === "bigint" || Number.isInteger(n);
  if (int && n >= 0 && n <= 2 ** 53) {
    return Number(n);
  }
  return { [Symbol.toPrimitive]() { throw "bend: a Nat past the largest immediate 2^48-1"; } };
}

function f32_show(x) {
  if (x !== x) {
    return "nan";
  }
  if (!Number.isFinite(x) || Object.is(x, -0)) {
    return x < 0 ? "-inf"
      : x === 0 ? "-0" : "inf";
  }
  let s = "x";
  for (let p = 1; p <= 9 && f32_round(s) !== x; p += 1) {
    s = String(Number(x.toExponential(p - 1)));
  }
  return s;
}

function f32_bits(x) {
  return new Uint32Array(new Float32Array([x]).buffer)[0];
}

function f32_from_bits(u) {
  return new Float32Array(new Uint32Array([u]).buffer)[0];
}

function f32_read(s) {
  const re = /^\s*[+-]?((\d+\.?\d*|\.\d+)(e[+-]?\d+)?|inf(inity)?|nan)$/i;
  const v = f32_round(s.replace(/inf\w*/i, "Infinity"));
  return re.test(s) ? {$: "Some", value: v} : {$: "None"};
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

function char_new(code) {
  if (code > 0x10FFFF || (code >= 0xD800 && code <= 0xDFFF)) {
    throw "bend: " + code + " is not a Unicode scalar value";
  }
  return String.fromCodePoint(code);
}
// Array
// =====

function array_new(d, v) {
  if (d > 31) {
    throw "bend: an array past the deepest block class 31";
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
  const at = i % a.length;
  const old = a[at];
  a[at] = f(old);
  return {$: "Tuple", fst: a, snd: old};
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
    : f(...a);
}

// Effect
// ======

const $0eff = Object.create(null);

function io_eff(k, run, need) {
  if (k in $0eff) {
    throw new Error("bend: two effects register " + k);
  }
  $0eff[k] = { run, need };
}

// Cli
// ===

let cli_args = [];

function cli(argv) {
  cli_args.push(argv[0]);
  for (let i = 1; i < argv.length; i += 1) {
    if (argv[i] === "--") {
      cli_args.push(...argv.slice(i + 1));
      break;
    } else if (argv[i] === "--bend-help") {
      io_out(1, io_bytes("usage: " + argv[0] + "\n"));
      process.exit(0);
    } else if (argv[i] === "--threads" || argv[i] === "--gpu") {
      i += 1;
    } else {
      cli_args.push(argv[i]);
    }
  }
}

// Show
// ====

// show_val prints a pure main's value as term_show does (see show_main);
// chain is the bracket it continues, or 0. show_chr escapes as char_show.

function show_chr(c, q) {
  const k = { 10: "n", 9: "t", 13: "r", 0: "0", 92: "\\" }[c]
    ?? (c === q.codePointAt(0) ? q : null);
  return k !== null ? "\\" + k : c < 32 || c === 127
    || (c >= 0xD800 && c <= 0xDFFF) || c > 0x10FFFF
    ? "\\u{" + c.toString(16) + "}" : String.fromCodePoint(c);
}

function show_val(D, N, d, v, chain) {
  if (D[d] === 7) {
    const fs = Object.values(typeof v === "boolean"
      ? { $: v ? "True" : "False" } : v);
    let a = d + 3;
    for (; N[D[a]] !== fs[0]; a += 4 + 2 * D[a + 2]) {}
    const o = "{[("[D[a + 3]];
    let s = o === "{" ? fs[0] + "{" : chain === o ? "" : o;
    for (const [j, f] of fs.slice(1).entries()) {
      if (o === "[" ? j === 0 && chain === o : j > 0) {
        s += ", ";
      }
      s += show_val(D, N, D[a + 5 + 2 * j], f, j === 1 && o !== "{" ? o : 0);
    }
    return o === "{" || chain !== o ? s + "}])"[D[a + 3]] : s;
  }
  return D[d] === 0 ? String(v)
    : D[d] === 1 ? f32_show(v).replace(/^-?\d+(?=e|$)/, "$&.0")
    : D[d] === 2 ? v + "n"
    : D[d] === 3 ? "'" + show_chr(v.codePointAt(0), "'") + "'"
    : D[d] === 4 ? "\"" + [...v].map((c) =>
      show_chr(c.codePointAt(0), "\"")).join("") + "\""
    : D[d] === 5 ? "{==}"
    : "[" + v.map((x) => show_val(D, N, D[d + 1], x, 0)).join(", ") + "]";
}

// Io
// ==

// Apple arm64 passes variadic fcntl flags on the stack, so io_sys
// binds fcntl there with the flags as the ninth fixed argument. A
// parked effect waits for fd (a write when out) or until at
// (performance.now()), either one undefined when unused; io_wake
// resumes k with the value of more, and undefined parks it again. The
// waits stay in deadline order, as io_park does in C.

function io_exit(main, show) {
  try {
    if (show !== null) {
      io_out(1, io_bytes(show_val(...show, 0, run_loop(main()), 0) + "\n"));
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
  let at = 0;
  while (at < data.length) {
    try {
      at += fs.writeSync(fd, data, at, data.length - at);
    } catch (e) {
      if (e.code === "EAGAIN" || e.code === "EINTR") {
        continue;
      }
      try {
        fs.writeSync(2, "bend: a short write on a standard stream\n");
      } catch (o) {
      }
      process.exit(1);
    }
  }
}

function io_errs(message) {
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
        + " accept:ipp>i send:ipUi>I recv:ipUi>I read:ipU>I pread:ipUI>I"
        + " sendto:ipUipu>I recvfrom:ipUipp>I close:i>i setsockopt:iiipu>i"
        + " " + sel + ":ipppp>i"
        + (vari ? " fcntl:iiiiiiiii>i" : " fcntl:iii>i") + " getsockopt:iiipp>i"
        + " strerror:i>c " + err + ":>p").split(" ").map((s) => {
        const [name, args, ret] = s.split(/[:>]/);
        return [name, { args: [...args].map((a) => T[a]), returns: T[ret] }];
      }))).symbols;
    const fcntl = (fd, cmd, arg) => vari
      ? lib.fcntl(fd, cmd, 0, 0, 0, 0, 0, 0, arg)
      : lib.fcntl(fd, cmd, arg);
    globalThis.BEND_SYS = { ...lib, fcntl, select: lib[sel],
      ptr: ffi.ptr, mac,
      errno: () => ffi.read.i32(lib[err](), 0) };
  }
  return globalThis.BEND_SYS;
}

function io_fail(code) {
  return { $: "Fail",
    error: io_tup(code >>> 0, String(io_sys().strerror(code))) };
}

function io_done(value) {
  return { $: "Done", value };
}

function io_tup(...xs) {
  return xs.reduceRight((snd, fst) => ({ $: "Tuple", fst, snd }));
}

function io_bytes(text) {
  return new TextEncoder().encode(text);
}

function io_text(b, n) {
  return new TextDecoder("utf-8", { ignoreBOM: true }).decode(b.subarray(0, n));
}

// Bytes cross as they are (0..255), one List cell each, with no UTF-8 in
// either direction; io_unlist answers null if a value is past 255.
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
  const head = io_sys().mac ? [16, 2] : [2, 0];
  b.set([...head, port >> 8, port & 255, ...part.map(Number)]);
  return b;
}

function io_push(fun, arg, fresh) {
  const io = globalThis.BEND_IO;
  io.runs.push({ fun, arg });
  io.live += fresh ? 1 : 0;
}

function io_wait(io) {
  const soon = io.waits[0]?.at ?? Infinity;
  const ms = soon === Infinity ? -1
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
  const sys = io_sys();
  if (sys.select(top + 1, sys.ptr(set), sys.ptr(set, len), null,
    ms < 0 ? null : sys.ptr(tv)) < 0) {
    if (sys.errno() !== 4) {
      throw "bend: the poller failed";
    }
    set.fill(0);
  }
  const now = performance.now();
  io.waits = io.waits.filter((w) => {
    const ready = w.at <= now || w.fd !== undefined
      && set[at(w)] & 1 << (w.fd & 7);
    if (ready) {
      io_push(io_wake, w, false);
    }
    return !ready;
  });
}

function io_wake(w) {
  const x = w.more();
  return x === undefined ? undefined : w.k(x);
}

function io_park_on(fd, out, k, more, at) {
  const ws = globalThis.BEND_IO.waits;
  const i = ws.findLastIndex((w) => (w.at ?? Infinity) <= (at ?? Infinity));
  ws.splice(i + 1, 0, { fd, out, k, more, at });
}

function io_run(m) {
  const io = { runs: [], live: 0, waits: [] };
  globalThis.BEND_IO = io;
  try {
    io_push(run_loop(m()), (x) => ({ $: "Emit", value: x }), true);
    for (;;) {
      if (io.runs.length === 0) {
        if (io.live === 0) {
          return 0;
        }
        if (io.waits.length === 0) {
          io_errs("bend: deadlock: every computation waits on a channel");
          return 1;
        }
        io_wait(io);
        continue;
      }
      const s = io.runs.shift();
      let op = s.fun(s.arg);
      while (op !== undefined) {
        if (op.$ === "Emit") {
          io.live -= 1;
          break;
        }
        if (op.$ === "Halt") {
          io_errs(op.message);
          return op.code;
        }
        const need = op.need?.() ?? {};
        if (need.time || need.read) {
          const more = () => op.run(...op.args, op.kont);
          io_park_on(need.read ? op.args[0] : undefined, false, op.kont, more,
            need.read ? undefined : performance.now() + Number(op.args[0]));
          break;
        }
        const x = op.run(...op.args, op.kont);
        if (x === undefined) {
          break;
        }
        op = op.kont(x);
      }
    }
  } catch (req) {
    if (req instanceof RangeError) {
      throw "bend: memory fault (machine stack overflow?)";
    }
    if (req?.$ !== "$FFI") {
      throw req;
    }
    io_errs("bend: runtime fail-stop");
    return 1;
  }
}

// Direct core names. A named tail call carries all already-evaluated arguments;
// run_tail above retains the upstream unary native-closure protocol unchanged.
const jd_run = run_loop;
const jd_clo = run_clo;
function jd_tail(f, args) {
  return {$: "$JMP", f, x: args};
}


// Direct JavaScript prototype: native functions and live arguments.
function $jd$Bool_46_and($a0,$a1){for(;;){{const $match1=$a0;if(!$match1){return false;}else{{const $match2=$match1;const $x367=$a1;return (
/*JD_USE:367*/$x367);}}}}}
function $jd$U32_46_add($a0,$a1){return (($a0 + $a1) >>> 0);}
function $jd$U32_46_mul($a0,$a1){return (Math.imul($a0, $a1) >>> 0);}
function $jd$U32_46_xor($a0,$a1){return (($a0 ^ $a1) >>> 0);}
function $jd$U32_46_is_95_ne($a0,$a1){return ($a0 !== $a1);}
function $jd$U32_46_to_95_nat($a0){return $a0;}
function $jd$prng($a0){for(;;){const $x3416=$a0;{const $let0=(
/*JD_REF:$jd$U32_46_xor*/$jd$U32_46_xor((
/*JD_USE:3416*/$x3416),((13 >= 32 ? 0 : ((
/*JD_USE:3416*/$x3416) << 13) >>> 0))));{const $x3417=$let0;{const $let0=(
/*JD_REF:$jd$U32_46_xor*/$jd$U32_46_xor((
/*JD_USE:3417*/$x3417),((17 >= 32 ? 0 : ((
/*JD_USE:3417*/$x3417) >>> 17) >>> 0))));{const $x3418=$let0;return (
/*JD_REF:$jd$U32_46_xor*/$jd$U32_46_xor((
/*JD_USE:3418*/$x3418),((5 >= 32 ? 0 : ((
/*JD_USE:3418*/$x3418) << 5) >>> 0))));}}}}}}
function $jd$seed($a0){for(;;){const $x3420=$a0;return (
/*JD_REF:$jd$prng*/$jd$prng((
/*JD_REF:$jd$U32_46_mul*/$jd$U32_46_mul(((((
/*JD_USE:3420*/$x3420) + 1) >>> 0)),2654435761))));}}
function $jd$salt($a0,$a1){for(;;){const $x3423=$a0;const $x3424=$a1;return (
/*JD_REF:$jd$prng*/$jd$prng((
/*JD_REF:$jd$U32_46_xor*/$jd$U32_46_xor((
/*JD_USE:3423*/$x3423),((Math.imul((
/*JD_USE:3424*/$x3424), 2654435761) >>> 0))))));}}
function $jd$op_46_pick($a0,$a1){for(;;){{const $match1=$a0;if(!$match1){{const $match2=$a1;if(!$match2){return "+";}else{{const $match3=$match2;return "-";}}}}else{{const $match2=$match1;{const $match3=$a1;if(!$match3){return "*";}else{{const $match4=$match3;return "/";}}}}}}}}
function $jd$op($a0,$a1){for(;;){const $x3429=$a0;const $x3430=$a1;return ((
/*JD_REF:$jd$op_46_pick*/$jd$op_46_pick((
/*JD_REF:$jd$U32_46_is_95_ne*/$jd$U32_46_is_95_ne(((((
/*JD_USE:3429*/$x3429) & 2) >>> 0)),0)),(
/*JD_REF:$jd$U32_46_is_95_ne*/$jd$U32_46_is_95_ne(((((
/*JD_USE:3429*/$x3429) & 1) >>> 0)),0))))+(
/*JD_USE:3430*/$x3430));}}
function $jd$ident($a0,$a1,$a2){for(;;){{const $match1=$a0;if($match1===0){const $x3435=$a2;return (
/*JD_USE:3435*/$x3435);}else{const $x3436=($match1-1);const $x3437=$a1;const $x3438=$a2;{const $let0=(
/*JD_REF:$jd$prng*/$jd$prng((
/*JD_USE:3437*/$x3437)));{const $x3439=$let0;return (char_new((
/*JD_REF:$jd$U32_46_add*/$jd$U32_46_add(97,((26 === 0 ? (
/*JD_USE:3439*/$x3439) : (
/*JD_USE:3439*/$x3439) % 26)))))+(
/*JD_REF:$jd$ident*/$jd$ident((
/*JD_USE:3436*/$x3436),(
/*JD_USE:3439*/$x3439),(
/*JD_USE:3438*/$x3438))));}}}}}}
function $jd$num($a0,$a1,$a2){for(;;){{const $match1=$a0;if($match1===0){const $x3444=$a2;return (
/*JD_USE:3444*/$x3444);}else{const $x3445=($match1-1);const $x3446=$a1;const $x3447=$a2;{const $let0=(
/*JD_REF:$jd$prng*/$jd$prng((
/*JD_USE:3446*/$x3446)));{const $x3448=$let0;return (char_new((
/*JD_REF:$jd$U32_46_add*/$jd$U32_46_add(48,((10 === 0 ? (
/*JD_USE:3448*/$x3448) : (
/*JD_USE:3448*/$x3448) % 10)))))+(
/*JD_REF:$jd$num*/$jd$num((
/*JD_USE:3445*/$x3445),(
/*JD_USE:3448*/$x3448),(
/*JD_USE:3447*/$x3447))));}}}}}}
function $jd$expand($a0,$a1,$a2,$a3){for(;;){{const $match1=$a0;if($match1.$==="Id"){const $x3454=$a2;const $x3455=$a3;return (
/*JD_REF:$jd$ident*/$jd$ident((
/*JD_REF:$jd$U32_46_to_95_nat*/$jd$U32_46_to_95_nat((
/*JD_REF:$jd$U32_46_add*/$jd$U32_46_add(1,((((
/*JD_USE:3454*/$x3454) & 7) >>> 0)))))),(
/*JD_USE:3454*/$x3454),(
/*JD_USE:3455*/$x3455)));}else{{const $match2=$match1;if($match2.$==="Nm"){const $x3457=$a2;const $x3458=$a3;return (
/*JD_REF:$jd$num*/$jd$num((
/*JD_REF:$jd$U32_46_to_95_nat*/$jd$U32_46_to_95_nat((
/*JD_REF:$jd$U32_46_add*/$jd$U32_46_add(1,((6 === 0 ? (
/*JD_USE:3457*/$x3457) : (
/*JD_USE:3457*/$x3457) % 6)))))),(
/*JD_USE:3457*/$x3457),(
/*JD_USE:3458*/$x3458)));}else{{const $match3=$match2;if($match3.$==="Op"){const $x3460=$a2;const $x3461=$a3;return (
/*JD_REF:$jd$op*/$jd$op((
/*JD_USE:3460*/$x3460),(
/*JD_USE:3461*/$x3461)));}else{{const $match4=$match3;const $x3462=$a1;const $x3464=$a3;return (char_new((
/*JD_USE:3462*/$x3462))+(
/*JD_USE:3464*/$x3464));}}}}}}}}}
function $jd$slot_46_go($a0,$a1,$a2){for(;;){{const $match1=$a0;if($match1){{const $match2=$a1;if($match2){{const $match3=$a2;if($match3){return ({$:"Id"});}else{return ({$:"Id"});}}}else{{const $match4=$a2;if($match4){return ({$:"Id"});}else{return ({$:"Id"});}}}}}else{{const $match3=$a1;if($match3){{const $match4=$a2;if($match4){return ({$:"Nm"});}else{return ({$:"Nm"});}}}else{{const $match5=$a2;if($match5){return ({$:"Op"});}else{return ({$:"Lit"});}}}}}}}}
function $jd$slot($a0){for(;;){const $x3476=$a0;return (
/*JD_REF:$jd$slot_46_go*/$jd$slot_46_go((((
/*JD_USE:3476*/$x3476) === 105)),(((
/*JD_USE:3476*/$x3476) === 110)),(((
/*JD_USE:3476*/$x3476) === 111))));}}
function $jd$gen_46_at($a0,$a1,$a2){for(;;){const $x3480=$a0;const $x3481=$a1;const $x3482=$a2;return (
/*JD_REF:$jd$expand*/$jd$expand((
/*JD_REF:$jd$slot*/$jd$slot((
/*JD_USE:3480*/$x3480))),(
/*JD_USE:3480*/$x3480),(
/*JD_USE:3481*/$x3481),(
/*JD_USE:3482*/$x3482)));}}
function $jd$gen($a0,$a1,$a2){for(;;){{const $match1=$a0;if($match1===""){return "";}else{{const $match2=$match1;{const $match3=($match2.codePointAt(0)>0xFFFF?$match2.slice(0,2):$match2[0]);const $x3489=($match2.codePointAt(0)>0xFFFF?$match2.slice(2):$match2.slice(1));const $x3490=$a1;const $x3491=$a2;return (
/*JD_REF:$jd$gen_46_at*/$jd$gen_46_at((
/*JD_USE:3488*/$match3.codePointAt(0)),(
/*JD_REF:$jd$salt*/$jd$salt((
/*JD_USE:3490*/$x3490),(
/*JD_USE:3491*/$x3491))),(
/*JD_REF:$jd$gen*/$jd$gen((
/*JD_USE:3489*/$x3489),(
/*JD_USE:3490*/$x3490),((((
/*JD_USE:3491*/$x3491) + 1) >>> 0))))));}}}}}}
function $jd$tpl(){for(;;){return "i = ( n o i ) o ( n o i ) o ( n o i ) ;";}}
function $jd$cls_46_go($a0,$a1,$a2){for(;;){{const $match1=$a0;if($match1){{const $match2=$a1;if($match2){{const $match3=$a2;if($match3){return ({$:"Letter"});}else{return ({$:"Letter"});}}}else{{const $match4=$a2;if($match4){return ({$:"Letter"});}else{return ({$:"Letter"});}}}}}else{{const $match3=$a1;if($match3){{const $match4=$a2;if($match4){return ({$:"Digit"});}else{return ({$:"Digit"});}}}else{{const $match5=$a2;if($match5){return ({$:"Space"});}else{return ({$:"Punct"});}}}}}}}}
function $jd$cls($a0){for(;;){const $x3503=$a0;return (
/*JD_REF:$jd$cls_46_go*/$jd$cls_46_go((
/*JD_REF:$jd$Bool_46_and*/$jd$Bool_46_and(((97 <= (
/*JD_USE:3503*/$x3503))),(((
/*JD_USE:3503*/$x3503) <= 122)))),(
/*JD_REF:$jd$Bool_46_and*/$jd$Bool_46_and(((48 <= (
/*JD_USE:3503*/$x3503))),(((
/*JD_USE:3503*/$x3503) <= 57)))),(((
/*JD_USE:3503*/$x3503) === 32))));}}
function $jd$mix($a0,$a1,$a2){for(;;){const $x3507=$a0;const $x3508=$a1;const $x3509=$a2;return (
/*JD_REF:$jd$U32_46_xor*/$jd$U32_46_xor(((Math.imul((
/*JD_USE:3507*/$x3507), 2654435761) >>> 0)),(
/*JD_REF:$jd$U32_46_add*/$jd$U32_46_add(((Math.imul((
/*JD_USE:3508*/$x3508), 40503) >>> 0)),(
/*JD_USE:3509*/$x3509)))));}}
function $jd$fnv($a0,$a1){for(;;){const $x3512=$a0;const $x3513=$a1;return (
/*JD_REF:$jd$U32_46_mul*/$jd$U32_46_mul(((((
/*JD_USE:3512*/$x3512) ^ (
/*JD_USE:3513*/$x3513)) >>> 0)),16777619));}}
function $jd$step_46_at($a0,$a1,$a2,$a3){for(;;){{const $match1=$a0;if($match1.$==="Gap"){{const $match2=$a1;if($match2.$==="Letter"){const $x3518=$a2;const $x3519=$a3;return ({$:"Tuple",["fst"]:({$:"InId",["h"]:(
/*JD_REF:$jd$fnv*/$jd$fnv(2166136261,(
/*JD_USE:3518*/$x3518)))}),["snd"]:(
/*JD_USE:3519*/$x3519)});}else{{const $match3=$match2;if($match3.$==="Digit"){const $x3520=$a2;const $x3521=$a3;return ({$:"Tuple",["fst"]:({$:"InNm",["v"]:((((
/*JD_USE:3520*/$x3520) - 48) >>> 0))}),["snd"]:(
/*JD_USE:3521*/$x3521)});}else{{const $match4=$match3;if($match4.$==="Space"){const $x3523=$a3;return ({$:"Tuple",["fst"]:({$:"Gap"}),["snd"]:(
/*JD_USE:3523*/$x3523)});}else{{const $match5=$match4;const $x3524=$a2;const $x3525=$a3;return ({$:"Tuple",["fst"]:({$:"Gap"}),["snd"]:(
/*JD_REF:$jd$mix*/$jd$mix((
/*JD_USE:3525*/$x3525),3,(
/*JD_USE:3524*/$x3524)))});}}}}}}}}else{{const $match2=$match1;if($match2.$==="InId"){const $x3526=$match2["h"];{const $match4=$a1;if($match4.$==="Letter"){const $x3527=$a2;const $x3528=$a3;return ({$:"Tuple",["fst"]:({$:"InId",["h"]:(
/*JD_REF:$jd$fnv*/$jd$fnv((
/*JD_USE:3526*/$x3526),(
/*JD_USE:3527*/$x3527)))}),["snd"]:(
/*JD_USE:3528*/$x3528)});}else{{const $match5=$match4;if($match5.$==="Digit"){const $x3529=$a2;const $x3530=$a3;return ({$:"Tuple",["fst"]:({$:"InNm",["v"]:((((
/*JD_USE:3529*/$x3529) - 48) >>> 0))}),["snd"]:(
/*JD_REF:$jd$mix*/$jd$mix((
/*JD_USE:3530*/$x3530),1,(
/*JD_USE:3526*/$x3526)))});}else{{const $match6=$match5;if($match6.$==="Space"){const $x3532=$a3;return ({$:"Tuple",["fst"]:({$:"Gap"}),["snd"]:(
/*JD_REF:$jd$mix*/$jd$mix((
/*JD_USE:3532*/$x3532),1,(
/*JD_USE:3526*/$x3526)))});}else{{const $match7=$match6;const $x3533=$a2;const $x3534=$a3;return ({$:"Tuple",["fst"]:({$:"Gap"}),["snd"]:(
/*JD_REF:$jd$mix*/$jd$mix((
/*JD_REF:$jd$mix*/$jd$mix((
/*JD_USE:3534*/$x3534),1,(
/*JD_USE:3526*/$x3526))),3,(
/*JD_USE:3533*/$x3533)))});}}}}}}}}else{{const $match3=$match2;const $x3535=$match3["v"];{const $match5=$a1;if($match5.$==="Letter"){const $x3536=$a2;const $x3537=$a3;return ({$:"Tuple",["fst"]:({$:"InId",["h"]:(
/*JD_REF:$jd$fnv*/$jd$fnv(2166136261,(
/*JD_USE:3536*/$x3536)))}),["snd"]:(
/*JD_REF:$jd$mix*/$jd$mix((
/*JD_USE:3537*/$x3537),2,(
/*JD_USE:3535*/$x3535)))});}else{{const $match6=$match5;if($match6.$==="Digit"){const $x3538=$a2;const $x3539=$a3;return ({$:"Tuple",["fst"]:({$:"InNm",["v"]:(
/*JD_REF:$jd$U32_46_add*/$jd$U32_46_add(((Math.imul((
/*JD_USE:3535*/$x3535), 10) >>> 0)),((((
/*JD_USE:3538*/$x3538) - 48) >>> 0))))}),["snd"]:(
/*JD_USE:3539*/$x3539)});}else{{const $match7=$match6;if($match7.$==="Space"){const $x3541=$a3;return ({$:"Tuple",["fst"]:({$:"Gap"}),["snd"]:(
/*JD_REF:$jd$mix*/$jd$mix((
/*JD_USE:3541*/$x3541),2,(
/*JD_USE:3535*/$x3535)))});}else{{const $match8=$match7;const $x3542=$a2;const $x3543=$a3;return ({$:"Tuple",["fst"]:({$:"Gap"}),["snd"]:(
/*JD_REF:$jd$mix*/$jd$mix((
/*JD_REF:$jd$mix*/$jd$mix((
/*JD_USE:3543*/$x3543),2,(
/*JD_USE:3535*/$x3535))),3,(
/*JD_USE:3542*/$x3542)))});}}}}}}}}}}}}}}
function $jd$step($a0,$a1,$a2){for(;;){const $x3547=$a0;const $x3548=$a1;const $x3549=$a2;return (
/*JD_REF:$jd$step_46_at*/$jd$step_46_at((
/*JD_USE:3547*/$x3547),(
/*JD_REF:$jd$cls*/$jd$cls((
/*JD_USE:3548*/$x3548))),(
/*JD_USE:3548*/$x3548),(
/*JD_USE:3549*/$x3549)));}}
function $jd$flush($a0,$a1){for(;;){{const $match1=$a0;if($match1.$==="Gap"){const $x3552=$a1;return (
/*JD_USE:3552*/$x3552);}else{{const $match2=$match1;if($match2.$==="InId"){const $x3553=$match2["h"];const $x3554=$a1;return (
/*JD_REF:$jd$mix*/$jd$mix((
/*JD_USE:3554*/$x3554),1,(
/*JD_USE:3553*/$x3553)));}else{{const $match3=$match2;const $x3555=$match3["v"];const $x3556=$a1;return (
/*JD_REF:$jd$mix*/$jd$mix((
/*JD_USE:3556*/$x3556),2,(
/*JD_USE:3555*/$x3555)));}}}}}}}
function $jd$lex($a0,$a1){for(;;){{const $match1=$a0;if($match1===""){{const $match2=$a1;const $x3559=$match2["fst"];const $x3560=$match2["snd"];return (
/*JD_REF:$jd$flush*/$jd$flush((
/*JD_USE:3559*/$x3559),(
/*JD_USE:3560*/$x3560)));}}else{{const $match2=$match1;{const $match3=($match2.codePointAt(0)>0xFFFF?$match2.slice(0,2):$match2[0]);const $x3562=($match2.codePointAt(0)>0xFFFF?$match2.slice(2):$match2.slice(1));{const $match6=$a1;const $x3563=$match6["fst"];const $x3564=$match6["snd"];{
/*JD_REF:$jd$lex*/const $next0=(
/*JD_USE:3562*/$x3562);const $next1=(
/*JD_REF:$jd$step*/$jd$step((
/*JD_USE:3563*/$x3563),(
/*JD_USE:3561*/$match3.codePointAt(0)),(
/*JD_USE:3564*/$x3564)));$a0=$next0;$a1=$next1;continue;}}}}}}}}
function $jd$line($a0){for(;;){const $x3566=$a0;return (
/*JD_REF:$jd$lex*/$jd$lex((
/*JD_REF:$jd$gen*/$jd$gen((
/*JD_REF:$jd$tpl*/$jd$tpl()),(
/*JD_REF:$jd$seed*/$jd$seed((
/*JD_USE:3566*/$x3566))),0)),({$:"Tuple",["fst"]:({$:"Gap"}),["snd"]:0})));}}
function $jd$batch($a0,$a1){for(;;){{const $match1=$a0;if($match1===0){const $x3569=$a1;return (
/*JD_REF:$jd$line*/$jd$line((
/*JD_USE:3569*/$x3569)));}else{const $x3570=($match1-1);const $x3571=$a1;{const $let0=(
/*JD_REF:$jd$batch*/$jd$batch((
/*JD_USE:3570*/$x3570),(
/*JD_USE:3571*/$x3571)));const $let1=(
/*JD_REF:$jd$batch*/$jd$batch((
/*JD_USE:3570*/$x3570),(
/*JD_REF:$jd$U32_46_add*/$jd$U32_46_add((
/*JD_USE:3571*/$x3571),(((
/*JD_USE:3570*/$x3570) >= 32 ? 0 : (1 << (
/*JD_USE:3570*/$x3570)) >>> 0))))));{const $x3572=$let0;const $x3573=$let1;return ((((
/*JD_USE:3572*/$x3572) + (
/*JD_USE:3573*/$x3573)) >>> 0));}}}}}}
function $jd$size_46_small(){for(;;){return 8;}}
function $jd$expect_46_small(){for(;;){return 1822208108;}}
function $jd$size_46_big(){for(;;){return 23;}}
function $jd$expect_46_big(){for(;;){return 2401049475;}}
function $jd$bench($a0,$a1){for(;;){const $x3576=$a0;const $x3577=$a1;return (
/*JD_REF:$jd$batch*/$jd$batch(((
/*JD_USE:3576*/$x3576)),(
/*JD_USE:3577*/$x3577)));}}

export const backend={kind:"direct-js",representation:"upstream-native",prototype:true,foreign:"upstream-cps"};
export default {
"prng":run_lib((a0,)=>{const r=(run_loop($jd$prng((a0),)));(a0);return r;},1),
"seed":run_lib((a0,)=>{const r=(run_loop($jd$seed((a0),)));(a0);return r;},1),
"salt":run_lib((a0,a1,)=>{const r=(run_loop($jd$salt((a0),(a1),)));(a0);(a1);return r;},2),
"op.pick":run_lib((a0,a1,)=>{const r=(run_loop($jd$op_46_pick((a0),(a1),)));(a0);(a1);return r;},2),
"op":run_lib((a0,a1,)=>{const r=(run_loop($jd$op((a0),(a1),)));(a0);(a1);return r;},2),
"ident":run_lib((a0,a1,a2,)=>{const r=(run_loop($jd$ident(nat_host(a0),(a1),(a2),)));BigInt(a0);(a1);(a2);return r;},3),
"num":run_lib((a0,a1,a2,)=>{const r=(run_loop($jd$num(nat_host(a0),(a1),(a2),)));BigInt(a0);(a1);(a2);return r;},3),
"expand":run_lib((a0,a1,a2,a3,)=>{const r=(run_loop($jd$expand((a0),(a1),(a2),(a3),)));(a0);(a1);(a2);(a3);return r;},4),
"slot.go":run_lib((a0,a1,a2,)=>{const r=(run_loop($jd$slot_46_go((a0),(a1),(a2),)));(a0);(a1);(a2);return r;},3),
"slot":run_lib((a0,)=>{const r=(run_loop($jd$slot((a0),)));(a0);return r;},1),
"gen.at":run_lib((a0,a1,a2,)=>{const r=(run_loop($jd$gen_46_at((a0),(a1),(a2),)));(a0);(a1);(a2);return r;},3),
"gen":run_lib((a0,a1,a2,)=>{const r=(run_loop($jd$gen((a0),(a1),(a2),)));(a0);(a1);(a2);return r;},3),
"tpl":run_lib(()=>{const r=(run_loop($jd$tpl()));return r;},0),
"cls.go":run_lib((a0,a1,a2,)=>{const r=(run_loop($jd$cls_46_go((a0),(a1),(a2),)));(a0);(a1);(a2);return r;},3),
"cls":run_lib((a0,)=>{const r=(run_loop($jd$cls((a0),)));(a0);return r;},1),
"mix":run_lib((a0,a1,a2,)=>{const r=(run_loop($jd$mix((a0),(a1),(a2),)));(a0);(a1);(a2);return r;},3),
"fnv":run_lib((a0,a1,)=>{const r=(run_loop($jd$fnv((a0),(a1),)));(a0);(a1);return r;},2),
"step.at":run_lib((a0,a1,a2,a3,)=>{const r=(run_loop($jd$step_46_at((a0),(a1),(a2),(a3),)));(a0);(a1);(a2);(a3);return r;},4),
"step":run_lib((a0,a1,a2,)=>{const r=(run_loop($jd$step((a0),(a1),(a2),)));(a0);(a1);(a2);return r;},3),
"flush":run_lib((a0,a1,)=>{const r=(run_loop($jd$flush((a0),(a1),)));(a0);(a1);return r;},2),
"lex":run_lib((a0,a1,)=>{const r=(run_loop($jd$lex((a0),(a1),)));(a0);(a1);return r;},2),
"line":run_lib((a0,)=>{const r=(run_loop($jd$line((a0),)));(a0);return r;},1),
"batch":run_lib((a0,a1,)=>{const r=(run_loop($jd$batch(nat_host(a0),(a1),)));BigInt(a0);(a1);return r;},2),
"size.small":run_lib(()=>{const r=BigInt(run_loop($jd$size_46_small()));return r;},0),
"expect.small":run_lib(()=>{const r=(run_loop($jd$expect_46_small()));return r;},0),
"size.big":run_lib(()=>{const r=BigInt(run_loop($jd$size_46_big()));return r;},0),
"expect.big":run_lib(()=>{const r=(run_loop($jd$expect_46_big()));return r;},0),
"bench":run_lib((a0,a1,)=>{const r=(run_loop($jd$bench((a0),(a1),)));(a0);(a1);return r;},2),
};
