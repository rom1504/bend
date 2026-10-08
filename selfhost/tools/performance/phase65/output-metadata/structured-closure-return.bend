# Nested closures capture an outer scalar through a constructor-held function.
# This prevents named-function arity from absorbing every lambda.
import Base

type NestedClosure is Type:
  MkNested{f: U32 -> U32 -> U32}

def make_nested(seed: U32) -> NestedClosure:
  MkNested{x => y => U32.add(seed, U32.add(x, y))}

def use_nested(box: NestedClosure) -> U32:
  match box:
    case MkNested{f}: f(3)(5)

def main.out() -> U32:
  use_nested(make_nested(7))

def main() -> IO(Unit):
  IO.print(U32.show(main.out()))

#|15
