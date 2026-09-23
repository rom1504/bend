import Base
def apply(f: U32 -> U32) -> U32:
  f(42)
def main() -> U32:
  apply(\{x => x})

#| 42
