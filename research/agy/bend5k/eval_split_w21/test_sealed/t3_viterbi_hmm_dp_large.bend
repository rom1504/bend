import Base
# t3_viterbi_hmm_dp (large): Integer-cost Viterbi HMM trellis dynamic programming over Array<U32>
# Sealed-Test family 3: S = 32 hidden states, T = 512 timesteps, 12 sequences.

type MinRes is Type:
  MRes{prev: Array<U32>, trans: Array<U32>, best: U32, best_i: U32}

type VitSt is Type:
  VSt{trans: Array<U32>, emit: Array<U32>, prev: Array<U32>, cur: Array<U32>, bp_h: U32}

def prng(+x: U32) -> U32:
  +b = U32.xor(x, U32.shln(x, 13n))
  +d = U32.xor(b, U32.shrn(b, 17n))
  U32.xor(d, U32.shln(d, 5n))

def fill_trans(+rem: Nat, +i: U32, a: Array<U32>) -> Array<U32>:
  match rem:
    case 0n:
      a
    case 1n+p:
      +r = prng(U32.xor(U32.mul(U32.inc(i), 2654435761), 53))
      fill_trans(p, U32.inc(i), Array.set(U32, a, i, U32.inc(U32.and(r, 63))))

def fill_emit(+rem: Nat, +i: U32, a: Array<U32>) -> Array<U32>:
  match rem:
    case 0n:
      a
    case 1n+p:
      +r = prng(U32.xor(U32.mul(U32.inc(i), 2246822519), 89))
      fill_emit(p, U32.inc(i), Array.set(U32, a, i, U32.inc(U32.and(r, 127))))

def init_prev(+rem: Nat, +j: U32, a: Array<U32>) -> Array<U32>:
  match rem:
    case 0n:
      a
    case 1n+p:
      init_prev(p, U32.inc(j), Array.set(U32, a, j, U32.mul(j, 7)))

def pick_best(lt: Bool, +cand: U32, +i: U32, +best: U32, +best_i: U32, prev: Array<U32>, trans: Array<U32>) -> MinRes:
  match lt:
    case True{}:
      MRes{prev, trans, cand, i}
    case False{}:
      MRes{prev, trans, best, best_i}

def inner_tr(+pv: U32, +i: U32, +best: U32, +best_i: U32, prev: Array<U32>, rt: Array<U32> & U32) -> MinRes:
  (trans, +tv) = rt
  +cand = U32.add(pv, tv)
  pick_best(U32.is_lt(cand, best), cand, i, best, best_i, prev, trans)

def inner_pv(+i: U32, +j: U32, +best: U32, +best_i: U32, rp: Array<U32> & U32, trans: Array<U32>) -> MinRes:
  (prev, +pv) = rp
  +tidx = U32.or(U32.shln(i, 5n), j)
  inner_tr(pv, i, best, best_i, prev, Array.get(U32, trans, tidx))

def find_min(+rem: Nat, +i: U32, +j: U32, mr: MinRes) -> MinRes:
  match rem:
    case 0n:
      mr
    case 1n+p:
      MRes{prev, trans, +best, +best_i} = mr
      find_min(p, U32.inc(i), j, inner_pv(i, j, best, best_i, Array.get(U32, prev, i), trans))

def store_j(+j: U32, +em: U32, +bp_h: U32, emit: Array<U32>, cur: Array<U32>, mr: MinRes) -> VitSt:
  MRes{prev, trans, +best, +best_i} = mr
  cur1 = Array.set(U32, cur, j, U32.add(best, em))
  VSt{trans, emit, prev, cur1, U32.xor(U32.mul(bp_h, 16777619), best_i)}

def step_j_em(+j: U32, +bp_h: U32, re: Array<U32> & U32, trans: Array<U32>, prev: Array<U32>, cur: Array<U32>) -> VitSt:
  (emit, +em) = re
  mr = find_min(32n, 0, j, MRes{prev, trans, 2147483647, 0})
  store_j(j, em, bp_h, emit, cur, mr)

def step_states(+rem: Nat, +j: U32, +obs: U32, vs: VitSt) -> VitSt:
  match rem:
    case 0n:
      vs
    case 1n+p:
      VSt{trans, emit, prev, cur, +bp_h} = vs
      +eidx = U32.or(U32.shln(j, 4n), obs)
      step_states(p, U32.inc(j), obs, step_j_em(j, bp_h, Array.get(U32, emit, eidx), trans, prev, cur))

def swap_dp(vs: VitSt) -> VitSt:
  VSt{trans, emit, prev, cur, +bp_h} = vs
  VSt{trans, emit, cur, prev, bp_h}

def run_timesteps(+rem: Nat, +seed: U32, vs: VitSt) -> VitSt & U32:
  match rem:
    case 0n:
      (vs, seed)
    case 1n+p:
      +ns = prng(seed)
      +obs = U32.and(ns, 15)
      run_timesteps(p, ns, swap_dp(step_states(32n, 0, obs, vs)))

def hash_prev(+rem: Nat, +j: U32, +h: U32, rp: Array<U32> & U32) -> Array<U32> & U32:
  match rem:
    case 0n:
      (a, v) = rp
      (a, h)
    case 1n+p:
      (a, +v) = rp
      hash_prev(p, U32.inc(j), U32.xor(U32.mul(h, 2654435761), v), Array.get(U32, a, U32.inc(j)))

type SeqSt is Type:
  SSt{vs: VitSt, seed: U32, th: U32}

def pack_seq(trans: Array<U32>, emit: Array<U32>, cur: Array<U32>, +bp_h: U32, +nseed: U32, ph: Array<U32> & U32) -> SeqSt:
  (prev3, +nth) = ph
  SSt{VSt{trans, emit, prev3, cur, bp_h}, nseed, nth}

def after_timesteps(+th: U32, res: VitSt & U32) -> SeqSt:
  (vs2, +nseed) = res
  VSt{trans2, emit2, prev2, cur2, +bp_h2} = vs2
  pack_seq(trans2, emit2, cur2, bp_h2, nseed, hash_prev(32n, 0, th, Array.get(U32, prev2, 0)))

def run_seqs(+rem: Nat, ss: SeqSt) -> U32:
  match rem:
    case 0n:
      SSt{vs, +seed, +th} = ss
      VSt{trans, emit, prev, cur, +bp_h} = vs
      U32.xor(th, bp_h)
    case 1n+p:
      SSt{vs, +seed, +th} = ss
      VSt{trans, emit, prev, cur, +bp_h} = vs
      prev1 = init_prev(32n, 0, prev)
      run_seqs(p, after_timesteps(th, run_timesteps(512n, seed, VSt{trans, emit, prev1, cur, bp_h})))

def main() -> U32:
  trans = fill_trans(1024n, 0, Array.new(U32, 10n, 0))
  emit = fill_emit(512n, 0, Array.new(U32, 9n, 0))
  prev = Array.new(U32, 5n, 0)
  cur = Array.new(U32, 5n, 0)
  run_seqs(20n, SSt{VSt{trans, emit, prev, cur, 2166136261}, 555123457, 2166136261})
