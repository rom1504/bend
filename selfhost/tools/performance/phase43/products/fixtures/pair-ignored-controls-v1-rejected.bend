import Base

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

def p43.pair.ignored.loop(n: Nat, flag: Bool, st: P43Cell & P43Cell) -> P43Cell & P43Cell:
  match n:
    case 0n:
      st
    case 1n+p:
      p43.pair.ignored.loop(p, flag, p43.pair.ignored.step(flag, st))

def p43.pair.ignored.finish(st: P43Cell & P43Cell) -> U32:
  match st:
    case (P43Box{a}, P43Box{b}):
      U32.add(U32.mul(a, 17), b)

def p43.pair.ignored.result(size: U32, +seed: U32) -> U32:
  p43.pair.ignored.finish(p43.pair.ignored.loop(U32.to_nat(size), U32.is_eq(seed, 0), (P43Box{seed}, P43Box{1})))
