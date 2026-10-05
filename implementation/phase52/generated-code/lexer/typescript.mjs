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

function $prng$(_x_0) {
  const _x_1 = (13 >= 32 ? 0 : (_x_0 << 13) >>> 0);
  const _b_0 = ((_x_0 ^ _x_1) >>> 0);
  const _x_2 = (17 >= 32 ? 0 : (_b_0 >>> 17) >>> 0);
  const _d_0 = ((_b_0 ^ _x_2) >>> 0);
  const _x_3 = (5 >= 32 ? 0 : (_d_0 << 5) >>> 0);
  return ((_d_0 ^ _x_3) >>> 0);
}

function $seed$(_i_0) {
  const _x_0 = ((_i_0 + 1) >>> 0);
  return $prng$((Math.imul(_x_0, 2654435761) >>> 0));
}

function $salt$(_s_0, _k_0) {
  const _x_0 = (Math.imul(_k_0, 2654435761) >>> 0);
  return $prng$(((_s_0 ^ _x_0) >>> 0));
}

function $op$pick$(_b1_0, _b0_0) {
  if (!_b1_0) {
    if (!_b0_0) {
      return "+";
    } else {
      return "-";
    }
  } else {
    if (!_b0_0) {
      return "*";
    } else {
      return "/";
    }
  }
}

function $op$(_t_0, _rest_0) {
  const _x_0 = ((_t_0 & 2) >>> 0);
  const _x_1 = ((_t_0 & 1) >>> 0);
  return (($op$pick$((_x_0 !== 0), (_x_1 !== 0))) + _rest_0);
}

function $ident$(_n_0, _t_0, _rest_0) {
  if (_n_0 === 0) {
    return _rest_0;
  } else {
    const _p_0 = (_n_0 - 1);
    const _u_0 = ($prng$(_t_0));
    const _x_0 = (26 === 0 ? _u_0 : _u_0 % 26);
    return (char_new(((97 + _x_0) >>> 0)) + ($ident$(_p_0, _u_0, _rest_0)));
  }
}

function $num$(_n_0, _t_0, _rest_0) {
  if (_n_0 === 0) {
    return _rest_0;
  } else {
    const _p_0 = (_n_0 - 1);
    const _u_0 = ($prng$(_t_0));
    const _x_0 = (10 === 0 ? _u_0 : _u_0 % 10);
    return (char_new(((48 + _x_0) >>> 0)) + ($num$(_p_0, _u_0, _rest_0)));
  }
}

function $expand$(_sl_0, _c_0, _t_0, _rest_0) {
  if (_sl_0.$ === "Id") {
    const _x_0 = ((_t_0 & 7) >>> 0);
    const _x_1 = ((1 + _x_0) >>> 0);
    return $ident$(_x_1, _t_0, _rest_0);
  } else if (_sl_0.$ === "Nm") {
    const _x_2 = (6 === 0 ? _t_0 : _t_0 % 6);
    const _x_3 = ((1 + _x_2) >>> 0);
    return $num$(_x_3, _t_0, _rest_0);
  } else if (_sl_0.$ === "Op") {
    return $op$(_t_0, _rest_0);
  } else {
    return (char_new(_c_0) + _rest_0);
  }
}

function $slot$go$(_i_0, _n_0, _o_0) {
  if (_i_0) {
    if (_n_0) {
      if (_o_0) {
        return {$: "Id"};
      } else {
        return {$: "Id"};
      }
    } else {
      if (_o_0) {
        return {$: "Id"};
      } else {
        return {$: "Id"};
      }
    }
  } else {
    if (_n_0) {
      if (_o_0) {
        return {$: "Nm"};
      } else {
        return {$: "Nm"};
      }
    } else {
      if (_o_0) {
        return {$: "Op"};
      } else {
        return {$: "Lit"};
      }
    }
  }
}

