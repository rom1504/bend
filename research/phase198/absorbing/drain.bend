# Spend at most one unit of work per tick, leaving a checksum after completion.
import Base

type Queue is Data:
  Drained{}
  Pending{left: U32}

def drain.consume(left: U32, checksum: U32, step: U32, empty: Bool) -> Queue & U32:
  match empty:
    case True{}: (Drained{}, checksum)
    case False{}: (Pending{U32.sub(left, 1)}, U32.add(checksum, step))

def drain.next(+step: U32, st: Queue & U32) -> Queue & U32:
  match st:
    case (Drained{}, checksum):
      (Drained{}, checksum)
    case (Pending{word}, checksum):
      +n = {word : U32}
      drain.consume(n, checksum, step, U32.is_eq(n, 0))

def drain.ticks(fuel: Nat, +step: U32, st: Queue & U32) -> Queue & U32:
  match fuel:
    case 0n: st
    case 1n+left: drain.ticks(left, step, drain.next(step, st))

def drain.finish(st: Queue & U32) -> U32:
  match st:
    case (Drained{}, checksum): checksum
    case (Pending{left}, checksum): U32.add(U32.mul(left, 257), checksum)

def bench(size: U32, +seed: U32) -> U32:
  drain.finish(drain.ticks(U32.to_nat(size), U32.add(seed, 1), (Pending{U32.mod(seed, 11)}, seed)))
