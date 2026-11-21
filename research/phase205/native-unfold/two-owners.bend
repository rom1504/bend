import Base

def absorb(chars: String, sum: U32) -> U32:
  match chars:
    case SNil{}: sum
    case SCon{Chr{code},tail}: absorb(tail,U32.add(sum,code))

def first(seed: U32) -> U32:
  absorb("ab",seed)

def second(seed: U32) -> U32:
  absorb("Ω|Z",seed)

def main() -> U32:
  U32.add(first(7),second(19))
#| 1372
