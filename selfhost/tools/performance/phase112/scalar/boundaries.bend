# Frozen boundary expectations; no candidate-generated answers.
import Base

def main() -> IO(Unit):
  do IO<Unit>:
    Unit <- IO.print(U32.show(U32.add(4294967295, 1)))
    Unit <- IO.print(U32.show(U32.add(2147483648, 2147483648)))
    Unit <- IO.print(U32.show(U32.add(4294967294, 1)))
    Unit <- IO.print(U32.show(U32.sub(0, 1)))
    Unit <- IO.print(U32.show(U32.sub(2147483648, 2147483649)))
    Unit <- IO.print(U32.show(U32.sub(1, 1)))
    Unit <- IO.print(U32.show(U32.mul(4294967295, 4294967295)))
    Unit <- IO.print(U32.show(U32.mul(2147483648, 2)))
    Unit <- IO.print(U32.show(U32.mul(65535, 65537)))
    Unit <- IO.print(U32.show(U32.and(2863311530, 1431655765)))
    Unit <- IO.print(U32.show(U32.and(4294967295, 2147483648)))
    Unit <- IO.print(U32.show(U32.or(2863311530, 1431655765)))
    Unit <- IO.print(U32.show(U32.or(0, 2147483648)))
    Unit <- IO.print(U32.show(U32.xor(4294967295, 1431655765)))
    Unit <- IO.print(U32.show(U32.xor(2147483648, 2147483648)))
    Unit <- IO.print(U32.show(U32.inc(4294967295)))
    Unit <- IO.print(U32.show(U32.inc(2147483647)))
    Unit <- IO.print(U32.show(U32.not(0)))
    Unit <- IO.print(U32.show(U32.not(4294967295)))
    Unit <- IO.print(U32.show(U32.not(2147483648)))
    Unit <- IO.print(U32.show(U32.shl(2147483648)))
    Unit <- IO.print(U32.show(U32.shl(4294967295)))
    Unit <- IO.print(U32.show(U32.shr(2147483648)))
    Unit <- IO.print(U32.show(U32.shr(4294967295)))
    Unit <- IO.print(U32.show(U32.shln(4294967295, 0n)))
    Unit <- IO.print(U32.show(U32.shln(1, 31n)))
    Unit <- IO.print(U32.show(U32.shln(1, 32n)))
    Unit <- IO.print(U32.show(U32.shln(4294967295, 33n)))
    Unit <- IO.print(U32.show(U32.shln(1, 64n)))
    Unit <- IO.print(U32.show(U32.shrn(4294967295, 0n)))
    Unit <- IO.print(U32.show(U32.shrn(2147483648, 31n)))
    Unit <- IO.print(U32.show(U32.shrn(4294967295, 32n)))
    Unit <- IO.print(U32.show(U32.shrn(4294967295, 33n)))
    Unit <- IO.print(U32.show(U32.shrn(4294967295, 64n)))
    Unit <- IO.print(U32.show(U32.shln(1, Nat.add(U32.to_nat(4294967295), 1n))))
    Unit <- IO.print(U32.show(U32.shrn(4294967295, Nat.add(U32.to_nat(4294967295), 1n))))
    Unit <- IO.print(U32.show(Bool.to_u32(U32.is_eq(4294967295, 4294967295))))
    Unit <- IO.print(U32.show(Bool.to_u32(U32.is_eq(0, 4294967295))))
    Unit <- IO.print(U32.show(Bool.to_u32(U32.is_ne(2147483648, 2147483647))))
    Unit <- IO.print(U32.show(Bool.to_u32(U32.is_ne(0, 0))))
    Unit <- IO.print(U32.show(Bool.to_u32(U32.is_lt(2147483647, 2147483648))))
    Unit <- IO.print(U32.show(Bool.to_u32(U32.is_lt(4294967295, 0))))
    Unit <- IO.print(U32.show(Bool.to_u32(U32.is_le(4294967295, 4294967295))))
    Unit <- IO.print(U32.show(Bool.to_u32(U32.is_le(4294967295, 2147483648))))
    Unit <- IO.print(U32.show(Bool.to_u32(U32.is_gt(2147483648, 2147483647))))
    Unit <- IO.print(U32.show(Bool.to_u32(U32.is_gt(0, 4294967295))))
    Unit <- IO.print(U32.show(Bool.to_u32(U32.is_ge(0, 0))))
    Unit <- IO.print(U32.show(Bool.to_u32(U32.is_ge(0, 4294967295))))
    Unit <- IO.print(U32.show(Bool.to_u32(U32.is_zero(0))))
    Unit <- IO.print(U32.show(Bool.to_u32(U32.is_zero(2147483648))))
    Unit <- IO.print(U32.show(U32.div(4294967295, 0)))
    Unit <- IO.print(U32.show(U32.mod(4294967295, 0)))
    Unit <- IO.print(U32.show(U32.div(4294967295, 10)))
    Unit <- IO.print(U32.show(U32.mod(4294967295, 10)))
    Unit <- IO.print(U32.show(Bool.to_u32(Cmp.is_lt(U32.cmp(0, 4294967295)))))
    Unit <- IO.print(U32.show(Bool.to_u32(Cmp.is_eq(U32.cmp(2147483648, 2147483648)))))
    IO.print(U32.show(Bool.to_u32(Cmp.is_gt(U32.cmp(4294967295, 0)))))

#|0
#|0
#|4294967295
#|4294967295
#|4294967295
#|0
#|1
#|0
#|4294967295
#|0
#|2147483648
#|4294967295
#|2147483648
#|2863311530
#|0
#|0
#|2147483648
#|4294967295
#|0
#|2147483647
#|0
#|4294967294
#|1073741824
#|2147483647
#|4294967295
#|2147483648
#|0
#|0
#|0
#|4294967295
#|1
#|0
#|0
#|0
#|0
#|0
#|1
#|0
#|1
#|0
#|1
#|0
#|1
#|0
#|1
#|0
#|1
#|0
#|1
#|0
#|0
#|4294967295
#|429496729
#|5
#|1
#|1
#|1
