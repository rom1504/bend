import Base
# v4_list_partition_tree (std): Functional 3-way list partition -> BST build & in-order fold
# Validation family 4: N = 4096 uniform keys, 45 rounds.

type PartRes is Data:
  PRes{lt: List<&2, U32>, gt: List<&2, U32>, cnt: U32}

type Tree is Data:
  Leaf{}
  Node{key: U32, cnt: U32, l: Tree, r: Tree}

type BuildArg is Data:
  BList{xs: List<&2, U32>}
  BPart{piv: U32, pr: PartRes}

def prng(+x: U32) -> U32:
  +b = U32.xor(x, U32.shln(x, 13n))
  +d = U32.xor(b, U32.shrn(b, 17n))
  U32.xor(d, U32.shln(d, 5n))

def gen_list(+n: Nat, +seed: U32, acc: List<&2, U32>) -> List<&2, U32>:
  match n:
    case 0n:
      acc
    case 1n+p:
      +ns = prng(seed)
      gen_list(p, ns, Con{ns, acc})

def hash_list(xs: List<&2, U32>, +acc: U32) -> U32:
  match xs:
    case Nil{}:
      acc
    case Con{x, rest}:
      hash_list(rest, U32.xor(U32.mul(acc, 2654435761), x))

def part_insert(c: Cmp, +x: U32, lt: List<&2, U32>, gt: List<&2, U32>, +cnt: U32) -> PartRes:
  match c:
    case LT{}:
      PRes{Con{x, lt}, gt, cnt}
    case EQ{}:
      PRes{lt, gt, U32.inc(cnt)}
    case GT{}:
      PRes{lt, Con{x, gt}, cnt}

def partition(xs: List<&2, U32>, +piv: U32, pr: PartRes) -> PartRes:
  match xs:
    case Nil{}:
      pr
    case Con{+x, rest}:
      PRes{lt, gt, +cnt} = pr
      partition(rest, piv, part_insert(U32.cmp(x, piv), x, lt, gt, cnt))

def build_tree(+fuel: Nat, arg: BuildArg) -> Tree:
  match fuel:
    case 0n:
      match arg:
        case BList{xs}:
          match xs:
            case Nil{}:
              Leaf{}
            case Con{x, rest}:
              Node{hash_list(Con{x, rest}, 1), 1, Leaf{}, Leaf{}}
        case BPart{piv, pr}:
          Leaf{}
    case 1n+f:
      match arg:
        case BPart{piv, pr}:
          PRes{lt, gt, cnt} = pr
          Node{piv, cnt, build_tree(f, BList{lt}), build_tree(f, BList{gt})}
        case BList{xs}:
          match xs:
            case Nil{}:
              Leaf{}
            case Con{+piv, rest}:
              build_tree(f, BPart{piv, partition(rest, piv, PRes{Nil{}, Nil{}, 1})})

def fold_tree(t: Tree, +acc: U32) -> U32:
  match t:
    case Leaf{}:
      acc
    case Node{key, cnt, l, r}:
      +a1 = fold_tree(l, acc)
      +a2 = U32.add(U32.xor(U32.mul(a1, 2654435761), key), cnt)
      fold_tree(r, a2)

def run_rounds(+rounds: Nat, +seed: U32, +acc: U32) -> U32:
  match rounds:
    case 0n:
      acc
    case 1n+p:
      xs = gen_list(4096n, seed, Nil{})
      t = build_tree(128n, BList{xs})
      +nacc = fold_tree(t, acc)
      run_rounds(p, prng(seed), nacc)

def main() -> U32:
  run_rounds(45n, 314159265, 2166136261)
