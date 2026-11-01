# a binary search tree: insert then in-order fold -- ctor churn plus
# ordered traversal, a different data-shape from lists and arrays
# ported from bend3: the x < v dispatch rides a fueled zipper (descend
# collecting frames, insert at the leaf, rebuild) -- a computed-match
# branch cannot hold the recursion any more; compared words +U32
# binders
import Base

type BST is Data:
  BLeaf{}
  BNode{l: BST, v: U32, r: BST}

type BFrame is Data:
  BF{v: U32, other: BST, left: Bool}

law bst.pick:
  for l    : BST
  for v    : U32
  for r    : BST
  for path : List<&2, BFrame>
  for z    : Bool
  BST & List<&2, BFrame>

def bst.pick(l, v, r, path, z):
  match z:
    case True{}:
      (l, BF{v, r, True{}} <> path)
    case False{}:
      (r, BF{v, l, False{}} <> path)

law bst.step:
  for +x : U32
  for st : BST & List<&2, BFrame>
  BST & List<&2, BFrame>

def bst.step(x, st):
  match st:
    case (BLeaf{}, path):
      (BLeaf{}, path)
    case (BNode{l, v0, r}, path):
      +v = {v0 : U32}
      bst.pick(l, v, r, path, U32.is_lt(x, v))

law bst.down:
  for fuel : Nat
  for +x   : U32
  for st   : BST & List<&2, BFrame>
  BST & List<&2, BFrame>

def bst.down(fuel, x, st):
  match fuel:
    case 0n:
      st
    case 1n+f:
      bst.down(f, x, bst.step(x, st))

law bst.up:
  for path : List<&2, BFrame>
  for acc  : BST
  BST

def bst.up(path, acc):
  match path:
    case Nil{}:
      acc
    case BF{v, other, True{}} <> rest:
      bst.up(rest, BNode{acc, v, other})
    case BF{v, other, False{}} <> rest:
      bst.up(rest, BNode{other, v, acc})

law insert.fin:
  for +x : U32
  for st : BST & List<&2, BFrame>
  BST

def insert.fin(x, st):
  match st:
    case (BLeaf{}, path):
      bst.up(path, BNode{BLeaf{}, x, BLeaf{}})
    case (BNode{l, v, r}, path):
      bst.up(path, BNode{l, v, r})

law insert:
  for +x: U32
  for  t: BST
  BST

def insert(x, t):
  insert.fin(x, bst.down(8n, x, (t, Nil{})))

law inorder:
  for t   : BST
  for acc : U32
  U32

def inorder(t, acc):
  match t:
    case BLeaf{}:
      acc
    case BNode{l, v, r}:
      inorder(r, U32.add(U32.mul(inorder(l, acc), 10), v))

law main.out:
  U32

def main.out():
  t0 = {BLeaf{} : BST}
  t1 = insert(5, t0)
  t2 = insert(2, t1)
  t3 = insert(8, t2)
  t4 = insert(1, t3)
  t5 = insert(9, t4)
  inorder(t5, 0)

law p88_original_main:
  IO(Unit)

def p88_original_main():
  IO.print(U32.show(main.out()))

#|12589

# Phase37 wrapper: upstream body above is unchanged.
# Dynamic fuel is sufficient for either a skewed or irregular insertion tree.
def p37.bst.insert(+fuel: Nat, +x: U32, tree: BST) -> BST:
  insert.fin(x, bst.down(fuel, x, (tree, Nil{})))

def p37.bst.build(n: Nat, +fuel: Nat, +i: U32, +seed: U32, tree: BST) -> BST:
  match n:
    case 0n:
      tree
    case 1n+p:
      x = U32.mod(U32.add(U32.mul(i, U32.add(U32.mul(seed, 2), 1)), seed), 257)
      p37.bst.build(p, fuel, U32.add(i, 1), seed, p37.bst.insert(fuel, x, tree))

def bench(+size: U32, seed: U32) -> U32:
  inorder(p37.bst.build(U32.to_nat(size), Nat.add(U32.to_nat(size), 1n), 0, seed, BLeaf{}), 0)

# Phase93: fixed catalog inputs, repeated complete-result validation.
# Final four argv words: repetitions warmups arg0 arg1.
# The measured interval includes result validation and success-count printing.
def p93.parsed(value: Maybe<&2, Nat>, fallback: Nat) -> Nat:
  match value:
    case None{}:
      fallback
    case Some{n}:
      n

def p93.number(text: String, fallback: Nat) -> Nat:
  p93.parsed(Nat.read(text), fallback)

def p93.word_parsed(value: Maybe<&2, U32>, fallback: U32) -> U32:
  match value:
    case None{}:
      fallback
    case Some{n}:
      n

def p93.word(text: String, fallback: U32) -> U32:
  p93.word_parsed(U32.read(text), fallback)

def p93.arguments(args: List<String>) -> (Nat & Nat) & (U32 & U32):
  match args:
    case repetitions <> warmups <> first <> second <> Nil{}:
      ((p93.number(repetitions, 8n), p93.number(warmups, 2n)), (p93.word(first, 64), p93.word(second, 17)))
    case head <> rest:
      p93.arguments(rest)
    case Nil{}:
      ((8n, 2n), (64, 17))

def p93.value(a: U32, b: U32) -> U32:
  bench(a, b)

def p93.loop(n: Nat, +a: U32, +b: U32, h: U32) -> U32:
  match n:
    case 0n:
      h
    case 1n+p:
      value = p93.value(a, b)
      valid = U32.is_eq(value, 861157620)
      p93.loop(p, a, b, U32.add(h, Bool.to_u32(valid)))

def p93.execute(repetitions: Nat, warmups: Nat, +a: U32, +b: U32) -> IO(Unit):
  do IO<Unit>:
    Unit <- IO.print(U32.show(p93.value(a, b)))
    Unit <- IO.print(U32.show(p93.loop(warmups, a, b, 0)))
    t0 : Nat <- IO.now()
    Unit <- IO.print(U32.show(p93.loop(repetitions, a, b, 0)))
    t1 : Nat <- IO.now()
    IO.print(Nat.show(Nat.sub(t1, t0)))

def p93.run(options: (Nat & Nat) & (U32 & U32)) -> IO(Unit):
  (counts, arguments) = options
  (repetitions, warmups) = counts
  (a, b) = arguments
  p93.execute(repetitions, warmups, a, b)

def main() -> IO(Unit):
  do IO<Unit>:
    args : List<String> <- IO.args()
    p93.run(p93.arguments(args))
