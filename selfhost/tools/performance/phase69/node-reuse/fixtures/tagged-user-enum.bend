import Base

type Choice is Data:
  Left{}
  Right{}

def choose(c: Choice) -> Nat:
  match c:
    case Left{}: 3n
    case Right{}: 7n

def main() -> Nat:
  Nat.add(choose(Left{}), choose(Right{}))

#|10n
