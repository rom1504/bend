# run-length encoding: list -> (count, value) pairs -> expanded back;
# the round trip is the pin
# ported from bend3: bend-base's List helpers are inlined over bend's
# List (Nil/Con); strict -- the run and expand helpers folded into
# their callers' case trees, the shared code list a + binder over a
# List<&2, ..> of reusable pairs
import Base

law SamplePair:
  Data

def SamplePair(): Sigma<&2, &2, U32, _ => U32>

law bu:
  for b: Bool
  U32

def bu(b):
  match b:
    case False{}:
      0
    case True{}:
      1

law lconcat:
  for xs: List<&2, U32>
  for ys: List<&2, U32>
  List<&2, U32>

def lconcat(xs, ys):
  match xs:
    case Nil{}:
      ys
    case h <> t:
      h <> lconcat(t, ys)

law lrepeat:
  for  n: Nat
  for +v: U32
  List<&2, U32>

def lrepeat(n, v):
  match n:
    case 0n:
      Nil{}
    case 1n+p:
      v <> lrepeat(p, v)

law archive.reverse.go:
  for xs  : List<&2, SamplePair()>
  for acc : List<&2, SamplePair()>
  List<&2, SamplePair()>

def archive.reverse.go(xs, acc):
  match xs:
    case Nil{}:
      acc
    case h <> t:
      archive.reverse.go(t, h <> acc)

law archive.reverse:
  for xs: List<&2, SamplePair()>
  List<&2, SamplePair()>

def archive.reverse(xs):
  archive.reverse.go(xs, Nil{})

law llenp:
  for xs: List<&2, SamplePair()>
  U32

def llenp(xs):
  match xs:
    case Nil{}:
      0
    case h <> t:
      U32.add(1, llenp(t))

law archive.step:
  for +cur : U32
  for +h   : U32
  for n    : U32
  for acc  : List<&2, SamplePair()>
  for e    : Bool
  U32 & U32 & List<&2, SamplePair()>

def archive.step(cur, h, n, acc, e):
  match e:
    case False{}:
      (h, 1, (n, cur) <> acc)
    case True{}:
      (cur, U32.add(n, 1), acc)

law archive.scan:
  for xs: List<&2, U32>
  for st: U32 & U32 & List<&2, SamplePair()>
  List<&2, SamplePair()>

def archive.scan(xs, st):
  match xs:
    case Nil{}:
      (cur, n, acc) = st
      archive.reverse((n, cur) <> acc)
    case h0 <> t:
      (cur0, n, acc) = st
      +h = {h0 : U32}
      +cur = {cur0 : U32}
      archive.scan(t, archive.step(cur, h, n, acc, U32.is_eq(h, cur)))

# Diagnostic helpers scrutinize a Bool parameter, as required by Bend.
def p123.next_cur(+cur: U32, +h: U32, equal: Bool) -> U32:
  match equal:
    case False{}: h
    case True{}: cur

def p123.next_count(+n: U32, equal: Bool) -> U32:
  match equal:
    case False{}: 1
    case True{}: U32.add(n, 1)

def p123.next_acc(+cur: U32, +n: U32, acc: List<&2, SamplePair()>, equal: Bool) -> List<&2, SamplePair()>:
  match equal:
    case False{}: (n, cur) <> acc
    case True{}: acc

# Outer state shell removed; count/acc remain a single source-level pair.
law lanes.outer:
  for xs: List<&2, U32>
  for +cur: U32
  for state: U32 & List<&2, SamplePair()>
  List<&2, SamplePair()>

def lanes.outer(xs, cur, state):
  match xs:
    case Nil{}:
      (n, acc) = state
      archive.reverse((n, cur) <> acc)
    case h0 <> t:
      (n0, acc) = state
      +n = {n0 : U32}
      +h = {h0 : U32}
      +equal = {U32.is_eq(h, cur) : Bool}
      next_cur = p123.next_cur(cur, h, equal)
      next_n = p123.next_count(n, equal)
      next_acc = p123.next_acc(cur, n, acc, equal)
      lanes.outer(t, next_cur, (next_n, next_acc))

