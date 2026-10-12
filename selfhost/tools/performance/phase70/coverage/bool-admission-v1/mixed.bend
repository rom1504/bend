import Base
import common.bend as C

def word(r: Array<U32> & U32) -> U32:
  (a, x) = r
  x

def float_bits(r: Array<F32> & F32) -> U32:
  (a, x) = r
  F32.bits(x)

def char_code(r: Array<Char> & Char) -> U32:
  (a, x) = r
  Char.to_u32(x)

def main() -> IO(Unit):
  do IO<Unit>:
    IO.print(U32.show(C.sum(Array.set(Bool, Array.new(Bool, 2n, True{}), 3, False{}))))
    IO.print(U32.show(word(Array.get(U32, Array.new(U32, 1n, 4294967295), 1))))
    IO.print(U32.show(float_bits(Array.get(F32, Array.new(F32, 1n, -1.5), 1))))
    IO.print(U32.show(char_code(Array.get(Char, Array.new(Char, 1n, '🙂'), 1))))

#|3
#|4294967295
#|3217031168
#|128578
