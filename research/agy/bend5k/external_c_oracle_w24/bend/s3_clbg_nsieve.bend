import Base
# s3_clbg_nsieve: Port of CLBG nsieve (bench/algorithm/nsieve/1.c)
# Sieves primes up to 1,280,000; 640,000; 320,000.

type SieveSt is Type:
  SS{flags: Array<U32>, count: U32}

def mark_multiples(+rem: Nat, +j: U32, +step: U32, +m: U32, flags: Array<U32>) -> Array<U32>:
  match rem:
    case 0n:
      flags
    case 1n+p:
      mark_multiples(p, U32.add(j, step), step, m, Array.set(U32, flags, j, 0))

def sieve_branch(is_prime: Bool, +i: U32, +m: U32, +count: U32, flags: Array<U32>) -> SieveSt:
  match is_prime:
    case True{}:
      +j0 = U32.shln(i, 1n)
      +cnt = Bool.pick(U32, U32.is_lt(j0, m), U32.inc(U32.div(U32.sub(U32.sub(m, 1), j0), i)), 0)
      SS{mark_multiples(U32.to_nat(cnt), j0, i, m, flags), U32.inc(count)}
    case False{}:
      SS{flags, count}

def sieve_step(+i: U32, +m: U32, +count: U32, r: Array<U32> & U32) -> SieveSt:
  (flags1, +fv) = r
  sieve_branch(U32.is_ne(fv, 0), i, m, count, flags1)

def sieve_loop(+rem: Nat, +i: U32, +m: U32, st: SieveSt) -> U32:
  match rem:
    case 0n:
      SS{flags, +count} = st
      count
    case 1n+p:
      SS{flags, +count} = st
      sieve_loop(p, U32.inc(i), m, sieve_step(i, m, count, Array.get(U32, flags, i)))

def run_nsieve(+m: U32, +depth: Nat) -> U32:
  flags = Array.new(U32, depth, 1)
  sieve_loop(U32.to_nat(U32.sub(m, 2)), 2, m, SS{flags, 0})

def fold_res(+acc: U32, +m: U32, +cnt: U32) -> U32:
  +a1 = U32.mul(U32.xor(acc, m), 16777619)
  U32.mul(U32.xor(a1, cnt), 16777619)

def main() -> U32:
  +c0 = run_nsieve(1280000, 21n)
  +a0 = fold_res(2166136261, 1280000, c0)
  +c1 = run_nsieve(640000, 20n)
  +a1 = fold_res(a0, 640000, c1)
  +c2 = run_nsieve(320000, 19n)
  fold_res(a1, 320000, c2)
