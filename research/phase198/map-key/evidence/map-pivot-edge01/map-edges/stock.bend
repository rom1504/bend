# Phase37 authored collection workload; uses the pinned Base Map implementation.
# Build many keys, replace every third value, remove every fourth key, then
# observe the entire ordered key/value content through a wrapping digest.
import Base

def kp.edge16(n: Nat) -> String:
  match n:
    case 0n: SCon{Chr{4294967295}, SCon{Chr{97}, SNil{}}}
    case 1n+p: SCon{Chr{4294967293}, SCon{Chr{97}, SNil{}}}

def kp.edge15(n: Nat) -> String:
  match n:
    case 0n: SCon{Chr{4294967294}, SCon{Chr{97}, SNil{}}}
    case 1n+p: kp.edge16(p)

def kp.edge14(n: Nat) -> String:
  match n:
    case 0n: SCon{Chr{1114111}, SNil{}}
    case 1n+p: kp.edge15(p)

def kp.edge13(n: Nat) -> String:
  match n:
    case 0n: SCon{Chr{38263}, SCon{Chr{38263}, SCon{Chr{38263}, SCon{Chr{38263}, SCon{Chr{38263}, SCon{Chr{38263}, SCon{Chr{38263}, SCon{Chr{38263}, SCon{Chr{38263}, SCon{Chr{38263}, SCon{Chr{38263}, SCon{Chr{38263}, SCon{Chr{38263}, SCon{Chr{38263}, SCon{Chr{38263}, SCon{Chr{38263}, SCon{Chr{38263}, SCon{Chr{38263}, SCon{Chr{38263}, SCon{Chr{38263}, SCon{Chr{38263}, SCon{Chr{38263}, SCon{Chr{38263}, SCon{Chr{38263}, SCon{Chr{38263}, SCon{Chr{38263}, SCon{Chr{38263}, SCon{Chr{38263}, SCon{Chr{38263}, SCon{Chr{38263}, SCon{Chr{38263}, SCon{Chr{128998}, SNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}
    case 1n+p: kp.edge14(p)

def kp.edge12(n: Nat) -> String:
  match n:
    case 0n: SCon{Chr{128998}, SNil{}}
    case 1n+p: kp.edge13(p)

def kp.edge11(n: Nat) -> String:
  match n:
    case 0n: SCon{Chr{38263}, SCon{Chr{38263}, SCon{Chr{38263}, SCon{Chr{38263}, SCon{Chr{38263}, SCon{Chr{38263}, SCon{Chr{38263}, SCon{Chr{38263}, SCon{Chr{38263}, SCon{Chr{38263}, SCon{Chr{38263}, SCon{Chr{38263}, SCon{Chr{38263}, SCon{Chr{38263}, SCon{Chr{38263}, SCon{Chr{38263}, SCon{Chr{38263}, SCon{Chr{38263}, SCon{Chr{38263}, SCon{Chr{38263}, SCon{Chr{38263}, SCon{Chr{38263}, SCon{Chr{38263}, SCon{Chr{38263}, SCon{Chr{38263}, SCon{Chr{38263}, SCon{Chr{38263}, SCon{Chr{38263}, SCon{Chr{38263}, SCon{Chr{38263}, SCon{Chr{38263}, SCon{Chr{38263}, SCon{Chr{98}, SNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}
    case 1n+p: kp.edge12(p)

def kp.edge10(n: Nat) -> String:
  match n:
    case 0n: SCon{Chr{38263}, SCon{Chr{38263}, SCon{Chr{38263}, SCon{Chr{38263}, SCon{Chr{38263}, SCon{Chr{38263}, SCon{Chr{38263}, SCon{Chr{38263}, SCon{Chr{38263}, SCon{Chr{38263}, SCon{Chr{38263}, SCon{Chr{38263}, SCon{Chr{38263}, SCon{Chr{38263}, SCon{Chr{38263}, SCon{Chr{38263}, SCon{Chr{38263}, SCon{Chr{38263}, SCon{Chr{38263}, SCon{Chr{38263}, SCon{Chr{38263}, SCon{Chr{38263}, SCon{Chr{38263}, SCon{Chr{38263}, SCon{Chr{38263}, SCon{Chr{38263}, SCon{Chr{38263}, SCon{Chr{38263}, SCon{Chr{38263}, SCon{Chr{38263}, SCon{Chr{38263}, SCon{Chr{38263}, SCon{Chr{97}, SNil{}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}
    case 1n+p: kp.edge11(p)

def kp.edge9(n: Nat) -> String:
  match n:
    case 0n: SCon{Chr{255}, SCon{Chr{0}, SCon{Chr{120}, SNil{}}}}
    case 1n+p: kp.edge10(p)

def kp.edge8(n: Nat) -> String:
  match n:
    case 0n: SCon{Chr{97}, SCon{Chr{0}, SCon{Chr{0}, SCon{Chr{98}, SNil{}}}}}
    case 1n+p: kp.edge9(p)

def kp.edge7(n: Nat) -> String:
  match n:
    case 0n: SCon{Chr{120}, SCon{Chr{0}, SNil{}}}
    case 1n+p: kp.edge8(p)

def kp.edge6(n: Nat) -> String:
  match n:
    case 0n: SCon{Chr{97}, SCon{Chr{98}, SCon{Chr{99}, SCon{Chr{100}, SCon{Chr{101}, SCon{Chr{102}, SCon{Chr{103}, SCon{Chr{128578}, SNil{}}}}}}}}}
    case 1n+p: kp.edge7(p)

def kp.edge5(n: Nat) -> String:
  match n:
    case 0n: SCon{Chr{120}, SCon{Chr{7522}, SNil{}}}
    case 1n+p: kp.edge6(p)

def kp.edge4(n: Nat) -> String:
  match n:
    case 0n: SCon{Chr{97}, SCon{Chr{98}, SCon{Chr{99}, SCon{Chr{233}, SNil{}}}}}
    case 1n+p: kp.edge5(p)

def kp.edge3(n: Nat) -> String:
  match n:
    case 0n: SCon{Chr{97}, SCon{Chr{98}, SCon{Chr{99}, SCon{Chr{100}, SCon{Chr{101}, SCon{Chr{102}, SCon{Chr{103}, SCon{Chr{104}, SNil{}}}}}}}}}
    case 1n+p: kp.edge4(p)

def kp.edge2(n: Nat) -> String:
  match n:
    case 0n: SCon{Chr{97}, SCon{Chr{98}, SCon{Chr{99}, SCon{Chr{100}, SCon{Chr{101}, SCon{Chr{102}, SCon{Chr{103}, SNil{}}}}}}}}
    case 1n+p: kp.edge3(p)

def kp.edge1(n: Nat) -> String:
  match n:
    case 0n: SCon{Chr{97}, SCon{Chr{0}, SCon{Chr{98}, SNil{}}}}
    case 1n+p: kp.edge2(p)

def kp.edge0(n: Nat) -> String:
  match n:
    case 0n: SNil{}
    case 1n+p: kp.edge1(p)

def p37.map.key(i: U32) -> String:
  kp.edge0(U32.to_nat(U32.mod(i, 18)))

def p37.map.fill(n: Nat, +i: U32, +seed: U32, m: Map<&2, U32>) -> Map<&2, U32>:
  match n:
    case 0n:
      m
    case 1n+p:
      p37.map.fill(p, U32.add(i, 1), seed,
        Map.set(&2, U32, m, p37.map.key(i), U32.add(seed, U32.mul(i, 17))))

def p37.map.update(n: Nat, +i: U32, +seed: U32, m: Map<&2, U32>) -> Map<&2, U32>:
  match n:
    case 0n:
      m
    case 1n+p:
      p37.map.update(p, U32.add(i, 3), seed,
        Map.set(&2, U32, m, p37.map.key(i), U32.xor(seed, U32.mul(i, 31))))

def p37.map.remove(n: Nat, +i: U32, m: Map<&2, U32>) -> Map<&2, U32>:
  match n:
    case 0n:
      m
    case 1n+p:
      p37.map.remove(p, U32.add(i, 4), Map.del(&2, U32, m, p37.map.key(i)))

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
      ((p93.number(repetitions, 8n), p93.number(warmups, 2n)), (p93.word(first, 32), p93.word(second, 17)))
    case head <> rest:
      p93.arguments(rest)
    case Nil{}:
      ((8n, 2n), (32, 17))

def p93.value(a: U32, b: U32) -> U32:
  bench(a, b)

def p93.loop(n: Nat, +a: U32, +b: U32, h: U32) -> U32:
  match n:
    case 0n:
      h
    case 1n+p:
      value = p93.value(a, b)
      valid = U32.is_eq(value, 2641268989)
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
