import Base

type TextBox is Data:
  TextA{value: String}
  TextB{value: String}

type Outer is Data:
  OuterA{value: TextBox}
  OuterB{value: TextBox}

def read(box: TextBox) -> String:
  match box:
    case TextA{value}: value
    case TextB{value}: value

def read_outer(outer: Outer) -> String:
  match outer:
    case OuterA{value}: read(value)
    case OuterB{value}: String.reverse(read(value))

def shared(+text: String, +outer: Outer) -> IO(Unit):
  do IO<Unit>:
    Unit <- IO.print(read_outer(outer))
    Unit <- IO.print(text)
    Unit <- IO.print(read_outer(outer))
    IO.print(text)

def observe(+text: String) -> IO(Unit):
  shared(text, OuterA{TextA{text}})

def main() -> IO(Unit):
  do IO<Unit>:
    Unit <- IO.print(read(TextA{""}))
    Unit <- IO.print(read(TextB{"literalλ"}))
    Unit <- observe(String.reverse("🙂β"))
    Unit <- IO.print(read_outer(OuterB{TextB{String.reverse("λtfel")}}))
    IO.print(read_outer(OuterA{TextB{String.reverse("thgir")}}))

#|
#|literalλ
#|β🙂
#|β🙂
#|β🙂
#|β🙂
#|λtfel
#|right