function $slot$(_c_0) {
  return $slot$go$((_c_0 === 105), (_c_0 === 110), (_c_0 === 111));
}

function $gen$at$(_c_0, _t_0, _rest_0) {
  return $expand$(($slot$(_c_0)), _c_0, _t_0, _rest_0);
}

function $gen$(_tpl_0, _s_0, _k_0) {
  if (_tpl_0 === "") {
    return "";
  } else {
    const _t_0 = (_tpl_0.codePointAt(0) > 0xFFFF ? _tpl_0.slice(0, 2) : _tpl_0[0]);
    const _u_0 = (_tpl_0.codePointAt(0) > 0xFFFF ? _tpl_0.slice(2) : _tpl_0.slice(1));
    return $gen$at$(_t_0.codePointAt(0), ($salt$(_s_0, _k_0)), ($gen$(_u_0, _s_0, ((_k_0 + 1) >>> 0))));
  }
}

function $tpl$() {
  return "i = ( n o i ) o ( n o i ) o ( n o i ) ;";
}

function $cls$go$(_l_0, _d_0, _s_0) {
  if (_l_0) {
    if (_d_0) {
      if (_s_0) {
        return {$: "Letter"};
      } else {
        return {$: "Letter"};
      }
    } else {
      if (_s_0) {
        return {$: "Letter"};
      } else {
        return {$: "Letter"};
      }
    }
  } else {
    if (_d_0) {
      if (_s_0) {
        return {$: "Digit"};
      } else {
        return {$: "Digit"};
      }
    } else {
      if (_s_0) {
        return {$: "Space"};
      } else {
        return {$: "Punct"};
      }
    }
  }
}

function $cls$(_c_0) {
  return $cls$go$(($Bool$and$((97 <= _c_0), (_c_0 <= 122))), ($Bool$and$((48 <= _c_0), (_c_0 <= 57))), (_c_0 === 32));
}

function $mix$(_acc_0, _kind_0, _x_0) {
  const _x_1 = (Math.imul(_kind_0, 40503) >>> 0);
  const _x_2 = (Math.imul(_acc_0, 2654435761) >>> 0);
  const _x_3 = ((_x_1 + _x_0) >>> 0);
  return ((_x_2 ^ _x_3) >>> 0);
}

function $fnv$(_h_0, _c_0) {
  const _x_0 = ((_h_0 ^ _c_0) >>> 0);
  return (Math.imul(_x_0, 16777619) >>> 0);
}

function $step$at$(_m_0, _k_0, _c_0, _acc_0) {
  if (_m_0.$ === "Gap") {
    if (_k_0.$ === "Letter") {
      return {$: "Tuple", "fst": {$: "InId", "h": ($fnv$(2166136261, _c_0))}, "snd": _acc_0};
    } else if (_k_0.$ === "Digit") {
      return {$: "Tuple", "fst": {$: "InNm", "v": ((_c_0 - 48) >>> 0)}, "snd": _acc_0};
    } else if (_k_0.$ === "Space") {
      return {$: "Tuple", "fst": {$: "Gap"}, "snd": _acc_0};
    } else {
      return {$: "Tuple", "fst": {$: "Gap"}, "snd": ($mix$(_acc_0, 3, _c_0))};
    }
  } else if (_m_0.$ === "InId") {
    const _h_0 = _m_0["h"];
    if (_k_0.$ === "Letter") {
      return {$: "Tuple", "fst": {$: "InId", "h": ($fnv$(_h_0, _c_0))}, "snd": _acc_0};
    } else if (_k_0.$ === "Digit") {
      return {$: "Tuple", "fst": {$: "InNm", "v": ((_c_0 - 48) >>> 0)}, "snd": ($mix$(_acc_0, 1, _h_0))};
    } else if (_k_0.$ === "Space") {
      return {$: "Tuple", "fst": {$: "Gap"}, "snd": ($mix$(_acc_0, 1, _h_0))};
    } else {
      return {$: "Tuple", "fst": {$: "Gap"}, "snd": ($mix$(($mix$(_acc_0, 1, _h_0)), 3, _c_0))};
    }
  } else {
    const _v_0 = _m_0["v"];
    if (_k_0.$ === "Letter") {
      return {$: "Tuple", "fst": {$: "InId", "h": ($fnv$(2166136261, _c_0))}, "snd": ($mix$(_acc_0, 2, _v_0))};
    } else if (_k_0.$ === "Digit") {
      const _x_0 = (Math.imul(_v_0, 10) >>> 0);
      const _x_1 = ((_c_0 - 48) >>> 0);
      return {$: "Tuple", "fst": {$: "InNm", "v": ((_x_0 + _x_1) >>> 0)}, "snd": _acc_0};
    } else if (_k_0.$ === "Space") {
      return {$: "Tuple", "fst": {$: "Gap"}, "snd": ($mix$(_acc_0, 2, _v_0))};
    } else {
      return {$: "Tuple", "fst": {$: "Gap"}, "snd": ($mix$(($mix$(_acc_0, 2, _v_0)), 3, _c_0))};
    }
  }
}

