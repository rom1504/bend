import Base

# Public-source controls complement the typed-IR U64/signed controls. Base
# exposes U32 comparisons; every path below uses ordinary source operations.
def branch.pick(condition: Bool, yes: U32, no: U32) -> U32:
  match condition:
    case True{}: yes
    case False{}: no

def branch.nested(+a: U32, +b: U32, less: Bool) -> U32:
  match less:
    case True{}: branch.pick(U32.is_eq(a, 0), 101, 103)
    case False{}: branch.pick(U32.is_eq(a, b), 107, 109)

# The same comparison result feeds both a branch and a later value consumer.
def branch.reused(+less: Bool) -> U32:
  U32.add(branch.pick(less, 131, 137), Bool.to_u32(less))

def branch.score(+a: U32, +b: U32) -> U32:
  +less = U32.is_lt(a, b)
  eq = branch.pick(U32.is_eq(a, b), 1, 0)
  ne = branch.pick(U32.is_ne(a, b), 2, 0)
  lt = branch.pick(less, 4, 0)
  le = branch.pick(U32.is_le(a, b), 8, 0)
  gt = branch.pick(U32.is_gt(a, b), 16, 0)
  ge = branch.pick(U32.is_ge(a, b), 32, 0)
  alias = branch.pick(U32.is_eq(a, a), 64, 128)
  bits = U32.add(U32.add(U32.add(eq, ne), U32.add(lt, le)), U32.add(U32.add(gt, ge), alias))
  U32.add(bits, U32.add(branch.nested(a, b, less), branch.reused(less)))

@unsafe
def branch.step(n: U32, +a: U32, +b: U32, acc: U32, done: Bool) -> U32:
  match done:
    case True{}: acc
    case False{}:
      branch.loop(U32.sub(n, 1), U32.add(a, 2147483649), U32.xor(b, a),
        U32.add(U32.mul(acc, 33), branch.score(a, b)))

@unsafe
def branch.loop(+n: U32, a: U32, b: U32, acc: U32) -> U32:
  branch.step(n, a, b, acc, U32.is_eq(n, 0))

def main() -> List<U32>:
  [branch.score(0, 0), branch.score(0, 4294967295),
   branch.score(4294967295, 0), branch.score(2147483647, 2147483648),
   branch.score(2147483648, 2147483647), branch.score(4294967295, 4294967295),
   branch.loop(0, 2147483648, 1, 19), branch.loop(1, 2147483648, 1, 19),
   branch.loop(257, 2147483648, 1, 19)]
#|[349, 311, 360, 313, 360, 349, 19, 987, 316459035]
