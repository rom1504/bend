import Base
# s4_clbg_binary_trees: Port of CLBG binarytrees (bench/algorithm/binarytrees/2.c)
# Recursive algebraic binary tree allocation, traversal, and checksum (min=4, max=14).

type Tree is Type:
  Leaf{}
  Node{l: Tree, r: Tree}

def make_tree(+d: Nat) -> Tree:
  match d:
    case 0n:
      Leaf{}
    case 1n+p:
      Node{make_tree(p), make_tree(p)}

def check_tree(t: Tree) -> U32:
  match t:
    case Leaf{}:
      1
    case Node{l, r}:
      U32.inc(U32.add(check_tree(l), check_tree(r)))

def iter_depth(+rem: Nat, +d: Nat, +chk: U32) -> U32:
  match rem:
    case 0n:
      chk
    case 1n+p:
      iter_depth(p, d, U32.add(chk, check_tree(make_tree(d))))

def depth_loop(+rem: Nat, +d: Nat, +iters: U32, +acc: U32) -> U32:
  match rem:
    case 0n:
      acc
    case 1n+p:
      +chk = iter_depth(U32.to_nat(iters), d, 0)
      +acc1 = U32.mul(U32.xor(acc, chk), 16777619)
      depth_loop(p, Nat.add(d, 2n), U32.shrn(iters, 2n), acc1)

def main() -> U32:
  +stretch = check_tree(make_tree(15n))
  +acc0 = U32.mul(U32.xor(2166136261, stretch), 16777619)
  long_lived = make_tree(14n)
  +acc1 = depth_loop(6n, 4n, 16384, acc0)
  +ll_chk = check_tree(long_lived)
  U32.mul(U32.xor(acc1, ll_chk), 16777619)
