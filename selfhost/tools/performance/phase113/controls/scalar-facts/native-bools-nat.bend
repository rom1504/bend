import Base

# Logical Bool paths and full-width Nat values; packed representation is tested
# independently in raw IR because source syntax does not prescribe a Bool tag.
def select(flag: Bool, yes: Nat, no: Nat) -> Nat:
  match flag:
    case True{}: yes
    case False{}: no

def u32_result(value: U32, flag: Bool) -> U32:
  match flag:
    case True{}: U32.inc(value)
    case False{}: U32.sub(value, 1)

def u32_branch(+value: U32) -> U32:
  u32_result(value, U32.is_lt(value, 2147483648))

def nat_branch(+value: Nat) -> Nat:
  select(Nat.is_lt(value, Nat.pow(2n, 40n)), value, Nat.sub(value, 1n))

type FlagBox is Data:
  FlagBox{flag: Bool, marker: String}

def boxed(box: FlagBox) -> Nat:
  match box:
    case FlagBox{flag, marker}:
      select(flag, Nat.pow(2n, 40n), Nat.add(Nat.pow(2n, 47n), Nat.sub(Nat.pow(2n, 47n), 1n)))

def share(+box: FlagBox) -> IO(Unit):
  do IO<Unit>:
    Unit <- IO.print(Nat.show(boxed(box)))
    IO.print(Nat.show(boxed(box)))

def main() -> IO(Unit):
  do IO<Unit>:
    Unit <- IO.print(U32.show(u32_branch(0)))
    Unit <- IO.print(U32.show(u32_branch(1)))
    Unit <- IO.print(U32.show(u32_branch(2147483648)))
    Unit <- IO.print(U32.show(u32_branch(4294967295)))
    Unit <- IO.print(Nat.show(nat_branch(0n)))
    Unit <- IO.print(Nat.show(nat_branch(1n)))
    Unit <- IO.print(Nat.show(nat_branch(Nat.pow(2n, 40n))))
    Unit <- IO.print(Nat.show(nat_branch(Nat.add(Nat.pow(2n, 47n), Nat.sub(Nat.pow(2n, 47n), 1n)))))
    Unit <- share(FlagBox{True{}, String.reverse("λ")})
    share(FlagBox{False{}, String.reverse("🙂")})

#|1
#|2
#|2147483647
#|4294967294
#|0
#|1
#|1099511627775
#|281474976710654
#|1099511627776
#|1099511627776
#|281474976710655
#|281474976710655