# All state fields cross the backedge as separate scalar/owner arguments.
law lanes.full:
  for xs: List<&2, U32>
  for +cur: U32
  for +n: U32
  for acc: List<&2, SamplePair()>
  List<&2, SamplePair()>

def lanes.full(xs, cur, n, acc):
  match xs:
    case Nil{}:
      archive.reverse((n, cur) <> acc)
    case h0 <> t:
      +h = {h0 : U32}
      +equal = {U32.is_eq(h, cur) : Bool}
      next_cur = p123.next_cur(cur, h, equal)
      next_n = p123.next_count(n, equal)
      next_acc = p123.next_acc(cur, n, acc, equal)
      lanes.full(t, next_cur, next_n, next_acc)

def verify.pairs(xs: List<&2, SamplePair()>) -> String:
  match xs:
    case Nil{}: ""
    case (n, v) <> rest:
      U32.show(n) ++ ":" ++ U32.show(v) ++ ";" ++ verify.pairs(rest)

def verify.words(xs: List<&2, U32>) -> String:
  match xs:
    case Nil{}: ""
    case h <> rest: U32.show(h) ++ ";" ++ verify.words(rest)

def verify.reference(xs: List<&2, U32>) -> List<&2, SamplePair()>:
  match xs:
    case Nil{}: Nil{}
    case h <> t: archive.scan(t, (h, 1, Nil{}))

def verify.outer(xs: List<&2, U32>) -> List<&2, SamplePair()>:
  match xs:
    case Nil{}: Nil{}
    case h <> t: lanes.outer(t, h, (1, Nil{}))

def verify.full(xs: List<&2, U32>) -> List<&2, SamplePair()>:
  match xs:
    case Nil{}: Nil{}
    case h <> t: lanes.full(t, h, 1, Nil{})

def verify.input(+xs: List<&2, U32>) -> IO(Unit):
  do IO<Unit>:
    Unit <- IO.print(verify.pairs(verify.reference(xs)))
    Unit <- IO.print(verify.pairs(verify.outer(xs)))
    Unit <- IO.print(verify.pairs(verify.full(xs)))
    IO.print(verify.words(xs))

def verify.state(+xs: List<&2, U32>, +cur: U32, +n: U32, +acc: List<&2, SamplePair()>) -> IO(Unit):
  do IO<Unit>:
    Unit <- IO.print(verify.pairs(archive.scan(xs, (cur, n, acc))))
    Unit <- IO.print(verify.pairs(lanes.outer(xs, cur, (n, acc))))
    Unit <- IO.print(verify.pairs(lanes.full(xs, cur, n, acc)))
    IO.print(verify.pairs(acc))

def main() -> IO(Unit):
  do IO<Unit>:
    Unit <- verify.input([])
    Unit <- verify.input([0])
    Unit <- verify.input([4294967295])
    Unit <- verify.input([7, 7, 7, 2, 9, 9])
    Unit <- verify.input([0, 1, 0, 1])
    Unit <- verify.input([4294967295, 4294967295, 0, 0, 4294967295])
    Unit <- verify.input([1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1])
    Unit <- verify.input([0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16])
    Unit <- verify.state([], 7, 0, [(3, 99), (4, 0)])
    Unit <- verify.state([], 4294967295, 4294967295, [(3, 99), (4, 0)])
    Unit <- verify.state([7], 7, 4294967295, [(3, 99), (4, 0)])
    Unit <- verify.state([7, 7], 7, 4294967295, [(3, 99), (4, 0)])
    Unit <- verify.state([0, 0, 4294967295], 4294967295, 4294967295, [(3, 99), (4, 0)])
    verify.state([1, 1, 2, 2, 1], 1, 4294967294, [(3, 99), (4, 0)])
