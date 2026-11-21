# Phase37 authored collection workload; uses the pinned Base Map implementation.
# Build many keys, replace every third value, remove every fourth key, then
# observe the entire ordered key/value content through a wrapping digest.
import Base

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

def kw.set.ready(a, -V: Kind(a), m: Map<a, V>, key: String, x: V, anchor: Nat, words: U32 & U32) -> Map<a, V>:
  (word0, word1) = words
  kw.set(anchor, word0, word1, a, V, m, key, x)

def kw.set.start(a, -V: Kind(a), m: Map<a, V>, +key: String, x: V, +anchor: Nat) -> Map<a, V>:
  kw.set.ready(a, V, m, key, x, anchor, kw.pack(String.drop(key, anchor)))

def kw.set.entry(a, -V: Kind(a), m: Map<a, V>, key: String, x: V) -> Map<a, V>:
  match m:
    case MNode{+p, lo, hi}: kw.set.start(a, V, MNode{p, lo, hi}, key, x, Nat.div(p, 33n))
    case other: Map.set(a, V, other, key, x)

def kw.del.ready(a, -V: Kind(a), m: Map<a, V>, key: String, anchor: Nat, words: U32 & U32) -> Map<a, V>:
  (word0, word1) = words
  kw.del(anchor, word0, word1, a, V, m, key)

def kw.del.start(a, -V: Kind(a), m: Map<a, V>, +key: String, +anchor: Nat) -> Map<a, V>:
  kw.del.ready(a, V, m, key, anchor, kw.pack(String.drop(key, anchor)))

def kw.del.entry(a, -V: Kind(a), m: Map<a, V>, key: String) -> Map<a, V>:
  match m:
    case MNode{+p, lo, hi}: kw.del.start(a, V, MNode{p, lo, hi}, key, Nat.div(p, 33n))
    case other: Map.del(a, V, other, key)

def kw.get.ready(-V: Data, d: V, m: Map<&2, V>, key: String, anchor: Nat, words: U32 & U32) -> Map<&2, V> & V:
  (word0, word1) = words
  kw.get(anchor, word0, word1, V, d, m, key)

def kw.get.start(-V: Data, d: V, m: Map<&2, V>, +key: String, +anchor: Nat) -> Map<&2, V> & V:
  kw.get.ready(V, d, m, key, anchor, kw.pack(String.drop(key, anchor)))

def kw.get.entry(-V: Data, d: V, m: Map<&2, V>, key: String) -> Map<&2, V> & V:
  match m:
    case MNode{+p, lo, hi}: kw.get.start(V, d, MNode{p, lo, hi}, key, Nat.div(p, 33n))
    case other: Map.get(V, d, other, key)

def kw.put.go(+anchor: Nat, +word0: U32, +word1: U32, -a: Quant, -V: Kind(a), node: Map<a, V>, x: V, kb: String & Bool) -> Map<a, V>:
  match node kb:
    case MNode{p, MTip{}, hi} Tuple{key, False{}}:
      MNode{p, MLeaf{key, x}, hi}
    case MNode{p, MLeaf{k, v}, hi} Tuple{key, False{}}:
      MNode{p, MLeaf{k, x}, hi}
    case MNode{p, MNode{+q, c, d}, hi} Tuple{key, False{}}:
      MNode{p, kw.put.go(anchor, word0, word1, a, V, MNode{q, c, d}, x, kw.bit(anchor, word0, word1, key, q)), hi}
    case MNode{p, lo, MTip{}} Tuple{key, True{}}:
      MNode{p, lo, MLeaf{key, x}}
    case MNode{p, lo, MLeaf{k, v}} Tuple{key, True{}}:
      MNode{p, lo, MLeaf{k, x}}
    case MNode{p, lo, MNode{+q, c, d}} Tuple{key, True{}}:
      MNode{p, lo, kw.put.go(anchor, word0, word1, a, V, MNode{q, c, d}, x, kw.bit(anchor, word0, word1, key, q))}
    case m _:
      m

