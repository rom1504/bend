import Base

type Box is Data:
  Box{+value: Nat}

def number(n: Nat) -> IO(Nat):
  import "./foreign.js"
def character(c: Char) -> IO(Char):
  import "./foreign.js"
def scalar() -> IO(F32):
  import "./foreign.js"
def box() -> IO(Box):
  import "./foreign.js"
def take(b: Box) -> Nat:
  match b:
    case Box{n}: n
