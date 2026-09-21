import Base
def ignore(-unused, x: U32) -> U32:
  x
def main() -> U32:
  ignore(&1, 7)
