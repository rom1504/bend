import Base
# v1_fenwick_bit_range (std): Fenwick Tree (BIT) point update, prefix sum & binary-lifting lower_bound
# Validation family 1: N = 4096, 24 rounds x 16384 uniform ops.

type BitSt is Type:
  BS{bit: Array<U32>, acc: U32, total: U32, seed: U32}

type BitSum is Type:
  BR{bit: Array<U32>, val: U32}

type BitLb is Type:
  BL{bit: Array<U32>, pos: U32, acc: U32}

type InitSt is Type:
  IS{bit: Array<U32>, total: U32, seed: U32}

def prng(+x: U32) -> U32:
  +b = U32.xor(x, U32.shln(x, 13n))
  +d = U32.xor(b, U32.shrn(b, 17n))
  U32.xor(d, U32.shln(d, 5n))

def clear_bit(+rem: Nat, +i: U32, bit: Array<U32>) -> Array<U32>:
  match rem:
    case 0n:
      bit
    case 1n+p:
      clear_bit(p, U32.inc(i), Array.set(U32, bit, i, 0))

def lowbit(+i: U32) -> U32:
  U32.and(i, U32.sub(0, i))

type AddSt is Type:
  ASt{bit: Array<U32>, i: U32, done: Bool}

type SumSt is Type:
  SSt{bit: Array<U32>, i: U32, s: U32, done: Bool}

def add_write(+i: U32, +delta: U32, r: Array<U32> & U32) -> AddSt:
  (bit, +cur) = r
  ASt{Array.set(U32, bit, i, U32.add(cur, delta)), U32.add(i, lowbit(i)), False{}}

def bit_add_step(le: Bool, +i: U32, +delta: U32, bit: Array<U32>) -> AddSt:
  match le:
    case True{}:
      add_write(i, delta, Array.get(U32, bit, i))
    case False{}:
      ASt{bit, i, True{}}

def bit_add_loop(+rem: Nat, +delta: U32, st: AddSt) -> Array<U32>:
  match rem:
    case 0n:
      ASt{bit, +i, done} = st
      bit
    case 1n+p:
      ASt{bit, +i, done} = st
      match done:
        case True{}:
          bit
        case False{}:
          bit_add_loop(p, delta, bit_add_step(U32.is_le(i, 4096), i, delta, bit))

def bit_add_go(+rem: Nat, +i: U32, +delta: U32, bit: Array<U32>) -> Array<U32>:
  bit_add_loop(rem, delta, ASt{bit, i, False{}})

def sum_acc(+i: U32, +s: U32, r: Array<U32> & U32) -> SumSt:
  (bit, +v) = r
  SSt{bit, U32.sub(i, lowbit(i)), U32.add(s, v), False{}}

def bit_sum_step(gt: Bool, +i: U32, +s: U32, bit: Array<U32>) -> SumSt:
  match gt:
    case True{}:
      sum_acc(i, s, Array.get(U32, bit, i))
    case False{}:
      SSt{bit, i, s, True{}}

def bit_sum_loop(+rem: Nat, st: SumSt) -> BitSum:
  match rem:
    case 0n:
      SSt{bit, +i, +s, done} = st
      BR{bit, s}
    case 1n+p:
      SSt{bit, +i, +s, done} = st
      match done:
        case True{}:
          BR{bit, s}
        case False{}:
          bit_sum_loop(p, bit_sum_step(U32.is_gt(i, 0), i, s, bit))

def bit_sum_go(+rem: Nat, +i: U32, +s: U32, bit: Array<U32>) -> BitSum:
  bit_sum_loop(rem, SSt{bit, i, s, False{}})

def lb_cmp(lt: Bool, +nxt: U32, +cand: U32, +pos: U32, +acc: U32, bit: Array<U32>) -> BitLb:
  match lt:
    case True{}:
      BL{bit, nxt, cand}
    case False{}:
      BL{bit, pos, acc}

def lb_get(+nxt: U32, +pos: U32, +acc: U32, +tgt: U32, r: Array<U32> & U32) -> BitLb:
  (bit, +v) = r
  +cand = U32.add(acc, v)
  lb_cmp(U32.is_lt(cand, tgt), nxt, cand, pos, acc, bit)

def lb_check(le: Bool, +nxt: U32, +pos: U32, +acc: U32, +tgt: U32, bit: Array<U32>) -> BitLb:
  match le:
    case True{}:
      lb_get(nxt, pos, acc, tgt, Array.get(U32, bit, nxt))
    case False{}:
      BL{bit, pos, acc}

def bit_lb_go(+rem: Nat, +k: U32, +tgt: U32, bl: BitLb) -> BitSum:
  match rem:
    case 0n:
      BL{bit, +pos, +acc} = bl
      BR{bit, U32.inc(pos)}
    case 1n+p:
      BL{bit, +pos, +acc} = bl
      +nxt = U32.add(pos, k)
      bit_lb_go(p, U32.shrn(k, 1n), tgt, lb_check(U32.is_le(nxt, 4096), nxt, pos, acc, tgt, bit))

