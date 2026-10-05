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
function $jd$U32_46_add($a0,$a1){return (($a0 + $a1) >>> 0);}
function $jd$U32_46_sub($a0,$a1){return (($a0 - $a1) >>> 0);}
function $jd$U32_46_mul($a0,$a1){return (Math.imul($a0, $a1) >>> 0);}
function $jd$U32_46_to_95_nat($a0){return $a0;}
function $jd$eval($a0){for(;;){{const $match1=$a0;if($match1.$==="Lit"){const $x3422=$match1["n"];return (
/*JD_USE:3422*/$x3422);}else{{const $match2=$match1;if($match2.$==="Add"){const $x3423=$match2["a"];const $x3424=$match2["b"];return (
/*JD_REF:$jd$U32_46_add*/$jd$U32_46_add((
/*JD_REF:$jd$eval*/$jd$eval((
/*JD_USE:3423*/$x3423))),(
/*JD_REF:$jd$eval*/$jd$eval((
/*JD_USE:3424*/$x3424)))));}else{{const $match3=$match2;if($match3.$==="Mul"){const $x3425=$match3["a"];const $x3426=$match3["b"];return (
/*JD_REF:$jd$U32_46_mul*/$jd$U32_46_mul((
/*JD_REF:$jd$eval*/$jd$eval((
/*JD_USE:3425*/$x3425))),(
/*JD_REF:$jd$eval*/$jd$eval((
/*JD_USE:3426*/$x3426)))));}else{{const $match4=$match3;const $x3427=$match4["a"];const $x3428=$match4["b"];return (
/*JD_REF:$jd$U32_46_sub*/$jd$U32_46_sub((
/*JD_REF:$jd$eval*/$jd$eval((
/*JD_USE:3427*/$x3427))),(
/*JD_REF:$jd$eval*/$jd$eval((
/*JD_USE:3428*/$x3428)))));}}}}}}}}}
function $jd$main_46_out(){for(;;){{const $let0=({$:"Mul",["a"]:({$:"Add",["a"]:({$:"Lit",["n"]:2}),["b"]:({$:"Lit",["n"]:3})}),["b"]:({$:"Sub",["a"]:({$:"Lit",["n"]:10}),["b"]:({$:"Lit",["n"]:4})})});{const $x3429=$let0;{const $let0=({$:"Mul",["a"]:({$:"Lit",["n"]:5}),["b"]:({$:"Lit",["n"]:4294967295})});{const $x3430=$let0;return (
/*JD_REF:$jd$U32_46_add*/$jd$U32_46_add((
/*JD_REF:$jd$eval*/$jd$eval((
/*JD_USE:3429*/$x3429))),(
/*JD_REF:$jd$eval*/$jd$eval((
/*JD_USE:3430*/$x3430)))));}}}}}}
function $jd$p37_46_expr_46_pick($a0,$a1,$a2){for(;;){{const $match1=$a0;if($match1===0){const $x3434=$a1;const $x3435=$a2;return ({$:"Add",["a"]:(
/*JD_USE:3434*/$x3434),["b"]:({$:"Mul",["a"]:({$:"Lit",["n"]:(
/*JD_USE:3435*/$x3435)}),["b"]:({$:"Lit",["n"]:3})})});}else{if($match1===1){const $x3436=$a1;const $x3437=$a2;return ({$:"Mul",["a"]:(
/*JD_USE:3436*/$x3436),["b"]:({$:"Add",["a"]:({$:"Lit",["n"]:((5 === 0 ? (
/*JD_USE:3437*/$x3437) : (
/*JD_USE:3437*/$x3437) % 5))}),["b"]:({$:"Lit",["n"]:1})})});}else{const $x3439=$a1;const $x3440=$a2;return ({$:"Sub",["a"]:(
/*JD_USE:3439*/$x3439),["b"]:({$:"Add",["a"]:({$:"Lit",["n"]:(
/*JD_USE:3440*/$x3440)}),["b"]:({$:"Lit",["n"]:7})})});}}}}}
function $jd$p37_46_expr($a0,$a1){for(;;){{const $match1=$a0;if($match1===0){const $x3443=$a1;return ({$:"Lit",["n"]:(
/*JD_USE:3443*/$x3443)});}else{const $x3444=($match1-1);const $x3445=$a1;return (
/*JD_REF:$jd$p37_46_expr_46_pick*/$jd$p37_46_expr_46_pick((
/*JD_REF:$jd$U32_46_to_95_nat*/$jd$U32_46_to_95_nat(((3 === 0 ? (
/*JD_USE:3445*/$x3445) : (
/*JD_USE:3445*/$x3445) % 3)))),(
/*JD_REF:$jd$p37_46_expr*/$jd$p37_46_expr((
/*JD_USE:3444*/$x3444),((((
/*JD_USE:3445*/$x3445) + 1) >>> 0)))),(
/*JD_USE:3445*/$x3445)));}}}}
function $jd$bench($a0,$a1){for(;;){const $x3448=$a0;const $x3449=$a1;return (
/*JD_REF:$jd$eval*/$jd$eval((
/*JD_REF:$jd$p37_46_expr*/$jd$p37_46_expr(((
/*JD_USE:3448*/$x3448)),(
/*JD_USE:3449*/$x3449)))));}}

export const backend={kind:"direct-js",representation:"upstream-native",prototype:true,foreign:"upstream-cps"};
export default {
"eval":run_lib((a0,)=>{const r=(run_loop($jd$eval((a0),)));(a0);return r;},1),
"main.out":run_lib(()=>{const r=(run_loop($jd$main_46_out()));return r;},0),
"p37.expr.pick":run_lib((a0,a1,a2,)=>{const r=(run_loop($jd$p37_46_expr_46_pick(nat_host(a0),(a1),(a2),)));BigInt(a0);(a1);(a2);return r;},3),
"p37.expr":run_lib((a0,a1,)=>{const r=(run_loop($jd$p37_46_expr(nat_host(a0),(a1),)));BigInt(a0);(a1);return r;},2),
"bench":run_lib((a0,a1,)=>{const r=(run_loop($jd$bench((a0),(a1),)));(a0);(a1);return r;},2),
};
