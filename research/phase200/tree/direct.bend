def zr.walk(fuel: Nat, +x: U32, node: BST, left: Bool) -> BST:
  match fuel node left:
    case 0n BLeaf{} _: BNode{BLeaf{}, x, BLeaf{}}
    case 0n BNode{l, v, r} _: BNode{l, v, r}
    case 1n+p BLeaf{} _: BNode{BLeaf{}, x, BLeaf{}}
    case 1n+p BNode{BLeaf{}, v, r} True{}:
      BNode{BNode{BLeaf{}, x, BLeaf{}}, v, r}
    case 1n+p BNode{BNode{ll, +u, lr}, v, r} True{}:
      BNode{zr.walk(p, x, BNode{ll, u, lr}, U32.is_lt(x, u)), v, r}
    case 1n+p BNode{l, v, BLeaf{}} False{}:
      BNode{l, v, BNode{BLeaf{}, x, BLeaf{}}}
    case 1n+p BNode{l, v, BNode{rl, +u, rr}} False{}:
      BNode{l, v, zr.walk(p, x, BNode{rl, u, rr}, U32.is_lt(x, u))}

def zr.insert(fuel: Nat, +x: U32, tree: BST) -> BST:
  match tree:
    case BLeaf{}: BNode{BLeaf{}, x, BLeaf{}}
    case BNode{l, +v, r}:
      zr.walk(fuel, x, BNode{l, v, r}, U32.is_lt(x, v))
