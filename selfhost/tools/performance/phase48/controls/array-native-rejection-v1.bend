import Base

# An ordinary scalar helper receives a recursive computation as its live first
# argument. Native Array admission must reject its name before normalizing it.
def fern.join(+left: U32, +right: U32) -> U32:
  U32.add(left, right)

def fern.dp(n: Nat, +seed: U32) -> U32:
  match n:
    case Zero{}: seed
    case Succ{p}: fern.join(fern.dp(p, seed), fern.dp(p, U32.inc(seed)))

def ordinary.consume(+value: U32) -> U32:
  U32.inc(value)

def bench(+seed: U32) -> U32:
  ordinary.consume(fern.dp(12n, seed))

def main() -> U32:
  bench(3)
