import Base

type Reel is Data:
  Stop{}
  Link{left: U32, right: U32, rest: Reel}

def inspect(xs: Reel) -> Reel & U32:
  match xs:
    case Stop{}: (Stop{}, 0)
    case Link{left, right, rest}: (Link{right, left, rest}, 0)

def hash(xs: Reel, acc: U32) -> U32:
  match xs:
    case Stop{}: acc
    case Link{left, right, rest}:
      hash(rest, U32.add(U32.mul(acc, 100), U32.add(U32.mul(left, 10), right)))

def main() -> U32:
  xs : Reel = Link{2, 7, Link{3, 8, Stop{}}}
  (root, value) = inspect(xs)
  U32.add(hash(root, 0), value)

#|7238
