# One admitted self-tail loop and two rejected recursion shapes.
# tail68(100000,7)=100007; nontail68(17)=17; mutual_a68(20)=1.
# The weighted independent result is 100007 + 1700 + 1000000 = 1101707.
import Base

def tail68(n: Nat, acc: U32) -> U32:
  match n:
    case 0n:
      acc
    case 1n+p:
      tail68(p, U32.add(acc, 1))

def nontail68(n: Nat) -> U32:
  match n:
    case 0n:
      0
    case 1n+p:
      value = nontail68(p)
      U32.add(value, 1)

@unsafe
def mutual_a68(n: Nat) -> U32:
  match n:
    case 0n:
      1
    case 1n+p:
      mutual_b68(p)

@unsafe
def mutual_b68(n: Nat) -> U32:
  match n:
    case 0n:
      2
    case 1n+p:
      mutual_a68(p)

def main() -> U32:
  deep = tail68(100000n, 7)
  slow = nontail68(17n)
  cycle = mutual_a68(20n)
  U32.add(deep, U32.add(U32.mul(slow, 100), U32.mul(cycle, 1000000)))

#|1101707
