import Base
type A is Data:
  Same{}
def Same() -> A:
  Same{}
def read(x: A) -> U32:
  match x:
    case Same{}: 42
def main() -> U32:
  read(Same())
