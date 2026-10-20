import Base

# Same values as the useful Phase68 readback boundary, now ordinary checked
# Bend source with complete stdout and no representation instrumentation.
type NumberBox is Data:
  NumberA{value: Nat}
  NumberB{value: Nat}

def read(box: NumberBox) -> Nat:
  match box:
    case NumberA{value}: value
    case NumberB{value}: value

def shared(+box: NumberBox) -> IO(Unit):
  do IO<Unit>:
    Unit <- IO.print(Nat.show(read(box)))
    IO.print(Nat.show(read(box)))

# The parser accepts numeric literals through U32 max. Build larger Nat
# values without any intermediate exceeding the runtime Nat limit.
def threshold() -> Nat:
  Nat.mul(65536n, 16777216n)

def maximum() -> Nat:
  Nat.add(Nat.mul(65536n, 4294967295n), 65535n)

def main() -> IO(Unit):
  do IO<Unit>:
    Unit <- IO.print(Nat.show(read(NumberA{0n})))
    Unit <- IO.print(Nat.show(read(NumberA{Nat.sub(threshold(), 1n)})))
    Unit <- IO.print(Nat.show(read(NumberB{threshold()})))
    Unit <- IO.print(Nat.show(read(NumberB{maximum()})))
    Unit <- shared(NumberA{Nat.add(Nat.sub(threshold(), 2n), 1n)})
    shared(NumberB{Nat.add(Nat.sub(threshold(), 1n), 1n)})

#|0
#|1099511627775
#|1099511627776
#|281474976710655
#|1099511627775
#|1099511627775
#|1099511627776
#|1099511627776
