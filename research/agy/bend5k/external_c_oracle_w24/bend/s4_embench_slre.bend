import Base
# s4_embench_slre: Port of Embench-IoT slre (libslre.c / slre.h)
# Recursive AST backtracking regex matcher on the 4 Embench patterns across 4000 rotated strings.

type Regex is Data:
  RLit{ch: U32}
  RAny{}
  RSet2{c1: U32, c2: U32}
  RSet4{c1: U32, c2: U32, c3: U32, c4: U32}
  RSeq{a: Regex, b: Regex}
  RStar{r: Regex}
  RPlus{r: Regex}

type MatchRes is Type:
  MR{buf: Array<U32>, end_pos: U32}

type SearchRes is Type:
  SR{buf: Array<U32>, res: U32}

type RoundSt is Type:
  RS{buf: Array<U32>, acc: U32}

def match_atom_chk(ok: Bool, +pos: U32, buf: Array<U32>) -> MatchRes:
  match ok:
    case True{}:
      MR{buf, U32.inc(pos)}
    case False{}:
      MR{buf, 4294967295}

def match_atom_val(r: Array<U32> & U32, re: Regex, +pos: U32) -> MatchRes:
  (buf, +ch) = r
  match re:
    case RLit{+c}:
      match_atom_chk(U32.is_eq(ch, c), pos, buf)
    case RAny{}:
      MR{buf, U32.inc(pos)}
    case RSet2{+c1, +c2}:
      match_atom_chk(Bool.or(U32.is_eq(ch, c1), U32.is_eq(ch, c2)), pos, buf)
    case RSet4{+c1, +c2, +c3, +c4}:
      +ok1 = Bool.or(U32.is_eq(ch, c1), U32.is_eq(ch, c2))
      +ok2 = Bool.or(U32.is_eq(ch, c3), U32.is_eq(ch, c4))
      match_atom_chk(Bool.or(ok1, ok2), pos, buf)
    case RSeq{a, b}:
      MR{buf, 4294967295}
    case RStar{x}:
      MR{buf, 4294967295}
    case RPlus{x}:
      MR{buf, 4294967295}

def match_atom_bounds(in_b: Bool, re: Regex, +pos: U32, buf: Array<U32>) -> MatchRes:
  match in_b:
    case True{}:
      match_atom_val(Array.get(U32, buf, pos), re, pos)
    case False{}:
      MR{buf, 4294967295}

# Continuation stack (Data, pure, no linear Array inside!)
type Kont is Data:
  KDone{}
  KSeq{b: Regex, k: Kont}
  KStar{r: Regex, prev: U32, k: Kont}
  KPlus{r: Regex, k: Kont}

type StepReq is Type:
  SEval{re: Regex, pos: U32, k: Kont, buf: Array<U32>}
  SRet{pos: U32, k: Kont, buf: Array<U32>}
  SRetMr{mr: MatchRes, k: Kont}
  SRetChk{ok: Bool, pos: U32, prev: U32, r: Regex, k: Kont, buf: Array<U32>}

