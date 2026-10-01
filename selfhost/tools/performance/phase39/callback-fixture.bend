# Affine callbacks: each captured closure is constructed and consumed once.
# Input, callback and result lists remain materialized; this is not fusion.
import Base

type CallbackList is Type:
  CallbackEnd{}
  CallbackMore{f: U32 -> U32, tail: CallbackList}

def callback.offset(amount: U32) -> U32 -> U32:
  x => U32.add(x, amount)

def callback.make(n: Nat, +seed: U32) -> CallbackList:
  match n:
    case 0n:
      CallbackEnd{}
    case 1n+p:
      CallbackMore{callback.offset(U32.add(seed, U32.from_nat(p))), callback.make(p, seed)}

def callback.values(n: Nat, +seed: U32) -> List<&2, U32>:
  match n:
    case 0n:
      Nil{}
    case 1n+p:
      U32.mod(seed, 65536) <> callback.values(p, U32.add(U32.mul(seed, 1664525), 1013904223))

def callback.map(fs: CallbackList, xs: List<&2, U32>) -> List<&2, U32>:
  match fs:
    case CallbackEnd{}:
      Nil{}
    case CallbackMore{f, tail}:
      match xs:
        case Nil{}:
          Nil{}
        case Con{x, rest}:
          f(x) <> callback.map(tail, rest)

def callback.sum(xs: List<&2, U32>, acc: U32) -> U32:
  match xs:
    case Nil{}:
      acc
    case Con{x, rest}:
      callback.sum(rest, U32.add(acc, x))

def callback.result(+size: U32, +seed: U32) -> List<&2, U32>:
  callback.map(callback.make(U32.to_nat(size), seed), callback.values(U32.to_nat(size), seed))

def bench(size: U32, seed: U32) -> U32:
  callback.sum(callback.result(size, seed), 0)
