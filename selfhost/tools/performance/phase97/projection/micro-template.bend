@unsafe
def p97.name(n: Nat) -> String:
  "module:worker~" ++ Nat.show(n)

@unsafe
def p97.row(+n: Nat) -> KDef:
  KDef{p97.name(n), "Def", U32.inc(U32.from_nat(n)), 7,
    KTerm{"ADT", "U32", 0, 0, Nil{}, Nil{}, 3, 9},
    KLiteral{"U32", U32.from_nat(n), "", 11, 19}, Nil{}, True{}, False{}}

@unsafe
def p97.rows(+n: Nat) -> List<&2,KDef>:
  match n:
    case 0n: Nil{}
    case 1n+p: Con{p97.row(p), p97.rows(p)}

@unsafe
def p97.query_last(+size: Nat, mode: Nat) -> Nat:
  match mode:
    case 0n: size
    case 1n+rest: 0n

@unsafe
def p97.query_more(+size: Nat, mode: Nat) -> Nat:
  match mode:
    case 0n: Nat.div(size, 2n)
    case 1n+rest: p97.query_last(size, rest)

@unsafe
def p97.query(+size: Nat, mode: Nat) -> Nat:
  match mode:
    case 0n: Nat.sub(size, 1n)
    case 1n+rest: p97.query_more(size, rest)

@unsafe
def p97.token(d: KDef) -> U32:
  match d:
    case KDef{name, kind, arity, templates, typ, value, ctors, native, unsafe}: arity
    case KIndexLeaf{hash, bucket}: 4294967294
    case KIndexNode{hash, mask, left, right}: 4294967295

@unsafe
def p97.loop(n: Nat, +rows: List<&2,KDef>, +key: String, +expected: U32, acc: U32) -> U32:
  match n:
    case 0n: acc
    case 1n+p:
      p97.loop(p, rows, key, expected, U32.add(acc, Bool.to_u32(U32.is_eq(p97.token(f_find(key, rows)), expected))))

@unsafe
def p97.expected(+size: Nat, +index: Nat) -> U32:
  p97.expected_ready(index, Nat.is_lt(index, size))

@unsafe
def p97.expected_ready(index: Nat, live: Bool) -> U32:
  match live:
    case True{}: U32.inc(U32.from_nat(index))
    case False{}: 0

@unsafe
def p97.nat(value: Maybe<&2,Nat>) -> Nat:
  match value:
    case None{}: 1n
    case Some{n}: n

@unsafe
def p97.options(args: List<String>) -> (Nat & Nat) & Nat:
  match args:
    case reps <> size <> mode <> Nil{}:
      ((p97.nat(Nat.read(reps)), p97.nat(Nat.read(size))), p97.nat(Nat.read(mode)))
    case head <> rest: p97.options(rest)
    case Nil{}: ((10n, 128n), 0n)

@unsafe
def p97.execute(reps: Nat, +rows: List<&2,KDef>, +key: String, +expected: U32) -> IO(Unit):
  do IO<Unit>:
    Unit <- IO.print(p97.def(f_find(key, rows)))
    t0 : Nat <- IO.now()
    Unit <- IO.print(U32.show(p97.loop(reps, rows, key, expected, 0)))
    t1 : Nat <- IO.now()
    Unit <- IO.print(Nat.show(Nat.sub(t1, t0)))
    Unit <- IO.print(p97.def(f_find(key, rows)))
    IO.print(p97.defs(rows))

@unsafe
def p97.sized(reps: Nat, +size: Nat, mode: Nat) -> IO(Unit):
  +index : Nat = p97.query(size, mode)
  p97.execute(reps, p97.rows(size), p97.name(index), p97.expected(size, index))

@unsafe
def p97.run(options: (Nat & Nat) & Nat) -> IO(Unit):
  (sizes, mode) = options
  (reps, size) = sizes
  p97.sized(reps, size, mode)

@unsafe
def main() -> IO(Unit):
  do IO<Unit>:
    args : List<String> <- IO.args()
    p97.run(p97.options(args))
