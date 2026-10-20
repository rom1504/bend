import Base

# Two constructors prevent one-constructor product flattening from defining
# this fixture's semantics. Concrete heap/static admission is observed separately.
type Packet is Data:
  Empty{}
  Pair{left: String, right: String}

def consume(packet: Packet) -> String:
  match packet:
    case Empty{}: "empty"
    case Pair{left, right}: left ++ "/" ++ right

def flip(packet: Packet) -> Packet:
  match packet:
    case Empty{}: Empty{}
    case Pair{left, right}: Pair{right, left}

def first(packet: Packet) -> String:
  match packet:
    case Empty{}: "none"
    case Pair{left, right}: left

def second(packet: Packet) -> String:
  match packet:
    case Empty{}: "none"
    case Pair{left, right}: right

def shared(+packet: Packet) -> IO(Unit):
  do IO<Unit>:
    Unit <- IO.print(consume(packet))
    Unit <- IO.print(consume(flip(packet)))
    Unit <- IO.print(first(packet))
    IO.print(second(packet))

def turn(n: Nat, packet: Packet) -> Packet:
  match n:
    case 0n: packet
    case 1n+p: turn(p, flip(packet))

def main() -> IO(Unit):
  do IO<Unit>:
    Unit <- IO.print(consume(Pair{"staticλ", "root🙂"}))
    Unit <- IO.print(consume(Pair{String.reverse("tfel"), String.reverse("thgir")}))
    Unit <- shared(Pair{String.reverse("α"), String.reverse("🙂β")})
    Unit <- IO.print(consume(turn(257n, Pair{String.reverse("eno"), String.reverse("owt")})))
    Unit <- IO.print(consume(Empty{}))
    IO.print(first(Pair{String.reverse("evil"), String.reverse("deppord")}))

#|staticλ/root🙂
#|left/right
#|α/β🙂
#|β🙂/α
#|α
#|β🙂
#|two/one
#|empty
#|live
