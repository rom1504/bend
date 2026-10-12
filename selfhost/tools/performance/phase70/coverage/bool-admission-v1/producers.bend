import Base
import common.bend as C

type Single is Data:
  BoxBit{bit: Bool}

type Pair is Data:
  BoxBits{left: Bool, right: Bool}

def Bit() -> Data:
  Bool

def flip(b: Bit()) -> Bit():
  Bool.not(b)

def single(p: Single) -> Bool:
  match p:
    case BoxBit{b}: b

def pair(p: Pair) -> Bool:
  match p:
    case BoxBits{left, right}: Bool.xor(left, right)

def relay(b: Bool) -> Bool:
  b

def apply(f: Bool -> Bool, b: Bool) -> Bool:
  f(b)

def bit(n: U32) -> Bool:
  match n:
    case U32{w}:
      match w:
        case WCon{head, tail}: head

def main() -> IO(Unit):
  do IO<Unit>:
    IO.print(U32.show(C.stored(True{})))
    IO.print(U32.show(C.stored(False{})))
    IO.print(U32.show(C.stored(U32.is_lt(4294967295, 0))))
    IO.print(U32.show(C.stored(F32.is_ne(F32.div(0.0, 0.0), F32.div(0.0, 0.0)))))
    IO.print(U32.show(C.stored(F32.is_eq(-0.0, 0.0))))
    IO.print(U32.show(C.stored(Nat.is_lt(0n, 1n))))
    IO.print(U32.show(C.stored(Bool.or(False{}, True{}))))
    IO.print(U32.show(C.stored(Bool.xor(True{}, True{}))))
    IO.print(U32.show(C.stored(single(BoxBit{True{}}))))
    IO.print(U32.show(C.stored(pair(BoxBits{False{}, True{}}))))
    IO.print(U32.show(C.stored(flip(False{}))))
    IO.print(U32.show(C.stored(relay!(True{}))))
    IO.print(U32.show(C.stored(apply(x => Bool.not(x), False{}))))
    IO.print(U32.show(C.stored(bit(0))))
    IO.print(U32.show(C.stored(bit(4294967295))))

#|1
#|0
#|0
#|1
#|1
#|1
#|1
#|0
#|1
#|1
#|1
#|1
#|1
#|0
#|1
