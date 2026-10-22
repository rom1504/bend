import Base

def ratio(a: U32, b: U32) -> F32:
  F32.div(U32.to_f32(a), U32.to_f32(b))

def palette(index: Nat) -> F32:
  match index:
    case 0n: ratio(1, 2)
    case 1n: F32.sub(U32.to_f32(0), ratio(7, 2))
    case 2n: F32.add(U32.to_f32(16777217), U32.to_f32(1))
    case 3n: F32.mul(ratio(3, 2), ratio(5, 2))
    case 4n: F32.mul(F32.sub(0.0, 1.0), 0.0)
    case 5n+rest: ratio(1, 10)

def words(index: Nat) -> U32:
  match index:
    case 0n: 4294967295
    case 1n: 2147483648
    case 2n: 7
    case 3n: 0
    case 4n+rest: 123456789

# These are ordinary supported programs, outside table admission.
def remainder(index: Nat) -> F32:
  match index:
    case 0n: 1.0
    case 1n+rest: U32.to_f32(U32.from_nat(rest))

def text_first(text: String, value: F32) -> F32:
  value

def owning_actual(index: Nat) -> F32:
  match index:
    case 0n: text_first("kept strict", 3.0)
    case 1n+rest: 4.0

def apply_float(f: F32 -> F32, value: F32) -> F32:
  f(value)

def higher_order(index: Nat) -> F32:
  match index:
    case 0n: apply_float(x => F32.add(x, 1.0), 2.0)
    case 1n+rest: 4.0

def recursive_value(n: Nat) -> F32:
  match n:
    case 0n: 2.0
    case 1n+p: recursive_value(p)

def recursive_helper(index: Nat) -> F32:
  match index:
    case 0n: recursive_value(2n)
    case 1n+rest: 4.0

def main() -> IO(Unit):
  do IO<Unit>:
    Unit <- IO.print(U32.show(F32.bits(palette(0n))))
    Unit <- IO.print(U32.show(F32.bits(palette(1n))))
    Unit <- IO.print(U32.show(F32.bits(palette(2n))))
    Unit <- IO.print(U32.show(F32.bits(palette(3n))))
    Unit <- IO.print(U32.show(F32.bits(palette(4n))))
    Unit <- IO.print(U32.show(F32.bits(palette(5n))))
    Unit <- IO.print(U32.show(F32.bits(palette(6n))))
    Unit <- IO.print(U32.show(F32.bits(palette(4294967296n))))
    Unit <- IO.print(U32.show(F32.bits(palette(1099511627776n))))
    Unit <- IO.print(U32.show(words(0n)))
    Unit <- IO.print(U32.show(words(1n)))
    Unit <- IO.print(U32.show(words(2n)))
    Unit <- IO.print(U32.show(words(1099511627776n)))
    Unit <- IO.print(U32.show(F32.bits(remainder(3n))))
    Unit <- IO.print(U32.show(F32.bits(owning_actual(0n))))
    Unit <- IO.print(U32.show(F32.bits(higher_order(0n))))
    IO.print(U32.show(F32.bits(recursive_helper(0n))))
