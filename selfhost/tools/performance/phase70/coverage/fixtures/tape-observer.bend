# Independent user ADT: dynamic root, reconstruction, aliases and a later full
# traversal. This is not Base.String, Map or a renamed benchmark function.
import Base

type Tape is Data:
  End{}
  Link{word: U32, next: Tape}

def build(n: Nat, +seed: U32) -> Tape:
  match n:
    case 0n:
      End{}
    case 1n+p:
      Link{U32.mod(seed, 257), build(p, U32.add(U32.mul(seed, 1664525), 1013904223))}

def restore(word: U32, result: Tape & U32) -> Tape & U32:
  (root, observation) = result
  (Link{word, root}, observation)

def total(root: Tape, acc: U32) -> Tape & U32:
  match root:
    case End{}:
      (End{}, acc)
    case Link{word0, next}:
      +word = {word0 : U32}
      restore(word, total(next, U32.add(acc, word)))

def hash(root: Tape, acc: U32) -> U32:
  match root:
    case End{}:
      acc
    case Link{word, next}:
      hash(next, U32.xor(U32.mul(acc, 16777619), word))

def bench(size: U32, seed: U32) -> U32:
  +root = build(U32.to_nat(size), seed)
  (retained, sum) = total(root, 0)
  U32.xor(sum, U32.add(hash(retained, 2166136261), hash(root, 2166136261)))
