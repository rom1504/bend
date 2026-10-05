import Base

def classify(n: Nat) -> String:
  match n:
    case 0n:
      "zero"
    case 1n:
      "one"
    case 2n+q:
      "many"

def demand(n: Nat) -> Nat:
  match n:
    case 0n:
      0n
    case 1n:
      1n
    case 2n+q:
      q
