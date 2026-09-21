import Base
type Box is Data:
  Box{value: U32}
type Outer is Data:
  Outer{inner: Box}
def unbox(b: Outer) -> U32:
  Outer{Box{x}} = b
  x
def main() -> U32:
  unbox(Outer{Box{3}})
