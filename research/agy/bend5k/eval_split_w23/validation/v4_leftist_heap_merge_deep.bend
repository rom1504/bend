import Base
# v4_leftist_heap_merge (deep): Persistent Leftist Heap priority queue (merge, insert, delete_min)
# Validation family 4: 60 rounds x (512 inserts + 512 pop_mins) on Data ADT LHeap.

type LHeap is Data:
  Empty{}
  Node{rk: U32, key: U32, val: U32, l: LHeap, r: LHeap}

type BuildRes is Data:
  BRes{h: LHeap, seed: U32}

type PopRes is Data:
  PRes{acc: U32, seed: U32}

def prng(+x: U32) -> U32:
  +b = U32.xor(x, U32.shln(x, 13n))
  +d = U32.xor(b, U32.shrn(b, 17n))
  U32.xor(d, U32.shln(d, 5n))

def make_node_cmp(ge: Bool, +ra: U32, +rb: U32, +k: U32, +v: U32, a: LHeap, b: LHeap) -> LHeap:
  match ge:
    case True{}:
      Node{U32.inc(rb), k, v, a, b}
    case False{}:
      Node{U32.inc(ra), k, v, b, a}

def make_node_b(+ra: U32, +k: U32, +v: U32, a: LHeap, b: LHeap) -> LHeap:
  match b:
    case Empty{}:
      Node{1, k, v, a, Empty{}}
    case Node{+rb, +bk, +bv, bl, br}:
      make_node_cmp(U32.is_ge(ra, rb), ra, rb, k, v, a, Node{rb, bk, bv, bl, br})

def make_node(+k: U32, +v: U32, a: LHeap, b: LHeap) -> LHeap:
  match a:
    case Empty{}:
      make_node_b(0, k, v, Empty{}, b)
    case Node{+ra, +ak, +av, al, ar}:
      make_node_b(ra, k, v, Node{ra, ak, av, al, ar}, b)

type MergeReq is Data:
  MGo{h1: LHeap, h2: LHeap}
  MCmp{le: Bool, rk1: U32, k1: U32, v1: U32, l1: LHeap, r1: LHeap, rk2: U32, k2: U32, v2: U32, l2: LHeap, r2: LHeap}

def merge_heap(+fuel: Nat, req: MergeReq) -> LHeap:
  match fuel:
    case 0n:
      Empty{}
    case 1n+f:
      match req:
        case MGo{h1, h2}:
          match h1:
            case Empty{}:
              h2
            case Node{+rk1, +k1, +v1, l1, r1}:
              match h2:
                case Empty{}:
                  Node{rk1, k1, v1, l1, r1}
                case Node{+rk2, +k2, +v2, l2, r2}:
                  merge_heap(f, MCmp{U32.is_le(k1, k2), rk1, k1, v1, l1, r1, rk2, k2, v2, l2, r2})
        case MCmp{le, +rk1, +k1, +v1, l1, r1, +rk2, +k2, +v2, l2, r2}:
          match le:
            case True{}:
              make_node(k1, v1, l1, merge_heap(f, MGo{r1, Node{rk2, k2, v2, l2, r2}}))
            case False{}:
              make_node(k2, v2, l2, merge_heap(f, MGo{Node{rk1, k1, v1, l1, r1}, r2}))

def do_inserts(+rem: Nat, +i: U32, +rd: U32, +seed: U32, h: LHeap) -> BuildRes:
  match rem:
    case 0n:
      BRes{h, seed}
    case 1n+p:
      +ns = prng(seed)
      +k = U32.and(ns, 65535)
      +v = U32.xor(U32.shrn(ns, 16n), U32.add(i, rd))
      do_inserts(p, U32.inc(i), rd, ns, merge_heap(128n, MGo{Node{1, k, v, Empty{}, Empty{}}, h}))

def do_pops(+rem: Nat, +acc: U32, h: LHeap) -> U32:
  match rem:
    case 0n:
      acc
    case 1n+p:
      match h:
        case Empty{}:
          acc
        case Node{+rk, +k, +v, l, r}:
          +nacc = U32.xor(U32.mul(acc, 16777619), U32.xor(U32.shln(k, 16n), v))
          do_pops(p, nacc, merge_heap(128n, MGo{l, r}))

def round_pop(+acc: U32, br: BuildRes) -> PopRes:
  BRes{h, +seed1} = br
  PRes{do_pops(512n, acc, h), seed1}

def run_rounds(+rem: Nat, +rd: U32, pr: PopRes) -> U32:
  match rem:
    case 0n:
      PRes{+acc, +seed} = pr
      acc
    case 1n+p:
      PRes{+acc, +seed} = pr
      run_rounds(p, U32.inc(rd), round_pop(acc, do_inserts(512n, 0, rd, seed, Empty{})))

def main() -> U32:
  run_rounds(60n, 0, PRes{2166136261, 314159265})
