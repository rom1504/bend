# Equal strings, strict prefixes, both unequal orders and early/late mismatch.
# Observe both returned roots, not just ordering; mix generated/shared roots
# with static Unicode literals. Comparison is the repository Base definition.
import Base

def prefix(n: Nat, +seed: U32) -> String:
  match n:
    case 0n:
      SNil{}
    case 1n+p:
      String.append("λ🙂中", SCon{Chr{U32.add(97, U32.mod(seed, 26))}, prefix(p, seed)})

def pair(mode: Nat, +pre: String) -> String & String:
  match mode:
    case 0n:
      (pre, pre)
    case 1n+0n:
      (pre, String.append(pre, "a"))
    case 1n+1n+0n:
      (String.append(pre, "a"), pre)
    case 1n+1n+1n+0n:
      (String.append(pre, "λ"), String.append(pre, "中"))
    case 1n+1n+1n+1n+0n:
      (String.append(pre, "🙂"), String.append(pre, "λ"))
    case 1n+1n+1n+1n+1n+0n:
      (String.append(pre, "same"), String.append(pre, "same"))
    case 1n+1n+1n+1n+1n+1n+0n:
      (pre, String.append("!", pre))
    case 1n+1n+1n+1n+1n+1n+1n+p:
      (String.append("!", pre), pre)

def hash(text: String, acc: U32) -> U32:
  match text:
    case SNil{}:
      acc
    case SCon{Chr{word}, rest}:
      hash(rest, U32.xor(U32.mul(acc, 16777619), word))

def order(c: Cmp) -> U32:
  match c:
    case LT{}:
      1
    case EQ{}:
      2
    case GT{}:
      3

def observe(result: (String & String) & Cmp) -> U32:
  ((left, right), cmp) = result
  U32.add(U32.xor(hash(left, 2166136261), U32.mul(hash(right, 2166136261), 33)), order(cmp))

def compare(pair0: String & String) -> U32:
  (left, right) = pair0
  observe(String.cmp(left, right))

def bench(size: U32, +seed: U32) -> U32:
  U32.xor(compare(pair(U32.to_nat(U32.and(seed, 7)), prefix(U32.to_nat(size), seed))), observe(String.cmp("λ🙂", "λ中")))
