import Base

type Chain is Data:
  Stop{}
  Cell{word: U32, tail: Chain}

def make(n: Nat, seed: U32) -> Chain:
  match n:
    case 0n: Stop{}
    case 1n+p: Cell{seed, make(p, U32.add(seed, 1))}

def sum(xs: Chain, acc: U32) -> U32:
  match xs:
    case Stop{}: acc
    case Cell{h, t}: sum(t, U32.add(acc, h))

def head(xs: Chain) -> U32:
  match xs:
    case Stop{}: 0
    case Cell{h, t}: h

def lists(xs: List<&2, Chain>) -> U32:
  match xs:
    case Nil{}: 0
    case Con{h, t}: U32.add(sum(h, 0), lists(t))

def shared(seed: U32) -> U32:
  +root = make(10000n, seed)
  U32.add(sum(root, 0), U32.add(head(root), sum(root, 0)))

def nested(seed: U32) -> U32:
  +xs : List<&2, Chain> = [make(2n, seed), make(3n, 10)]
  U32.add(lists(xs), lists(xs))

def main() -> U32:
  U32.add(shared(1), nested(3))

#|100010081