def eval_cps(+fuel: Nat, +len: U32, req: StepReq) -> MatchRes:
  match fuel:
    case 0n:
      match req:
        case SEval{re, +pos, k, buf}: MR{buf, 4294967295}
        case SRet{+pos, k, buf}: MR{buf, 4294967295}
        case SRetMr{mr, k}: mr
        case SRetChk{ok, +pos, +prev, r, k, buf}: MR{buf, 4294967295}
    case 1n+f:
      match req:
        case SEval{re, +pos, k, buf}:
          match re:
            case RLit{+c}:
              eval_cps(f, len, SRetMr{match_atom_bounds(U32.is_lt(pos, len), RLit{c}, pos, buf), k})
            case RAny{}:
              eval_cps(f, len, SRetMr{match_atom_bounds(U32.is_lt(pos, len), RAny{}, pos, buf), k})
            case RSet2{+c1, +c2}:
              eval_cps(f, len, SRetMr{match_atom_bounds(U32.is_lt(pos, len), RSet2{c1, c2}, pos, buf), k})
            case RSet4{+c1, +c2, +c3, +c4}:
              eval_cps(f, len, SRetMr{match_atom_bounds(U32.is_lt(pos, len), RSet4{c1, c2, c3, c4}, pos, buf), k})
            case RSeq{a, b}:
              eval_cps(f, len, SEval{a, pos, KSeq{b, k}, buf})
            case RStar{+r}:
              eval_cps(f, len, SEval{r, pos, KStar{r, pos, k}, buf})
            case RPlus{+r}:
              eval_cps(f, len, SEval{r, pos, KPlus{r, k}, buf})
        case SRetMr{mr, k}:
          MR{buf, +p1} = mr
          eval_cps(f, len, SRet{p1, k, buf})
        case SRet{+pos, k, buf}:
          match k:
            case KDone{}:
              MR{buf, pos}
            case KSeq{b, k1}:
              eval_cps(f, len, SRetChk{U32.is_ne(pos, 4294967295), pos, 4294967295, b, k1, buf})
            case KStar{+r, +prev, k1}:
              +adv = Bool.and(U32.is_ne(pos, 4294967295), U32.is_gt(pos, prev))
              eval_cps(f, len, SRetChk{adv, pos, prev, RStar{r}, k1, buf})
            case KPlus{+r, k1}:
              eval_cps(f, len, SRetChk{U32.is_ne(pos, 4294967295), pos, 4294967295, RStar{r}, k1, buf})
        case SRetChk{ok, +pos, +prev, r, k, buf}:
          match ok:
            case True{}:
              eval_cps(f, len, SEval{r, pos, k, buf})
            case False{}:
              eval_cps(f, len, SRet{prev, k, buf})

def search_upd(found: Bool, +ep: U32, buf: Array<U32>) -> SearchRes:
  match found:
    case True{}:
      SR{buf, ep}
    case False{}:
      SR{buf, 4294967295}

def search_after(mr: MatchRes) -> SearchRes:
  MR{buf, +ep} = mr
  search_upd(U32.is_ne(ep, 4294967295), ep, buf)

def search_step(already: Bool, +len: U32, +re: Regex, +pos: U32, +res: U32, buf: Array<U32>) -> SearchRes:
  match already:
    case True{}:
      SR{buf, res}
    case False{}:
      search_after(eval_cps(600n, len, SEval{re, pos, KDone{}, buf}))

def search_re(+rem: Nat, +len: U32, +re: Regex, +pos: U32, st: SearchRes) -> SearchRes:
  match rem:
    case 0n:
      st
    case 1n+p:
      SR{buf, +res} = st
      search_re(p, len, re, U32.inc(pos), search_step(U32.is_ne(res, 4294967295), len, re, pos, res, buf))

def rot_shift_step(+i: U32, r: Array<U32> & U32) -> Array<U32>:
  (buf1, +ch) = r
  Array.set(U32, buf1, i, ch)

def rot_shift(+rem: Nat, +i: U32, buf: Array<U32>) -> Array<U32>:
  match rem:
    case 0n:
      buf
    case 1n+p:
      rot_shift(p, U32.inc(i), rot_shift_step(i, Array.get(U32, buf, U32.inc(i))))

def rot_finish(r: Array<U32> & U32) -> Array<U32>:
  (buf1, +first) = r
  buf2 = rot_shift(44n, 0, buf1)
  Array.set(U32, buf2, 44, first)

def rotate_buf(buf: Array<U32>) -> Array<U32>:
  rot_finish(Array.get(U32, buf, 0))

def fold_sr(+acc: U32, sr: SearchRes) -> RoundSt:
  SR{buf, +m} = sr
  RS{buf, U32.mul(U32.xor(acc, m), 16777619)}