def init_vals(+rem: Nat, +i: U32, st: InitSt) -> InitSt:
  match rem:
    case 0n:
      st
    case 1n+p:
      IS{bit, +total, +seed} = st
      +ns = prng(seed)
      +v = U32.inc(U32.and(ns, 31))
      bit1 = bit_add_go(14n, i, v, bit)
      init_vals(p, U32.inc(i), IS{bit1, U32.add(total, v), ns})

def op_lb_done(+acc: U32, +total: U32, +ns: U32, br: BitSum) -> BitSt:
  BR{bit, +pos} = br
  BS{bit, U32.xor(U32.mul(acc, 2246822519), pos), total, ns}

def op_range_done(+sr: U32, +acc: U32, +total: U32, +ns: U32, br: BitSum) -> BitSt:
  BR{bit, +sl} = br
  BS{bit, U32.xor(U32.mul(acc, 2654435761), U32.sub(sr, sl)), total, ns}

def op_range_l(+l: U32, +acc: U32, +total: U32, +ns: U32, br: BitSum) -> BitSt:
  BR{bit, +sr} = br
  op_range_done(sr, acc, total, ns, bit_sum_go(14n, U32.sub(l, 1), 0, bit))

def clamp_r(gt: Bool, +r: U32) -> U32:
  match gt:
    case True{}:
      4096
    case False{}:
      r

def op_sum_done(+acc: U32, +total: U32, +ns: U32, br: BitSum) -> BitSt:
  BR{bit, +s} = br
  BS{bit, U32.xor(U32.mul(acc, 16777619), s), total, ns}

def dispatch_op2(is2: Bool, +idx: U32, +ns: U32, +acc: U32, +total: U32, bit: Array<U32>) -> BitSt:
  match is2:
    case True{}:
      +l = U32.inc(U32.and(idx, 2047))
      +r0 = U32.add(l, U32.and(U32.shrn(ns, 16n), 1023))
      +r = clamp_r(U32.is_gt(r0, 4096), r0)
      op_range_l(l, acc, total, ns, bit_sum_go(14n, r, 0, bit))
    case False{}:
      +tgt = U32.inc(U32.and(U32.shrn(ns, 14n), 32767))
      op_lb_done(acc, total, ns, bit_lb_go(12n, 2048, tgt, BL{bit, 0, 0}))

def dispatch_op1(is1: Bool, +op: U32, +idx: U32, +ns: U32, +acc: U32, +total: U32, bit: Array<U32>) -> BitSt:
  match is1:
    case True{}:
      op_sum_done(acc, total, ns, bit_sum_go(14n, idx, 0, bit))
    case False{}:
      dispatch_op2(U32.is_eq(op, 2), idx, ns, acc, total, bit)

def dispatch_op0(is0: Bool, +op: U32, +idx: U32, +ns: U32, +acc: U32, +total: U32, bit: Array<U32>) -> BitSt:
  match is0:
    case True{}:
      +delta = U32.inc(U32.and(U32.shrn(ns, 16n), 15))
      BS{bit_add_go(14n, idx, delta, bit), acc, U32.add(total, delta), ns}
    case False{}:
      dispatch_op1(U32.is_eq(op, 1), op, idx, ns, acc, total, bit)

def run_ops(+rem: Nat, st: BitSt) -> BitSt:
  match rem:
    case 0n:
      st
    case 1n+p:
      BS{bit, +acc, +total, +seed} = st
      +ns = prng(seed)
      +idx = U32.inc(U32.and(ns, 4095))
      +op = U32.and(U32.shrn(ns, 12n), 3)
      run_ops(p, dispatch_op0(U32.is_zero(op), op, idx, ns, acc, total, bit))

def round_finish(st: BitSt) -> BitSt:
  BS{bit, +acc, +total, +seed} = st
  BS{bit, U32.xor(U32.mul(acc, 16777619), total), total, seed}

def round_after_init(+acc: U32, ist: InitSt) -> BitSt:
  IS{bit, +total, +seed} = ist
  round_finish(run_ops(16384n, BS{bit, acc, total, seed}))

def run_rounds(+rem: Nat, st: BitSt) -> U32:
  match rem:
    case 0n:
      BS{bit, +acc, +total, +seed} = st
      acc
    case 1n+p:
      BS{bit, +acc, +total, +seed} = st
      bit0 = clear_bit(4097n, 0, bit)
      run_rounds(p, round_after_init(acc, init_vals(4096n, 1, IS{bit0, 0, seed})))

def main() -> U32:
  bit = Array.new(U32, 13n, 0)
  run_rounds(24n, BS{bit, 2166136261, 0, 135792468})
