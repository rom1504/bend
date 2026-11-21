import Base

type Audit is Data:
  Event{before: U32, low: Bool, after: U32}

law audit.emit:
  for +before : U32
  for +after : U32
  for trail : List<&2, Audit>
  for zero : Bool
  U32 & List<&2, Audit>

def audit.emit(before, after, trail, zero):
  match zero:
    case True{}: (after, Event{before, True{}, after} <> trail)
    case False{}: (after, Event{before, False{}, after} <> trail)

law audit.advance:
  for +salt : U32
  for st : U32 & List<&2, Audit>
  U32 & List<&2, Audit>

def audit.advance(salt, st):
  match st:
    case (old, path):
      +a = {old : U32}
      +b = {U32.add(U32.mul(a, 1664525), salt) : U32}
      audit.emit(a, b, path, U32.is_eq(U32.and(b, 1), 0))

law audit.collect:
  for fuel : Nat
  for +salt : U32
  for st : U32 & List<&2, Audit>
  U32 & List<&2, Audit>

def audit.collect(fuel, salt, st):
  match fuel:
    case 0n: st
    case 1n+p: audit.collect(p, salt, audit.advance(salt, st))

law audit.reverse:
  for path : List<&2, Audit>
  for +acc : U32
  U32

def audit.reverse(path, acc):
  match path:
    case Nil{}:
      acc
    case Event{a, True{}, b} <> rest:
      audit.reverse(rest, U32.xor(U32.mul(acc, 33), U32.add(a, b)))
    case Event{a, False{}, b} <> rest:
      audit.reverse(rest, U32.add(U32.mul(acc, 17), U32.xor(a, b)))

law audit.check:
  for mask : U32
  for st : U32 & List<&2, Audit>
  U32

def audit.check(mask, st):
  match st:
    case (last, path): audit.reverse(path, U32.xor(last, mask))

def stamp(fuel: Nat, +salt: U32, origin: U32) -> U32:
  audit.check(salt, audit.collect(fuel, salt, (origin, Nil{})))

def main() -> IO(Unit):
  do IO<Unit>:
    Unit <- IO.print(U32.show(stamp(0n, 7, 99)))
    Unit <- IO.print(U32.show(stamp(1n, 7, 99)))
    Unit <- IO.print(U32.show(stamp(2n, 7, 99)))
    Unit <- IO.print(U32.show(stamp(3n, 7, 99)))
    Unit <- IO.print(U32.show(stamp(8n, 4294967295, 0)))
    Unit <- IO.print(U32.show(stamp(31n, 17, 4294967295)))
    Unit <- IO.print(U32.show(stamp(64n, 2, 7)))
    IO.print(U32.show(stamp(127n, 3, 42)))
