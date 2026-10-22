# Ordinary deep self-tail loop, parallel lane moves, and retained mixed records.
import Base

def route.bits(value: F32) -> U32:
  F32{word} = value
  U32{word}

def route.rotate(n: Nat, x: F32, y: F32, stamp: U32) -> (F32 & F32) & U32:
  match n:
    case 0n: ((x, y), stamp)
    case 1n+p:
      route.rotate(p, y, F32.add(x, 0.25), U32.add(U32.mul(stamp, 3), 1))

def route.show(result: (F32 & F32) & U32) -> String:
  (values, stamp) = result
  (x, y) = values
  U32.show(route.bits(x)) ++ ":" ++ U32.show(route.bits(y)) ++ ":" ++ U32.show(stamp)

def route.case(n: Nat) -> IO(Unit):
  IO.print(route.show(route.rotate(n, 1.0, 5.0, 4294967295)))

type Parcel is Data:
  Parcel{stamp: U32, left: F32, text: String, right: F32}

def parcel.tick(value: Parcel) -> Parcel:
  match value:
    case Parcel{stamp, left, text, right}:
      Parcel{U32.add(U32.mul(stamp, 3), 1), right, text, F32.add(left, 0.25)}

def parcel.loop(n: Nat, value: Parcel) -> Parcel:
  match n:
    case 0n: value
    case 1n+p: parcel.loop(p, parcel.tick(value))

def parcel.show(value: Parcel) -> String:
  match value:
    case Parcel{stamp, left, text, right}:
      U32.show(stamp) ++ ":" ++ U32.show(route.bits(left)) ++ ":" ++ text ++ ":" ++ U32.show(route.bits(right))

def parcel.check(+value: Parcel, n: Nat) -> IO(Unit):
  do IO<Unit>:
    Unit <- IO.print(parcel.show(parcel.loop(n, value)))
    IO.print(parcel.show(value))

def main() -> IO(Unit):
  do IO<Unit>:
    Unit <- route.case(0n)
    Unit <- route.case(1n)
    Unit <- route.case(2n)
    Unit <- route.case(17n)
    Unit <- route.case(4096n)
    Unit <- parcel.check(Parcel{4294967295, 1.0, "heap:" ++ U32.show(47), 5.0}, 17n)
    parcel.check(Parcel{4294967295, 1.0, "heap:" ++ U32.show(47), 5.0}, 4096n)
