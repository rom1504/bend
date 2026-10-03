import Base

# Closed scalar roots exercise sequential descendant continuations independently.
type SeqTree is Data:
  SEmpty{}
  SNode{left: SeqTree, value: U32, right: SeqTree}

def sequence.make_right(n: Nat, +seed: U32) -> SeqTree:
  match n:
    case 0n: SEmpty{}
    case 1n+p: SNode{SEmpty{}, seed, sequence.make_right(p, U32.inc(seed))}

def sequence.make_left(n: Nat, +seed: U32) -> SeqTree:
  match n:
    case 0n: SEmpty{}
    case 1n+p: SNode{sequence.make_left(p, U32.inc(seed)), seed, SEmpty{}}

def sequence.fold(tree: SeqTree, acc: U32) -> U32:
  match tree:
    case SEmpty{}: acc
    case SNode{left, value, right}:
      sequence.fold(left, U32.add(sequence.fold(right, acc), value))

def sequence.weighted(tree: SeqTree, acc: U32) -> U32:
  match tree:
    case SEmpty{}: acc
    case SNode{left, value, right}:
      sequence.weighted(left, U32.add(U32.mul(sequence.weighted(right, acc), 10), value))

def sequence.mirror(tree: SeqTree, acc: U32) -> U32:
  match tree:
    case SEmpty{}: acc
    case SNode{left, value, right}:
      sequence.mirror(right, U32.sub(value, sequence.mirror(left, acc)))

# Explicit source annotations must remain ordinary typed argument shells.
def sequence.annotated(tree: SeqTree, acc: U32) -> U32:
  match tree:
    case SEmpty{}: acc
    case SNode{left, value, right}:
      sequence.annotated(left, {U32.add({sequence.annotated(right, acc): U32}, value): U32})

def sequence.right(depth: U32, +seed: U32) -> U32:
  sequence.fold(sequence.make_right(U32.to_nat(depth), seed), seed)

def sequence.left(depth: U32, +seed: U32) -> U32:
  sequence.fold(sequence.make_left(U32.to_nat(depth), seed), seed)

def sequence.weight(depth: U32, +seed: U32) -> U32:
  sequence.weighted(sequence.make_right(U32.to_nat(depth), seed), seed)

def sequence.reverse(depth: U32, +seed: U32) -> U32:
  sequence.mirror(sequence.make_left(U32.to_nat(depth), seed), seed)

def sequence.annotation(depth: U32, +seed: U32) -> U32:
  sequence.annotated(sequence.make_right(U32.to_nat(depth), seed), seed)

def main() -> IO(Unit):
  IO.print(U32.show(sequence.right(0, 11)))

#|11

# Bounded existing component consumes a native Nat.add result.
def sequence.nat(a: Nat, b: Nat) -> U32:
  +sum = {Nat.add(a, b): Nat}
  sequence.fold(sequence.make_right(U32.to_nat(U32.mod(U32.from_nat(sum), 4)), 17), U32.from_nat(sum))

def sequence.nat.point(a: U32, b: U32) -> U32:
  sequence.nat(U32.to_nat(a), U32.to_nat(b))
