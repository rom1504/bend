import Base
def sum(a: U32,b: U32) -> U32:
  U32.add(a,b)
def main() -> U32:
  sum((x = {20 : U32}; x),22)

#| 42
