import Base

# Deliberately reuse Packet/Pair/consume/main from another valid source request,
# while giving Pair three fields and consume two arguments.
type Packet is Data:
  Empty{}
  Pair{left: String, middle: String, right: String}

def consume(packet: Packet, suffix: String) -> String:
  match packet:
    case Empty{}: "empty" ++ suffix
    case Pair{left, middle, right}: right ++ "/" ++ middle ++ "/" ++ left ++ suffix

def main() -> IO(Unit):
  do IO<Unit>:
    Unit <- IO.print(consume(Pair{String.reverse("tfel"), "middleλ", String.reverse("thgir")}, "!"))
    IO.print(consume(Empty{}, "?"))

#|right/middleλ/left!
#|empty?
