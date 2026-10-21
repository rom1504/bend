# Ordinary owned-list call/resume control. No unsafe definitions or intrinsics.
import Base

def parcel.turn(xs: List<&2, U32>, acc: List<&2, U32>) -> List<&2, U32>:
  match xs:
    case Nil{}: acc
    case h <> t:
      parcel.turn(t, U32.add(U32.mul(h, 3), 5) <> acc)

def parcel.join(xs: List<&2, U32>, ys: List<&2, U32>) -> List<&2, U32>:
  match xs:
    case Nil{}: ys
    case h <> t: h <> parcel.join(t, ys)

def parcel.collect(rows: List<&2, List<&2, U32>>) -> List<&2, U32>:
  match rows:
    case Nil{}: Nil{}
    case row <> rest:
      head = parcel.turn(row, Nil{})
      tail = parcel.collect(rest)
      parcel.join(head, tail)

def parcel.make(n: Nat, +seed: U32, acc: List<&2, List<&2, U32>>) -> List<&2, List<&2, U32>>:
  match n:
    case 0n: acc
    case 1n+p: parcel.make(p, U32.add(seed, 1), [seed] <> acc)

def parcel.words(xs: List<&2, U32>) -> String:
  match xs:
    case Nil{}: ""
    case h <> t: U32.show(h) ++ ";" ++ parcel.words(t)

def parcel.rows(rows: List<&2, List<&2, U32>>) -> String:
  match rows:
    case Nil{}: ""
    case row <> rest: "[" ++ parcel.words(row) ++ "]" ++ parcel.rows(rest)

def parcel.check(+rows: List<&2, List<&2, U32>>) -> IO(Unit):
  do IO<Unit>:
    Unit <- IO.print(parcel.words(parcel.collect(rows)))
    IO.print(parcel.rows(rows))

def main() -> IO(Unit):
  do IO<Unit>:
    Unit <- parcel.check([])
    Unit <- parcel.check([[]])
    Unit <- parcel.check([[0, 1, 4294967295], [], [17, 0]])
    parcel.check(parcel.make(4096n, 0, Nil{}))
