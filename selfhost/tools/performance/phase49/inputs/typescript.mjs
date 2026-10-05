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

function $P2$() {
  return null;
}

function $bu$(_b_0) {
  if (!_b_0) {
    return 0;
  } else {
    return 1;
  }
}

function $lconcat$(_xs_0, _ys_0) {
  if (_xs_0.$ === "Nil") {
    return _ys_0;
  } else {
    const _h_0 = _xs_0["head"];
    const _t_0 = _xs_0["tail"];
    return {$: "Con", "head": _h_0, "tail": ($lconcat$(_t_0, _ys_0))};
  }
}

function $lrepeat$(_n_0, _v_0) {
  if (_n_0 === 0) {
    return {$: "Nil"};
  } else {
    const _p_0 = (_n_0 - 1);
    return {$: "Con", "head": _v_0, "tail": ($lrepeat$(_p_0, _v_0))};
  }
}

function $lrevp$go$($0, $1) {
  for (;;) {
    {
      const _xs_0 = $0;
      const _acc_0 = $1;
      if (_xs_0.$ === "Nil") {
        return _acc_0;
      } else {
        const _h_0 = _xs_0["head"];
        const _t_0 = _xs_0["tail"];
        $0 = _t_0;
        $1 = {$: "Con", "head": _h_0, "tail": _acc_0};
        continue;
      }
    }
  }
}

function $lrevp$(_xs_0) {
  return $lrevp$go$(_xs_0, {$: "Nil"});
}

function $llenp$(_xs_0) {
  if (_xs_0.$ === "Nil") {
    return 0;
  } else {
    const _t_0 = _xs_0["tail"];
    const _x_0 = ($llenp$(_t_0));
    return ((1 + _x_0) >>> 0);
  }
}

function $rle$step$(_cur_0, _h_0, _n_0, _acc_0, _e_0) {
  if (!_e_0) {
    return {$: "Tuple", "fst": _h_0, "snd": {$: "Tuple", "fst": 1, "snd": {$: "Con", "head": {$: "Tuple", "fst": _n_0, "snd": _cur_0}, "tail": _acc_0}}};
  } else {
    return {$: "Tuple", "fst": _cur_0, "snd": {$: "Tuple", "fst": ((_n_0 + 1) >>> 0), "snd": _acc_0}};
  }
}

function $rle$($0, $1) {
  for (;;) {
    {
      const _xs_0 = $0;
      const _st_0 = $1;
      if (_xs_0.$ === "Nil") {
        const _cur_0 = _st_0["fst"];
        const _t_0 = _st_0["snd"];
        const _n_0 = _t_0["fst"];
        const _acc_0 = _t_0["snd"];
        return $lrevp$({$: "Con", "head": {$: "Tuple", "fst": _n_0, "snd": _cur_0}, "tail": _acc_0});
      } else {
        const _h0_0 = _xs_0["head"];
        const _t_1 = _xs_0["tail"];
        const _cur0_0 = _st_0["fst"];
        const _t_2 = _st_0["snd"];
        const _n_1 = _t_2["fst"];
        const _acc_1 = _t_2["snd"];
        const _h_0 = _h0_0;
        const _cur_1 = _cur0_0;
        $0 = _t_1;
        $1 = ($rle$step$(_cur_1, _h_0, _n_1, _acc_1, (_h_0 === _cur_1)));
        continue;
      }
    }
  }
}

function $expand$(_ps_0) {
  if (_ps_0.$ === "Nil") {
    return {$: "Nil"};
  } else {
    const _t_0 = _ps_0["head"];
    const _n_0 = _t_0["fst"];
    const _v_0 = _t_0["snd"];
    const _t_1 = _ps_0["tail"];
    return $lconcat$(($lrepeat$(_n_0, _v_0)), ($expand$(_t_1)));
  }
}

function $digest$go$($0, $1) {
  for (;;) {
    {
      const _xs_0 = $0;
      const _acc_0 = $1;
      if (_xs_0.$ === "Nil") {
        return _acc_0;
      } else {
        const _h_0 = _xs_0["head"];
        const _t_0 = _xs_0["tail"];
        const _x_0 = (Math.imul(_acc_0, 10) >>> 0);
        $0 = _t_0;
        $1 = ((_x_0 + _h_0) >>> 0);
        continue;
      }
    }
  }
}

function $digest$(_xs_0) {
  return $digest$go$(_xs_0, 0);
}

function $go$(_xs_0) {
  if (_xs_0.$ === "Con") {
    const _h_0 = _xs_0["head"];
    const _t_0 = _xs_0["tail"];
    const _code_0 = ($rle$(_t_0, {$: "Tuple", "fst": _h_0, "snd": {$: "Tuple", "fst": 1, "snd": {$: "Nil"}}}));
    const _x_0 = ($llenp$(_code_0));
    const _x_1 = ($bu$((_x_0 === 3)));
    const _x_2 = ($digest$(($expand$(_code_0))));
    const _x_3 = (Math.imul(_x_1, 10) >>> 0);
    const _x_4 = ($bu$((_x_2 === 777299)));
    return ((_x_3 + _x_4) >>> 0);
  } else {
    return 0;
  }
}

function $main$out$() {
  return $go$({$: "Con", "head": 7, "tail": {$: "Con", "head": 7, "tail": {$: "Con", "head": 7, "tail": {$: "Con", "head": 2, "tail": {$: "Con", "head": 9, "tail": {$: "Con", "head": 9, "tail": {$: "Nil"}}}}}}});
}
export default {
  "P2": run_lib(() => { const r = (run_loop($P2$()));  return r; }, 0),
  "bu": run_lib((a0) => { const r = (run_loop($bu$((a0)))); (a0); return r; }, 1),
  "lconcat": run_lib((a0, a1) => { const r = (run_loop($lconcat$((a0), (a1)))); (a0); (a1); return r; }, 2),
  "lrepeat": run_lib((a0, a1) => { const r = (run_loop($lrepeat$(nat_host(a0), (a1)))); BigInt(a0); (a1); return r; }, 2),
  "lrevp.go": run_lib((a0, a1) => { const r = (run_loop($lrevp$go$((a0), (a1)))); (a0); (a1); return r; }, 2),
  "lrevp": run_lib((a0) => { const r = (run_loop($lrevp$((a0)))); (a0); return r; }, 1),
  "llenp": run_lib((a0) => { const r = (run_loop($llenp$((a0)))); (a0); return r; }, 1),
  "rle.step": run_lib((a0, a1, a2, a3, a4) => { const r = (run_loop($rle$step$((a0), (a1), (a2), (a3), (a4)))); (a0); (a1); (a2); (a3); (a4); return r; }, 5),
  "rle": run_lib((a0, a1) => { const r = (run_loop($rle$((a0), (a1)))); (a0); (a1); return r; }, 2),
  "expand": run_lib((a0) => { const r = (run_loop($expand$((a0)))); (a0); return r; }, 1),
  "digest.go": run_lib((a0, a1) => { const r = (run_loop($digest$go$((a0), (a1)))); (a0); (a1); return r; }, 2),
  "digest": run_lib((a0) => { const r = (run_loop($digest$((a0)))); (a0); return r; }, 1),
  "go": run_lib((a0) => { const r = (run_loop($go$((a0)))); (a0); return r; }, 1),
  "main.out": run_lib(() => { const r = (run_loop($main$out$()));  return r; }, 0),
};
