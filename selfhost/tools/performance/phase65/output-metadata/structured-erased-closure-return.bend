# A live closure returns through an erased inner lambda before another live one.
import Base

type ErasedNested is Type:
  MkErasedNested{f: U32 -> @-A: Type -> U32 -> U32}

def make_erased_nested(seed: U32) -> ErasedNested:
  MkErasedNested{x => A => y => U32.add(seed, U32.add(x, y))}

def use_erased_nested(box: ErasedNested) -> U32:
  match box:
    case MkErasedNested{f}: f(3, U32, 5)

def main.out() -> U32:
  use_erased_nested(make_erased_nested(9))

def main() -> IO(Unit):
  IO.print(U32.show(main.out()))

#|17
