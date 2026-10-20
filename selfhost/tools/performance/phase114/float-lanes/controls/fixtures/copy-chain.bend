import Base

# These are ordinary lexical copies/rebindings. The structural gate separately
# requires surviving N111 copies and repeated operation destination names.
def copy_chain(+a: F32, +b: F32) -> F32:
  x = F32.add(a, b)
  y = x
  +z = y
  value = F32.mul(z, a)
  value = F32.sub(value, b)
  F32.add(value, z)

def convert_chain(n: U32) -> F32:
  +x = U32.to_f32(n)
  F32.add(x, x)

def choose(c: Bool, a: F32, b: F32) -> F32:
  match c:
    case True{}: F32.add(a, b)
    case False{}: F32.sub(a, b)

# Unsupported sqrt forces the existing exact buffer fallback.
def mixed(a: F32) -> F32:
  F32.add(F32.sqrt(a), 1.0)

def main() -> IO(Unit):
  do IO<Unit>:
    Unit <- IO.print(U32.show(F32.bits(copy_chain(1.5, 2.5))))
    Unit <- IO.print(U32.show(F32.bits(copy_chain(F32.neg(2.0), 0.5))))
    Unit <- IO.print(U32.show(F32.bits(convert_chain(3))))
    Unit <- IO.print(U32.show(F32.bits(choose(True{}, 1.5, 2.5))))
    Unit <- IO.print(U32.show(F32.bits(choose(False{}, 1.5, 2.5))))
    IO.print(U32.show(F32.bits(mixed(9.0))))

#|1089470464
#|1065353216
#|1086324736
#|1082130432
#|3212836864
#|1082130432
