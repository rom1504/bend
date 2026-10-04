import Base

type P43Cell is Data:
  P43Box{v: U32}

# Noncommutative simultaneous fields: second RHS must read the old first field.
def p43.pair.step(st: U32 & U32) -> U32 & U32:
  match st:
    case (a0, b0):
      +a = {a0 : U32}
      +b = {b0 : U32}
      (U32.add(U32.mul(a, 3), b), U32.sub(a, b))

def p43.pair.nested(st: U32 & U32) -> U32 & U32:
  match st:
    case (a, b):
      p43.pair.step((a, b))

def p43.pair.loop(n: Nat, st: U32 & U32) -> U32 & U32:
  match n:
    case 0n:
      st
    case 1n+p:
      p43.pair.loop(p, p43.pair.nested(st))

def p43.pair.finish(st: U32 & U32) -> U32:
  match st:
    case (a0, b0):
      +a = {a0 : U32}
      +b = {b0 : U32}
      p43.pair.observer(P43Branch{P43Tip{a}, P43Tip{b}}, 0)

def p43.pair.result(size: U32, seed: U32) -> U32:
  p43.pair.finish(p43.pair.loop(U32.to_nat(size), (seed, 1)))

# Existing field aliases survive; fresh destination shell itself cannot escape.
def p43.pair.swap(st: P43Cell & P43Cell) -> P43Cell & P43Cell:
  match st:
    case (a, b):
      (b, a)

def p43.pair.shared(n: Nat, st: P43Cell & P43Cell) -> P43Cell & P43Cell:
  match n:
    case 0n:
      st
    case 1n+p:
      p43.pair.shared(p, p43.pair.swap(st))

def p43.pair.shared.finish(st: P43Cell & P43Cell) -> U32:
  match st:
    case (P43Box{a}, P43Box{b}):
      p43.pair.observer(P43Branch{P43Tip{a}, P43Tip{b}}, 0)

def p43.pair.shared.result(size: U32, seed: U32) -> U32:
  p43.pair.shared.finish(p43.pair.shared(U32.to_nat(size), (P43Box{seed}, P43Box{1})))

# Whole-pair Lam binder must refuse this lowering, even though pure and total.
def p43.pair.identity(st: U32 & U32) -> U32 & U32:
  st

def p43.pair.escape(n: Nat, st: U32 & U32) -> U32 & U32:
  match n:
    case 0n:
      st
    case 1n+p:
      p43.pair.escape(p, p43.pair.identity(st))

def p43.pair.escape.result(size: U32, seed: U32) -> U32:
  p43.pair.finish(p43.pair.escape(U32.to_nat(size), (seed, 1)))

# Binary recursion keeps this independent consumer outside the older Nat scalar island.
type P43Observe is Data:
  P43Tip{v: U32}
  P43Branch{l: P43Observe, r: P43Observe}

def p43.pair.observer(tree: P43Observe, acc: U32) -> U32:
  match tree:
    case P43Tip{v}:
      U32.add(U32.mul(acc, 17), v)
    case P43Branch{l, r}:
      p43.pair.observer(r, p43.pair.observer(l, acc))
