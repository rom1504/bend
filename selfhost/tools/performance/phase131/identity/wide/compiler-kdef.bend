import Base

type KTerm is Data:
  KTerm{+tag: String, +name: String, +id: U32, +quant: U32, +kids: List<&2, KTerm>, +removed: List<&2, String>, +originBegin: U32, +originEnd: U32}
  KLambda{+name: String, +id: U32, +quant: U32, +kids: List<&2,KTerm>, +removed: List<&2,String>, +originBegin: U32, +originEnd: U32, +quantityPresent: Bool}
  KLiteral{+kind: String, +number: U32, +text: String, +originBegin: U32, +originEnd: U32}

# Module: src/core/term.bend:30

type KDef is Data:
  KDef{+name: String, +kind: String, +arity: U32, +templates: U32, +typ: KTerm, +value: KTerm, +ctors: List<&2, KDef>, +native: Bool, +unsafe: Bool}
  KIndexLeaf{+hash: U32, +bucket: List<&2,KDef>}
  KIndexNode{+hash: U32, +mask: U32, +left: KDef, +right: KDef}

# Module: src/core/normalize.bend:367

@unsafe
def dn(
  +d: KDef,
) -> String:
  match d:
    case KDef{name, kind, arity, templates, typ, value, ctors, native, unsafe}:
      name
    case KIndexLeaf{hash, bucket}: ""
    case KIndexNode{hash, mask, left, right}: ""

# Module: src/core/term.bend:194

@unsafe
def da(
  +d: KDef,
) -> U32:
  match d:
    case KDef{name, kind, arity, templates, typ, value, ctors, native, unsafe}:
      arity
    case KIndexLeaf{hash, bucket}: hash
    case KIndexNode{hash, mask, left, right}: hash

# Module: src/core/term.bend:214

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


# Appended to exact selected KTerm/KDef/dn/da declarations by fixtures.py.

type P131Wide9 is Data:
  P131Wide9{+label: String, +other: String, +numbers: List<&2,U32>, +labels: List<&2,String>, +payload: KTerm, +serial: U32, +marker: Bool, +children: List<&2,KTerm>, +tail: String}

type P131Wide16 is Data:
  P131Wide16{+label: String, +a: U32, +b: U32, +c: U32, +d: U32, +e: U32, +f: U32, +g: U32, +h: U32, +i: U32, +j: U32, +k: U32, +l: U32, +m: U32, +n: U32, +o: U32}

@unsafe
def p131w_query(record: KDef, key: String) -> Bool:
  String.eq(dn(record),key)

@unsafe
def p131w_name(record: P131Wide9) -> String:
  match record:
    case P131Wide9{label,other,numbers,labels,payload,serial,marker,children,tail}: label

@unsafe
def p131w_query9(record: P131Wide9, key: String) -> Bool:
  String.eq(p131w_name(record),key)

@unsafe
def p131w_query16(record: P131Wide16, key: String) -> Bool:
  match record:
    case P131Wide16{label,a,b,c,d,e,f,g,h,i,j,k,l,m,n,o}: String.eq(label,key)

@unsafe
def p131w_escape(record: P131Wide9) -> List<&2,U32>:
  match record:
    case P131Wide9{label,other,numbers,labels,payload,serial,marker,children,tail}: numbers

@unsafe
def p131w_record(+label: String) -> KDef:
  KDef{label,"WideQuery",17,3,KLiteral{"String",0,"opaque type",0,0},
    KTerm{"App","opaque value",23,2,[],["retained"],2,9},[],False{},False{}}

@unsafe
def p131w_record9(label: String) -> P131Wide9:
  P131Wide9{label,"other",[3,5,7],["retained","λ"],
    KLiteral{"String",0,"opaque payload",0,0},99,True{},[],"tail"}

@unsafe
def p131w_record16(label: String) -> P131Wide16:
  P131Wide16{label,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15}

@unsafe
def p131w_line(value: Bool) -> IO(Unit):
  IO.print(U32.show(Bool.to_u32(value)))

@unsafe
def p131w_check() -> IO(Unit):
  +key : String = String.append("compiler","-name")
  +record : KDef = p131w_record(key)
  +other : P131Wide9 = p131w_record9(key)
  +wide : P131Wide16 = p131w_record16(key)
  do IO<Unit>:
    Unit <- p131w_line(p131w_query(record,key))
    Unit <- p131w_line(p131w_query(record,"different"))
    Unit <- p131w_line(p131w_query(record,"compiler-name"))
    Unit <- p131w_line(p131w_query(KIndexLeaf{7,[]},""))
    Unit <- IO.print(U32.show(da(record)))
    Unit <- p131w_line(p131w_query9(other,key))
    Unit <- p131w_line(p131w_query9(other,"different"))
    Unit <- IO.print(Nat.show(List.length(&2,U32,p131w_escape(other))))
    Unit <- p131w_line(p131w_query16(wide,key))
    Unit <- p131w_line(p131w_query16(wide,"different"))
    p131w_line(p131w_query(p131w_record("λ🌍"),"λ🌍"))

@unsafe
def p131w_once(+record: KDef, +other: P131Wide9, +key: String) -> U32:
  U32.add(Bool.to_u32(p131w_query(record,key)),Bool.to_u32(p131w_query(record,"different")))

@unsafe
def p131w_repeat(left: Nat, +record: KDef, +other: P131Wide9, +key: String, sum: U32) -> U32:
  match left:
    case 0n: sum
    case 1n+rest: p131w_repeat(rest,record,other,key,U32.add(sum,p131w_once(record,other,key)))

@unsafe
def p131w_timed(repeats: Nat) -> IO(Unit):
  +key : String = String.append("compiler","-name")
  +record : KDef = p131w_record(key)
  +other : P131Wide9 = p131w_record9(key)
  do IO<Unit>:
    Unit <- IO.print(U32.show(p131w_once(record,other,key)))
    before : Nat <- IO.now()
    Unit <- IO.print(U32.show(p131w_repeat(repeats,record,other,key,0)))
    after : Nat <- IO.now()
    IO.print(Nat.show(Nat.sub(after,before)))

@unsafe
def p131w_select(repeats: Nat) -> IO(Unit):
  match repeats:
    case 0n: p131w_check()
    case 1n+rest: p131w_timed(1n+rest)

@unsafe
def p131w_value(value: Maybe<&2,Nat>, fallback: Nat) -> Nat:
  match value:
    case None{}: fallback
    case Some{number}: number

@unsafe
def p131w_args(args: List<String>, fallback: Nat) -> Nat:
  match args:
    case Nil{}: fallback
    case head <> tail: p131w_args(tail,p131w_value(Nat.read(head),fallback))

@unsafe
def main() -> IO(Unit):
  do IO<Unit>:
    args : List<String> <- IO.args()
    p131w_select(p131w_args(args,0n))
