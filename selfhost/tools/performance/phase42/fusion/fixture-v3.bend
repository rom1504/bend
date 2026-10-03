import Base

# Independent semantic shape: full-width heads and a separate recursive owner.
type Chain is Data:
  End{}
  Link{head: U32, tail: Chain}

def chain.make(n: Nat, +seed: U32) -> Chain:
  match n:
    case 0n:
      End{}
    case 1n+p:
      Link{seed, chain.make(p, U32.add(U32.mul(seed, 1103515245), 12345))}

def chain.keep.at(h: U32, r: Chain, z: Bool) -> Chain:
  match z:
    case True{}:
      Link{h, r}
    case False{}:
      r

def chain.keep(xs: Chain) -> Chain:
  match xs:
    case End{}:
      End{}
    case Link{h0, t}:
      +h = {h0 : U32}
      chain.keep.at(h, chain.keep(t), U32.is_gt(h, 2147483647))

def chain.bump(xs: Chain) -> Chain:
  match xs:
    case End{}:
      End{}
    case Link{h, t}:
      Link{U32.add(U32.mul(h, 3), 17), chain.bump(t)}

def chain.fold(xs: Chain, acc: U32) -> U32:
  match xs:
    case End{}:
      acc
    case Link{h, t}:
      chain.fold(t, U32.add(acc, h))

def pipeline(n: U32, seed: U32, initial: U32) -> U32:
  chain.fold(chain.bump(chain.keep(chain.make(U32.to_nat(n), seed))), initial)

# Returning an intermediate is a refusal shape for scalar-only fusion.
def retained(n: U32, seed: U32) -> Chain:
  chain.bump(chain.keep(chain.make(U32.to_nat(n), seed)))

# Let-bound intermediate ownership is deliberately outside the first grammar.
def alias_single(n: U32, seed: U32, initial: U32) -> U32:
  xs = chain.make(U32.to_nat(n), seed)
  chain.fold(chain.bump(chain.keep(xs)), initial)

# Two uses of the source must not be silently erased or duplicated.
def shared(n: U32, seed: U32, initial: U32) -> U32:
  +xs = {chain.make(U32.to_nat(n), seed) : Chain}
  U32.add(chain.fold(chain.bump(chain.keep(xs)), initial), chain.fold(xs, 0))

# Purity alone does not admit operations outside the totality whitelist.
def chain.divide(xs: Chain) -> Chain:
  match xs:
    case End{}:
      End{}
    case Link{h, t}:
      Link{U32.div(h, 3), chain.divide(t)}

def refused_division(n: U32, seed: U32, initial: U32) -> U32:
  chain.fold(chain.divide(chain.keep(chain.make(U32.to_nat(n), seed))), initial)

def main() -> IO(Unit):
  IO.print(U32.show(pipeline(0, 4294967295, 4294967295)))

#|4294967295
