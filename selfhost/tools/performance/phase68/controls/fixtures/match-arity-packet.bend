# Common matcher prefixes, an unequal syntactic arm, and partial escape.
# Independent arithmetic: 12*1000000 + 29*10000 + 7*100 + 11 = 12290711.
import Base

type Pick68 is Data:
  Add68{bias: U32}
  Keep68{}

def identity68(x: U32) -> U32:
  x

def raised68(p: Pick68) -> U32 -> U32:
  match p:
    case Add68{bias}:
      x => U32.add(bias, x)
    case Keep68{}:
      x => U32.add(x, 20)

def unequal68(p: Pick68) -> U32 -> U32:
  match p:
    case Add68{bias}:
      x => U32.add(bias, x)
    case Keep68{}:
      identity68

def apply68(f: U32 -> U32, x: U32) -> U32:
  f(x)

def main() -> U32:
  a = raised68(Add68{7}, 5)
  b = apply68(raised68(Keep68{}), 9)
  c = unequal68(Add68{4}, 3)
  d = apply68(unequal68(Keep68{}), 11)
  U32.add(U32.mul(a, 1000000),
    U32.add(U32.mul(b, 10000), U32.add(U32.mul(c, 100), d)))

#|12290711
