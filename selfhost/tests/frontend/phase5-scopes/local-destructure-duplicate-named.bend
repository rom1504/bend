import Base
type ScopePair is Data:
  ScopePair{a: U32, b: U32}
def choose(p: ScopePair) -> U32:
  ScopePair{x, x} = p
  x
def main() -> U32:
  choose(ScopePair{1, 2})
#| 2
