import Base
type AdjBox is Data:
  AdjBoxValue{value: U32}
def main() -> AdjBox:
  s b = {"😀" : String} {AdjBoxValue{42} : AdjBox}
  b
