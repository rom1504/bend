import Base

type Scalar is Data:
  NumericA{value: U32}
  NumericB{value: U32}

def read(value: Scalar) -> U32:
  match value:
    case NumericA{x}: x
    case NumericB{x}: x

def identity(value: Scalar) -> U32:
  match value:
    case NumericA{x}: 11
    case NumericB{x}: 29

def observe(+value: U32) -> IO(Unit):
  do IO<Unit>:
    Unit <- IO.print(U32.show(read(NumericA{U32.add(value, 0)})))
    IO.print(U32.show(read(NumericB{U32.xor(value, 0)})))

type CharBox is Data:
  Code{value: Char}

def read_char(box: CharBox) -> U32:
  match box:
    case Code{value}: Char.to_u32(value)

type FloatBox is Data:
  FloatValue{value: F32}

def read_float(box: FloatBox) -> F32:
  match box:
    case FloatValue{value}: value

def main() -> IO(Unit):
  do IO<Unit>:
    Unit <- observe(0)
    Unit <- observe(1)
    Unit <- observe(2147483647)
    Unit <- observe(2147483648)
    Unit <- observe(4294967295)
    Unit <- IO.print(U32.show(identity(NumericA{4294967295})))
    Unit <- IO.print(U32.show(identity(NumericB{0})))
    Unit <- IO.print(U32.show(read_char(Code{'λ'})))
    Unit <- IO.print(U32.show(read_char(Code{'🙂'})))
    Unit <- IO.print(F32.show(read_float(FloatValue{1.5})))
    IO.print(F32.show(read_float(FloatValue{F32.neg(2.5)})))

#|0
#|0
#|1
#|1
#|2147483647
#|2147483647
#|2147483648
#|2147483648
#|4294967295
#|4294967295
#|11
#|29
#|955
#|128578
#|1.5
#|-2.5
