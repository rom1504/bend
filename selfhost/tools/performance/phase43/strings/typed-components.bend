import Base

# Scalar roots own complete native Strings; names differ from the benchmark.
# Alias + custom String field + nested SCon/Chr pattern probe family propagation.
def Text() -> Data:
  String

type Packet is Data:
  Packet{text: Text()}

def literal.template() -> Text():
  "a😃9 z"

def rename.copy(s: Text()) -> Text():
  match s:
    case SNil{}: SNil{}
    case SCon{Chr{c}, tail}: SCon{Chr{c}, rename.copy(tail)}

def rename.score(s: Text(), acc: U32) -> U32:
  match s:
    case SNil{}: acc
    case SCon{Chr{c}, tail}:
      rename.score(tail, U32.xor(U32.mul(acc, 16777619), c))

def packet.score(p: Packet, seed: U32) -> U32:
  match p:
    case Packet{text}: rename.score(text, seed)

def branch.lines(depth: Nat, seed: U32) -> U32:
  match depth:
    case 0n:
      packet.score(Packet{rename.copy(literal.template())}, seed)
    case 1n+p:
      a b = branch.lines(p, seed) branch.lines(p, U32.add(seed, 1))
      U32.add(a, b)

def bench(depth: U32, seed: U32) -> U32:
  branch.lines(U32.to_nat(depth), seed)
