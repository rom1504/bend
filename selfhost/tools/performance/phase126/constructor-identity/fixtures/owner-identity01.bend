# Ordinary owning values; no fabricated native nodes or runtime representation.
import Base

type Orchard is Data:
  Bud{label: String}
  Graft{left: Orchard, right: Orchard}

def orchard.stay(value: Orchard) -> Orchard:
  match value:
    case Bud{label}: Bud{label}
    case Graft{left, right}: Graft{left, right}

def orchard.swap(value: Orchard) -> Orchard:
  match value:
    case Bud{label}: Bud{label}
    case Graft{left, right}: Graft{right, left}

def orchard.show(value: Orchard) -> String:
  match value:
    case Bud{label}: "[" ++ label ++ "]"
    case Graft{left, right}: "(" ++ orchard.show(left) ++ "|" ++ orchard.show(right) ++ ")"

def orchard.loop(n: Nat, value: Orchard) -> Orchard:
  match n:
    case 0n: value
    case 1n+p: orchard.loop(p, orchard.stay(value))

def orchard.with_drop(value: Orchard, unused: String) -> Orchard:
  match value:
    case Bud{label}: Bud{label}
    case Graft{left, right}: Graft{left, right}

def orchard.shared(+value: Orchard) -> IO(Unit):
  do IO<Unit>:
    Unit <- IO.print(orchard.show(orchard.stay(value)))
    Unit <- IO.print(orchard.show(value))
    Unit <- IO.print(orchard.show(orchard.swap(value)))
    IO.print(orchard.show(value))

def orchard.payload(+label: String) -> IO(Unit):
  do IO<Unit>:
    Unit <- orchard.shared(Graft{Bud{label}, Graft{Bud{"middle"}, Bud{label}}})
    IO.print(label)

def main() -> IO(Unit):
  do IO<Unit>:
    Unit <- orchard.shared(Graft{Bud{"left"}, Bud{"right"}})
    Unit <- orchard.payload("heap:" ++ U32.show(4294967295))
    Unit <- IO.print(orchard.show(orchard.loop(4096n, Graft{Bud{"deep:" ++ U32.show(17)}, Bud{"done"}})))
    IO.print(orchard.show(orchard.with_drop(Graft{Bud{"kept"}, Bud{"also-kept"}}, "dropped:" ++ U32.show(31337))))
