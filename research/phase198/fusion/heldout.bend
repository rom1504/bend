# Different constructor set, child orientation and zero/successor alternatives.
# The right-hand recursive child tests modular negation in the affine law.
import Base

type Cost is Data:
  Price{v: U32}
  Credit{from: Cost, paid: Cost}
  Scale{a: Cost, b: Cost}

def price(t: Cost) -> U32:
  match t:
    case Price{v}: v
    case Credit{a,b}: U32.sub(price(a), price(b))
    case Scale{a,b}: U32.mul(price(a), price(b))

def choose(n: Nat, t: Cost, +key: U32) -> Cost:
  match n:
    case 0n: Credit{Price{U32.add(key, 11)}, t}
    case 1n+0n: Scale{Price{U32.add(U32.mod(key, 7), 3)}, t}
    case 1n+1n+p: Credit{t, Price{U32.mul(key, 5)}}

def invoice(fuel: Nat, +key: U32) -> Cost:
  match fuel:
    case 0n: Price{key}
    case 1n+p: choose(U32.to_nat(U32.mod(key, 4)), invoice(p, U32.add(key, 19)), key)

def bench(size: U32, seed: U32) -> U32:
  price(invoice(U32.to_nat(size), seed))
