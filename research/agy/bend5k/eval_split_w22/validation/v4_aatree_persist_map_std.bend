import Base
# v4_aatree_persist_map (std): Persistent AA-Tree balanced BST (skew/split rotations + lookups)
# Validation family 4: 140 rounds x (256 random inserts + 512 lookups) on Data ADT.

type AATree is Data:
  Leaf{}
  Node{lvl: U32, key: U32, val: U32, l: AATree, r: AATree}

type BuildRes is Data:
  BRes{tree: AATree, seed: U32}

type QueryRes is Data:
  QRes{acc: U32, seed: U32}

def prng(+x: U32) -> U32:
  +b = U32.xor(x, U32.shln(x, 13n))
  +d = U32.xor(b, U32.shrn(b, 17n))
  U32.xor(d, U32.shln(d, 5n))

def skew_cmp(
  eq: Bool, +lv: U32, +k: U32, +v: U32,
  +llv: U32, +lk: U32, +lv2: U32, ll: AATree, lr: AATree, r: AATree
) -> AATree:
  match eq:
    case True{}:
      Node{llv, lk, lv2, ll, Node{lv, k, v, lr, r}}
    case False{}:
      Node{lv, k, v, Node{llv, lk, lv2, ll, lr}, r}

def aa_skew(t: AATree) -> AATree:
  match t:
    case Leaf{}:
      Leaf{}
    case Node{+lv, +k, +v, l, r}:
      match l:
        case Leaf{}:
          Node{lv, k, v, Leaf{}, r}
        case Node{+llv, +lk, +lv2, ll, lr}:
          skew_cmp(U32.is_eq(llv, lv), lv, k, v, llv, lk, lv2, ll, lr, r)

def split_cmp(
  eq: Bool, +lv: U32, +k: U32, +v: U32, l: AATree,
  +rlv: U32, +rk: U32, +rv: U32, rl: AATree,
  +rrlv: U32, +rrk: U32, +rrv: U32, rrl: AATree, rrr: AATree
) -> AATree:
  match eq:
    case True{}:
      Node{U32.inc(rlv), rk, rv, Node{lv, k, v, l, rl}, Node{rrlv, rrk, rrv, rrl, rrr}}
    case False{}:
      Node{lv, k, v, l, Node{rlv, rk, rv, rl, Node{rrlv, rrk, rrv, rrl, rrr}}}

def aa_split(t: AATree) -> AATree:
  match t:
    case Leaf{}:
      Leaf{}
    case Node{+lv, +k, +v, l, r}:
      match r:
        case Leaf{}:
          Node{lv, k, v, l, Leaf{}}
        case Node{+rlv, +rk, +rv, rl, rr}:
          match rr:
            case Leaf{}:
              Node{lv, k, v, l, Node{rlv, rk, rv, rl, Leaf{}}}
            case Node{+rrlv, +rrk, +rrv, rrl, rrr}:
              split_cmp(U32.is_eq(lv, rrlv), lv, k, v, l, rlv, rk, rv, rl, rrlv, rrk, rrv, rrl, rrr)

type InsReq is Data:
  IRoot{t: AATree}
  ICmp{c: Cmp, lv: U32, tk: U32, tv: U32, l: AATree, r: AATree}

type LookReq is Data:
  LRoot{t: AATree}
  LCmp{c: Cmp, tv: U32, l: AATree, r: AATree}

def aa_insert(+fuel: Nat, req: InsReq, +k: U32, +v: U32) -> AATree:
  match fuel:
    case 0n:
      Leaf{}
    case 1n+f:
      match req:
        case IRoot{t}:
          match t:
            case Leaf{}:
              Node{1, k, v, Leaf{}, Leaf{}}
            case Node{+lv, +tk, +tv, l, r}:
              aa_insert(f, ICmp{U32.cmp(k, tk), lv, tk, tv, l, r}, k, v)
        case ICmp{c, +lv, +tk, +tv, l, r}:
          match c:
            case LT{}:
              aa_split(aa_skew(Node{lv, tk, tv, aa_insert(f, IRoot{l}, k, v), r}))
            case GT{}:
              aa_split(aa_skew(Node{lv, tk, tv, l, aa_insert(f, IRoot{r}, k, v)}))
            case EQ{}:
              Node{lv, k, v, l, r}

def aa_lookup(+fuel: Nat, req: LookReq, +k: U32) -> U32:
  match fuel:
    case 0n:
      0
    case 1n+f:
      match req:
        case LRoot{t}:
          match t:
            case Leaf{}:
              0
            case Node{+lv, +tk, +tv, l, r}:
              aa_lookup(f, LCmp{U32.cmp(k, tk), tv, l, r}, k)
        case LCmp{c, +tv, l, r}:
          match c:
            case LT{}:
              aa_lookup(f, LRoot{l}, k)
            case GT{}:
              aa_lookup(f, LRoot{r}, k)
            case EQ{}:
              tv

def do_inserts(+rem: Nat, +i: U32, +rd: U32, +seed: U32, t: AATree) -> BuildRes:
  match rem:
    case 0n:
      BRes{t, seed}
    case 1n+p:
      +ns = prng(seed)
      +k = U32.and(ns, 1023)
      +v = U32.xor(U32.shrn(ns, 10n), U32.add(i, rd))
      do_inserts(p, U32.inc(i), rd, ns, aa_insert(128n, IRoot{t}, k, v))

def do_queries(+rem: Nat, +seed: U32, +acc: U32, +t: AATree) -> QueryRes:
  match rem:
    case 0n:
      QRes{acc, seed}
    case 1n+p:
      +ns = prng(seed)
      +k = U32.and(ns, 1023)
      +val = aa_lookup(128n, LRoot{t}, k)
      do_queries(p, ns, U32.xor(U32.mul(acc, 16777619), val), t)

def round_query(+acc: U32, br: BuildRes) -> QueryRes:
  BRes{t, +seed1} = br
  do_queries(512n, seed1, acc, t)

def run_rounds(+rem: Nat, +rd: U32, qr: QueryRes) -> U32:
  match rem:
    case 0n:
      QRes{+acc, +seed} = qr
      acc
    case 1n+p:
      QRes{+acc, +seed} = qr
      run_rounds(p, U32.inc(rd), round_query(acc, do_inserts(256n, 0, rd, seed, Leaf{})))

def main() -> U32:
  run_rounds(140n, 0, QRes{2166136261, 246813579})
