import Base
# t1_lzw_dict_coder (std): LZW dictionary compressor with open-addressed hash table
# Sealed-Test family 1: 24 rounds x 16384 mixed-entropy bytes, 4096-code dict + resets.

type LzwSt is Type:
  LS{hk: Array<U32>, hv: Array<U32>, pref: U32, next_c: U32, acc: U32, emit: U32, rst: U32, seed: U32}

type ProbeRes is Type:
  PR{hk: Array<U32>, hv: Array<U32>, status: U32, val_or_slot: U32}

type ProbeStep is Type:
  PCont{hk: Array<U32>, hv: Array<U32>, slot: U32}
  PHit{hk: Array<U32>, hv: Array<U32>, code: U32}
  PEmpty{hk: Array<U32>, hv: Array<U32>, slot: U32}

type PairArr is Type:
  PA{hk: Array<U32>, hv: Array<U32>}

def prng(+x: U32) -> U32:
  +b = U32.xor(x, U32.shln(x, 13n))
  +d = U32.xor(b, U32.shrn(b, 17n))
  U32.xor(d, U32.shln(d, 5n))

def clear_arr(+rem: Nat, +i: U32, a: Array<U32>) -> Array<U32>:
  match rem:
    case 0n:
      a
    case 1n+p:
      clear_arr(p, U32.inc(i), Array.set(U32, a, i, 0))

def clear_both(+rem: Nat, +i: U32, hk: Array<U32>, hv: Array<U32>) -> PairArr:
  match rem:
    case 0n:
      PA{hk, hv}
    case 1n+p:
      clear_both(p, U32.inc(i), Array.set(U32, hk, i, 0), Array.set(U32, hv, i, 0))

def probe_hit(hk: Array<U32>, rhv: Array<U32> & U32) -> ProbeStep:
  (hv, +code) = rhv
  PHit{hk, hv, code}

def probe_zero(is_zero: Bool, +slot: U32, hk: Array<U32>, hv: Array<U32>) -> ProbeStep:
  match is_zero:
    case True{}:
      PEmpty{hk, hv, slot}
    case False{}:
      PCont{hk, hv, U32.and(U32.inc(slot), 8191)}

def probe_eq(is_eq: Bool, +slot: U32, +cur: U32, hk: Array<U32>, hv: Array<U32>) -> ProbeStep:
  match is_eq:
    case True{}:
      probe_hit(hk, Array.get(U32, hv, slot))
    case False{}:
      probe_zero(U32.is_zero(cur), slot, hk, hv)

def probe_step(+slot: U32, +key: U32, rhk: Array<U32> & U32, hv: Array<U32>) -> ProbeStep:
  (hk, +cur) = rhk
  probe_eq(U32.is_eq(cur, key), slot, cur, hk, hv)

def ht_probe_go(+rem: Nat, +key: U32, ps: ProbeStep) -> ProbeRes:
  match rem:
    case 0n:
      match ps:
        case PCont{hk, hv, +slot}:
          PR{hk, hv, 0, slot}
        case PHit{hk, hv, +code}:
          PR{hk, hv, 1, code}
        case PEmpty{hk, hv, +slot}:
          PR{hk, hv, 2, slot}
    case 1n+p:
      match ps:
        case PCont{hk, hv, +slot}:
          ht_probe_go(p, key, probe_step(slot, key, Array.get(U32, hk, slot), hv))
        case PHit{hk, hv, +code}:
          PR{hk, hv, 1, code}
        case PEmpty{hk, hv, +slot}:
          PR{hk, hv, 2, slot}

def ht_probe(+slot: U32, +key: U32, hk: Array<U32>, hv: Array<U32>) -> ProbeRes:
  ht_probe_go(16n, key, PCont{hk, hv, slot})

def handle_full(
  is_full: Bool, +ch: U32, +next_c: U32, +nacc: U32, +nemit: U32, +rst: U32, +seed: U32,
  hk: Array<U32>, hv: Array<U32>
) -> LzwSt:
  match is_full:
    case True{}:
      hk1 = clear_arr(8192n, 0, hk)
      LS{hk1, hv, ch, 256, nacc, nemit, U32.inc(rst), seed}
    case False{}:
      LS{hk, hv, ch, next_c, nacc, nemit, rst, seed}

