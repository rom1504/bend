import Base
# s4_embench_sglib_rbtree: Port of Embench-IoT sglib.h Red-Black Tree
# Okasaki functional Red-Black Tree: 300 rounds x 512 inserts + in-order traversal.

type Color is Data:
  Red{}
  Blk{}

type RBTree is Data:
  Emp{}
  RBN{c: Color, l: RBTree, k: U32, r: RBTree}

type InsReq is Data:
  IGo{t: RBTree}
  ICmp{cmp: Cmp, c: Color, l: RBTree, y: U32, r: RBTree}

type BuildSt is Data:
  BS{t: RBTree, seed: U32}

type RndRes is Data:
  RR{seed: U32, acc: U32}

def bal_ll(c: Color, l: RBTree, +z: U32, d: RBTree) -> RBTree:
  match l:
    case Emp{}:
      RBN{c, Emp{}, z, d}
    case RBN{lc, ll, +y, lr}:
      match lc:
        case Blk{}:
          RBN{c, RBN{Blk{}, ll, y, lr}, z, d}
        case Red{}:
          match ll:
            case RBN{Red{}, a, +x, b}:
              RBN{Red{}, RBN{Blk{}, a, x, b}, y, RBN{Blk{}, lr, z, d}}
            case ll:
              match lr:
                case RBN{Red{}, b, +x, g}:
                  RBN{Red{}, RBN{Blk{}, ll, y, b}, x, RBN{Blk{}, g, z, d}}
                case lr:
                  RBN{c, RBN{Red{}, ll, y, lr}, z, d}

def bal_rr(c: Color, a: RBTree, +x: U32, r: RBTree) -> RBTree:
  match r:
    case Emp{}:
      RBN{c, a, x, Emp{}}
    case RBN{rc, rl, +y, rr}:
      match rc:
        case Blk{}:
          RBN{c, a, x, RBN{Blk{}, rl, y, rr}}
        case Red{}:
          match rl:
            case RBN{Red{}, b, +z, g}:
              RBN{Red{}, RBN{Blk{}, a, x, b}, z, RBN{Blk{}, g, y, rr}}
            case rl:
              match rr:
                case RBN{Red{}, g, +z, d}:
                  RBN{Red{}, RBN{Blk{}, a, x, rl}, y, RBN{Blk{}, g, z, d}}
                case rr:
                  RBN{c, a, x, RBN{Red{}, rl, y, rr}}

def bal_rr_check(t: RBTree) -> RBTree:
  match t:
    case Emp{}:
      Emp{}
    case RBN{Red{}, l, +k, r}:
      RBN{Red{}, l, k, r}
    case RBN{Blk{}, l, +k, r}:
      bal_rr(Blk{}, l, k, r)

def balance(c: Color, l: RBTree, +k: U32, r: RBTree) -> RBTree:
  match c:
    case Red{}:
      RBN{Red{}, l, k, r}
    case Blk{}:
      bal_rr_check(bal_ll(Blk{}, l, k, r))

def rb_ins(+fuel: Nat, +x: U32, req: InsReq) -> RBTree:
  match fuel:
    case 0n:
      Emp{}
    case 1n+f:
      match req:
        case IGo{t}:
          match t:
            case Emp{}:
              RBN{Red{}, Emp{}, x, Emp{}}
            case RBN{c, l, +y, r}:
              rb_ins(f, x, ICmp{U32.cmp(x, y), c, l, y, r})
        case ICmp{cmp, c, l, +y, r}:
          match cmp:
            case LT{}:
              balance(c, rb_ins(f, x, IGo{l}), y, r)
            case GT{}:
              balance(c, l, y, rb_ins(f, x, IGo{r}))
            case EQ{}:
              RBN{c, l, y, r}

def make_black(t: RBTree) -> RBTree:
  match t:
    case Emp{}:
      Emp{}
    case RBN{c, l, +k, r}:
      RBN{Blk{}, l, k, r}

def insert(t: RBTree, +x: U32) -> RBTree:
  make_black(rb_ins(64n, x, IGo{t}))

def inorder(t: RBTree, +acc: U32) -> U32:
  match t:
    case Emp{}:
      acc
    case RBN{c, l, +k, r}:
      +a1 = inorder(l, acc)
      +a2 = U32.mul(U32.xor(a1, k), 16777619)
      inorder(r, a2)

def build_tree(+rem: Nat, st: BuildSt) -> BuildSt:
  match rem:
    case 0n:
      st
    case 1n+p:
      BS{t, +seed} = st
      +s1 = U32.add(U32.mul(seed, 1664525), 1013904223)
      +k = U32.and(s1, 1023)
      build_tree(p, BS{insert(t, k), s1})

def finish_round(+acc: U32, st: BuildSt) -> RndRes:
  BS{t, +seed} = st
  RR{seed, inorder(t, acc)}

def run_rounds(+rem: Nat, st: RndRes) -> U32:
  match rem:
    case 0n:
      RR{+seed, +acc} = st
      acc
    case 1n+p:
      RR{+seed, +acc} = st
      run_rounds(p, finish_round(acc, build_tree(512n, BS{Emp{}, seed})))

def main() -> U32:
  run_rounds(300n, RR{3405691582, 2166136261})
