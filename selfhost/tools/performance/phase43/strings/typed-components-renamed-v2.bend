import Base

# Scalar roots own complete native Strings; names differ from the benchmark.
# Alias + custom String field + nested SCon/Chr pattern probe family propagation.
def RuneBuffer() -> Data:
  String

type Envelope is Data:
  Envelope{text: RuneBuffer()}

def seed.text() -> RuneBuffer():
  "a😃9 z"

def clone.text(s: RuneBuffer()) -> RuneBuffer():
  match s:
    case SNil{}: SNil{}
    case SCon{Chr{c}, tail}: SCon{Chr{c}, clone.text(tail)}

def consume.text(s: RuneBuffer(), acc: U32) -> U32:
  match s:
    case SNil{}: acc
    case SCon{Chr{c}, tail}:
      consume.text(tail, U32.xor(U32.mul(acc, 16777619), c))

def read.envelope(p: Envelope, seed: U32) -> U32:
  match p:
    case Envelope{text}: consume.text(text, seed)

def sum.jobs(depth: Nat, +seed: U32) -> U32:
  match depth:
    case 0n:
      read.envelope(Envelope{clone.text(seed.text())}, seed)
    case 1n+p:
      a b = sum.jobs(p, seed) sum.jobs(p, U32.add(seed, 1))
      U32.add(a, b)

def bench(depth: U32, seed: U32) -> U32:
  sum.jobs(U32.to_nat(depth), seed)
