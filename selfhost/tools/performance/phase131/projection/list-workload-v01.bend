import Base

# Unrelated retained-root product: lexicographic U32-list comparison. Both
# compilers receive these same definitions, including the reconstruction loop.
type P131List is Data:
  P131Nil{}
  P131Cons{head: U32, tail: P131List}

def p131l_cmp_rec(ha: U32, hb: U32, rr: (P131List & P131List) & Cmp) ->
  (P131List & P131List) & Cmp:
  ((ta,tb),c) = rr
  ((P131Cons{ha,ta},P131Cons{hb,tb}),c)

law p131l_cmp:
  for a: P131List
  for b: P131List
  (P131List & P131List) & Cmp

def p131l_cmp_fin(ha: U32, ta: P131List, hb: U32, tb: P131List, c: Cmp) ->
  (P131List & P131List) & Cmp:
  match c:
    case LT{}: ((P131Cons{ha,ta},P131Cons{hb,tb}),LT{})
    case EQ{}: p131l_cmp_rec(ha,hb,p131l_cmp(ta,tb))
    case GT{}: ((P131Cons{ha,ta},P131Cons{hb,tb}),GT{})

def p131l_cmp(a,b):
  match a b:
    case P131Nil{} P131Nil{}: ((P131Nil{},P131Nil{}),EQ{})
    case P131Nil{} P131Cons{h,t}: ((P131Nil{},P131Cons{h,t}),LT{})
    case P131Cons{h,t} P131Nil{}: ((P131Cons{h,t},P131Nil{}),GT{})
    case P131Cons{+ha,ta} P131Cons{+hb,tb}:
      p131l_cmp_fin(ha,ta,hb,tb,U32.cmp(ha,hb))

def p131l_query(a: P131List, b: P131List) -> Cmp:
  Pair.snd(P131List & P131List,Cmp,p131l_cmp(a,b))

def p131l_code(c: Cmp) -> U32:
  match c:
    case LT{}: 1
    case EQ{}: 2
    case GT{}: 3

def p131l_prefix(n: Nat) -> P131List:
  match n:
    case 0n: P131Nil{}
    case 1n+rest: P131Cons{7,p131l_prefix(rest)}

def p131l_append(xs: P131List, value: U32) -> P131List:
  match xs:
    case P131Nil{}: P131Cons{value,P131Nil{}}
    case P131Cons{h,t}: P131Cons{h,p131l_append(t,value)}

type P131LCase is Data:
  P131LCase{left: P131List, right: P131List}

def p131l_pairs(+p: P131List) -> List<&2,P131LCase>:
  [P131LCase{p,p},P131LCase{p,p131l_append(p,1)},P131LCase{p131l_append(p,1),p},
   P131LCase{p131l_append(p,2),p131l_append(p,9)},P131LCase{p131l_append(p,9),p131l_append(p,2)},
   P131LCase{p131l_append(p,5),p131l_append(p,5)},P131LCase{p,P131Cons{0,p}},P131LCase{P131Cons{0,p},p},
   P131LCase{P131Cons{0,p},P131Cons{1,p}},P131LCase{p131l_append(p,57344),p131l_append(p,65536)}]

def p131l_digest(pairs: List<&2,P131LCase>, hash: U32) -> U32:
  match pairs:
    case Nil{}: hash
    case Con{P131LCase{a,b},rest}:
      p131l_digest(rest,U32.add(U32.mul(hash,16777619),p131l_code(p131l_query(a,b))))

def p131l_once(pairs: List<&2,P131LCase>) -> U32:
  p131l_digest(pairs,2166136261)

def p131l_loop(n: Nat, +pairs: List<&2,P131LCase>, sum: U32) -> U32:
  match n:
    case 0n: sum
    case 1n+rest: p131l_loop(rest,pairs,U32.add(sum,p131l_once(pairs)))

def p131l_length(xs: P131List, n: U32) -> U32:
  match xs:
    case P131Nil{}: n
    case P131Cons{h,t}: p131l_length(t,U32.inc(n))

def p131l_retained() -> U32:
  +tail = p131l_prefix(9n)
  +a = P131Cons{1,tail}
  +b = P131Cons{2,tail}
  U32.add(U32.mul(p131l_code(p131l_query(a,b)),100),
    U32.add(U32.mul(p131l_code(p131l_query(a,a)),10),p131l_length(tail,0)))

def p131l_check() -> IO(Unit):
  do IO<Unit>:
    Unit <- IO.print(U32.show(p131l_once(p131l_pairs(p131l_prefix(0n)))))
    Unit <- IO.print(U32.show(p131l_once(p131l_pairs(p131l_prefix(1n)))))
    Unit <- IO.print(U32.show(p131l_once(p131l_pairs(p131l_prefix(17n)))))
    Unit <- IO.print(U32.show(p131l_once(p131l_pairs(p131l_prefix(128n)))))
    Unit <- IO.print(U32.show(p131l_code(p131l_query(p131l_prefix(7n),p131l_prefix(8n)))))
    IO.print(U32.show(p131l_retained()))

def p131l_nat(value: Maybe<&2,Nat>, fallback: Nat) -> Nat:
  match value:
    case None{}: fallback
    case Some{number}: number

def p131l_execute(repetitions: Nat, warmups: Nat, size: Nat) -> IO(Unit):
  +pairs = p131l_pairs(p131l_prefix(size))
  do IO<Unit>:
    Unit <- IO.print(U32.show(p131l_once(pairs)))
    Unit <- IO.print(U32.show(p131l_loop(warmups,pairs,0)))
    t0 : Nat <- IO.now()
    Unit <- IO.print(U32.show(p131l_loop(repetitions,pairs,0)))
    t1 : Nat <- IO.now()
    IO.print(Nat.show(Nat.sub(t1,t0)))

def p131l_arguments(args: List<String>) -> IO(Unit):
  match args:
    case repetitions <> warmups <> size <> reserved <> Nil{}:
      p131l_execute(p131l_nat(Nat.read(repetitions),4096n),
        p131l_nat(Nat.read(warmups),16n),p131l_nat(Nat.read(size),64n))
    case head <> rest: p131l_arguments(rest)
    case Nil{}: p131l_check()

def main() -> IO(Unit):
  do IO<Unit>:
    args : List<String> <- IO.args()
    p131l_arguments(args)
