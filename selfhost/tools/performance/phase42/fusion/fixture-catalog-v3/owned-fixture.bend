import Base

type OwnedChain is Data:
  ODone{value: U32}
  OLink{value: U32, rest: OwnedChain}

def owned.make(n: Nat, +seed: U32) -> OwnedChain:
  match n:
    case 0n: ODone{seed}
    case 1n+p: OLink{seed, owned.make(p, U32.inc(seed))}

def owned.copy(chain: OwnedChain) -> OwnedChain:
  match chain:
    case ODone{x}: ODone{x}
    case OLink{x, rest}: OLink{x, owned.copy(rest)}

def owned.count(chain: OwnedChain, +acc: U32) -> U32:
  match chain:
    case ODone{x}: U32.add(acc, x)
    case OLink{x, rest}: owned.count(rest, U32.add(acc, x))

def bench(depth: U32, seed: U32) -> U32:
  owned.count(owned.copy(owned.make(U32.to_nat(depth), seed)), 0)

def owned.native(values: List<&2,U32>, flag: Bool, n: Nat) -> U32:
  match values:
    case Nil{}: 0
    case Con{x, xs}:
      match flag:
        case False{}: 0
        case True{}:
          match n:
            case 0n: x
            case 1n+p: U32.inc(x)

def nativebench(seed: U32) -> U32:
  owned.native([seed], True{}, 1n)

def main() -> IO(Unit):
  IO.print(U32.show(U32.add(bench(3, 7), nativebench(11))))

#|46
