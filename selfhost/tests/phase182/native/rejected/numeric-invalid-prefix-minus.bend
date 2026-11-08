import Base

def main() -> List<&2, Bool>:
  [F32.is_eq(F32.from_nat(16777217n), 16777216.0),
   F32.is_eq(F32.from_nat(Nat.add(4294967295n, 1n)), 4294967296.0),
   F32.is_eq(F32.from_nat(Nat.add(4294967295n, 258n)), 4294967808.0),
   F32.is_eq(F32.from_nat(Nat.add(Nat.mul(65536n, 4294967295n), 65535n)), 281474976710656.0),
   Nat.is_eq(F32.to_nat(4294967808.0), Nat.add(4294967295n, 513n)),
   Nat.is_eq(F32.to_nat(281474976710656.0), 0n),
   U32.is_eq(F32.to_u32(-1.0), 0),
   U32.is_eq(F32.to_u32(4294967296.0), 0),
   U32.is_eq(F32.bits(F32.round(-0.5)), 2147483648),
   Nat.is_eq(U32.popcount(4294967295), 32n),
   Nat.is_eq(U32.ctz(0), 32n),
   Nat.is_eq(U32.ctz(2147483648), 31n)]

#|[True, True, True, True, True, True, True, True, True, True, True, True]
