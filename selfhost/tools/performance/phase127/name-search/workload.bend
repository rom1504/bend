# Baseline workload only. The five compiler functions above are unchanged.

@unsafe
def p127ns_at(names: List<&2,String>, +position: U32) -> String:
  match names:
    case Nil{}: "_outside_retained_names"
    case Con{head,tail}: p127ns_at_next(head,tail,position,U32.is_eq(position,0))

@unsafe
def p127ns_at_next(head: String, tail: List<&2,String>, position: U32, at_zero: Bool) -> String:
  match at_zero:
    case True{}: head
    case False{}: p127ns_at(tail,U32.sub(position,1))

def p127ns_name(+index: U32) -> String:
  p127ns_at(p127ns_corpus(), U32.mod(index, 16)) ++ "." ++ U32.show(index)

def p127ns_build(left: Nat, +index: U32) -> List<&2,String>:
  match left:
    case 0n: ["λ.compiler.α","路径.查找"]
    case 1n+rest: Con{p127ns_name(index),p127ns_build(rest,U32.inc(index))}

def p127ns_queries(+names: List<&2,String>, +size: U32) -> List<&2,String>:
  [p127ns_at(names,0), p127ns_name(0), p127ns_at(names,U32.div(size,2)),
   p127ns_name(U32.sub(size,1)), p127ns_name(size), "p113pl",
   p127ns_name(size) ++ ".absent", "λ.compiler.α", "λ.compiler.β",
   "路径.查找", p127ns_at(names,0), "_absent", p127ns_name(7), p127ns_name(63)]

def p127ns_digest(queries: List<&2,String>, +names: List<&2,String>, hash: U32) -> U32:
  match queries:
    case Nil{}: hash
    case Con{query,rest}:
      p127ns_digest(rest,names,U32.add(U32.mul(hash,16777619),Bool.to_u32(has_name(names,query))))

def p127ns_once(+names: List<&2,String>, queries: List<&2,String>) -> U32:
  p127ns_digest(queries,names,2166136261)

def p127ns_loop(repetitions: Nat, +names: List<&2,String>, +queries: List<&2,String>, sum: U32) -> U32:
  match repetitions:
    case 0n: sum
    case 1n+rest:
      p127ns_loop(rest,names,queries,U32.add(sum,p127ns_once(names,queries)))

def p127ns_control(+size: U32) -> U32:
  +names = p127ns_build(U32.to_nat(size),0)
  p127ns_once(names,p127ns_queries(names,size))

def p127ns_check() -> IO(Unit):
  do IO<Unit>:
    Unit <- IO.print(U32.show(p127ns_control(0)))
    Unit <- IO.print(U32.show(p127ns_control(1)))
    Unit <- IO.print(U32.show(p127ns_control(17)))
    IO.print(U32.show(p127ns_control(128)))

def p127ns_nat(value: Maybe<&2,Nat>, fallback: Nat) -> Nat:
  match value:
    case None{}: fallback
    case Some{number}: number

def p127ns_word(value: Maybe<&2,U32>, fallback: U32) -> U32:
  match value:
    case None{}: fallback
    case Some{number}: number

def p127ns_execute(repetitions: Nat, warmups: Nat, +size: U32) -> IO(Unit):
  +names = p127ns_build(U32.to_nat(size),0)
  +queries = p127ns_queries(names,size)
  do IO<Unit>:
    Unit <- IO.print(U32.show(p127ns_once(names,queries)))
    Unit <- IO.print(U32.show(p127ns_loop(warmups,names,queries,0)))
    t0 : Nat <- IO.now()
    Unit <- IO.print(U32.show(p127ns_loop(repetitions,names,queries,0)))
    t1 : Nat <- IO.now()
    IO.print(Nat.show(Nat.sub(t1,t0)))

# Four final arguments match the retained harness shape:
# repetitions warmups list_size reserved. Reserved is presently ignored.
# With no such argument group, the exact four-line ordinary control runs.
def p127ns_arguments(args: List<String>) -> IO(Unit):
  match args:
    case repetitions <> warmups <> size <> reserved <> Nil{}:
      p127ns_execute(p127ns_nat(Nat.read(repetitions),64n),
        p127ns_nat(Nat.read(warmups),2n),p127ns_word(U32.read(size),256))
    case head <> rest: p127ns_arguments(rest)
    case Nil{}: p127ns_check()

def main() -> IO(Unit):
  do IO<Unit>:
    args : List<String> <- IO.args()
    p127ns_arguments(args)
