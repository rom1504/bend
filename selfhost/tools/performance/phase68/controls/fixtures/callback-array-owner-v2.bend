# A captured affine array is consumed once. Pair destructuring is confined
# to a function parameter; computed/local scrutinees are not legal Bend2.
import Base

type Callback68 is Type:
  Callback68{f: U32 -> U32}

def pick_result68(pair: Array<U32> & U32) -> U32:
  (rest, value) = pair
  value

def pick68(a: Array<U32>, at: U32) -> U32:
  pick_result68(Array.get(U32, a, at))

def capture68(a: Array<U32>) -> U32 -> U32:
  at => pick68(a, at)

def invoke68(c: Callback68, at: U32) -> U32:
  match c:
    case Callback68{f}:
      f(at)

def main() -> U32:
  invoke68(Callback68{capture68(ANode{ALeaf{17}, ALeaf{29}})}, 1)

#|29
