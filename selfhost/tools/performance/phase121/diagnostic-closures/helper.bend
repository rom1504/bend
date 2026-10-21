# Diagnostic-only closure construction/application fusion. Preserve descending
# application order and each original U32 operation, including from_nat.
def p121.closure_loop(+n: Nat, value: U32) -> U32:
  match n:
    case 0n:
      value
    case 1n+p:
      p121.closure_loop(p, U32.add(value, U32.add(1, U32.from_nat(p))))
