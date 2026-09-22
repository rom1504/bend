import Base
type Box is Data:
  Box{value: U32}
def main() -> U32:
  Box{n} x = Box{1} {42 : U32}
  x
