# Zero exit, repeated product backedges, alias retention and ordered array reads.
import Base

def carry72(n: Nat, pair: Array<U32> & U32) -> U32:
  match n:
    case 0n: 7
    case 1n+p:
      (array, value) = pair
      carry72(p, Array.get(U32, array, U32.mod(value, 2)))

def read72(pair: Array<U32> & U32) -> U32:
  (array, value) = pair
  value

def finish72(a: U32, b: U32, c: U32, d: U32) -> U32:
  U32.add(U32.mul(a, 1000000), U32.add(U32.mul(b, 10000), U32.add(U32.mul(c, 100), d)))

def main() -> U32:
  +array = ANode{ALeaf{17}, ALeaf{29}}
  finish72(carry72(0n, (array, 0)), carry72(128n, (array, 1)),
    read72(Array.get(U32, array, 0)), read72(Array.get(U32, array, 1)))

#|7071729