def kw.put(+anchor: Nat, +word0: U32, +word1: U32, -a: Quant, -V: Kind(a), m: Map<a, V>, key: String, x: V) -> Map<a, V>:
  match m:
    case MTip{}:
      MLeaf{key, x}
    case MLeaf{k, v}:
      MLeaf{k, x}
    case MNode{+pos, lo, hi}:
      kw.put.go(anchor, word0, word1, a, V, MNode{pos, lo, hi}, x, kw.bit(anchor, word0, word1, key, pos))

def kw.ins.splice(+anchor: Nat, +word0: U32, +word1: U32, 
  a, -V: Kind(a), +p: Nat, key: String, x: V, rest: Map<a, V>
) -> Map<a, V>:
  Map.ins.splice.bit(a, V, x, rest, p, kw.bit(anchor, word0, word1, key, p))

def kw.ins.go(+anchor: Nat, +word0: U32, +word1: U32, 
  -a: Quant, -V: Kind(a), node: Map<a, V>, x: V, +p: Nat, kb: String & Bool,
  t: Bool
) -> Map<a, V>:
  match node kb t:
    case MNode{q, lo, hi} Tuple{key, b} False{}:
      kw.ins.splice(anchor, word0, word1, a, V, p, key, x, MNode{q, lo, hi})
    case MNode{q, MTip{}, hi} Tuple{key, False{}} True{}:
      MNode{q, MLeaf{key, x}, hi}
    case MNode{q, MLeaf{k, v}, hi} Tuple{key, False{}} True{}:
      MNode{q, kw.ins.splice(anchor, word0, word1, a, V, p, key, x, MLeaf{k, v}), hi}
    case MNode{q, MNode{+r, c, d}, hi} Tuple{key, False{}} True{}:
      MNode{q, kw.ins.go(anchor, word0, word1, a, V, MNode{r, c, d}, x, p, kw.bit(anchor, word0, word1, key, r), Nat.is_lt(r, p)), hi}
    case MNode{q, lo, MTip{}} Tuple{key, True{}} True{}:
      MNode{q, lo, MLeaf{key, x}}
    case MNode{q, lo, MLeaf{k, v}} Tuple{key, True{}} True{}:
      MNode{q, lo, kw.ins.splice(anchor, word0, word1, a, V, p, key, x, MLeaf{k, v})}
    case MNode{q, lo, MNode{+r, c, d}} Tuple{key, True{}} True{}:
      MNode{q, lo, kw.ins.go(anchor, word0, word1, a, V, MNode{r, c, d}, x, p, kw.bit(anchor, word0, word1, key, r), Nat.is_lt(r, p))}
    case m _ _:
      m

def kw.ins(+anchor: Nat, +word0: U32, +word1: U32, 
  -a: Quant, -V: Kind(a), m: Map<a, V>, key: String, x: V, +p: Nat
) -> Map<a, V>:
  match m:
    case MTip{}:
      MLeaf{key, x}
    case MLeaf{k, v}:
      kw.ins.splice(anchor, word0, word1, a, V, p, key, x, MLeaf{k, v})
    case MNode{+pos, lo, hi}:
      kw.ins.go(anchor, word0, word1, a, V, MNode{pos, lo, hi}, x, p, kw.bit(anchor, word0, word1, key, pos), Nat.is_lt(pos, p))