def handle_insert(
  can_ins: Bool, +key: U32, +ch: U32, +slot: U32, +next_c: U32, +nacc: U32, +nemit: U32, +rst: U32, +seed: U32,
  hk: Array<U32>, hv: Array<U32>
) -> LzwSt:
  match can_ins:
    case True{}:
      LS{Array.set(U32, hk, slot, key), Array.set(U32, hv, slot, next_c), ch, U32.inc(next_c), nacc, nemit, rst, seed}
    case False{}:
      handle_full(U32.is_ge(next_c, 4096), ch, next_c, nacc, nemit, rst, seed, hk, hv)

def bool_and(a: Bool, b: Bool) -> Bool:
  match a:
    case True{}:
      b
    case False{}:
      False{}

def finish_probe(
  is_hit: Bool, +status: U32, +vs: U32, +key: U32, +ch: U32,
  +pref: U32, +next_c: U32, +acc: U32, +emit: U32, +rst: U32, +seed: U32,
  hk: Array<U32>, hv: Array<U32>
) -> LzwSt:
  match is_hit:
    case True{}:
      LS{hk, hv, vs, next_c, acc, emit, rst, seed}
    case False{}:
      +nacc = U32.xor(U32.mul(acc, 16777619), pref)
      +nemit = U32.inc(emit)
      +can_ins = bool_and(U32.is_eq(status, 2), U32.is_lt(next_c, 4096))
      handle_insert(can_ins, key, ch, vs, next_c, nacc, nemit, rst, seed, hk, hv)

def sel_u32(cond: Bool, +t: U32, +f: U32) -> U32:
  match cond:
    case True{}:
      t
    case False{}:
      f

def byte_after_probe(
  +key: U32, +ch: U32, +pref: U32, +next_c: U32, +acc: U32, +emit: U32, +rst: U32, +ns: U32,
  pr: ProbeRes
) -> LzwSt:
  PR{hk1, hv1, +status, +vs} = pr
  finish_probe(U32.is_eq(status, 1), status, vs, key, ch, pref, next_c, acc, emit, rst, ns, hk1, hv1)

def run_bytes(+rem: Nat, +b: U32, +rd: U32, st: LzwSt) -> LzwSt:
  match rem:
    case 0n:
      st
    case 1n+p:
      LS{hk, hv, +pref, +next_c, +acc, +emit, +rst, +seed} = st
      +ns = prng(seed)
      +ch = sel_u32(
        U32.is_lt(U32.and(ns, 7), 5),
        U32.and(U32.add(U32.mul(b, 3), rd), 15),
        U32.and(U32.shrn(ns, 8n), 31)
      )
      +key = U32.or(U32.or(U32.shln(pref, 8n), ch), 2147483648)
      +slot = U32.and(U32.shrn(U32.mul(key, 2654435761), 19n), 8191)
      run_bytes(p, U32.inc(b), rd, byte_after_probe(key, ch, pref, next_c, acc, emit, rst, ns, ht_probe(slot, key, hk, hv)))

def round_finish(st1: LzwSt) -> LzwSt:
  LS{hk1, hv1, +pfin, +nc1, +acc1, +em1, +rst1, +s1} = st1
  +acc2 = U32.xor(U32.mul(acc1, 16777619), pfin)
  LS{hk1, hv1, pfin, nc1, acc2, U32.inc(em1), rst1, s1}

def round_after_clear(+rd: U32, +acc: U32, +emit: U32, +rst: U32, +seed: U32, pa: PairArr) -> LzwSt:
  PA{hk0, hv0} = pa
  +ns = prng(seed)
  +p0 = U32.and(ns, 31)
  round_finish(run_bytes(16383n, 1, rd, LS{hk0, hv0, p0, 256, acc, emit, rst, ns}))

def run_rounds(+rem: Nat, +rd: U32, st: LzwSt) -> U32:
  match rem:
    case 0n:
      LS{hk, hv, +pref, +next_c, +acc, +emit, +rst, +seed} = st
      U32.add(U32.xor(acc, U32.mul(emit, 2654435761)), U32.mul(rst, 2246822519))
    case 1n+p:
      LS{hk, hv, +pref, +next_c, +acc, +emit, +rst, +seed} = st
      run_rounds(p, U32.inc(rd), round_after_clear(rd, acc, emit, rst, seed, clear_both(8192n, 0, hk, hv)))

def main() -> U32:
  hk = Array.new(U32, 13n, 0)
  hv = Array.new(U32, 13n, 0)
  run_rounds(40n, 0, LS{hk, hv, 0, 256, 2166136261, 0, 0, 111222333})
