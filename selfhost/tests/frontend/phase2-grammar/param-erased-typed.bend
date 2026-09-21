import Base
def ignore(-unused: U32, x: U32) -> U32:
  x
def main() -> U32:
  ignore(3, 7)
