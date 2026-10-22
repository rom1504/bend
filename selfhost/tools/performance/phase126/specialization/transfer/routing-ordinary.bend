import Base

def routing.code(slot: Nat) -> U32:
  match slot:
    case 0n: 2654435769
    case 1n: 7
    case 2n: 4294967295
    case 3n: 123456789
    case 4n: 0
    case 5n: 2147483648
    case 6n: 65537
    case 7n: 97
    case 8n: 2882400001
    case 9n: 4093
    case 10n: 271828183
    case 11n: 314159265
    case 12n+rest: 42

def routing.weight(slot: Nat) -> F32:
  match slot:
    case 0n: 0.0
    case 1n: 0.5
    case 2n: 1.0
    case 3n: F32.sub(0.0, 1.0)
    case 4n: 1.5
    case 5n: 2.0
    case 6n: 3.0
    case 7n+rest: 4.0

def routing.fold(left: Nat, +state: U32, +salt: U32, hash: U32) -> U32:
  match left:
    case 0n: hash
    case 1n+rest:
      +slot = U32.to_nat(U32.and(state, 15))
      code = routing.code(slot)
      weight = F32.bits(routing.weight(slot))
      value = U32.add(U32.add(code, weight), salt)
      next = U32.xor(U32.mul(hash, 65599), value)
      routing.fold(rest, U32.add(U32.mul(state, 1664525), 1013904223), salt, next)

def routing.value(seed: U32, +salt: U32) -> U32:
  routing.fold(1024n, seed, salt, U32.xor(2166136261, salt))

def main() -> IO(Unit):
  IO.print(U32.show(routing.value(17,99)))
