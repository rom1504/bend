# An affine array escapes into a stored callback and is consumed once.
# Index 1 of [17,29] returns 29; the residual array is dropped.
import Base

type Callback68 is Type:
  Callback68{f: U32 -> U32}

def pick68(a: Array<U32>, at: U32) -> U32:
  (rest, value) = Array.get(U32, a, at)
  value

def capture68(a: Array<U32>) -> U32 -> U32:
  at => pick68(a, at)

def invoke68(c: Callback68, at: U32) -> U32:
  match c:
    case Callback68{f}:
      f(at)

def main() -> U32:
  invoke68(Callback68{capture68(ANode{ALeaf{17}, ALeaf{29}})}, 1)

#|29
