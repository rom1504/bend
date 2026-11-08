import Base

def main() -> List<&2, Bool>:
  [F32.is_eq(F32.from_nat(16777217n), 16777216.0),
   F32.is_eq(F32.from_nat(4294967296n), 4294967296.0),
   F32.is_eq(F32.from_nat(4294967553n), 4294967808.0),
   F32.is_eq(F32.from_nat(281474976710655n), 281474976710656.0),
   Nat.is_eq(F32.to_nat(4294967808.0), 4294967808n),
   Nat.is_eq(F32.to_nat(281474976710656.0), 0n),
   U32.is_eq(F32.to_u32(-1.0), 0),
   U32.is_eq(F32.to_u32(4294967296.0), 0),
   U32.is_eq(F32.bits(F32.round(-0.5)), 2147483648),
   Nat.is_eq(U32.popcount(4294967295), 32n),
   Nat.is_eq(U32.ctz(0), 32n),
   Nat.is_eq(U32.ctz(2147483648), 31n)]

#|[True, True, True, True, True, True, True, True, True, True, True, True]
