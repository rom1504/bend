import Base
type Pair is Data:
  Pair{a: U32, b: U32}
def choose(p: Pair) -> U32:
  match p:
    case Pair{x, x}:
      x
def main() -> U32:
  choose(Pair{1, 2})
#| 2
