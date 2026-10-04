import Base

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

type P43Cell is Data:
  P43Box{v: U32}

# Both reachable branches consume the pair through Tuple matching. True ignores
# both old fields and reconstructs fresh data; False keeps the field aliases.
def p43.pair.ignored.step(flag: Bool, st: P43Cell & P43Cell) -> P43Cell & P43Cell:
  match flag:
    case True{}:
      match st:
        case (a, b):
          (P43Box{7}, P43Box{11})
    case False{}:
      match st:
        case (a, b):
          (b, a)

def p43.pair.ignored.loop(n: Nat, +flag: Bool, st: P43Cell & P43Cell) -> P43Cell & P43Cell:
  match n:
    case 0n:
      st
    case 1n+p:
      p43.pair.ignored.loop(p, flag, p43.pair.ignored.step(flag, st))

def p43.pair.ignored.finish(st: P43Cell & P43Cell) -> U32:
  match st:
    case (P43Box{a}, P43Box{b}):
      p43.pair.observer(P43Branch{P43Tip{a}, P43Tip{b}}, 0)

def p43.pair.ignored.result(size: U32, +seed: U32) -> U32:
  p43.pair.ignored.finish(p43.pair.ignored.loop(U32.to_nat(size), U32.is_eq(seed, 0), (P43Box{seed}, P43Box{1})))