def kw.seek.go(+anchor: Nat, +word0: U32, +word1: U32, -a: Quant, -V: Kind(a), node: Map<a, V>, kb: String & Bool) ->
  Map<a, V> & String & Maybe<&2, String>:
  match node kb:
    case MNode{p, MTip{}, hi} Tuple{key, False{}}:
      (MNode{p, MTip{}, hi}, key, None{})
    case MNode{p, MLeaf{+k, v}, hi} Tuple{key, False{}}:
      (MNode{p, MLeaf{k, v}, hi}, key, Some{k})
    case MNode{p, MNode{+q, c, d}, hi} Tuple{key, False{}}:
      Map.lo(a, V, String & Maybe<&2, String>, p, hi, kw.seek.go(anchor, word0, word1, a, V, MNode{q, c, d}, kw.bit(anchor, word0, word1, key, q)))
    case MNode{p, lo, MTip{}} Tuple{key, True{}}:
      (MNode{p, lo, MTip{}}, key, None{})
    case MNode{p, lo, MLeaf{+k, v}} Tuple{key, True{}}:
      (MNode{p, lo, MLeaf{k, v}}, key, Some{k})
    case MNode{p, lo, MNode{+q, c, d}} Tuple{key, True{}}:
      Map.hi(a, V, String & Maybe<&2, String>, p, lo, kw.seek.go(anchor, word0, word1, a, V, MNode{q, c, d}, kw.bit(anchor, word0, word1, key, q)))
    case m Tuple{key, b}:
      (m, key, None{})

def kw.seek(+anchor: Nat, +word0: U32, +word1: U32, -a: Quant, -V: Kind(a), m: Map<a, V>, key: String) ->
  Map<a, V> & String & Maybe<&2, String>:
  match m:
    case MTip{}:
      (MTip{}, key, None{})
    case MLeaf{+k, v}:
      (MLeaf{k, v}, key, Some{k})
    case MNode{+pos, lo, hi}:
      kw.seek.go(anchor, word0, word1, a, V, MNode{pos, lo, hi}, kw.bit(anchor, word0, word1, key, pos))

def kw.set.fin.go(+anchor: Nat, +word0: U32, +word1: U32, 
  a, -V: Kind(a), m: Map<a, V>, key: String, x: V, r: (String & String) & Cmp
) -> Map<a, V>:
  ((keyb2, k2), c) = r
  match c:
    case EQ{}:
      kw.put(anchor, word0, word1, a, V, m, key, x)
    case o:
      kw.ins(anchor, word0, word1, a, V, m, key, x, Map.diff(keyb2, k2))

def kw.set.fin(+anchor: Nat, +word0: U32, +word1: U32, 
  a, -V: Kind(a), m: Map<a, V>, key: String, x: V, keyb: String, k: String
) -> Map<a, V>:
  kw.set.fin.go(anchor, word0, word1, a, V, m, key, x, String.cmp(keyb, k))

def kw.set.go(+anchor: Nat, +word0: U32, +word1: U32, 
  a, -V: Kind(a), x: V, r: Map<a, V> & String & Maybe<&2, String>
) -> Map<a, V>:
  (m2, key2, found) = r
  match found:
    case None{}:
      MLeaf{key2, x}
    case Some{k}:
      +ka = {key2 : String}
      kw.set.fin(anchor, word0, word1, a, V, m2, ka, x, ka, k)

def kw.set(+anchor: Nat, +word0: U32, +word1: U32, a, -V: Kind(a), m: Map<a, V>, key: String, x: V) -> Map<a, V>:
  kw.set.go(anchor, word0, word1, a, V, x, kw.seek(anchor, word0, word1, a, V, m, key))

def kw.pop.go(+anchor: Nat, +word0: U32, +word1: U32, -a: Quant, -V: Kind(a), node: Map<a, V>, kb: String & Bool) ->
  Map<a, V> & Maybe<a, V>:
  match node kb:
    case MNode{p, MTip{}, hi} Tuple{key, False{}}:
      (hi, None{})
    case MNode{p, MLeaf{k, v}, hi} Tuple{key, False{}}:
      Map.pop.lo(a, V, p, hi, Map.pop.leaf(a, V, v, String.cmp(key, k)))
    case MNode{p, MNode{+q, c, d}, hi} Tuple{key, False{}}:
      Map.pop.lo(a, V, p, hi, kw.pop.go(anchor, word0, word1, a, V, MNode{q, c, d}, kw.bit(anchor, word0, word1, key, q)))
    case MNode{p, lo, MTip{}} Tuple{key, True{}}:
      (lo, None{})
    case MNode{p, lo, MLeaf{k, v}} Tuple{key, True{}}:
      Map.pop.hi(a, V, p, lo, Map.pop.leaf(a, V, v, String.cmp(key, k)))
    case MNode{p, lo, MNode{+q, c, d}} Tuple{key, True{}}:
      Map.pop.hi(a, V, p, lo, kw.pop.go(anchor, word0, word1, a, V, MNode{q, c, d}, kw.bit(anchor, word0, word1, key, q)))
    case m _:
      (m, None{})

