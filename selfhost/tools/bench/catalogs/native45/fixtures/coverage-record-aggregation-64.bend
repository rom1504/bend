# Phase37 independent composed application: produce textual numeric records,
# parse every amount, aggregate into 16 Unicode-named departments, and render
# every aggregate in ordered Map traversal. This is an in-memory application;
# neither filesystem throughput nor a full CSV parser is measured.
import Base

def p37.records(n: Nat, +i: U32, +seed: U32) -> List<&2, Sigma<&2, &2, String, _ => String>>:
  match n:
    case 0n:
      Nil{}
    case 1n+p:
      key = String.append("部門", U32.show(U32.mod(U32.add(i, seed), 16)))
      amount = U32.show(U32.mod(U32.add(U32.mul(i, 37), seed), 1000))
      (key, amount) <> p37.records(p, U32.add(i, 1), seed)

def p37.amount(value: Maybe<&2, U32>) -> U32:
  match value:
    case None{}:
      0
    case Some{v}:
      v

def p37.aggregate.put(key: String, amount: U32, got: Map<&2, U32> & U32) -> Map<&2, U32>:
  (m, old) = got
  Map.set(&2, U32, m, key, U32.add(old, amount))

def p37.aggregate(xs: List<&2, Sigma<&2, &2, String, _ => String>>, m: Map<&2, U32>) -> Map<&2, U32>:
  match xs:
    case Nil{}:
      m
    case (key0, text) <> rest:
      +key = {key0 : String}
      p37.aggregate(rest, p37.aggregate.put(key, p37.amount(U32.read(text)), Map.get(U32, 0, m, key)))

def p37.render(xs: List<&2, Sigma<&2, &2, String, _ => U32>>) -> String:
  match xs:
    case Nil{}:
      SNil{}
    case (key, amount) <> rest:
      String.append(key, String.append("=", String.append(U32.show(amount), String.append(";", p37.render(rest)))))

def bench(size: U32, seed: U32) -> String:
  p37.render(Map.to_list(&2, U32, p37.aggregate(p37.records(U32.to_nat(size), 0, seed), Map.new(&2, U32))))

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
      ((p93.number(repetitions, 8n), p93.number(warmups, 2n)), (p93.word(first, 64), p93.word(second, 17)))
    case head <> rest:
      p93.arguments(rest)
    case Nil{}:
      ((8n, 2n), (64, 17))

def p93.value(a: U32, b: U32) -> String:
  bench(a, b)

def p93.loop(n: Nat, +a: U32, +b: U32, h: U32) -> U32:
  match n:
    case 0n:
      h
    case 1n+p:
      value = p93.value(a, b)
      valid = String.eq(value, "部門0=1840;部門1=1620;部門10=1952;部門11=2100;部門12=1248;部門13=1396;部門14=1544;部門15=1692;部門2=1768;部門3=1916;部門4=2064;部門5=2212;部門6=2360;部門7=1508;部門8=1656;部門9=1804;")
      p93.loop(p, a, b, U32.add(h, Bool.to_u32(valid)))

def p93.execute(repetitions: Nat, warmups: Nat, +a: U32, +b: U32) -> IO(Unit):
  do IO<Unit>:
    Unit <- IO.print(p93.value(a, b))
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
