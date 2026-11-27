import Base
# t3_kmp_multi_scan (skew): KMP prefix-function builder + streaming pattern search
# Sealed-Test family 3: N = 8192 periodic binary haystack, 70 patterns (deep fallback chains).

type KmpSt is Type:
  KS{text: Array<U32>, pat: Array<U32>, pi: Array<U32>, acc: U32, matches: U32, seed: U32}

type FallRes is Type:
  FR{pat: Array<U32>, pi: Array<U32>, q: U32}

type ScanRes is Type:
  SR{text: Array<U32>, pat: Array<U32>, pi: Array<U32>, q: U32, acc: U32, matches: U32}

def prng(+x: U32) -> U32:
  +b = U32.xor(x, U32.shln(x, 13n))
  +d = U32.xor(b, U32.shrn(b, 17n))
  U32.xor(d, U32.shln(d, 5n))

def sel_u32(cond: Bool, +t: U32, +f: U32) -> U32:
  match cond:
    case True{}:
      t
    case False{}:
      f

type ArrSeed is Type:
  AS{arr: Array<U32>, seed: U32}

type ArrPair is Type:
  AP{a: Array<U32>, b: Array<U32>}

def init_text(+rem: Nat, +i: U32, +seed: U32, text: Array<U32>) -> ArrSeed:
  match rem:
    case 0n:
      AS{text, seed}
    case 1n+p:
      +ns = prng(seed)
      +ch = sel_u32(U32.is_zero(U32.and(ns, 7)), 1, 0)
      init_text(p, U32.inc(i), ns, Array.set(U32, text, i, ch))

def init_pat(+rem: Nat, +i: U32, +seed: U32, pat: Array<U32>) -> ArrSeed:
  match rem:
    case 0n:
      AS{pat, seed}
    case 1n+p:
      +ns = prng(seed)
      +ch = sel_u32(U32.is_zero(U32.and(ns, 7)), 1, 0)
      init_pat(p, U32.inc(i), ns, Array.set(U32, pat, i, ch))

type FallStep is Type:
  FSt{pat: Array<U32>, pi: Array<U32>, q: U32, done: Bool}

type PiSt is Type:
  PS{pat: Array<U32>, pi: Array<U32>, k: U32}

def fall_get_pi(pat: Array<U32>, rpi: Array<U32> & U32) -> FallStep:
  (pi, +nq) = rpi
  FSt{pat, pi, nq, False{}}

def fall_cmp(eq: Bool, +q: U32, pat: Array<U32>, pi: Array<U32>) -> FallStep:
  match eq:
    case True{}:
      FSt{pat, pi, q, True{}}
    case False{}:
      fall_get_pi(pat, Array.get(U32, pi, U32.sub(q, 1)))

def fall_get_pat(+q: U32, +ch: U32, rpat: Array<U32> & U32, pi: Array<U32>) -> FallStep:
  (pat, +pq) = rpat
  fall_cmp(U32.is_eq(pq, ch), q, pat, pi)

def fall_nz(is_z: Bool, +q: U32, +ch: U32, pat: Array<U32>, pi: Array<U32>) -> FallStep:
  match is_z:
    case True{}:
      FSt{pat, pi, 0, True{}}
    case False{}:
      fall_get_pat(q, ch, Array.get(U32, pat, q), pi)

def kmp_fallback_go(+rem: Nat, +ch: U32, fs: FallStep) -> FallRes:
  match rem:
    case 0n:
      FSt{pat, pi, +q, done} = fs
      FR{pat, pi, q}
    case 1n+p:
      FSt{pat, pi, +q, done} = fs
      match done:
        case True{}:
          FR{pat, pi, q}
        case False{}:
          kmp_fallback_go(p, ch, fall_nz(U32.is_zero(q), q, ch, pat, pi))

def kmp_fallback(+q: U32, +ch: U32, pat: Array<U32>, pi: Array<U32>) -> FallRes:
  kmp_fallback_go(32n, ch, FSt{pat, pi, q, False{}})

def pi_after_pat(+i: U32, +ch: U32, +q: U32, rpat: Array<U32> & U32, pi: Array<U32>) -> PiSt:
  (pat, +pq) = rpat
  +nq = sel_u32(U32.is_eq(pq, ch), U32.inc(q), q)
  PS{pat, Array.set(U32, pi, i, nq), nq}

def pi_after_fall(+i: U32, +ch: U32, fr: FallRes) -> PiSt:
  FR{pat1, pi1, +q} = fr
  pi_after_pat(i, ch, q, Array.get(U32, pat1, q), pi1)

def pi_step(+i: U32, +k: U32, rpat: Array<U32> & U32, pi: Array<U32>) -> PiSt:
  (pat, +ch) = rpat
  pi_after_fall(i, ch, kmp_fallback(k, ch, pat, pi))

