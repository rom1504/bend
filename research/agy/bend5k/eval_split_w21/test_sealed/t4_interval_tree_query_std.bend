import Base
# t4_interval_tree_query (std): Persistent Augmented Interval Tree with two-sided overlap pruning
# Sealed-Test family 4: N = 512 random intervals, 512 overlap queries, 65 rounds.

type ITree is Data:
  Empty{}
  INode{lo: U32, hi: U32, max_hi: U32, l: ITree, r: ITree}

type InsReq is Data:
  IRoot{t: ITree}
  ICmp{c: Cmp, nlo: U32, nhi: U32, nmax: U32, l: ITree, r: ITree}
  IGo{go_left: Bool, nlo: U32, nhi: U32, nmax: U32, l: ITree, r: ITree}

type QReq is Data:
  QRoot{t: ITree}
  QCheck{pruned: Bool, nlo: U32, nhi: U32, l: ITree, r: ITree}
  QRight{le_qhi: Bool, nlo: U32, nhi: U32, r: ITree}

type BuildRes is Data:
  BRes{t: ITree, seed: U32}

type QueryRes is Data:
  QRes{acc: U32, seed: U32}

def prng(+x: U32) -> U32:
  +b = U32.xor(x, U32.shln(x, 13n))
  +d = U32.xor(b, U32.shrn(b, 17n))
  U32.xor(d, U32.shln(d, 5n))

def insert_iv(+fuel: Nat, req: InsReq, +lo: U32, +hi: U32) -> ITree:
  match fuel:
    case 0n:
      Empty{}
    case 1n+f:
      match req:
        case IRoot{t}:
          match t:
            case Empty{}:
              INode{lo, hi, hi, Empty{}, Empty{}}
            case INode{+nlo, +nhi, +nm, l, r}:
              insert_iv(f, ICmp{U32.cmp(lo, nlo), nlo, nhi, U32.max(nm, hi), l, r}, lo, hi)
        case ICmp{c, +nlo, +nhi, +nmax, l, r}:
          match c:
            case LT{}:
              INode{nlo, nhi, nmax, insert_iv(f, IRoot{l}, lo, hi), r}
            case EQ{}:
              insert_iv(f, IGo{U32.is_lt(hi, nhi), nlo, nhi, nmax, l, r}, lo, hi)
            case GT{}:
              INode{nlo, nhi, nmax, l, insert_iv(f, IRoot{r}, lo, hi)}
        case IGo{go_left, +nlo, +nhi, +nmax, l, r}:
          match go_left:
            case True{}:
              INode{nlo, nhi, nmax, insert_iv(f, IRoot{l}, lo, hi), r}
            case False{}:
              INode{nlo, nhi, nmax, l, insert_iv(f, IRoot{r}, lo, hi)}

def hit_update(hit: Bool, +nlo: U32, +nhi: U32, +a1: U32) -> U32:
  match hit:
    case True{}:
      U32.xor(U32.mul(a1, 16777619), U32.add(nlo, U32.shln(nhi, 16n)))
    case False{}:
      a1

def query_overlap(+fuel: Nat, req: QReq, +qlo: U32, +qhi: U32, +acc: U32) -> U32:
  match fuel:
    case 0n:
      acc
    case 1n+f:
      match req:
        case QRoot{t}:
          match t:
            case Empty{}:
              acc
            case INode{+nlo, +nhi, +nm, l, r}:
              query_overlap(f, QCheck{U32.is_lt(nm, qlo), nlo, nhi, l, r}, qlo, qhi, acc)
        case QCheck{pruned, +nlo, +nhi, l, r}:
          match pruned:
            case True{}:
              acc
            case False{}:
              +a1 = query_overlap(f, QRoot{l}, qlo, qhi, acc)
              query_overlap(f, QRight{U32.is_le(nlo, qhi), nlo, nhi, r}, qlo, qhi, a1)
        case QRight{le_qhi, +nlo, +nhi, r}:
          match le_qhi:
            case True{}:
              +a2 = hit_update(U32.is_ge(nhi, qlo), nlo, nhi, acc)
              query_overlap(f, QRoot{r}, qlo, qhi, a2)
            case False{}:
              acc

def build_tree(+rem: Nat, +seed: U32, t: ITree) -> BuildRes:
  match rem:
    case 0n:
      BRes{t, seed}
    case 1n+p:
      +ns = prng(seed)
      +lo = U32.and(ns, 32767)
      +hi = U32.add(U32.add(lo, 16), U32.and(U32.shrn(ns, 16n), 255))
      build_tree(p, ns, insert_iv(1536n, IRoot{t}, lo, hi))

def run_queries(+rem: Nat, +t: ITree, +seed: U32, +acc: U32) -> QueryRes:
  match rem:
    case 0n:
      QRes{acc, seed}
    case 1n+p:
      +ns = prng(seed)
      +qlo = U32.and(ns, 32767)
      +qhi = U32.add(U32.add(qlo, 64), U32.and(U32.shrn(ns, 16n), 511))
      run_queries(p, t, ns, query_overlap(1536n, QRoot{t}, qlo, qhi, acc))

def run_one_round(br: BuildRes, +acc: U32) -> QueryRes:
  BRes{+t, +s1} = br
  run_queries(512n, t, s1, acc)

def run_rounds(+rem: Nat, qr: QueryRes) -> U32:
  match rem:
    case 0n:
      QRes{+acc, +seed} = qr
      acc
    case 1n+p:
      QRes{+acc, +seed} = qr
      run_rounds(p, run_one_round(build_tree(512n, seed, Empty{}), acc))

def main() -> U32:
  run_rounds(65n, QRes{2166136261, 314159265})
