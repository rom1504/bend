import Base

type KTerm is Data:
  KTerm{+tag: String, +name: String, +id: U32, +quant: U32, +kids: List<&2, KTerm>, +removed: List<&2, String>, +originBegin: U32, +originEnd: U32}
  KLambda{+name: String, +id: U32, +quant: U32, +kids: List<&2,KTerm>, +removed: List<&2,String>, +originBegin: U32, +originEnd: U32, +quantityPresent: Bool}
  KLiteral{+kind: String, +number: U32, +text: String, +originBegin: U32, +originEnd: U32}

def p88_string_eq_go(a: String, b: String, same: Bool) -> Bool:
  match a b same:
    case SNil{} SNil{} result: result
    case SNil{} SCon{h, t} result: False{}
    case SCon{h, t} SNil{} result: False{}
    case SCon{h1, t1} SCon{h2, t2} False{}: False{}
    case SCon{h1, t1} SCon{h2, t2} True{}:
      p88_string_eq_go(t1, t2, Char.is_eq(h1, h2))

def p98_eq_finish(same: Bool, left: String, right: String) -> Bool:
  same

def p88_string_eq(+a: String, +b: String) -> Bool:
  p98_eq_finish(p88_string_eq_go(a, b, True{}), a, b)

def p98_tag_eq_read(term: KTerm, key: String) -> Bool:
  match term:
    case KTerm{tag, name, id, quant, kids, removed, begin, end}:
      p88_string_eq_go(tag, key, True{})
    case KLambda{name, id, quant, kids, removed, begin, end, present}:
      p88_string_eq("Lam", key)
    case KLiteral{kind, number, text, begin, end}:
      p88_string_eq("Lit", key)

def p98_tag_eq_finish(same: Bool, term: KTerm, key: String) -> Bool:
  same

def p98_tag_eq(+term: KTerm, +key: String) -> Bool:
  p98_tag_eq_finish(p98_tag_eq_read(term, key), term, key)

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

# Retain both exact source constructors and wanted roots across every query.
# Constant Lam/Lit branches must remain correct for prefixes, misses, aliases
# and after earlier reads. Actual selected-reader code is checked separately.
def p131v_print(value: Bool) -> IO(Unit):
  IO.print(U32.show(Bool.to_u32(value)))

def main() -> IO(Unit):
  +wanted = String.append("L","am")
  +literal = String.append("L","it")
  +lam : KTerm = KLambda{"kept",1,2,[p131_term(wanted)],p131_labels(),3,4,True{}}
  +lit : KTerm = KLiteral{"String",0,"λ",5,6}
  do IO<Unit>:
    Unit <- p131v_print(p98_tag_eq(lam,wanted))
    Unit <- p131v_print(p98_tag_eq(lam,literal))
    Unit <- p131v_print(p98_tag_eq(lam,"L"))
    Unit <- p131v_print(p98_tag_eq(lam,"Lamp"))
    Unit <- p131v_print(p98_tag_eq(lam,""))
    Unit <- p131v_print(p98_tag_eq(lam,"λ"))
    Unit <- p131v_print(p98_tag_eq(lam,wanted))
    Unit <- p131v_print(p98_tag_eq(lit,literal))
    Unit <- p131v_print(p98_tag_eq(lit,wanted))
    Unit <- p131v_print(p98_tag_eq(lit,"Li"))
    Unit <- p131v_print(p98_tag_eq(lit,"Literal"))
    Unit <- p131v_print(p98_tag_eq(lit,""))
    Unit <- p131v_print(p98_tag_eq(lit,literal))
    Unit <- IO.print(wanted)
    IO.print(literal)
