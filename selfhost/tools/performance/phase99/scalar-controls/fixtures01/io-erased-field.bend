import Base

type Packet is Data:
  Packet{-erased: U32, word: U32, wide: Nat}

def value(p: Packet) -> Nat:
  match p:
    case Packet{erased, +word, wide}:
      Nat.add(wide, Nat.add(U32.to_nat(word), U32.to_nat(word)))

def answer() -> Nat:
  value(Packet{77, 4294967295, Nat.mul(65536n, 65536n)})

def main() -> IO(Unit):
  do IO<Unit>:
    IO.print_err("scalar-control")
    IO.print(Nat.show(answer()))

#|12884901886
