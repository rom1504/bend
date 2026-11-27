import Base
# k2_tree_nontail_fold: Pure non-tail recursive ADT binary tree fold (zero continuation ADT)
# Fresh Non-Suite Kernel 2 (Wave 22): depth-10 tree (1024 leaves, 2047 nodes), 12,000 non-tail folds.

type BTree is Data:
  BLeaf{v: U32}
  BNode{w: U32, tag: U32, l: BTree, r: BTree}

def prng(+x: U32) -> U32:
  +b = U32.xor(x, U32.shln(x, 13n))
  +d = U32.xor(b, U32.shrn(b, 17n))
  U32.xor(d, U32.shln(d, 5n))

def build_tree(+depth: Nat, +base: U32) -> BTree:
  match depth:
    case 0n:
      BLeaf{U32.xor(U32.mul(U32.inc(base), 2654435761), base)}
    case 1n+p:
      +half = U32.shln(1, p)
      +w = U32.add(U32.mul(base, 17), U32.shln(half, 3n))
      +tag = U32.and(U32.xor(base, half), 255)
      BNode{w, tag, build_tree(p, base), build_tree(p, U32.add(base, half))}

def fold_tree(t: BTree, +salt: U32) -> U32:
  match t:
    case BLeaf{+v}:
      U32.xor(U32.mul(U32.xor(v, salt), 16777619), v)
    case BNode{+w, +tag, l, r}:
      +fl = fold_tree(l, U32.add(salt, tag))
      +fr = fold_tree(r, U32.xor(salt, w))
      U32.add(U32.xor(U32.mul(fl, 16777619), fr), w)

def run_folds(+rem: Nat, +t: BTree, +seed: U32, +acc: U32) -> U32:
  match rem:
    case 0n:
      acc
    case 1n+p:
      +ns = prng(seed)
      +v = fold_tree(t, ns)
      run_folds(p, t, ns, U32.xor(U32.mul(acc, 16777619), v))

def main() -> U32:
  +t = build_tree(10n, 0)
  run_folds(12000n, t, 987654321, 2166136261)
