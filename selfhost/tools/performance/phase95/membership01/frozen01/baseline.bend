import Base
import ./extracted.bend as M

@unsafe
def p95.name(n: Nat) -> String:
  "module:worker~" ++ Nat.show(n)

@unsafe
def p95.rows(n: Nat) -> List<&2, String>:
  match n:
    case 0n: Nil{}
    case 1n+p: Con{p95.name(p), p95.rows(p)}

@unsafe
def p95.query_last(+size: Nat, mode: Nat) -> String:
  match mode:
    case 0n: p95.name(size)
    case 1n+rest: p95.name(0n)

@unsafe
def p95.query_more(+size: Nat, mode: Nat) -> String:
  match mode:
    case 0n: p95.name(Nat.div(size, 2n))
    case 1n+rest: p95.query_last(size, rest)

@unsafe
def p95.query(+size: Nat, mode: Nat) -> String:
  match mode:
    case 0n: p95.name(Nat.sub(size, 1n))
    case 1n+rest: p95.query_more(size, rest)

@unsafe
def p95.score(value: Bool) -> U32:
  match value:
    case False{}: 53
    case True{}: 97

@unsafe
def p95.kernel(+rows: List<&2, String>, +key: String) -> Bool:
  M.nb_contains(rows, key)

@unsafe
def p95.loop(n: Nat, +rows: List<&2, String>, +key: String, acc: U32) -> U32:
  match n:
    case 0n: acc
    case 1n+p:
      p95.loop(p, rows, key, U32.add(acc, p95.score(p95.kernel(rows, key))))

@unsafe
def p95.nat(value: Maybe<&2, Nat>) -> Nat:
  match value:
    case None{}: 1n
    case Some{n}: n

@unsafe
def p95.options(args: List<String>) -> (Nat & Nat) & Nat:
  match args:
    case reps <> size <> mode <> Nil{}:
      ((p95.nat(Nat.read(reps)), p95.nat(Nat.read(size))), p95.nat(Nat.read(mode)))
    case head <> rest: p95.options(rest)
    case Nil{}: ((10n, 128n), 0n)

@unsafe
def p95.execute(reps: Nat, +rows: List<&2, String>, +key: String) -> IO(Unit):
  do IO<Unit>:
    Unit <- IO.print(U32.show(p95.score(p95.kernel(rows, key))))
    t0 : Nat <- IO.now()
    Unit <- IO.print(U32.show(p95.loop(reps, rows, key, 0)))
    t1 : Nat <- IO.now()
    IO.print(Nat.show(Nat.sub(t1, t0)))

@unsafe
def p95.run(options: (Nat & Nat) & Nat) -> IO(Unit):
  (sizes, mode) = options
  (reps, +size) = sizes
  p95.execute(reps, p95.rows(size), p95.query(size, mode))

@unsafe
def main() -> IO(Unit):
  do IO<Unit>:
    args : List<String> <- IO.args()
    p95.run(p95.options(args))
