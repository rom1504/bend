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

const f32_round = function f32_round(s        )         {
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
  const [, i, r, e] = /(\d*)\.?(\d*)(?:e([+-]?\d+))?$/i.exec(s) ;
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
// Program
// =======

function $eval$(_e_0) {
  if (_e_0.$ === "Lit") {
    const _n_0 = _e_0["n"];
    return _n_0;
  } else if (_e_0.$ === "Add") {
    const _a_0 = _e_0["a"];
    const _b_0 = _e_0["b"];
    const _x_0 = ($eval$(_a_0));
    const _x_1 = ($eval$(_b_0));
    return ((_x_0 + _x_1) >>> 0);
  } else if (_e_0.$ === "Mul") {
    const _a_1 = _e_0["a"];
    const _b_1 = _e_0["b"];
    const _x_2 = ($eval$(_a_1));
    const _x_3 = ($eval$(_b_1));
    return (Math.imul(_x_2, _x_3) >>> 0);
  } else {
    const _a_2 = _e_0["a"];
    const _b_2 = _e_0["b"];
    const _x_4 = ($eval$(_a_2));
    const _x_5 = ($eval$(_b_2));
    return ((_x_4 - _x_5) >>> 0);
  }
}

function $main$out$() {
  const _e1_0 = {$: "Mul", "a": {$: "Add", "a": {$: "Lit", "n": 2}, "b": {$: "Lit", "n": 3}}, "b": {$: "Sub", "a": {$: "Lit", "n": 10}, "b": {$: "Lit", "n": 4}}};
  const _e2_0 = {$: "Mul", "a": {$: "Lit", "n": 5}, "b": {$: "Lit", "n": 4294967295}};
  const _x_0 = ($eval$(_e1_0));
  const _x_1 = ($eval$(_e2_0));
  return ((_x_0 + _x_1) >>> 0);
}

function $p37$expr$pick$(_op_0, _e_0, _seed_0) {
  if (_op_0 === 0) {
    return {$: "Add", "a": _e_0, "b": {$: "Mul", "a": {$: "Lit", "n": _seed_0}, "b": {$: "Lit", "n": 3}}};
  } else if (_op_0 === 1) {
    return {$: "Mul", "a": _e_0, "b": {$: "Add", "a": {$: "Lit", "n": (5 === 0 ? _seed_0 : _seed_0 % 5)}, "b": {$: "Lit", "n": 1}}};
  } else {
    return {$: "Sub", "a": _e_0, "b": {$: "Add", "a": {$: "Lit", "n": _seed_0}, "b": {$: "Lit", "n": 7}}};
  }
}

function $p37$expr$(_n_0, _seed_0) {
  if (_n_0 === 0) {
    return {$: "Lit", "n": _seed_0};
  } else {
    const _p_0 = (_n_0 - 1);
    const _x_0 = (3 === 0 ? _seed_0 : _seed_0 % 3);
    return $p37$expr$pick$(_x_0, ($p37$expr$(_p_0, ((_seed_0 + 1) >>> 0))), _seed_0);
  }
}

function $bench$(_size_0, _seed_0) {
  return $eval$(($p37$expr$(_size_0, _seed_0)));
}
export default {
  "eval": run_lib((a0) => { const r = (run_loop($eval$((a0)))); (a0); return r; }, 1),
  "main.out": run_lib(() => { const r = (run_loop($main$out$()));  return r; }, 0),
  "p37.expr.pick": run_lib((a0, a1, a2) => { const r = (run_loop($p37$expr$pick$(nat_host(a0), (a1), (a2)))); BigInt(a0); (a1); (a2); return r; }, 3),
  "p37.expr": run_lib((a0, a1) => { const r = (run_loop($p37$expr$(nat_host(a0), (a1)))); BigInt(a0); (a1); return r; }, 2),
  "bench": run_lib((a0, a1) => { const r = (run_loop($bench$((a0), (a1)))); (a0); (a1); return r; }, 2),
};