function $step$(_m_0, _c_0, _acc_0) {
  return $step$at$(_m_0, ($cls$(_c_0)), _c_0, _acc_0);
}

function $flush$(_m_0, _acc_0) {
  if (_m_0.$ === "Gap") {
    return _acc_0;
  } else if (_m_0.$ === "InId") {
    const _h_0 = _m_0["h"];
    return $mix$(_acc_0, 1, _h_0);
  } else {
    const _v_0 = _m_0["v"];
    return $mix$(_acc_0, 2, _v_0);
  }
}

function $lex$($0, $1) {
  for (;;) {
    {
      const _s_0 = $0;
      const _r_0 = $1;
      if (_s_0 === "") {
        const _m_0 = _r_0["fst"];
        const _acc_0 = _r_0["snd"];
        return $flush$(_m_0, _acc_0);
      } else {
        const _t_0 = (_s_0.codePointAt(0) > 0xFFFF ? _s_0.slice(0, 2) : _s_0[0]);
        const _t_1 = (_s_0.codePointAt(0) > 0xFFFF ? _s_0.slice(2) : _s_0.slice(1));
        const _m_1 = _r_0["fst"];
        const _acc_1 = _r_0["snd"];
        $0 = _t_1;
        $1 = ($step$(_m_1, _t_0.codePointAt(0), _acc_1));
        continue;
      }
    }
  }
}

function $line$(_i_0) {
  return $lex$(($gen$(($tpl$()), ($seed$(_i_0)), 0)), {$: "Tuple", "fst": {$: "Gap"}, "snd": 0});
}

function $batch$(_d_0, _i_0) {
  if (_d_0 === 0) {
    return $line$(_i_0);
  } else {
    const _p_0 = (_d_0 - 1);
    const _a_0 = ($batch$(_p_0, _i_0));
    const _x_0 = (_p_0 >= 32 ? 0 : (1 << _p_0) >>> 0);
    const _b_0 = ($batch$(_p_0, ((_i_0 + _x_0) >>> 0)));
    return ((_a_0 + _b_0) >>> 0);
  }
}

function $size$small$() {
  return 8;
}

function $expect$small$() {
  return 1822208108;
}

function $size$big$() {
  return 23;
}

function $expect$big$() {
  return 2401049475;
}

function $bench$(_size_0, _seed_0) {
  return $batch$(_size_0, _seed_0);
}

