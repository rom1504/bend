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
