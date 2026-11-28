import Base
# s5_embench_tarfind: Port of Embench-IoT tarfind (tarfind.c)
# 800 rounds: generate 35 POSIX TAR header filenames via rand_beebs, run 5 linear strcmp searches.

type FillSt is Type:
  FS{buf: Array<U32>, seed: U32}

type CmpRes is Type:
  CR{buf: Array<U32>, eq: Bool}

type FindRes is Type:
  FR{buf: Array<U32>, found: U32}

type RoundSt is Type:
  RS{buf: Array<U32>, acc: U32}

def zero_hdr(+rem: Nat, +idx: U32, buf: Array<U32>) -> Array<U32>:
  match rem:
    case 0n:
      buf
    case 1n+p:
      zero_hdr(p, U32.inc(idx), Array.set(U32, buf, idx, 0))

def fill_name(+rem: Nat, +idx: U32, st: FillSt) -> FillSt:
  match rem:
    case 0n:
      st
    case 1n+p:
      FS{buf, +seed} = st
      +s1 = U32.and(U32.add(U32.mul(seed, 1103515245), 12345), 2147483647)
      +rv = U32.shrn(s1, 16n)
      +ch = U32.add(U32.mod(rv, 26), 65)
      fill_name(p, U32.inc(idx), FS{Array.set(U32, buf, idx, ch), s1})

def build_archive(+rem: Nat, +i: U32, st: FillSt) -> FillSt:
  match rem:
    case 0n:
      st
    case 1n+p:
      FS{buf, +seed} = st
      +base = U32.mul(i, 100)
      buf0 = zero_hdr(100n, base, buf)
      +flen = U32.add(5, U32.mod(i, 94))
      build_archive(p, U32.inc(i), fill_name(U32.to_nat(flen), base, FS{buf0, seed}))

type CmpReq is Type:
  CGo{i1: U32, i2: U32, buf: Array<U32>}
  CGot1{i1: U32, i2: U32, r1: Array<U32> & U32}
  CGot2{i1: U32, i2: U32, c1: U32, r2: Array<U32> & U32}
  CChk{done: Bool, eq: Bool, i1: U32, i2: U32, buf: Array<U32>}

def strcmp_loop(+fuel: Nat, req: CmpReq) -> CmpRes:
  match fuel:
    case 0n:
      match req:
        case CGo{+i1, +i2, buf}: CR{buf, True{}}
        case CGot1{+i1, +i2, r1}:
          (buf, +v) = r1
          CR{buf, False{}}
        case CGot2{+i1, +i2, +c1, r2}:
          (buf, +v) = r2
          CR{buf, False{}}
        case CChk{done, eq, +i1, +i2, buf}: CR{buf, eq}
    case 1n+f:
      match req:
        case CGo{+i1, +i2, buf}:
          strcmp_loop(f, CGot1{i1, i2, Array.get(U32, buf, i1)})
        case CGot1{+i1, +i2, r1}:
          (buf1, +c1) = r1
          strcmp_loop(f, CGot2{i1, i2, c1, Array.get(U32, buf1, i2)})
        case CGot2{+i1, +i2, +c1, r2}:
          (buf2, +c2) = r2
          +both_nz = Bool.and(U32.is_ne(c1, 0), U32.is_ne(c2, 0))
          +cont = Bool.and(both_nz, U32.is_eq(c1, c2))
          +both_z = Bool.and(U32.is_eq(c1, 0), U32.is_eq(c2, 0))
          strcmp_loop(f, CChk{Bool.not(cont), both_z, i1, i2, buf2})
        case CChk{done, eq, +i1, +i2, buf}:
          match done:
            case True{}:
              CR{buf, eq}
            case False{}:
              strcmp_loop(f, CGo{U32.inc(i1), U32.inc(i2), buf})

type ScanReq is Type:
  SGo{i: U32, target: U32, buf: Array<U32>}
  SAfter{i: U32, target: U32, cr: CmpRes}

def scan_files(+rem: Nat, req: ScanReq) -> FindRes:
  match rem:
    case 0n:
      match req:
        case SGo{+i, +t, buf}: FR{buf, 0}
        case SAfter{+i, +t, cr}:
          CR{buf, eq} = cr
          FR{buf, Bool.to_u32(eq)}
    case 1n+p:
      match req:
        case SGo{+i, +target, buf}:
          scan_files(p, SAfter{i, target, strcmp_loop(410n, CGo{U32.mul(i, 100), target, buf})})
        case SAfter{+i, +target, cr}:
          CR{buf, eq} = cr
          match eq:
            case True{}:
              FR{buf, 1}
            case False{}:
              scan_files(p, SGo{U32.inc(i), target, buf})

def add_found(+found: U32, fr: FindRes) -> FindRes:
  FR{buf, +inc} = fr
  FR{buf, U32.add(found, inc)}

def search_loop(+rem: Nat, +p: U32, st: FindRes) -> FindRes:
  match rem:
    case 0n:
      st
    case 1n+q:
      FR{buf, +found} = st
      +tidx = U32.mod(U32.add(p, 17), 35)
      +target = U32.mul(tidx, 100)
      search_loop(q, U32.inc(p), add_found(found, scan_files(72n, SGo{0, target, buf})))

def finish_round(+acc: U32, +seed1: U32, fr: FindRes) -> RoundSt:
  FR{buf, +found} = fr
  +ok = Bool.to_u32(U32.is_eq(found, 5))
  +a1 = U32.mul(U32.xor(acc, ok), 16777619)
  +s2 = U32.and(U32.add(U32.mul(seed1, 1103515245), 12345), 2147483647)
  +rv = U32.shrn(s2, 16n)
  +a2 = U32.mul(U32.xor(a1, rv), 16777619)
  RS{buf, a2}

def after_build(+acc: U32, fs: FillSt) -> RoundSt:
  FS{buf, +seed1} = fs
  finish_round(acc, seed1, search_loop(5n, 0, FR{buf, 0}))

def run_rounds(+rem: Nat, +r: U32, st: RoundSt) -> U32:
  match rem:
    case 0n:
      RS{buf, +acc} = st
      acc
    case 1n+p:
      RS{buf, +acc} = st
      run_rounds(p, U32.inc(r), after_build(acc, build_archive(35n, 0, FS{buf, r})))

def main() -> U32:
  buf = Array.new(U32, 12n, 0)
  run_rounds(800n, 0, RS{buf, 2166136261})
