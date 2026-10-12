import Base
import common.bend as C

law coin:
  U32 -> IO(Bool)

def coin(n):
  import "./foreign.c"
  import "./foreign.js"

def main() -> IO(Unit):
  do IO<Unit>:
    b : Bool <- coin(1)
    IO.print(U32.show(C.sum(Array.new(Bool, 1n, b))))

#|2
