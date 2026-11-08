import Base
import ./foreign-lib.bend as F

def main() -> IO(Unit):
  do IO<Unit>:
    n : Nat <- F.number(41n)
    IO.print(Nat.show(n))
    c : Char <- F.character(Char.from_u32(4294967295))
    IO.print(U32.show(Char.to_u32(c)))
    x : F32 <- F.scalar()
    IO.print(U32.show(F32.bits(x)))
    b : F.Box <- F.box()
    IO.print(Nat.show(F.take(b)))

#|42
#|65533
#|1065353217
#|9