def build_pi_loop(+rem: Nat, +i: U32, ps: PiSt) -> ArrPair:
  match rem:
    case 0n:
      PS{pat, pi, +k} = ps
      AP{pat, pi}
    case 1n+p:
      PS{pat, pi, +k} = ps
      build_pi_loop(p, U32.inc(i), pi_step(i, k, Array.get(U32, pat, i), pi))

def scan_match_pi(
  +i: U32, +rd: U32, +acc: U32, +matches: U32,
  text: Array<U32>, pat: Array<U32>, rpi: Array<U32> & U32
) -> ScanRes:
  (pi, +nq) = rpi
  +nacc = U32.xor(U32.mul(acc, 16777619), U32.add(i, rd))
  SR{text, pat, pi, nq, nacc, U32.inc(matches)}

def scan_check_match(
  is_hit: Bool, +i: U32, +rd: U32, +nq: U32, +acc: U32, +matches: U32,
  text: Array<U32>, pat: Array<U32>, pi: Array<U32>
) -> ScanRes:
  match is_hit:
    case True{}:
      scan_match_pi(i, rd, acc, matches, text, pat, Array.get(U32, pi, U32.sub(nq, 1)))
    case False{}:
      SR{text, pat, pi, nq, acc, matches}

def scan_after_pat(
  +i: U32, +rd: U32, +plen: U32, +ch: U32, +q: U32, +acc: U32, +matches: U32,
  text: Array<U32>, rpat: Array<U32> & U32, pi: Array<U32>
) -> ScanRes:
  (pat, +pq) = rpat
  +nq = sel_u32(U32.is_eq(pq, ch), U32.inc(q), q)
  scan_check_match(U32.is_eq(nq, plen), i, rd, nq, acc, matches, text, pat, pi)

def scan_after_fall(
  +i: U32, +rd: U32, +plen: U32, +ch: U32, +acc: U32, +matches: U32,
  text: Array<U32>, fr: FallRes
) -> ScanRes:
  FR{pat1, pi1, +q1} = fr
  scan_after_pat(i, rd, plen, ch, q1, acc, matches, text, Array.get(U32, pat1, q1), pi1)

def scan_step(
  +i: U32, +rd: U32, +plen: U32, +q: U32, +acc: U32, +matches: U32,
  rtext: Array<U32> & U32, pat: Array<U32>, pi: Array<U32>
) -> ScanRes:
  (text, +ch) = rtext
  scan_after_fall(i, rd, plen, ch, acc, matches, text, kmp_fallback(q, ch, pat, pi))

def scan_text(+rem: Nat, +i: U32, +rd: U32, +plen: U32, sr: ScanRes) -> ScanRes:
  match rem:
    case 0n:
      sr
    case 1n+p:
      SR{text, pat, pi, +q, +acc, +matches} = sr
      sr1 = scan_step(i, rd, plen, q, acc, matches, Array.get(U32, text, i), pat, pi)
      scan_text(p, U32.inc(i), rd, plen, sr1)

def round_after_scan(+seed1: U32, sr: ScanRes) -> KmpSt:
  SR{text1, pat3, pi2, +qfin, +acc1, +m1} = sr
  +acc2 = U32.xor(U32.mul(acc1, 2654435761), qfin)
  KS{text1, pat3, pi2, acc2, m1, seed1}

def round_after_pi(+rd: U32, +plen: U32, +acc: U32, +matches: U32, +seed1: U32, text: Array<U32>, ap: ArrPair) -> KmpSt:
  AP{pat2, pi1} = ap
  round_after_scan(seed1, scan_text(8192n, 0, rd, plen, SR{text, pat2, pi1, 0, acc, matches}))

def round_after_pat(+rd: U32, +plen: U32, +acc: U32, +matches: U32, text: Array<U32>, pi: Array<U32>, as1: ArrSeed) -> KmpSt:
  AS{pat1, +seed1} = as1
  pi0 = Array.set(U32, pi, 0, 0)
  round_after_pi(rd, plen, acc, matches, seed1, text, build_pi_loop(U32.to_nat(U32.sub(plen, 1)), 1, PS{pat1, pi0, 0}))

def run_rounds(+rem: Nat, +rd: U32, st: KmpSt) -> U32:
  match rem:
    case 0n:
      KS{text, pat, pi, +acc, +matches, +seed} = st
      U32.xor(acc, U32.mul(matches, 2246822519))
    case 1n+p:
      KS{text, pat, pi, +acc, +matches, +seed} = st
      +plen = U32.add(8, U32.and(rd, 7))
      run_rounds(p, U32.inc(rd), round_after_pat(rd, plen, acc, matches, text, pi, init_pat(U32.to_nat(plen), 0, seed, pat)))

def main_go(as0: ArrSeed) -> U32:
  AS{text, +seed1} = as0
  pat = Array.new(U32, 5n, 0)
  pi = Array.new(U32, 5n, 0)
  run_rounds(140n, 0, KS{text, pat, pi, 2166136261, 0, seed1})

def main() -> U32:
  main_go(init_text(8192n, 0, 777888999, Array.new(U32, 13n, 0)))
