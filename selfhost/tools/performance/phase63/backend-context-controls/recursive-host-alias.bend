import Base

def Natural() -> Data:
  Nat

def Items(-A: Data) -> Data:
  List<&2,A>

type Bag is Data:
  Bag{values: Items(Natural)}

def identity_bag(x: Bag) -> Bag:
  x

def sum(xs: Items(Natural)) -> Natural:
  match xs:
    case Nil{}: 0n
    case Con{x, tail}: Nat.add(x, sum(tail))

def total(b: Bag) -> Natural:
  match b:
    case Bag{xs}: sum(xs)

def probe() -> Natural:
  total(identity_bag(Bag{[2n, 3n, 7n]}))
