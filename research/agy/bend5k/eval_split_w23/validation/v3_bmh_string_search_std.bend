import Base
# v3_bmh_string_search (std): Boyer-Moore-Horspool multi-pattern search with bad-char skip table
# Validation family 3: N = 16384 haystack, 280 patterns, 16-symbol uniform alphabet.

type ArrSeed is Type:
  AS{arr: Array<U32>, seed: U32}

type TextPat is Type:
  TP{text: Array<U32>, pat: Array<U32>}

type PatSkip is Type:
  PS{pat: Array<U32>, skip: Array<U32>}

type MatchRes is Type:
  MR{text: Array<U32>, pat: Array<U32>, hit: U32}

type CmpSt is Type:
  CSt{text: Array<U32>, pat: Array<U32>, j: U32, hit: U32, done: Bool}

type ScanSt is Type:
  SS{text: Array<U32>, pat: Array<U32>, skip: Array<U32>, pos: U32, steps: U32, acc: U32, matches: U32}

type ScanWrap is Type:
  SW{st: ScanSt, done: Bool}

type BmhSt is Type:
  BS{text: Array<U32>, pat: Array<U32>, skip: Array<U32>, acc: U32, matches: U32, seed: U32}

type BuildPatRes is Type:
  BP{text: Array<U32>, pat: Array<U32>, seed: U32}

def prng(+x: U32) -> U32:
  +b = U32.xor(x, U32.shln(x, 13n))
  +d = U32.xor(b, U32.shrn(b, 17n))
  U32.xor(d, U32.shln(d, 5n))

def init_text(+rem: Nat, +i: U32, +seed: U32, text: Array<U32>) -> ArrSeed:
  match rem:
    case 0n:
      AS{text, seed}
    case 1n+p:
      +ns = prng(seed)
      init_text(p, U32.inc(i), ns, Array.set(U32, text, i, U32.and(ns, 15)))

def copy_pat_set(+j: U32, rt: Array<U32> & U32, pat: Array<U32>) -> TextPat:
  (text, +ch) = rt
  TP{text, Array.set(U32, pat, j, ch)}

def copy_pat(+rem: Nat, +start: U32, +j: U32, tp: TextPat) -> TextPat:
  match rem:
    case 0n:
      tp
    case 1n+p:
      TP{text, pat} = tp
      copy_pat(p, start, U32.inc(j), copy_pat_set(j, Array.get(U32, text, U32.add(start, j)), pat))

def rand_pat(+rem: Nat, +j: U32, +seed: U32, pat: Array<U32>) -> ArrSeed:
  match rem:
    case 0n:
      AS{pat, seed}
    case 1n+p:
      +ns = prng(seed)
      rand_pat(p, U32.inc(j), ns, Array.set(U32, pat, j, U32.and(ns, 15)))

def pack_copy(+ns: U32, tp: TextPat) -> BuildPatRes:
  TP{text1, pat1} = tp
  BP{text1, pat1, ns}

def pack_rand(text: Array<U32>, as1: ArrSeed) -> BuildPatRes:
  AS{pat1, +ns} = as1
  BP{text, pat1, ns}

def build_pat(plant: Bool, +m: U32, +seed: U32, text: Array<U32>, pat: Array<U32>) -> BuildPatRes:
  match plant:
    case True{}:
      +ns = prng(seed)
      +start = U32.and(ns, 16352)
      pack_copy(ns, copy_pat(U32.to_nat(m), start, 0, TP{text, pat}))
    case False{}:
      pack_rand(text, rand_pat(U32.to_nat(m), 0, seed, pat))

def fill_skip_def(+rem: Nat, +c: U32, +m: U32, skip: Array<U32>) -> Array<U32>:
  match rem:
    case 0n:
      skip
    case 1n+p:
      fill_skip_def(p, U32.inc(c), m, Array.set(U32, skip, c, m))

