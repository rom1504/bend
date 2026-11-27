import Base
# t4_ski_combinator_eval (deep): Pure functional SKI combinator normal-order spine reducer
# Sealed-Test family 4: 420 rounds of nested 3-way Church product (B (B a b) c) via S/K/I.

type Term is Data:
  CS{}
  CK{}
  CI{}
  CSucc{}
  CNum{v: U32}
  CApp{f: Term, x: Term}

type Spine is Data:
  SpNil{}
  SpCons{arg: Term, rest: Spine}

def comb_b() -> Term:
  CApp{CApp{CS{}, CApp{CK{}, CS{}}}, CK{}}

def mk_succ() -> Term:
  CApp{CS{}, comb_b()}

def mk_app(f: Term, x: Term) -> Term:
  CApp{f, x}

def church_go(+rem: Nat, +succ: Term, cur: Term) -> Term:
  match rem:
    case 0n:
      cur
    case 1n+p:
      church_go(p, succ, CApp{succ, cur})

def church_num(+n: U32) -> Term:
  +succ = mk_succ()
  church_go(U32.to_nat(n), succ, CApp{CK{}, CI{}})

def eval_ski(+fuel: Nat, t: Term, sp: Spine) -> U32:
  match fuel:
    case 0n:
      0
    case 1n+p:
      match t:
        case CApp{f, x}:
          eval_ski(p, f, SpCons{x, sp})
        case CI{}:
          match sp:
            case SpNil{}:
              0
            case SpCons{x, rest}:
              eval_ski(p, x, rest)
        case CK{}:
          match sp:
            case SpNil{}:
              0
            case SpCons{x, rest1}:
              match rest1:
                case SpNil{}:
                  0
                case SpCons{y, rest2}:
                  eval_ski(p, x, rest2)
        case CS{}:
          match sp:
            case SpNil{}:
              0
            case SpCons{f, rest1}:
              match rest1:
                case SpNil{}:
                  0
                case SpCons{g, rest2}:
                  match rest2:
                    case SpNil{}:
                      0
                    case SpCons{+x, rest3}:
                      eval_ski(p, CApp{CApp{f, x}, CApp{g, x}}, rest3)
        case CSucc{}:
          match sp:
            case SpNil{}:
              0
            case SpCons{arg, rest}:
              U32.inc(eval_ski(p, arg, rest))
        case CNum{+v}:
          v

def run_rounds(+rem: Nat, +rd: U32, +acc: U32) -> U32:
  match rem:
    case 0n:
      acc
    case 1n+p:
      +a = U32.add(3, U32.and(rd, 3))
      +b = U32.add(3, U32.and(U32.shrn(rd, 2n), 3))
      +c = U32.add(2, U32.and(U32.shrn(rd, 4n), 3))
      +base = U32.and(rd, 15)
      ca = church_num(a)
      cb = church_num(b)
      cc = church_num(c)
      prod1 = mk_app(mk_app(comb_b(), ca), cb)
      expr = mk_app(mk_app(comb_b(), prod1), cc)
      applied = mk_app(mk_app(expr, CSucc{}), CNum{base})
      +v = eval_ski(40000n, applied, SpNil{})
      run_rounds(p, U32.inc(rd), U32.xor(U32.mul(acc, 16777619), v))

def main() -> U32:
  run_rounds(1260n, 0, 2166136261)
