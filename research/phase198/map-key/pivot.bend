def kw.second(tail: String) -> U32:
  match tail:
    case SNil{}: 4294967295
    case SCon{Chr{raw}, rest}: U32.min(raw, 4294967294)

def kw.pack(tail: String) -> U32 & U32:
  match tail:
    case SNil{}: (4294967295, 4294967295)
    case SCon{Chr{raw}, rest}: (U32.min(raw, 4294967294), kw.second(rest))

def kw.word.bit(word: U32, off: Nat) -> Bool:
  match off:
    case 0n: True{}
    case 1n+b: Map.bit.u(word, Nat.sub(31n, b))

def kw.absent(key: String, ci: Nat, off: Nat, missing: Bool) -> String & Bool:
  match missing:
    case True{}: (key, False{})
    case False{}: Map.bit.go(key, ci, off)

def kw.cover(+word: U32, key: String, ci: Nat, off: Nat, ordinary: Bool) -> String & Bool:
  match ordinary:
    case True{}: (key, kw.word.bit(word, off))
    case False{}: kw.absent(key, ci, off, U32.is_eq(word, 4294967295))

def kw.at.second(+word: U32, key: String, ci: Nat, off: Nat, second: Bool) -> String & Bool:
  match second:
    case True{}: kw.cover(word, key, ci, off, U32.is_lt(word, 4294967294))
    case False{}: Map.bit.go(key, ci, off)

def kw.at.first(anchor: Nat, +word0: U32, word1: U32, key: String, +ci: Nat, off: Nat, first: Bool) -> String & Bool:
  match first:
    case True{}: kw.cover(word0, key, ci, off, U32.is_lt(word0, 4294967294))
    case False{}: kw.at.second(word1, key, ci, off, Nat.is_eq(ci, Nat.add(anchor, 1n)))

def kw.at(+anchor: Nat, word0: U32, word1: U32, key: String, co: Nat & Nat) -> String & Bool:
  (raw, off) = co
  +ci = {raw : Nat}
  kw.at.first(anchor, word0, word1, key, ci, off, Nat.is_eq(ci, anchor))

def kw.bit(anchor: Nat, word0: U32, word1: U32, key: String, pos: Nat) -> String & Bool:
  kw.at(anchor, word0, word1, key, Nat.divmod(pos, 33n))
