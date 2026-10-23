# Ordinary transfer: a three-constructor user record with unrelated opaque
# List instantiations. Only its name is observed by the scalar query.
type P131Packet is Data:
  P131Empty{}
  P131Text{label: String, numbers: List<&2,U32>, labels: List<&2,String>, serial: U32}
  P131Pair{label: String, other: String, children: List<&2,P131Packet>}

def p131_packet_read(packet: P131Packet, key: String) -> Bool:
  match packet:
    case P131Empty{}: False{}
    case P131Text{label,numbers,labels,serial}: p88_string_eq_go(label,key,True{})
    case P131Pair{label,other,children}: p88_string_eq_go(label,key,True{})

def p131_packet_finish(same: Bool, packet: P131Packet, key: String) -> Bool:
  same

def p131_packet_query(+packet: P131Packet, +key: String) -> Bool:
  p131_packet_finish(p131_packet_read(packet,key),packet,key)

def p131_numbers() -> List<&2,U32>:
  [3,5,7]

def p131_labels() -> List<&2,String>:
  ["kept","λ"]

def p131_packet(+label: String) -> P131Packet:
  P131Text{label,p131_numbers(),p131_labels(),17}

def p131_term(+tag: String) -> KTerm:
  KTerm{tag,"retained name",37,2,[KLiteral{"String",0,"opaque child λ",0,0}],p131_labels(),3,19}

def p131_number_count(xs: List<&2,U32>, count: U32) -> U32:
  match xs:
    case Nil{}: count
    case Con{head,tail}: p131_number_count(tail,U32.inc(count))

# Admission-negative but executable ordinary controls. These must use fallback:
# matching an opaque payload and returning an owned payload, respectively.
def p131_opaque_count(packet: P131Packet) -> U32:
  match packet:
    case P131Empty{}: 0
    case P131Text{label,numbers,labels,serial}: p131_number_count(numbers,0)
    case P131Pair{label,other,children}: 0

def p131_opaque_escape(packet: P131Packet) -> List<&2,U32>:
  match packet:
    case P131Empty{}: []
    case P131Text{label,numbers,labels,serial}: numbers
    case P131Pair{label,other,children}: []

def p131_line(value: Bool) -> IO(Unit):
  IO.print(U32.show(Bool.to_u32(value)))

def p131_check() -> IO(Unit):
  +key = String.append("V","ar")
  +term = p131_term(key)
  +packet = p131_packet(key)
  do IO<Unit>:
    Unit <- p131_line(p98_tag_eq(term,key))
    Unit <- p131_line(p98_tag_eq(term,"Mat"))
    Unit <- p131_line(p98_tag_eq(term,"Var"))
    Unit <- p131_line(p98_tag_eq(KLambda{"x",1,1,[],[],0,0,True{}},"Lam"))
    Unit <- p131_line(p98_tag_eq(KLiteral{"String",0,"λ",0,0},"Lit"))
    Unit <- p131_line(p98_tag_eq(p131_term("λ"),"λ"))
    Unit <- p131_line(p131_packet_query(packet,key))
    Unit <- p131_line(p131_packet_query(packet,"Mat"))
    Unit <- p131_line(p131_packet_query(P131Empty{},""))
    Unit <- p131_line(p131_packet_query(P131Pair{"λ","other",[]},"λ"))
    Unit <- IO.print(U32.show(p131_opaque_count(packet)))
    IO.print(U32.show(p131_number_count(p131_opaque_escape(packet),0)))

def p131_repeat(left: Nat, +term: KTerm, +packet: P131Packet, +key: String, sum: U32) -> U32:
  match left:
    case 0n: sum
    case 1n+rest: p131_repeat(rest,term,packet,key,U32.add(sum,p131_once(term,packet,key)))

def p131_timed(repeats: Nat) -> IO(Unit):
  +key = String.append("V","ar")
  +term = p131_term(key)
  +packet = p131_packet(key)
  do IO<Unit>:
    Unit <- IO.print(U32.show(p131_once(term,packet,key)))
    t0 : Nat <- IO.now()
    Unit <- IO.print(U32.show(p131_repeat(repeats,term,packet,key,0)))
    t1 : Nat <- IO.now()
    IO.print(Nat.show(Nat.sub(t1,t0)))

def p131_select(repeats: Nat) -> IO(Unit):
  match repeats:
    case 0n: p131_check()
    case 1n+rest: p131_timed(1n+rest)

def p131_seed_value(value: Maybe<&2,Nat>, fallback: Nat) -> Nat:
  match value:
    case None{}: fallback
    case Some{number}: number

def p131_seed(args: List<String>, fallback: Nat) -> Nat:
  match args:
    case Nil{}: fallback
    case head <> tail: p131_seed(tail,p131_seed_value(Nat.read(head),fallback))

def main() -> IO(Unit):
  do IO<Unit>:
    args : List<String> <- IO.args()
    p131_select(p131_seed(args,0n))
