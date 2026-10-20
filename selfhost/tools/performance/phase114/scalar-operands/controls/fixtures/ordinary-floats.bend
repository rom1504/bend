import Base

def arithmetic(+a: F32, +b: F32) -> F32:
  F32.div(F32.sub(F32.mul(F32.add(a, b), a), b), 2.0)

def comparison(value: Bool) -> U32:
  match value:
    case True{}: 10
    case False{}: 20

def less(a: F32, b: F32) -> U32:
  comparison(F32.is_lt(a, b))

# sqrt is not an admitted scalar-operands operation. Its shared scratch buffer
# must retain the original rendering, including the following addition stores.
def mixed(a: F32) -> F32:
  F32.add(F32.sqrt(a), 1.0)

def convert(value: U32) -> F32:
  U32.to_f32(value)

def main() -> IO(Unit):
  do IO<Unit>:
    Unit <- IO.print(U32.show(F32.bits(arithmetic(1.5, 2.5))))
    Unit <- IO.print(U32.show(F32.bits(arithmetic(F32.neg(2.0), 0.5))))
    Unit <- IO.print(U32.show(less(1.0, 2.0)))
    Unit <- IO.print(U32.show(less(2.0, 1.0)))
    Unit <- IO.print(U32.show(less(F32.neg(0.0), 0.0)))
    Unit <- IO.print(U32.show(F32.bits(mixed(9.0))))
    IO.print(U32.show(F32.bits(convert(16777217))))

#|1071644672
#|1067450368
#|10
#|20
#|20
#|1082130432
#|1266679808
