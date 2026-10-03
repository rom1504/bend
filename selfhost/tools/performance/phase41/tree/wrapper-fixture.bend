import Base

type WrapTree is Data:
  WLeaf{value: U32}
  WNode{left: WrapTree, right: WrapTree}

# Independent proper-descendant worker, unrelated to bitonic sorting.
def wrap.map(tree: WrapTree) -> WrapTree:
  match tree:
    case WLeaf{x}: WLeaf{U32.add(x, 7)}
    case WNode{left, right}:
      a b = wrap.map(left) wrap.map(right)
      WNode{a, b}

# Both a matched wrapper and a plain saturated forwarding wrapper are acyclic.
def wrap.turn(tree: WrapTree, flag: Bool) -> WrapTree:
  match tree flag:
    case WLeaf{x} _: WLeaf{x}
    case WNode{left, right} False{}: wrap.map(WNode{left, right})
    case WNode{left, right} True{}: wrap.map(WNode{right, left})

def wrap.forward(tree: WrapTree) -> WrapTree:
  wrap.map(tree)

def wrap.make(n: Nat, +seed: U32) -> WrapTree:
  match n:
    case 0n: WLeaf{seed}
    case 1n+p: WNode{wrap.make(p, U32.inc(seed)), WLeaf{U32.xor(seed, 91)}}

def wrap.score(tree: WrapTree) -> U32:
  match tree:
    case WLeaf{x}: x
    case WNode{left, right}:
      a b = wrap.score(left) wrap.score(right)
      U32.add(U32.mul(a, 3), b)

def bench(+depth: U32, +seed: U32) -> U32:
  wrap.score(wrap.turn(wrap.make(U32.to_nat(depth), seed), U32.is_zero(U32.mod(seed, 2))))

def forward_check(+depth: U32, +seed: U32) -> U32:
  wrap.score(wrap.forward(wrap.make(U32.to_nat(depth), seed)))

# Nullary, scalar-first and Nat-first acyclic functions must not become new components.
def wrap.empty() -> WrapTree:
  wrap.map(WLeaf{9})

def wrap.scalar(flag: Bool, tree: WrapTree) -> WrapTree:
  match flag:
    case False{}: wrap.map(tree)
    case True{}: wrap.map(tree)

def wrap.nat(n: Nat, tree: WrapTree) -> WrapTree:
  match n:
    case 0n: wrap.map(tree)
    case 1n+p: wrap.map(tree)

def refusal_check(+depth: U32, +seed: U32) -> U32:
  wrap.score(wrap.scalar(False{}, wrap.nat(0n, wrap.make(U32.to_nat(depth), seed))))

# A first-class-only reference does not satisfy the independent pure graph.
def wrap.reference(tree: WrapTree) -> WrapTree:
  +unused = wrap.map
  tree

# An ADT-first acyclic wrapper calling an unproved reconstructed-parent worker refuses.
law wrap.improper:
  for tree: WrapTree
  WrapTree

@unsafe
def wrap.improper(tree):
  match tree:
    case WLeaf{x}: WLeaf{x}
    case WNode{left, right}: wrap.improper(WNode{left, right})

def wrap.bad_first(tree: WrapTree) -> WrapTree:
  wrap.improper(tree)

# A transitive backedge into the wrapper must refuse even with a proper worker self-call.
law wrap.back:
  for tree: WrapTree
  WrapTree

law wrap.bridge:
  for tree: WrapTree
  WrapTree

law wrap.back_worker:
  for tree: WrapTree
  WrapTree

@unsafe
def wrap.back(tree):
  wrap.back_worker(tree)

@unsafe
def wrap.bridge(tree):
  wrap.back(tree)

@unsafe
def wrap.back_worker(tree):
  match tree:
    case WLeaf{x}: wrap.bridge(WLeaf{x})
    case WNode{left, right}:
      a b = wrap.back_worker(left) wrap.back_worker(right)
      WNode{a, b}

def main() -> IO(Unit):
  IO.print(U32.show(bench(3, 17)))
