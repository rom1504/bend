# Ordinary-source ownership controls. Runtime representations are observed,
# never fabricated: helpers may dynamically admit or conservatively refuse.
import Base

def ledger.join(xs: List<&2, U32>, ys: List<&2, U32>) -> List<&2, U32>:
  match xs:
    case Nil{}: ys
    case h <> t: h <> ledger.join(t, ys)

def ledger.changed(xs: List<&2, U32>, ys: List<&2, U32>) -> List<&2, U32>:
  match xs:
    case Nil{}: ys
    case h <> t: U32.add(h, 1) <> ledger.changed(t, ys)

def ledger.make(n: Nat, +seed: U32, acc: List<&2, U32>) -> List<&2, U32>:
  match n:
    case 0n: acc
    case 1n+p: ledger.make(p, U32.add(seed, 1), seed <> acc)

def ledger.show(xs: List<&2, U32>) -> String:
  match xs:
    case Nil{}: ""
    case h <> t: U32.show(h) ++ ";" ++ ledger.show(t)

def ledger.length(xs: List<&2, U32>, n: U32) -> U32:
  match xs:
    case Nil{}: n
    case h <> t: ledger.length(t, U32.add(n, 1))

def ledger.digest(xs: List<&2, U32>, value: U32) -> U32:
  match xs:
    case Nil{}: value
    case h <> t: ledger.digest(t, U32.add(U32.mul(value, 65599), h))

def ledger.summary(+xs: List<&2, U32>) -> String:
  U32.show(ledger.length(xs, 0)) ++ ":" ++ U32.show(ledger.digest(xs, 2166136261))

def ledger.shared(+xs: List<&2, U32>, +ys: List<&2, U32>) -> IO(Unit):
  do IO<Unit>:
    Unit <- IO.print(ledger.show(ledger.join(xs, ys)))
    Unit <- IO.print(ledger.show(xs))
    IO.print(ledger.show(ys))

def ledger.interior(+tail: List<&2, U32>) -> IO(Unit):
  do IO<Unit>:
    Unit <- IO.print(ledger.show(ledger.join(99 <> tail, [111, 222])))
    IO.print(ledger.show(tail))

def ledger.overlap(+tail: List<&2, U32>) -> IO(Unit):
  do IO<Unit>:
    Unit <- IO.print(ledger.show(ledger.join(99 <> tail, tail)))
    IO.print(ledger.show(tail))

def label.join(xs: List<&2, String>, ys: List<&2, String>) -> List<&2, String>:
  match xs:
    case Nil{}: ys
    case h <> t: h <> label.join(t, ys)

def label.repeat(n: Nat, +word: String, acc: List<&2, String>) -> List<&2, String>:
  match n:
    case 0n: acc
    case 1n+p: label.repeat(p, word, word <> acc)

def label.show(xs: List<&2, String>) -> String:
  match xs:
    case Nil{}: ""
    case h <> t: "[" ++ h ++ "]" ++ label.show(t)

def label.alias(+word: String) -> IO(Unit):
  do IO<Unit>:
    Unit <- IO.print(label.show(label.join(label.repeat(3n, word, Nil{}), ["x", word])))
    IO.print(word)

def main() -> IO(Unit):
  do IO<Unit>:
    Unit <- ledger.shared(ledger.make(17n, 8, Nil{}), [4294967295, 0, 17])
    Unit <- ledger.interior(ledger.make(17n, 3, Nil{}))
    Unit <- ledger.overlap(ledger.make(17n, 3, Nil{}))
    Unit <- IO.print(ledger.show(ledger.join([2, 5, 9], [11, 13])))
    Unit <- ledger.shared([2, 5, 9], [11, 13])
    Unit <- label.alias("seed:" ++ U32.show(12345))
    Unit <- ledger.shared([], [0, 4294967295])
    Unit <- ledger.shared([], [])
    Unit <- IO.print(ledger.show(ledger.changed([4294967295, 2], [8])))
    IO.print(ledger.summary(ledger.join(ledger.make(4096n, 0, Nil{}), [4294967295, 17])))
