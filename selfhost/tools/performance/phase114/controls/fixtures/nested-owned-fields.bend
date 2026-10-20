import Base

type Envelope is Data:
  NoEnvelope{}
  Envelope{label: String, items: List<String>}

def join(items: List<String>) -> String:
  match items:
    case Nil{}: ""
    case Con{head, tail}: head ++ ":" ++ join(tail)

def describe(envelope: Envelope) -> String:
  match envelope:
    case NoEnvelope{}: "none"
    case Envelope{label, items}: label ++ "[" ++ join(items) ++ "]"

def label_only(envelope: Envelope) -> String:
  match envelope:
    case NoEnvelope{}: "none"
    case Envelope{label, items}: label

def items_only(envelope: Envelope) -> String:
  match envelope:
    case NoEnvelope{}: "none"
    case Envelope{label, items}: join(items)

def shared(+envelope: Envelope) -> IO(Unit):
  do IO<Unit>:
    Unit <- IO.print(describe(envelope))
    Unit <- IO.print(items_only(envelope))
    Unit <- IO.print(label_only(envelope))
    IO.print(describe(envelope))

def main() -> IO(Unit):
  do IO<Unit>:
    Unit <- IO.print(describe(Envelope{"static", ["one", "two"]}))
    Unit <- shared(Envelope{String.reverse("λxedni"), [String.reverse("α"), String.reverse("🙂β")]})
    Unit <- IO.print(describe(Envelope{String.reverse("ytpme"), []}))
    IO.print(describe(NoEnvelope{}))

#|static[one:two:]
#|indexλ[α:β🙂:]
#|α:β🙂:
#|indexλ
#|indexλ[α:β🙂:]
#|empty[]
#|none
