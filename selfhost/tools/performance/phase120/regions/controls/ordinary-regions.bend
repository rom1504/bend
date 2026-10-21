import Base

# Two ordinary call boundaries and a join. Independent oracle uses exact values.
def numeric_leaf(flag: Bool, +x: F32, a: F32) -> F32:
  match flag:
    case True{}: F32.mul(x, a)
    case False{}: F32.sub(x, a)

def numeric_region(flag: Bool, +a: F32, b: F32) -> F32:
  +x = F32.add(a, b)
  y = numeric_leaf(flag, x, a)
  F32.add(y, x)

def rebind(flag: Bool, +a: F32, b: F32) -> F32:
  +old = F32.add(a, b)
  alias = old
  a = numeric_leaf(flag, a, 2.0)
  F32.sub(alias, a)

def boolean(value: Bool) -> U32:
  match value:
    case True{}: 1
    case False{}: 0

def main() -> IO(Unit):
  do IO<Unit>:
    Unit <- IO.print(U32.show(F32.bits(numeric_region(True{}, 1.5, 2.5))))
    Unit <- IO.print(U32.show(F32.bits(numeric_region(False{}, 1.5, 2.5))))
    Unit <- IO.print(U32.show(F32.bits(rebind(True{}, 1.5, 2.5))))
    Unit <- IO.print(U32.show(F32.bits(rebind(False{}, 1.5, 2.5))))
    Unit <- IO.print(U32.show(F32.bits(numeric_leaf(True{}, F32.neg(0.0), 1.0))))
    Unit <- IO.print(U32.show(F32.bits(F32.add(U32.to_f32(16777217), 1.0))))
    Unit <- IO.print(U32.show(boolean(F32.is_ne(F32.div(0.0, 0.0), 1.0))))
    IO.print(U32.show(F32.bits(F32.add(F32.sqrt(9.0), 1.0))))

#|1092616192
#|1087373312
#|1065353216
#|1083179008
#|2147483648
#|1266679808
#|1
#|1082130432
