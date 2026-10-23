import Base

# Uses the structurally decreasing first String argument and the safe matched
# shape previously exercised in Phase89/equality/controls.bend. The accumulator
# follows the roots; a single ordered multi-match avoids v01's binder violation.
def p130s_order_go(a: String, b: String, order: Cmp) -> Cmp:
  match a b order:
    case SNil{} SNil{} result: result
    case SNil{} SCon{h,t} LT{}: LT{}
    case SNil{} SCon{h,t} EQ{}: LT{}
    case SNil{} SCon{h,t} GT{}: GT{}
    case SCon{h,t} SNil{} LT{}: LT{}
    case SCon{h,t} SNil{} EQ{}: GT{}
    case SCon{h,t} SNil{} GT{}: GT{}
    case SCon{ha,ta} SCon{hb,tb} LT{}: LT{}
    case SCon{ha,ta} SCon{hb,tb} GT{}: GT{}
    case SCon{ha,ta} SCon{hb,tb} EQ{}:
      p130s_order_go(ta,tb,U32.cmp(Char.to_u32(ha),Char.to_u32(hb)))

def p130s_order(a: String, b: String) -> Cmp:
  p130s_order_go(a,b,EQ{})

def p130s_query(a: String, b: String) -> Cmp:
  String.order(a,b)

type P130SCase is Data:
  P130SCase{left: String, right: String}

# Ordinary source workload, identical in both variants except p130s_query.
def p130s_code(c: Cmp) -> U32:
  match c:
    case LT{}: 1
    case EQ{}: 2
    case GT{}: 3

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
      p130s_digest(rest,U32.add(U32.mul(hash,16777619),p130s_code(p130s_query(left,right))))

def p130s_once(pairs: List<&2,P130SCase>) -> U32:
  p130s_digest(pairs,2166136261)

def p130s_loop(n: Nat, +pairs: List<&2,P130SCase>, sum: U32) -> U32:
  match n:
    case 0n: sum
    case 1n+rest: p130s_loop(rest,pairs,U32.add(sum,p130s_once(pairs)))

def p130s_control(size: U32) -> U32:
  p130s_once(p130s_pairs(p130s_prefix(U32.to_nat(size))))

def p130s_owned() -> U32:
  p130s_code(p130s_query(p130s_prefix(7n),p130s_prefix(8n)))

def p130s_retained() -> U32:
  +suffix : String = p130s_prefix(9n)
  +left : String = SCon{Char.from_u32(97),suffix}
  +right : String = SCon{Char.from_u32(98),suffix}
  U32.add(U32.mul(p130s_code(p130s_query(left,right)),100),
    U32.add(U32.mul(p130s_code(p130s_query(left,left)),10),
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
  +pairs = p130s_pairs(p130s_prefix(U32.to_nat(size)))
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
