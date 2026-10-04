import Base

# Nullary bodies outside an exact literal remain generic. No source execution
# or normalization may make the below call body pass the literal-only gate.
def computed.template() -> String:
  String.append("a", "9")

def count.chars(s: String, acc: U32) -> U32:
  match s:
    case SNil{}: acc
    case SCon{Chr{c}, tail}: count.chars(tail, U32.add(acc, c))

def rows(depth: Nat, seed: U32) -> U32:
  match depth:
    case 0n: count.chars(computed.template(), seed)
    case 1n+p:
      a b = rows(p, seed) rows(p, U32.add(seed, 1))
      U32.add(a, b)

def bench(depth: U32, seed: U32) -> U32:
  rows(U32.to_nat(depth), seed)
