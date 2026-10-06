import Base

type Quince58 is Data:
  Sprig58{}
  Seed58{+value: U32}

type Vessel58 is Type:
  Carry58{-T: Type, value: T, tag: Nat}

law forge58:
  for -T: Type
  for x: T
  Vessel58

def forge58(T, x): Carry58{T, x, 7n}

def tag58(v: Vessel58) -> Nat:
  match v:
    case Carry58{T, value, tag}: tag

def pick58(v: Quince58) -> U32:
  match v:
    case Sprig58{}: 5
    case Seed58{value}: value

def bits58(n: U32) -> U32:
  match n:
    case 8: 101
    case 9: 103
    case rest: U32.add(rest, 1)

def count58(n: Nat) -> U32:
  match n:
    case Zero{}: 0
    case Succ{p}: U32.add(count58(p), 1)

def main() -> U32:
  U32.add(U32.add(bits58(9), pick58(Seed58{7})), U32.add(count58(3n), U32.from_nat(tag58(forge58(Nat, 3n)))))

#|120
