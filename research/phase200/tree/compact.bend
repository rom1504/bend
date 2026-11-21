type ZTrail is Data:
  ZEnd{}
  ZLeft{v: U32, other: BST, next: ZTrail}
  ZRight{v: U32, other: BST, next: ZTrail}

def zc.choose(l: BST, v: U32, r: BST, path: ZTrail, left: Bool) -> BST & ZTrail:
  match left:
    case True{}: (l, ZLeft{v, r, path})
    case False{}: (r, ZRight{v, l, path})

def zc.step(+x: U32, state: BST & ZTrail) -> BST & ZTrail:
  match state:
    case (BLeaf{}, path): (BLeaf{}, path)
    case (BNode{l, +v, r}, path):
      zc.choose(l, v, r, path, U32.is_lt(x, v))

def zc.down(fuel: Nat, +x: U32, state: BST & ZTrail) -> BST & ZTrail:
  match fuel:
    case 0n: state
    case 1n+p: zc.down(p, x, zc.step(x, state))

def zc.up(path: ZTrail, acc: BST) -> BST:
  match path:
    case ZEnd{}: acc
    case ZLeft{v, other, next}: zc.up(next, BNode{acc, v, other})
    case ZRight{v, other, next}: zc.up(next, BNode{other, v, acc})

def zc.finish(x: U32, state: BST & ZTrail) -> BST:
  match state:
    case (BLeaf{}, path): zc.up(path, BNode{BLeaf{}, x, BLeaf{}})
    case (BNode{l, v, r}, path): zc.up(path, BNode{l, v, r})

def zc.insert(fuel: Nat, +x: U32, tree: BST) -> BST:
  zc.finish(x, zc.down(fuel, x, (tree, ZEnd{})))
