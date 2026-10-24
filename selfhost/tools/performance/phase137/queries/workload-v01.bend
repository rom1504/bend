# Fixed construction and independently specified outputs; no workload recognizer.
type P137QRecord is Data:
  P137QRecord{+label: String, +other: String, +numbers: List<&2,U32>, +labels: List<&2,String>, +payload: KTerm, +serial: U32, +marker: Bool, +children: List<&2,KTerm>, +tail: String}

@unsafe
def p137q_label(record: P137QRecord) -> String:
  match record:
    case P137QRecord{label,other,numbers,labels,payload,serial,marker,children,tail}: label

@unsafe
def p137q_record_query(record: P137QRecord, key: String) -> Bool:
  p88_string_eq(p137q_label(record),key)

@unsafe
def p137q_record_numbers(record: P137QRecord) -> List<&2,U32>:
  match record:
    case P137QRecord{label,other,numbers,labels,payload,serial,marker,children,tail}: numbers

@unsafe
def p137q_record(+key: String) -> P137QRecord:
  P137QRecord{key,"kept",[3,5,7],["retained","λ🌍"],KLiteral{"String",0,"opaque",0,0},99,True{},[],"tail"}

@unsafe
def p137q_node(name: String, kind: String, arity: U32, owned: Bool, children: List<&2,KDef>) -> KDef:
  KDef{name,kind,arity,3,KLiteral{"String",0,"opaque type",0,0},
    KTerm{"App","opaque value",23,2,[],["retained","λ🌍"],2,9},children,owned,False{}}

@unsafe
def p137q_value(record: KDef) -> String:
  match record:
    case KDef{name,kind,arity,templates,typ,value,ctors,native,unsafe}: p137q_term_value(value)
    case KIndexLeaf{hash,bucket}: "index"
    case KIndexNode{hash,mask,left,right}: "index"

@unsafe
def p137q_term_value(value: KTerm) -> String:
  match value:
    case KTerm{tag,name,id,quant,kids,removed,begin,end}: name
    case KLambda{name,id,quant,kids,removed,begin,end,present}: name
    case KLiteral{kind,number,text,begin,end}: text

@unsafe
def p137q_rows(names: List<&2,String>, +arity: U32) -> List<&2,KDef>:
  match names:
    case Nil{}: [p137q_node("PayloadOwner","ADT",71,True{},[p137q_node("Payload","Ctr",0,False{},[])])]
    case Con{name,rest}: Con{p137q_node(name,"Def",arity,False{},[]),p137q_rows(rest,U32.add(arity,1))}

@unsafe
def p137q_queries(+book: List<&2,KDef>, +key: String) -> U32:
  U32.add(da(f_find(key,book)),U32.add(da(lookup(book,key)),
    U32.add(Bool.to_u32(nc_ctor_owned(book,"Payload")),
    U32.add(da(f_find(":absent:",book)),U32.add(da(lookup(book,":absent:")),Bool.to_u32(nc_ctor_owned(book,":absent:")))))))

@unsafe
def p137q_once(+book: List<&2,KDef>, +record: P137QRecord, +key: String) -> U32:
  p137q_queries(book,key)

@unsafe
def p137q_checks() -> List<&2,Bool>:
  +first = p137q_node("a","Def",17,False{},[])
  +last = p137q_node("b","Def",23,False{},[])
  +duplicate = p137q_node("a","Def",99,False{},[])
  +ctor = p137q_node("C","Ctr",0,False{},[])
  +plain = p137q_node("Plain","ADT",0,False{},[ctor])
  +owned = p137q_node("Owned","ADT",0,True{},[ctor])
  +shadow = p137q_node("Shadow","ADT",0,True{},[p137q_node("C","Def",0,False{},[]),ctor])
  +cached = p137q_node("Cached","ADT",0,True{},book_cached([ctor],0))
  +book = book_cached([first,last,duplicate],0)
  +record = p137q_record("λ🌍")
  [p88_string_eq(dn(f_find("missing",[])),"missing"),
   p88_string_eq(dk(f_find("missing",[])),"Missing"),
   p88_string_eq(dn(lookup([],"missing")),""),
   p88_string_eq(dk(lookup([],"missing")),"Absent"),
   U32.is_eq(da(f_find("a",[first,last,duplicate])),17),
   U32.is_eq(da(lookup([first,last,duplicate],"a")),17),
   U32.is_eq(da(lookup(book,"a")),17),
   U32.is_eq(da(lookup(book,"b")),23),
   p88_string_eq(dk(lookup(book,"$kernel.cache")),"Absent"),
   p88_string_eq(dk(f_find("$kernel.cache",book)),"BookCache"),
   Bool.not(nc_ctor_owned([plain,owned],"C")),
   nc_ctor_owned([shadow,owned],"C"),
   nc_ctor_owned([cached],"C"),
   Bool.not(nc_ctor_owned([p137q_node("Ignored","Def",0,True{},[ctor])],"C")),
   Bool.not(nc_ctor_owned([plain,owned],"missing")),
   nc_ctor_owned([p137q_node("商","ADT",0,True{},[p137q_node("字","Ctr",0,False{},[])])],"字"),
   p88_string_eq(dk(f_find("",[KIndexLeaf{7,[]},first])),"IndexLeaf"),
   p88_string_eq(dk(lookup([KIndexNode{0,1,first,last}],"")),"IndexNode"),
   p88_string_eq(p137q_value(first),"opaque value"),
   U32.is_eq(da(first),17),
   p137q_record_query(record,"λ🌍"),
   Bool.not(p137q_record_query(record,"λ")),
   U32.is_eq(U32.from_nat(List.length(&2,U32,p137q_record_numbers(record))),3)]

@unsafe
def p137q_print(values: List<&2,Bool>) -> IO(Unit):
  match values:
    case Nil{}: IO.pure(Unit,Unit{})
    case Con{value,rest}:
      do IO<Unit>:
        Unit <- IO.print(U32.show(Bool.to_u32(value)))
        p137q_print(rest)

@unsafe
def p137q_repeat(left: Nat, +book: List<&2,KDef>, +record: P137QRecord, +key: String, sum: U32) -> U32:
  match left:
    case 0n: sum
    case 1n+rest: p137q_repeat(rest,book,record,key,U32.add(sum,p137q_once(book,record,key)))

@unsafe
def p137q_timed(repeats: Nat, +book: List<&2,KDef>, +record: P137QRecord, +key: String) -> IO(Unit):
  do IO<Unit>:
    Unit <- IO.print(U32.show(p137q_once(book,record,key)))
    before : Nat <- IO.now()
    Unit <- IO.print(U32.show(p137q_repeat(repeats,book,record,key,0)))
    after : Nat <- IO.now()
    IO.print(Nat.show(Nat.sub(after,before)))

@unsafe
def p137q_select(repeats: Nat) -> IO(Unit):
  match repeats:
    case 0n: p137q_print(p137q_checks())
    case 1n+rest:
      +key : String = String.append("p111_","emit_admitted")
      p137q_timed(1n+rest,p137q_rows(p137q_names(),0),p137q_record(key),key)

@unsafe
def p137q_number(value: Maybe<&2,Nat>, fallback: Nat) -> Nat:
  match value:
    case None{}: fallback
    case Some{number}: number

@unsafe
def p137q_args(args: List<String>, fallback: Nat) -> Nat:
  match args:
    case Nil{}: fallback
    case head <> tail: p137q_args(tail,p137q_number(Nat.read(head),fallback))

@unsafe
def main() -> IO(Unit):
  do IO<Unit>:
    args : List<String> <- IO.args()
    p137q_select(p137q_args(args,0n))
