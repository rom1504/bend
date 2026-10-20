import Base

def combine(a: U32, b: U32, c: U32) -> U32:
  U32.add(U32.mul(a, 100), U32.add(U32.mul(b, 10), c))

def plus_one(x: U32) -> U32:
  U32.add(x, 1)

def shadow(+x: U32) -> U32:
  +before = x
  +x = plus_one(x)
  +middle = x
  x = U32.add(x, 2)
  combine(plus_one(before), plus_one(middle), x)

def main() -> IO(Unit):
  do IO<Unit>:
    Unit <- IO.print(U32.show(shadow(4)))
    IO.print(U32.show(shadow(4294967295)))

#|567
#|12