def kw.pop(+anchor: Nat, +word0: U32, +word1: U32, -a: Quant, -V: Kind(a), m: Map<a, V>, key: String) -> Map<a, V> & Maybe<a, V>:
  match m:
    case MTip{}:
      (MTip{}, None{})
    case MLeaf{k, v}:
      Map.pop.leaf(a, V, v, String.cmp(key, k))
    case MNode{+pos, lo, hi}:
      kw.pop.go(anchor, word0, word1, a, V, MNode{pos, lo, hi}, kw.bit(anchor, word0, word1, key, pos))

def kw.del(+anchor: Nat, +word0: U32, +word1: U32, a, -V: Kind(a), m: Map<a, V>, key: String) -> Map<a, V>:
  Map.del.fin(a, V, kw.pop(anchor, word0, word1, a, V, m, key))

def kw.get.go(+anchor: Nat, +word0: U32, +word1: U32, -V: Data, node: Map<&2, V>, d: V, kb: String & Bool) -> Map<&2, V> & V:
  match node kb:
    case MNode{p, MTip{}, hi} Tuple{key2, False{}}:
      (MNode{p, MTip{}, hi}, d)
    case MNode{p, MLeaf{k, v}, hi} Tuple{key2, False{}}:
      Map.lo(&2, V, V, p, hi, Map.get.leaf(V, d, v, String.cmp(key2, k)))
    case MNode{p, MNode{+q, a, b}, hi} Tuple{key2, False{}}:
      Map.lo(&2, V, V, p, hi, kw.get.go(anchor, word0, word1, V, MNode{q, a, b}, d, kw.bit(anchor, word0, word1, key2, q)))
    case MNode{p, lo, MTip{}} Tuple{key2, True{}}:
      (MNode{p, lo, MTip{}}, d)
    case MNode{p, lo, MLeaf{k, v}} Tuple{key2, True{}}:
      Map.hi(&2, V, V, p, lo, Map.get.leaf(V, d, v, String.cmp(key2, k)))
    case MNode{p, lo, MNode{+q, a, b}} Tuple{key2, True{}}:
      Map.hi(&2, V, V, p, lo, kw.get.go(anchor, word0, word1, V, MNode{q, a, b}, d, kw.bit(anchor, word0, word1, key2, q)))
    case m _:
      (m, d)

def kw.get(+anchor: Nat, +word0: U32, +word1: U32, -V: Data, d: V, m: Map<&2, V>, key: String) -> Map<&2, V> & V:
  match m:
    case MTip{}:
      (MTip{}, d)
    case MLeaf{k, v}:
      Map.get.leaf(V, d, v, String.cmp(key, k))
    case MNode{+pos, lo, hi}:
      kw.get.go(anchor, word0, word1, V, MNode{pos, lo, hi}, d, kw.bit(anchor, word0, word1, key, pos))


def p37.map.key(i: U32) -> String:
  String.append("key", U32.show(i))

def p37.map.fill(n: Nat, +i: U32, +seed: U32, m: Map<&2, U32>) -> Map<&2, U32>:
  match n:
    case 0n:
      m
    case 1n+p:
      p37.map.fill(p, U32.add(i, 1), seed,
        kw.set.entry(&2, U32, m, p37.map.key(i), U32.add(seed, U32.mul(i, 17))))

