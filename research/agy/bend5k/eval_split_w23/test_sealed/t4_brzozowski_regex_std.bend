import Base
# t4_brzozowski_regex (std): Brzozowski Derivative Regular Expression Matcher over Data ADT
# Sealed-Test family 4: 90 rounds x 64 strings x length 10 over recursive Regex ADT.

type Regex is Data:
  REmpty{}
  REps{}
  RLit{ch: U32}
  RSeq{a: Regex, b: Regex}
  RAlt{a: Regex, b: Regex}
  RStar{r: Regex}

type StrRes is Data:
  SRes{r: Regex, seed: U32}

type RdRes is Data:
  RRes{acc: U32, hits: U32, seed: U32}

def prng(+x: U32) -> U32:
  +b = U32.xor(x, U32.shln(x, 13n))
  +d = U32.xor(b, U32.shrn(b, 17n))
  U32.xor(d, U32.shln(d, 5n))

def mk_seq_b(a: Regex, b: Regex) -> Regex:
  match b:
    case REmpty{}:
      REmpty{}
    case REps{}:
      a
    case RLit{+c}:
      RSeq{a, RLit{c}}
    case RSeq{ba, bb}:
      RSeq{a, RSeq{ba, bb}}
    case RAlt{ba, bb}:
      RSeq{a, RAlt{ba, bb}}
    case RStar{br}:
      RSeq{a, RStar{br}}

def mk_seq(a: Regex, b: Regex) -> Regex:
  match a:
    case REmpty{}:
      REmpty{}
    case REps{}:
      b
    case RLit{+c}:
      mk_seq_b(RLit{c}, b)
    case RSeq{aa, ab}:
      mk_seq_b(RSeq{aa, ab}, b)
    case RAlt{aa, ab}:
      mk_seq_b(RAlt{aa, ab}, b)
    case RStar{ar}:
      mk_seq_b(RStar{ar}, b)

def mk_alt_b(a: Regex, b: Regex) -> Regex:
  match b:
    case REmpty{}:
      a
    case REps{}:
      RAlt{a, REps{}}
    case RLit{+c}:
      RAlt{a, RLit{c}}
    case RSeq{ba, bb}:
      RAlt{a, RSeq{ba, bb}}
    case RAlt{ba, bb}:
      RAlt{a, RAlt{ba, bb}}
    case RStar{br}:
      RAlt{a, RStar{br}}

def mk_alt(a: Regex, b: Regex) -> Regex:
  match a:
    case REmpty{}:
      b
    case REps{}:
      mk_alt_b(REps{}, b)
    case RLit{+c}:
      mk_alt_b(RLit{c}, b)
    case RSeq{aa, ab}:
      mk_alt_b(RSeq{aa, ab}, b)
    case RAlt{aa, ab}:
      mk_alt_b(RAlt{aa, ab}, b)
    case RStar{ar}:
      mk_alt_b(RStar{ar}, b)

def nullable(r: Regex) -> U32:
  match r:
    case REmpty{}:
      0
    case REps{}:
      1
    case RLit{+c}:
      0
    case RSeq{a, b}:
      U32.and(nullable(a), nullable(b))
    case RAlt{a, b}:
      U32.or(nullable(a), nullable(b))
    case RStar{sub}:
      1

def lit_deriv(eq: Bool) -> Regex:
  match eq:
    case True{}:
      REps{}
    case False{}:
      REmpty{}

def seq_deriv(is_nul: Bool, da: Regex, db: Regex) -> Regex:
  match is_nul:
    case True{}:
      mk_alt(da, db)
    case False{}:
      da

def deriv(+c: U32, r: Regex) -> Regex:
  match r:
    case REmpty{}:
      REmpty{}
    case REps{}:
      REmpty{}
    case RLit{+ch}:
      lit_deriv(U32.is_eq(ch, c))
    case RAlt{a, b}:
      mk_alt(deriv(c, a), deriv(c, b))
    case RStar{+sub}:
      mk_seq(deriv(c, sub), RStar{sub})
    case RSeq{+a, +b}:
      +da = mk_seq(deriv(c, a), b)
      seq_deriv(U32.is_eq(nullable(a), 1), da, deriv(c, b))

def mk_star(r: Regex) -> Regex:
  RStar{r}

def build_regex(+rd: U32) -> Regex:
  +c0 = U32.and(rd, 3)
  +c1 = U32.and(U32.add(rd, 1), 3)
  +c2 = U32.and(U32.add(rd, 2), 3)
  +c3 = U32.and(U32.add(rd, 3), 3)
  p1 = mk_star(mk_alt(RLit{c0}, RLit{c1}))
  p2 = mk_alt(mk_seq(RLit{c0}, RLit{c2}), mk_seq(RLit{c1}, RLit{c3}))
  p3 = mk_star(mk_alt(RLit{c2}, RLit{c3}))
  mk_seq(p1, mk_seq(p2, p3))

def run_chars(+rem: Nat, +seed: U32, cur: Regex) -> StrRes:
  match rem:
    case 0n:
      SRes{cur, seed}
    case 1n+p:
      +ns = prng(seed)
      +ch = U32.and(ns, 3)
      run_chars(p, ns, deriv(ch, cur))

def after_str(+s: U32, +rd: U32, +acc: U32, +hits: U32, sr: StrRes) -> RdRes:
  SRes{cur, +seed1} = sr
  +ok = nullable(cur)
  +nacc = U32.xor(U32.mul(acc, 16777619), U32.xor(U32.shln(ok, 8n), U32.add(s, rd)))
  RRes{nacc, U32.add(hits, ok), seed1}

def run_strings(+rem: Nat, +s: U32, +rd: U32, +pat: Regex, rr: RdRes) -> RdRes:
  match rem:
    case 0n:
      rr
    case 1n+p:
      RRes{+acc, +hits, +seed} = rr
      rr1 = after_str(s, rd, acc, hits, run_chars(10n, seed, pat))
      run_strings(p, U32.inc(s), rd, pat, rr1)

def run_rounds(+rem: Nat, +rd: U32, rr: RdRes) -> U32:
  match rem:
    case 0n:
      RRes{+acc, +hits, +seed} = rr
      U32.xor(acc, U32.mul(hits, 2246822519))
    case 1n+p:
      +pat = build_regex(rd)
      rr1 = run_strings(64n, 0, rd, pat, rr)
      run_rounds(p, U32.inc(rd), rr1)

def main() -> U32:
  run_rounds(420n, 0, RRes{2166136261, 0, 123123127})
