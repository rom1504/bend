import Base

# Grounded List and independent zero-parameter tagged owner. Same compiler
# mechanism must recognize both; names are deliberately unlike the benchmark.
type Chain is Data:
  End{}
  Link{head: U32, tail: Chain}

def ground.make(n: Nat, +seed: U32) -> List<&2,U32>:
  match n:
    case 0n: Nil{}
    case 1n+p:
      U32.mod(seed, 16) <> ground.make(p, U32.add(U32.mul(seed, 1664525), 1013904223))

def ground.twice(xs: List<&2,U32>) -> List<&2,U32>:
  match xs:
    case Nil{}: Nil{}
    case h <> t: U32.mul(h, 2) <> ground.twice(t)

def ground.choose(h: U32, tail: List<&2,U32>, flag: Bool) -> List<&2,U32>:
  match flag:
    case True{}: h <> tail
    case False{}: tail

def ground.select(xs: List<&2,U32>) -> List<&2,U32>:
  match xs:
    case Nil{}: Nil{}
    case h0 <> t:
      +h = {h0 : U32}
      ground.choose(h, ground.select(t), U32.is_gt(h, 1))

def ground.add(xs: List<&2,U32>, acc: U32) -> U32:
  match xs:
    case Nil{}: acc
    case h <> t: ground.add(t, U32.add(acc, h))

def chain.make(n: Nat, +seed: U32) -> Chain:
  match n:
    case 0n: End{}
    case 1n+p:
      Link{U32.mod(seed, 16), chain.make(p, U32.add(U32.mul(seed, 1664525), 1013904223))}

def chain.twice(xs: Chain) -> Chain:
  match xs:
    case End{}: End{}
    case Link{h,t}: Link{U32.mul(h, 2), chain.twice(t)}

def chain.choose(h: U32, tail: Chain, flag: Bool) -> Chain:
  match flag:
    case True{}: Link{h,tail}
    case False{}: tail

def chain.select(xs: Chain) -> Chain:
  match xs:
    case End{}: End{}
    case Link{h0,t}:
      +h = {h0 : U32}
      chain.choose(h, chain.select(t), U32.is_gt(h, 1))

def chain.add(xs: Chain, acc: U32) -> U32:
  match xs:
    case End{}: acc
    case Link{h,t}: chain.add(t, U32.add(acc,h))

# Retained generic domains: a different element type, and non-descendant self.
def refuse.bool(xs: List<&2,Bool>) -> U32:
  match xs:
    case Nil{}: 0
    case h <> t: U32.inc(refuse.bool(t))

def refuse.same(+xs: List<&2,U32>) -> U32:
  refuse.same(xs)

def ground_bench(size: U32, seed: U32) -> U32:
  ground.add(ground.twice(ground.select(ground.make(U32.to_nat(size),seed))),0)

def chain_bench(size: U32, seed: U32) -> U32:
  chain.add(chain.twice(chain.select(chain.make(U32.to_nat(size),seed))),0)

def bench(+size: U32, +seed: U32) -> U32:
  U32.add(ground_bench(size,seed),chain_bench(size,seed))

def main.out() -> U32:
  bench(16,17)
