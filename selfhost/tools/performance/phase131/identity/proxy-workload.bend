# Two complete persistent-index construction/update passes, followed by exact
# name lookups. The index algorithms and KDef representation are copied verbatim
# from the selected compiler. The names are actual declarations in that source.

@unsafe
def p131ip_record(+name: String, +version: U32) -> KDef:
  KDef{name,"IdentityProxy",version,U32.add(version,7),
    kt("Type",name,version,2,[]),kt("Body",name,version,1,[atom("Nested")]),[],False{},False{}}

@unsafe
def p131ip_build(names: List<&2,String>, index: KDef, +version: U32) -> KDef:
  match names:
    case Nil{}: index
    case Con{+name,rest}:
      p131ip_build(rest,index_set(index,p131ip_record(name,version),index_hash(name,2166136261),32),U32.inc(version))

@unsafe
def p131ip_digest(names: List<&2,String>, +index: KDef, +acc: U32) -> U32:
  match names:
    case Nil{}: acc
    case Con{+name,rest}:
      p131ip_digest(rest,index,U32.add(U32.mul(acc,16777619),da(index_find(index,name,index_hash(name,2166136261),32))))

@unsafe
def p131ip_once(+names: List<&2,String>) -> U32:
  +index = p131ip_build(names,p131ip_build(names,missing(),1),1001)
  p131ip_digest(names,index,2166136261)

def p131ip_take(n: Nat, names: List<&2,String>) -> List<&2,String>:
  match n names:
    case 0n _: []
    case 1n+rest Nil{}: []
    case 1n+rest Con{name,tail}: Con{name,p131ip_take(rest,tail)}

@unsafe
def p131ip_loop(n: Nat, +names: List<&2,String>, acc: U32) -> U32:
  match n:
    case 0n: acc
    case 1n+rest: p131ip_loop(rest,names,U32.add(acc,p131ip_once(names)))

@unsafe
def p131ip_check() -> IO(Unit):
  do IO<Unit>:
    Unit <- IO.print(U32.show(p131ip_once([])))
    Unit <- IO.print(U32.show(p131ip_once(p131ip_take(1n,p131ip_names()))))
    Unit <- IO.print(U32.show(p131ip_once(p131ip_take(16n,p131ip_names()))))
    Unit <- IO.print(U32.show(p131ip_once(p131ip_take(64n,p131ip_names()))))
    IO.print(U32.show(p131ip_once(p131ip_take(256n,p131ip_names()))))

def p131ip_nat(value: Maybe<&2,Nat>, fallback: Nat) -> Nat:
  match value:
    case None{}: fallback
    case Some{number}: number

@unsafe
def p131ip_execute(repetitions: Nat, warmups: Nat, size: Nat) -> IO(Unit):
  +names : List<&2,String> = p131ip_take(size,p131ip_names())
  do IO<Unit>:
    Unit <- IO.print(U32.show(p131ip_once(names)))
    Unit <- IO.print(U32.show(p131ip_loop(warmups,names,0)))
    t0 : Nat <- IO.now()
    Unit <- IO.print(U32.show(p131ip_loop(repetitions,names,0)))
    t1 : Nat <- IO.now()
    IO.print(Nat.show(Nat.sub(t1,t0)))

@unsafe
def p131ip_arguments(args: List<String>) -> IO(Unit):
  match args:
    case repetitions <> warmups <> size <> reserved <> Nil{}:
      p131ip_execute(p131ip_nat(Nat.read(repetitions),256n),
        p131ip_nat(Nat.read(warmups),4n),p131ip_nat(Nat.read(size),256n))
    case head <> rest: p131ip_arguments(rest)
    case Nil{}: p131ip_check()

@unsafe
def main() -> IO(Unit):
  do IO<Unit>:
    args : List<String> <- IO.args()
    p131ip_arguments(args)
