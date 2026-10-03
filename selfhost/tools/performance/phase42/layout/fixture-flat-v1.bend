import Base

# Independent renamed graph: no bitonic names, layout, or benchmark constants.
type ReviewTree is Data:
  RLeaf{value: U32}
  RNode{left: ReviewTree, right: ReviewTree}

def review.flip(flag: Bool, order: Bool) -> Bool:
  Bool.xor(flag, order)

def review.key(x: U32) -> U32:
  U32.add(U32.mul(x, 1103515245), 12345)

def review.pair.at(+a: U32, +b: U32, flag: Bool) -> ReviewTree:
  match flag:
    case False{}: RNode{RLeaf{a}, RLeaf{b}}
    case True{}: RNode{RLeaf{b}, RLeaf{a}}

def review.pair(+a: U32, +b: U32, flag: Bool) -> ReviewTree:
  review.pair.at(a, b, review.flip(flag, U32.is_gt(a, b)))

def review.map(tree: ReviewTree, +flag: Bool) -> ReviewTree:
  match tree:
    case RLeaf{x}: review.pair(x, review.key(x), flag)
    case RNode{left, right}:
      a b = review.map(left, flag) review.map(right, flag)
      RNode{a, b}

def review.make(n: Nat, +seed: U32) -> ReviewTree:
  match n:
    case 0n: RLeaf{seed}
    case 1n+p: RNode{review.make(p, U32.inc(seed)), RLeaf{U32.xor(seed, 91)}}

def review.score(tree: ReviewTree) -> U32:
  match tree:
    case RLeaf{x}: x
    case RNode{left, right}:
      a b = review.score(left) review.score(right)
      U32.add(U32.mul(a, 3), b)

# Ordinary scalar entry must enter actual compiler-selected private call sites.
def bench(depth: U32, +seed: U32) -> U32:
  review.out(review.stat(review.map(review.make(U32.to_nat(depth), seed), U32.is_zero(U32.mod(seed, 2))))))

# Function-valued bindings and partial references fail the typed pure graph.
def review.reference(tree: ReviewTree) -> ReviewTree:
  unused = review.pair
  tree

def review.partial(tree: ReviewTree) -> ReviewTree:
  unused = review.pair(7)
  tree

# Unsupported input representation cannot become a closed private helper.
def review.text(text: String, tree: ReviewTree) -> ReviewTree:
  tree

# An acyclic forwarding helper cannot hide a transitive backedge.
law review.back:
  for tree: ReviewTree
  ReviewTree

law review.bridge:
  for tree: ReviewTree
  ReviewTree

law review.back_worker:
  for tree: ReviewTree
  ReviewTree

@unsafe
def review.back(tree):
  review.back_worker(tree)

@unsafe
def review.bridge(tree):
  review.back(tree)

@unsafe
def review.back_worker(tree):
  match tree:
    case RLeaf{x}: review.bridge(RLeaf{x})
    case RNode{left, right}:
      a b = review.back_worker(left) review.back_worker(right)
      RNode{a, b}


# Independent second ADT checks flattened internal Stat plus root-only scalar ABI.
type ReviewStat is Data:
  RStat{score: U32}

def review.combine(a: ReviewStat, b: ReviewStat) -> ReviewStat:
  match a b:
    case RStat{x} RStat{y}: RStat{U32.add(U32.mul(x, 3), y)}

def review.stat(tree: ReviewTree) -> ReviewStat:
  match tree:
    case RLeaf{x}: RStat{x}
    case RNode{left, right}:
      a b = review.stat(left) review.stat(right)
      review.combine(a, b)

def review.out(stat: ReviewStat) -> U32:
  match stat:
    case RStat{x}: x

# Native scalar result alone cannot license an observer or typed container edge.
def generic_observer_root(depth: U32, +seed: U32) -> U32:
  unused = review.text("observer", review.make(U32.to_nat(depth), seed))
  bench(depth, seed)

def data_result_root(depth: U32, +seed: U32) -> ReviewTree:
  review.map(review.make(U32.to_nat(depth), seed), False{})

def data_input_root(tree: ReviewTree, +seed: U32) -> U32:
  U32.add(review.out(review.stat(tree)), seed)

def partial_callback_root(depth: U32, +seed: U32) -> U32:
  unused = review.pair(seed)
  bench(depth, seed)

def string_crossing_root(depth: U32, +seed: U32) -> U32:
  review.out(review.stat(review.text("string", review.make(U32.to_nat(depth), seed))))

def review.list_cross(+seed: U32) -> List<&2, ReviewTree>:
  [RLeaf{seed}]

def list_crossing_root(depth: U32, +seed: U32) -> U32:
  unused = review.list_cross(seed)
  bench(depth, seed)

def review.vector(+seed: U32) -> U32 & U32:
  (seed, seed)

def vector_crossing_root(depth: U32, +seed: U32) -> U32:
  unused = review.vector(seed)
  bench(depth, seed)

def mutual_backedge_root(depth: U32, +seed: U32) -> U32:
  review.out(review.stat(review.back_worker(review.make(U32.to_nat(depth), seed))))

# Source spelling resembling the private route cannot enable its metadata.
def private.flat.clone(+x: U32) -> U32:
  U32.xor(x, 17)

def main() -> IO(Unit):
  IO.print(U32.show(bench(0, 0)))

#|37035
