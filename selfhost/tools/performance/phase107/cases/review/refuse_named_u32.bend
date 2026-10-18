# A valid non-native type with the spelling U32 must not become machine words.
type U32 is Data:
  Foo{}

def bench(value: U32) -> U32:
  value

def main() -> U32:
  bench(Foo{})
