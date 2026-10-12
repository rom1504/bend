import Base
import ../fixtures-v2/sharing.bend as S

def twins(a: S.Chain, b: S.Chain, acc: U32) -> U32:
  match a b:
    case S.Stop{} S.Stop{}: acc
    case S.Stop{} S.Cell{x, xt}: U32.add(acc, x)
    case S.Cell{x, xt} S.Stop{}: U32.add(acc, x)
    case S.Cell{x, xt} S.Cell{y, yt}: twins(xt, yt, U32.add(acc, U32.add(x, y)))

def main() -> U32:
  +a = S.make(3n, 2)
  b = S.make(3n, 4)
  U32.add(twins(a, b, 0), S.sum(a, 0))

#|33