def skip_set(+val: U32, rp: Array<U32> & U32, skip: Array<U32>) -> PatSkip:
  (pat, +ch) = rp
  PS{pat, Array.set(U32, skip, ch, val)}

def fill_skip_pat(+rem: Nat, +j: U32, +m1: U32, ps: PatSkip) -> PatSkip:
  match rem:
    case 0n:
      ps
    case 1n+p:
      PS{pat, skip} = ps
      fill_skip_pat(p, U32.inc(j), m1, skip_set(U32.sub(m1, j), Array.get(U32, pat, j), skip))

def cmp_is_zero(is_z: Bool, +j: U32, text: Array<U32>, pat: Array<U32>) -> CmpSt:
  match is_z:
    case True{}:
      CSt{text, pat, 0, 1, True{}}
    case False{}:
      CSt{text, pat, U32.sub(j, 1), 1, False{}}

def cmp_tail(eq: Bool, +j: U32, text: Array<U32>, pat: Array<U32>) -> CmpSt:
  match eq:
    case True{}:
      cmp_is_zero(U32.is_zero(j), j, text, pat)
    case False{}:
      CSt{text, pat, j, 0, True{}}

def cmp_pat(+j: U32, +tc: U32, text: Array<U32>, rp: Array<U32> & U32) -> CmpSt:
  (pat, +pc) = rp
  cmp_tail(U32.is_eq(tc, pc), j, text, pat)

def cmp_text(+j: U32, rt: Array<U32> & U32, pat: Array<U32>) -> CmpSt:
  (text, +tc) = rt
  cmp_pat(j, tc, text, Array.get(U32, pat, j))

def cmp_bwd_loop(+rem: Nat, +pos: U32, cs: CmpSt) -> MatchRes:
  match rem:
    case 0n:
      CSt{text, pat, +j, +hit, done} = cs
      MR{text, pat, hit}
    case 1n+p:
      CSt{text, pat, +j, +hit, done} = cs
      match done:
        case True{}:
          MR{text, pat, hit}
        case False{}:
          cmp_bwd_loop(p, pos, cmp_text(j, Array.get(U32, text, U32.add(pos, j)), pat))

def cmp_bwd(+rem: Nat, +pos: U32, +j: U32, text: Array<U32>, pat: Array<U32>) -> MatchRes:
  cmp_bwd_loop(rem, pos, CSt{text, pat, j, 1, False{}})

def scan_adv_skip(+pos: U32, +steps: U32, +acc: U32, +matches: U32, text: Array<U32>, pat: Array<U32>, rs: Array<U32> & U32) -> ScanSt:
  (skip, +sh) = rs
  SS{text, pat, skip, U32.add(pos, sh), steps, acc, matches}

def scan_adv_text(+pos: U32, +steps: U32, +acc: U32, +matches: U32, rt: Array<U32> & U32, pat: Array<U32>, skip: Array<U32>) -> ScanSt:
  (text, +lastc) = rt
  scan_adv_skip(pos, steps, acc, matches, text, pat, Array.get(U32, skip, lastc))

def scan_after_hit(is_hit: Bool, +pos: U32, +m1: U32, +rd: U32, +steps: U32, +acc: U32, +matches: U32, text: Array<U32>, pat: Array<U32>, skip: Array<U32>) -> ScanSt:
  match is_hit:
    case True{}:
      +nacc = U32.xor(U32.mul(acc, 16777619), U32.add(pos, rd))
      scan_adv_text(pos, steps, nacc, U32.inc(matches), Array.get(U32, text, U32.add(pos, m1)), pat, skip)
    case False{}:
      scan_adv_text(pos, steps, acc, matches, Array.get(U32, text, U32.add(pos, m1)), pat, skip)

def scan_after_cmp(+pos: U32, +m1: U32, +rd: U32, +steps: U32, +acc: U32, +matches: U32, skip: Array<U32>, mr: MatchRes) -> ScanWrap:
  MR{text1, pat1, +hit} = mr
  st1 = scan_after_hit(U32.is_eq(hit, 1), pos, m1, rd, U32.inc(steps), acc, matches, text1, pat1, skip)
  SW{st1, False{}}

