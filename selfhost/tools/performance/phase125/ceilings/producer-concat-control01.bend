# Independent producer/concat identity with heap-owned String payloads.
import Base

def decoration.wrap(text: String) -> String:
  "(" ++ text ++ ")"

def decoration.make(xs: List<&2, String>) -> List<&2, String>:
  match xs:
    case Nil{}: Nil{}
    case h <> t: decoration.wrap(h) <> decoration.make(t)

def decoration.join(xs: List<&2, String>, tail: List<&2, String>) -> List<&2, String>:
  match xs:
    case Nil{}: tail
    case h <> t: h <> decoration.join(t, tail)

def decoration.into(xs: List<&2, String>, tail: List<&2, String>) -> List<&2, String>:
  match xs:
    case Nil{}: tail
    case h <> t: decoration.wrap(h) <> decoration.into(t, tail)

def decoration.show(xs: List<&2, String>) -> String:
  match xs:
    case Nil{}: ""
    case h <> t: "[" ++ h ++ "]" ++ decoration.show(t)

def decoration.check(+xs: List<&2, String>, +tail: List<&2, String>) -> IO(Unit):
  do IO<Unit>:
    Unit <- IO.print(decoration.show(decoration.join(decoration.make(xs), tail)))
    Unit <- IO.print(decoration.show(decoration.into(xs, tail)))
    Unit <- IO.print(decoration.show(xs))
    IO.print(decoration.show(tail))

def main() -> IO(Unit):
  do IO<Unit>:
    Unit <- decoration.check([], [])
    Unit <- decoration.check([""], ["tail"])
    Unit <- decoration.check(["alpha", "beta", ""], ["omega", "", "end"])
    decoration.check(["red", "green", "blue", "green", "red"], ["red", "red"])
