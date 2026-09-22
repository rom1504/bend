import Base
type AdjBox is Data:
  AdjBoxValue{value: U32}
def Adj.read(box: AdjBox) -> U32:
  AdjBoxValue{x} = box
  x
def main() -> U32:
  Adj.read(AdjBoxValue{42})
#| 42
