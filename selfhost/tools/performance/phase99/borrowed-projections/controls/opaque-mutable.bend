import Base

type P99Mutable is Type:
  P99Mutable{cells: Array<U32>, +label: String, +stamp: U32}

# Reading an unrelated scalar does not grant access to the opaque Array field.
def p99_mutable_stamp(box: P99Mutable) -> U32:
  match box:
    case P99Mutable{cells, label, stamp}: stamp

# Owning mutation followed by a read must stay on the ordinary route.
def p99_mutable_swap(box: P99Mutable) -> U32:
  match box:
    case P99Mutable{cells, label, stamp}:
      (changed, old) = Array.swap(U32, cells, 0, 99)
      (remaining, current) = Array.get(U32, changed, 0)
      U32.add(old, current)

# Returning the mutable field is an ownership transfer, not an observation.
def p99_mutable_escape(box: P99Mutable) -> Array<U32>:
  match box:
    case P99Mutable{cells, label, stamp}: cells

# The print effect must not execute inside a borrowed worker.
def p99_mutable_effect(box: P99Mutable) -> IO(Unit):
  match box:
    case P99Mutable{cells, label, stamp}: IO.print(label)

def p99_mutable_value(cells: Array<U32>) -> U32:
  (remaining, value) = Array.get(U32, cells, 0)
  value

def main() -> IO(Unit):
  +stamp : U32 = p99_mutable_stamp(P99Mutable{Array.new(U32, 1n, 7), "marker", 47})
  +changed : U32 = p99_mutable_swap(P99Mutable{Array.new(U32, 1n, 7), "swap", 53})
  +escaped : U32 = p99_mutable_value(p99_mutable_escape(P99Mutable{Array.new(U32, 1n, 7), "escape", 59}))
  do IO<Unit>:
    IO.print(U32.show(stamp))
    IO.print(U32.show(changed))
    IO.print(U32.show(escaped))
    p99_mutable_effect(P99Mutable{Array.new(U32, 1n, 7), "effect-once", 61})
