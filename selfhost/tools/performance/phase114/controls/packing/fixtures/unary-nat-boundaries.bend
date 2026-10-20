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

def main() -> IO(Unit):
  do IO<Unit>:
    Unit <- IO.print(Nat.show(read(NumberA{0n})))
    Unit <- IO.print(Nat.show(read(NumberA{1099511627775n})))
    Unit <- IO.print(Nat.show(read(NumberB{1099511627776n})))
    Unit <- IO.print(Nat.show(read(NumberB{281474976710655n})))
    Unit <- shared(NumberA{Nat.add(1099511627774n, 1n)})
    shared(NumberB{Nat.add(1099511627775n, 1n)})

#|0
#|1099511627775
#|1099511627776
#|281474976710655
#|1099511627775
#|1099511627775
#|1099511627776
#|1099511627776