def p37.map.update(n: Nat, +i: U32, +seed: U32, m: Map<&2, U32>) -> Map<&2, U32>:
  match n:
    case 0n:
      m
    case 1n+p:
      p37.map.update(p, U32.add(i, 3), seed,
        kw.set.entry(&2, U32, m, p37.map.key(i), U32.xor(seed, U32.mul(i, 31))))

def p37.map.remove(n: Nat, +i: U32, m: Map<&2, U32>) -> Map<&2, U32>:
  match n:
    case 0n:
      m
    case 1n+p:
      p37.map.remove(p, U32.add(i, 4), kw.del.entry(&2, U32, m, p37.map.key(i)))

def p37.map.string(s: String, acc: U32) -> U32:
  match s:
    case SNil{}:
      acc
    case SCon{Chr{x}, t}:
      p37.map.string(t, U32.add(U32.mul(acc, 31), x))

def p37.map.digest(xs: List<&2, Sigma<&2, &2, String, _ => U32>>, acc: U32) -> U32:
  match xs:
    case Nil{}:
      acc
    case (k, v) <> t:
      p37.map.digest(t, U32.xor(U32.mul(p37.map.string(k, acc), 16777619), v))

def bench(+size: U32, +seed: U32) -> U32:
  m = p37.map.fill(U32.to_nat(size), 0, seed, Map.new(&2, U32))
  m = p37.map.update(U32.to_nat(U32.div(U32.add(size, 2), 3)), 0, seed, m)
  m = p37.map.remove(U32.to_nat(U32.div(U32.add(size, 3), 4)), 0, m)
  p37.map.digest(Map.to_list(&2, U32, m), 2166136261)

# Phase93: fixed catalog inputs, repeated complete-result validation.
# Final four argv words: repetitions warmups arg0 arg1.
# The measured interval includes result validation and success-count printing.
def p93.parsed(value: Maybe<&2, Nat>, fallback: Nat) -> Nat:
  match value:
    case None{}:
      fallback
    case Some{n}:
      n

def p93.number(text: String, fallback: Nat) -> Nat:
  p93.parsed(Nat.read(text), fallback)

def p93.word_parsed(value: Maybe<&2, U32>, fallback: U32) -> U32:
  match value:
    case None{}:
      fallback
    case Some{n}:
      n

def p93.word(text: String, fallback: U32) -> U32:
  p93.word_parsed(U32.read(text), fallback)

def p93.arguments(args: List<String>) -> (Nat & Nat) & (U32 & U32):
  match args:
    case repetitions <> warmups <> first <> second <> Nil{}:
      ((p93.number(repetitions, 8n), p93.number(warmups, 2n)), (p93.word(first, 128), p93.word(second, 123)))
    case head <> rest:
      p93.arguments(rest)
    case Nil{}:
      ((8n, 2n), (128, 123))

def p93.value(a: U32, b: U32) -> U32:
  bench(a, b)

def p93.loop(n: Nat, +a: U32, +b: U32, h: U32) -> U32:
  match n:
    case 0n:
      h
    case 1n+p:
      value = p93.value(a, b)
      valid = U32.is_eq(value, 3714872484)
      p93.loop(p, a, b, U32.add(h, Bool.to_u32(valid)))

def p93.execute(repetitions: Nat, warmups: Nat, +a: U32, +b: U32) -> IO(Unit):
  do IO<Unit>:
    Unit <- IO.print(U32.show(p93.value(a, b)))
    Unit <- IO.print(U32.show(p93.loop(warmups, a, b, 0)))
    t0 : Nat <- IO.now()
    Unit <- IO.print(U32.show(p93.loop(repetitions, a, b, 0)))
    t1 : Nat <- IO.now()
    IO.print(Nat.show(Nat.sub(t1, t0)))

def p93.run(options: (Nat & Nat) & (U32 & U32)) -> IO(Unit):
  (counts, arguments) = options
  (repetitions, warmups) = counts
  (a, b) = arguments
  p93.execute(repetitions, warmups, a, b)

def main() -> IO(Unit):
  do IO<Unit>:
    args : List<String> <- IO.args()
    p93.run(p93.arguments(args))