def run_one(+re: Regex, st: RoundSt) -> RoundSt:
  RS{buf, +acc} = st
  fold_sr(acc, search_re(45n, 45, re, 0, SR{buf, 4294967295}))

def run_rounds(+rem: Nat, +r0: Regex, +r1: Regex, +r2: Regex, +r3: Regex, st: RoundSt) -> U32:
  match rem:
    case 0n:
      RS{buf, +acc} = st
      acc
    case 1n+p:
      RS{buf, +acc} = st
      st1 = run_one(r0, RS{rotate_buf(buf), acc})
      st2 = run_one(r1, st1)
      st3 = run_one(r2, st2)
      st4 = run_one(r3, st3)
      run_rounds(p, r0, r1, r2, r3, st4)

def init_text(buf: Array<U32>) -> Array<U32>:
  buf = Array.set(U32, buf, 0, 97)
  buf = Array.set(U32, buf, 1, 98)
  buf = Array.set(U32, buf, 2, 98)
  buf = Array.set(U32, buf, 3, 98)
  buf = Array.set(U32, buf, 4, 97)
  buf = Array.set(U32, buf, 5, 98)
  buf = Array.set(U32, buf, 6, 97)
  buf = Array.set(U32, buf, 7, 98)
  buf = Array.set(U32, buf, 8, 97)
  buf = Array.set(U32, buf, 9, 97)
  buf = Array.set(U32, buf, 10, 98)
  buf = Array.set(U32, buf, 11, 99)
  buf = Array.set(U32, buf, 12, 99)
  buf = Array.set(U32, buf, 13, 97)
  buf = Array.set(U32, buf, 14, 98)
  buf = Array.set(U32, buf, 15, 97)
  buf = Array.set(U32, buf, 16, 98)
  buf = Array.set(U32, buf, 17, 99)
  buf = Array.set(U32, buf, 18, 97)
  buf = Array.set(U32, buf, 19, 99)
  buf = Array.set(U32, buf, 20, 98)
  buf = Array.set(U32, buf, 21, 99)
  buf = Array.set(U32, buf, 22, 98)
  buf = Array.set(U32, buf, 23, 99)
  buf = Array.set(U32, buf, 24, 98)
  buf = Array.set(U32, buf, 25, 97)
  buf = Array.set(U32, buf, 26, 98)
  buf = Array.set(U32, buf, 27, 98)
  buf = Array.set(U32, buf, 28, 97)
  buf = Array.set(U32, buf, 29, 98)
  buf = Array.set(U32, buf, 30, 99)
  buf = Array.set(U32, buf, 31, 98)
  buf = Array.set(U32, buf, 32, 97)
  buf = Array.set(U32, buf, 33, 98)
  buf = Array.set(U32, buf, 34, 99)
  buf = Array.set(U32, buf, 35, 97)
  buf = Array.set(U32, buf, 36, 98)
  buf = Array.set(U32, buf, 37, 99)
  buf = Array.set(U32, buf, 38, 98)
  buf = Array.set(U32, buf, 39, 98)
  buf = Array.set(U32, buf, 40, 99)
  buf = Array.set(U32, buf, 41, 98)
  buf = Array.set(U32, buf, 42, 98)
  buf = Array.set(U32, buf, 43, 97)
  Array.set(U32, buf, 44, 99)

def mk_r0() -> Regex:
  RPlus{RSeq{RLit{97}, RLit{98}}}

def mk_r1() -> Regex:
  RPlus{RSeq{RLit{98}, RPlus{RAny{}}}}

def mk_r2() -> Regex:
  RSeq{RLit{97}, RStar{RSet2{97, 98}}}

def mk_r3() -> Regex:
  RPlus{RSeq{RSet4{97, 98, 94, 99}, RSet4{97, 98, 94, 99}}}

def main() -> U32:
  buf = init_text(Array.new(U32, 6n, 0))
  run_rounds(4000n, mk_r0(), mk_r1(), mk_r2(), mk_r3(), RS{buf, 2166136261})
