import Base
type Box is Data:
  Box{value: U32}
def unbox(b: Box) -> U32:
  Box{x} = b
  x
def main() -> U32:
  unbox(Box{3})
