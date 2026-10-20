import Base

def high(x: U32) -> U32:
  U32.add(x, 4294967295)

def low(x: U32) -> U32:
  U32.mul(x, 17)

def branch(flag: Bool, x: U32) -> U32:
  match flag:
    case True{}: high(x)
    case False{}: low(x)

def suffix(flag: Bool, x: U32) -> U32:
  y = branch(flag, x)
  U32.xor(U32.add(y, 9), 85)

def main() -> IO(Unit):
  do IO<Unit>:
    Unit <- IO.print(U32.show(suffix(True{}, 0)))
    Unit <- IO.print(U32.show(suffix(False{}, 0)))
    Unit <- IO.print(U32.show(suffix(True{}, 4294967295)))
    IO.print(U32.show(suffix(False{}, 4294967295)))

#|93
#|92
#|82
#|4294967213