def scan_one(in_bounds: Bool, +m: U32, +m1: U32, +rd: U32, st: ScanSt) -> ScanWrap:
  match in_bounds:
    case True{}:
      SS{text, pat, skip, +pos, +steps, +acc, +matches} = st
      scan_after_cmp(pos, m1, rd, steps, acc, matches, skip, cmp_bwd(U32.to_nat(m), pos, m1, text, pat))
    case False{}:
      SW{st, True{}}

def scan_step_go(+limit: U32, +m: U32, +m1: U32, +rd: U32, st: ScanSt) -> ScanWrap:
  SS{text, pat, skip, +pos, +steps, +acc, +matches} = st
  scan_one(U32.is_le(pos, limit), m, m1, rd, SS{text, pat, skip, pos, steps, acc, matches})

def scan_loop_go(+rem: Nat, +limit: U32, +m: U32, +m1: U32, +rd: U32, sw: ScanWrap) -> ScanSt:
  match rem:
    case 0n:
      SW{st, done} = sw
      st
    case 1n+p:
      SW{st, done} = sw
      match done:
        case True{}:
          st
        case False{}:
          scan_loop_go(p, limit, m, m1, rd, scan_step_go(limit, m, m1, rd, st))

def scan_loop(+rem: Nat, +limit: U32, +m: U32, +m1: U32, +rd: U32, st: ScanSt) -> ScanSt:
  scan_loop_go(rem, limit, m, m1, rd, SW{st, False{}})

def rd_after_scan(+seed1: U32, ss: ScanSt) -> BmhSt:
  SS{text2, pat3, skip2, +pos1, +steps1, +acc1, +m1cnt} = ss
  +acc2 = U32.xor(U32.mul(acc1, 2654435761), steps1)
  BS{text2, pat3, skip2, acc2, m1cnt, seed1}

def rd_after_skip(+rd: U32, +m: U32, +m1: U32, +acc: U32, +matches: U32, +seed1: U32, text1: Array<U32>, ps: PatSkip) -> BmhSt:
  PS{pat2, skip1} = ps
  rd_after_scan(seed1, scan_loop(16384n, U32.sub(16384, m), m, m1, rd, SS{text1, pat2, skip1, 0, 0, acc, matches}))

def rd_after_pat(+rd: U32, +m: U32, +m1: U32, +acc: U32, +matches: U32, skip: Array<U32>, bp: BuildPatRes) -> BmhSt:
  BP{text1, pat1, +seed1} = bp
  skip0 = fill_skip_def(16n, 0, m, skip)
  rd_after_skip(rd, m, m1, acc, matches, seed1, text1, fill_skip_pat(U32.to_nat(m1), 0, m1, PS{pat1, skip0}))

def run_rounds(+rem: Nat, +rd: U32, st: BmhSt) -> U32:
  match rem:
    case 0n:
      BS{text, pat, skip, +acc, +matches, +seed} = st
      U32.xor(acc, U32.mul(matches, 2246822519))
    case 1n+p:
      BS{text, pat, skip, +acc, +matches, +seed} = st
      +m = U32.add(6, U32.and(rd, 7))
      +m1 = U32.sub(m, 1)
      st1 = rd_after_pat(rd, m, m1, acc, matches, skip, build_pat(U32.is_zero(U32.and(rd, 3)), m, seed, text, pat))
      run_rounds(p, U32.inc(rd), st1)

def main_go(as0: ArrSeed) -> U32:
  AS{text, +seed1} = as0
  pat = Array.new(U32, 4n, 0)
  skip = Array.new(U32, 4n, 0)
  run_rounds(280n, 0, BS{text, pat, skip, 2166136261, 0, seed1})

def main() -> U32:
  main_go(init_text(16384n, 0, 444555666, Array.new(U32, 14n, 0)))
