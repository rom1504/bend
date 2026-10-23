import Base

# Scalar-code discriminator. Roots stay structurally first and all state is
# nonowning. Two primitive predicates replace U32.cmp's enum transport.
def p130u_finish(same: Bool, less: Bool, ending: U32) -> U32:
  match same less:
    case True{} _: ending
    case False{} True{}: 1
    case False{} False{}: 3

def p130u_go(a: String, b: String, same: Bool, less: Bool) -> U32:
  match a b same:
    case SNil{} SNil{} equal:
      p130u_finish(equal,less,2)
    case SNil{} SCon{head,tail} equal:
      p130u_finish(equal,less,1)
    case SCon{head,tail} SNil{} equal:
      p130u_finish(equal,less,3)
    case SCon{ha,ta} SCon{hb,tb} False{}:
      p130u_finish(False{},less,2)
    case SCon{+ha,ta} SCon{+hb,tb} True{}:
      p130u_go(ta,tb,U32.is_eq(Char.to_u32(ha),Char.to_u32(hb)),
        U32.is_lt(Char.to_u32(ha),Char.to_u32(hb)))

def p130u_order(a: String, b: String) -> U32:
  p130u_go(a,b,True{},False{})

type P130SCase is Data:
  P130SCase{left: String, right: String}

# Ordinary source workload, identical in both variants except p130s_query.
def p130s_code(c: Cmp) -> U32:
  match c:
    case LT{}: 1
    case EQ{}: 2
    case GT{}: 3

def p130s_query(a: String, b: String) -> U32:
  p130u_order(a,b)

def p130s_prefix(n: Nat) -> String:
  match n:
    case 0n: ""
    case 1n+rest: SCon{Char.from_u32(955),p130s_prefix(rest)}

def p130s_pairs(+prefix: String) -> List<&2,P130SCase>:
  [P130SCase{prefix,prefix},P130SCase{prefix,prefix ++ "a"},P130SCase{prefix ++ "a",prefix},
   P130SCase{prefix ++ "λ",prefix ++ "中"},P130SCase{prefix ++ "🙂",prefix ++ "λ"},
   P130SCase{prefix ++ "same",prefix ++ "same"},P130SCase{prefix,"!" ++ prefix},P130SCase{"!" ++ prefix,prefix},
   P130SCase{SCon{Char.from_u32(0),prefix},SCon{Char.from_u32(1),prefix}},
   P130SCase{prefix ++ SCon{Char.from_u32(57344),SNil{}},prefix ++ SCon{Char.from_u32(65536),SNil{}}}]

def p130s_digest(pairs: List<&2,P130SCase>, hash: U32) -> U32:
  match pairs:
    case Nil{}: hash
    case Con{P130SCase{left,right},rest}:
      p130s_digest(rest,U32.add(U32.mul(hash,16777619),p130s_query(left,right)))

def p130s_once(pairs: List<&2,P130SCase>) -> U32:
  p130s_digest(pairs,2166136261)

def p130s_loop(n: Nat, +pairs: List<&2,P130SCase>, sum: U32) -> U32:
  match n:
    case 0n: sum
    case 1n+rest: p130s_loop(rest,pairs,U32.add(sum,p130s_once(pairs)))

def p130s_control(size: U32) -> U32:
  p130s_once(p130s_pairs(p130s_prefix(U32.to_nat(size))))

def p130s_owned() -> U32:
  p130s_query(p130s_prefix(7n),p130s_prefix(8n))

def p130s_retained() -> U32:
  +suffix : String = p130s_prefix(9n)
  +left : String = SCon{Char.from_u32(97),suffix}
  +right : String = SCon{Char.from_u32(98),suffix}
  U32.add(U32.mul(p130s_query(left,right),100),
    U32.add(U32.mul(p130s_query(left,left),10),
      U32.from_nat(String.length(suffix))))

def p130s_check() -> IO(Unit):
  do IO<Unit>:
    Unit <- IO.print(U32.show(p130s_control(0)))
    Unit <- IO.print(U32.show(p130s_control(1)))
    Unit <- IO.print(U32.show(p130s_control(17)))
    Unit <- IO.print(U32.show(p130s_control(128)))
    Unit <- IO.print(U32.show(p130s_owned()))
    IO.print(U32.show(p130s_retained()))

def p130s_nat(value: Maybe<&2,Nat>, fallback: Nat) -> Nat:
  match value:
    case None{}: fallback
    case Some{number}: number

def p130s_word(value: Maybe<&2,U32>, fallback: U32) -> U32:
  match value:
    case None{}: fallback
    case Some{number}: number

def p130s_execute(repetitions: Nat, warmups: Nat, size: U32) -> IO(Unit):
  +pairs : List<&2,P130SCase> = p130s_pairs(p130s_prefix(U32.to_nat(size)))
  do IO<Unit>:
    Unit <- IO.print(U32.show(p130s_once(pairs)))
    Unit <- IO.print(U32.show(p130s_loop(warmups,pairs,0)))
    t0 : Nat <- IO.now()
    Unit <- IO.print(U32.show(p130s_loop(repetitions,pairs,0)))
    t1 : Nat <- IO.now()
    IO.print(Nat.show(Nat.sub(t1,t0)))

def p130s_arguments(args: List<String>) -> IO(Unit):
  match args:
    case repetitions <> warmups <> size <> reserved <> Nil{}:
      p130s_execute(p130s_nat(Nat.read(repetitions),4096n),
        p130s_nat(Nat.read(warmups),16n),p130s_word(U32.read(size),64))
    case head <> rest: p130s_arguments(rest)
    case Nil{}: p130s_check()

def main() -> IO(Unit):
  do IO<Unit>:
    args : List<String> <- IO.args()
    p130s_arguments(args)
