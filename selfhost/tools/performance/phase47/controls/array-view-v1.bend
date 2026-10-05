import Base

# Independent four-cell recurrence. Reads and writes share the same backing
# array; revisiting a cell must observe every preceding write.
def seam.update(+i: U32, +acc: U32, r: Array<U32> & U32) -> Array<U32> & U32:
  (a, old) = r
  +next = U32.add(U32.add(acc, old), 1)
  (Array.set(U32, a, i, U32.xor(next, i)), next)

def seam.cell(+i: U32, st: Array<U32> & U32) -> Array<U32> & U32:
  (a, acc) = st
  seam.update(i, acc, Array.get(U32, a, i))

def seam.spin(+n: Nat, +i: U32, st: Array<U32> & U32) -> Array<U32> & U32:
  match n:
    case 0n: st
    case 1n+p: seam.spin(p, U32.inc(i), seam.cell(i, st))

def seam.finish(r: Array<U32> & U32) -> U32:
  (a, acc) = r
  acc

def bench(+n: U32, seed: U32) -> U32:
  seam.finish(seam.spin(U32.to_nat(n), 0, (Array.new(U32, 2n, seed), 0)))

# Public array parameters do not acquire a private-storage proof.
def external(n: Nat, a: Array<U32>) -> U32:
  seam.finish(seam.spin(n, 0, (a, 0)))

# Returning storage is an explicit escape, even with a scalar-only creator.
def escaped(+n: U32, seed: U32) -> Array<U32> & U32:
  seam.spin(U32.to_nat(n), 0, (Array.new(U32, 2n, seed), 0))

def seam.value(r: Array<U32> & U32) -> U32:
  (a, value) = r
  value

def seam.ignore(r: Array<U32> & U32) -> U32:
  (a, value) = r
  7

# An unused read result is still demanded by the tuple match.
def ignored_read(a: Array<U32>) -> U32:
  seam.ignore(Array.get(U32, a, 0))

def seam.alias_finish(a: Array<U32>, r: Array<U32> & U32) -> U32:
  (b, written) = r
  seam.value(Array.get(U32, a, 0))

# Host callers may supply separate handles for the same storage.
def aliases(a: Array<U32>, b: Array<U32>) -> U32:
  seam.alias_finish(a, Array.get(U32, Array.set(U32, b, 0, 19), 0))

def seam.after_callback(+i: U32, a: Array<U32>, tag: U32) -> U32:
  seam.finish(seam.update(i, tag, Array.get(U32, a, i)))

# The callback can resize or replace externally owned storage before the read.
def opaque(a: Array<U32>, +i: U32, f: U32 -> U32) -> U32:
  seam.after_callback(i, a, f(i))

def main() -> U32:
  bench(9, 3)
