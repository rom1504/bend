# A small module; def not_a_declaration() is only a comment.
import Base

type Greeting is Data:
  Greeting{message: String}

def Greeting.text(value: Greeting) -> String:
  match value:
    case Greeting{message}: message

def example() -> String:
  "A # inside a string is not a comment; def hidden()"

def escaped() -> String:
  "A quote: \" and a slash: \\"

def marker() -> Char:
  '#'

def main() -> IO(Unit):
  IO.print(Greeting.text(Greeting{example()}))

#|A # inside a string is not a comment; def hidden()