function $Bool$and$(_a_0, _b_0) {
  if (!_a_0) {
    return false;
  } else {
    return _b_0;
  }
}
export default {
  "prng": run_lib((a0) => { const r = (run_loop($prng$((a0)))); (a0); return r; }, 1),
  "seed": run_lib((a0) => { const r = (run_loop($seed$((a0)))); (a0); return r; }, 1),
  "salt": run_lib((a0, a1) => { const r = (run_loop($salt$((a0), (a1)))); (a0); (a1); return r; }, 2),
  "op.pick": run_lib((a0, a1) => { const r = (run_loop($op$pick$((a0), (a1)))); (a0); (a1); return r; }, 2),
  "op": run_lib((a0, a1) => { const r = (run_loop($op$((a0), (a1)))); (a0); (a1); return r; }, 2),
  "ident": run_lib((a0, a1, a2) => { const r = (run_loop($ident$(nat_host(a0), (a1), (a2)))); BigInt(a0); (a1); (a2); return r; }, 3),
  "num": run_lib((a0, a1, a2) => { const r = (run_loop($num$(nat_host(a0), (a1), (a2)))); BigInt(a0); (a1); (a2); return r; }, 3),
  "expand": run_lib((a0, a1, a2, a3) => { const r = (run_loop($expand$((a0), (a1), (a2), (a3)))); (a0); (a1); (a2); (a3); return r; }, 4),
  "slot.go": run_lib((a0, a1, a2) => { const r = (run_loop($slot$go$((a0), (a1), (a2)))); (a0); (a1); (a2); return r; }, 3),
  "slot": run_lib((a0) => { const r = (run_loop($slot$((a0)))); (a0); return r; }, 1),
  "gen.at": run_lib((a0, a1, a2) => { const r = (run_loop($gen$at$((a0), (a1), (a2)))); (a0); (a1); (a2); return r; }, 3),
  "gen": run_lib((a0, a1, a2) => { const r = (run_loop($gen$((a0), (a1), (a2)))); (a0); (a1); (a2); return r; }, 3),
  "tpl": run_lib(() => { const r = (run_loop($tpl$()));  return r; }, 0),
  "cls.go": run_lib((a0, a1, a2) => { const r = (run_loop($cls$go$((a0), (a1), (a2)))); (a0); (a1); (a2); return r; }, 3),
  "cls": run_lib((a0) => { const r = (run_loop($cls$((a0)))); (a0); return r; }, 1),
  "mix": run_lib((a0, a1, a2) => { const r = (run_loop($mix$((a0), (a1), (a2)))); (a0); (a1); (a2); return r; }, 3),
  "fnv": run_lib((a0, a1) => { const r = (run_loop($fnv$((a0), (a1)))); (a0); (a1); return r; }, 2),
  "step.at": run_lib((a0, a1, a2, a3) => { const r = (run_loop($step$at$((a0), (a1), (a2), (a3)))); (a0); (a1); (a2); (a3); return r; }, 4),
  "step": run_lib((a0, a1, a2) => { const r = (run_loop($step$((a0), (a1), (a2)))); (a0); (a1); (a2); return r; }, 3),
  "flush": run_lib((a0, a1) => { const r = (run_loop($flush$((a0), (a1)))); (a0); (a1); return r; }, 2),
  "lex": run_lib((a0, a1) => { const r = (run_loop($lex$((a0), (a1)))); (a0); (a1); return r; }, 2),
  "line": run_lib((a0) => { const r = (run_loop($line$((a0)))); (a0); return r; }, 1),
  "batch": run_lib((a0, a1) => { const r = (run_loop($batch$(nat_host(a0), (a1)))); BigInt(a0); (a1); return r; }, 2),
  "size.small": run_lib(() => { const r = BigInt(run_loop($size$small$()));  return r; }, 0),
  "expect.small": run_lib(() => { const r = (run_loop($expect$small$()));  return r; }, 0),
  "size.big": run_lib(() => { const r = BigInt(run_loop($size$big$()));  return r; }, 0),
  "expect.big": run_lib(() => { const r = (run_loop($expect$big$()));  return r; }, 0),
  "bench": run_lib((a0, a1) => { const r = (run_loop($bench$((a0), (a1)))); (a0); (a1); return r; }, 2),
};
