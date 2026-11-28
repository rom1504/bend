import Base
# s4_embench_sglib_listsort: Port of Embench-IoT sglib.h Singly-Linked List Mergesort
# Algebraic singly-linked list mergesort: 400 rounds x 512 elements.

type SList is Data:
  LNil{}
  LCons{h: U32, t: SList}

type MergeReq is Data:
  MGo{a: SList, b: SList}
  MCmp{le: Bool, x: U32, xs: SList, y: U32, ys: SList}

type ListPair is Data:
  LP{a: SList, b: SList}

type SortReq is Data:
  SGo{xs: SList}
  SPair{lp: ListPair}

type BuildSt is Data:
  BS{xs: SList, seed: U32}

type RndRes is Data:
  RR{seed: U32, acc: U32}

def merge_lists(+fuel: Nat, req: MergeReq) -> SList:
  match fuel:
    case 0n:
      LNil{}
    case 1n+f:
      match req:
        case MGo{a, b}:
          match a:
            case LNil{}:
              b
            case LCons{+x, xs}:
              match b:
                case LNil{}:
                  LCons{x, xs}
                case LCons{+y, ys}:
                  merge_lists(f, MCmp{U32.is_le(x, y), x, xs, y, ys})
        case MCmp{le, +x, xs, +y, ys}:
          match le:
            case True{}:
              LCons{x, merge_lists(f, MGo{xs, LCons{y, ys}})}
            case False{}:
              LCons{y, merge_lists(f, MGo{LCons{x, xs}, ys})}

def split_step(xs: SList, a: SList, b: SList) -> ListPair:
  match xs:
    case LNil{}:
      LP{a, b}
    case LCons{+x, rest}:
      split_step(rest, b, LCons{x, a})

def msort(+fuel: Nat, req: SortReq) -> SList:
  match fuel:
    case 0n:
      LNil{}
    case 1n+f:
      match req:
        case SGo{xs}:
          match xs:
            case LNil{}:
              LNil{}
            case LCons{+x, rest}:
              match rest:
                case LNil{}:
                  LCons{x, LNil{}}
                case LCons{+y, rest2}:
                  msort(f, SPair{split_step(rest2, LCons{x, LNil{}}, LCons{y, LNil{}})})
        case SPair{LP{a, b}}:
          merge_lists(1040n, MGo{msort(f, SGo{a}), msort(f, SGo{b})})

def build_list(+rem: Nat, st: BuildSt) -> BuildSt:
  match rem:
    case 0n:
      st
    case 1n+p:
      BS{xs, +seed} = st
      +s1 = U32.add(U32.mul(seed, 1664525), 1013904223)
      build_list(p, BS{LCons{U32.shrn(s1, 16n), xs}, s1})

def hash_list(xs: SList, +acc: U32) -> U32:
  match xs:
    case LNil{}:
      acc
    case LCons{+x, rest}:
      hash_list(rest, U32.mul(U32.xor(acc, x), 16777619))

def finish_round(+acc: U32, st: BuildSt) -> RndRes:
  BS{xs, +seed} = st
  RR{seed, hash_list(msort(24n, SGo{xs}), acc)}

def run_rounds(+rem: Nat, st: RndRes) -> U32:
  match rem:
    case 0n:
      RR{+seed, +acc} = st
      acc
    case 1n+p:
      RR{+seed, +acc} = st
      run_rounds(p, finish_round(acc, build_list(512n, BS{LNil{}, seed})))

def main() -> U32:
  run_rounds(400n, RR{324508639, 2166136261})
