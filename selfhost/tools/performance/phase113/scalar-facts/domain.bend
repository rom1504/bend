# Machine facts only. No source ownership kind implies a numeric range.
type P113KFact is Data:
  P113KFact{+bits: U32, +exact: Bool, +lo: U32, +hi: U32}
type P113KScalar is Data:
  P113KScalar{+body: List<&2,N111Stmt>, +facts: KDef}
type P113KBody is Data:
  P113KBody{+body: List<&2,P113DStmt>, +facts: KDef, +terminal: Bool}

@unsafe
def p113k_bits(+value: U32, +bits: U32) -> U32:
  nt_choose(U32,U32.is_eq(value,0),u => bits,u => p113k_bits(U32.shr(value),U32.inc(bits)))

@unsafe
def p113k_exact(+lo: U32, +hi: U32) -> P113KFact:
  P113KFact{nt_choose(U32,U32.is_eq(hi,0),u => p113k_bits(lo,0),u => U32.add(32,p113k_bits(hi,0))),True{},lo,hi}

@unsafe
def p113k_bound(+bits: U32) -> P113KFact:
  nt_choose(P113KFact,U32.is_eq(bits,0),u => p113k_exact(0,0),u => P113KFact{U32.min(bits,64),False{},0,0})

@unsafe
def p113k_get(+facts: KDef, +name: String) -> P113KFact:
  +record = p111v_get(facts,name)
  nt_choose(P113KFact,String.eq(dk(record),"P113KFact"),
    u => P113KFact{da(record),U32.is_eq(dx(record),1),ix(dv(record)),qt(dv(record))},
    u => p113k_bound(64))

@unsafe
def p113k_put(facts: KDef, +name: String, fact: P113KFact) -> KDef:
  match fact:
    case P113KFact{bits,exact,lo,hi}:
      index_set(facts,KDef{name,"P113KFact",bits,Bool.to_u32(exact),atom("Absent"),kt("P113KValue","",lo,hi,[]),[],False{},False{}},index_hash(name,2166136261),32)

@unsafe
def p113k_value(value: N111Value, +facts: KDef) -> P113KFact:
  match value:
    case N111Const{lo,hi}: p113k_exact(lo,hi)
    case N111Local{name}: p113k_get(facts,name)
    case _: p113k_bound(64)

@unsafe
def p113k_atom(+value: N111Value, fact: P113KFact) -> N111Value:
  match fact:
    case P113KFact{bits,+exact,lo,hi}: nt_choose(N111Value,exact,u => N111Const{lo,hi},u => value)

@unsafe
def p113k_replace(+value: N111Value, +facts: KDef) -> N111Value:
  p113k_atom(value,p113k_value(value,facts))

@unsafe
def p113k_values(values: List<&2,N111Value>, +facts: KDef) -> List<&2,N111Value>:
  match values:
    case Nil{}: []
    case Con{value,rest}: Con{p113k_replace(value,facts),p113k_values(rest,facts)}

@unsafe
def p113k_args(args: List<&2,N111Arg>, +facts: KDef) -> List<&2,N111Arg>:
  match args:
    case Nil{}: []
    case Con{N111Arg{N111Ptr{},value},rest}: Con{N111Arg{N111Ptr{},value},p113k_args(rest,facts)}
    case Con{N111Arg{typ,value},rest}: Con{N111Arg{typ,p113k_replace(value,facts)},p113k_args(rest,facts)}

@unsafe
def p113k_kill(names: List<&2,String>, facts: KDef) -> KDef:
  match names:
    case Nil{}: facts
    case Con{name,rest}: p113k_kill(rest,p113k_put(facts,name,p113k_bound(64)))

@unsafe
def p113k_join_fact(left: P113KFact, right: P113KFact) -> P113KFact:
  match left right:
    case P113KFact{+lb,+le,+ll,+lh} P113KFact{+rb,+re,+rl,+rh}:
      nt_choose(P113KFact,le && re && U32.is_eq(ll,rl) && U32.is_eq(lh,rh),
        u => p113k_exact(ll,lh),u => p113k_bound(U32.max(lb,rb)))

@unsafe
def p113k_join_bucket(bucket: List<&2,KDef>, +right: KDef, out: KDef) -> KDef:
  match bucket:
    case Nil{}: out
    case Con{+head,rest}: p113k_join_bucket(rest,right,p113k_join_record(head,right,out))

@unsafe
def p113k_join_record(+record: KDef, +right: KDef, +out: KDef) -> KDef:
  +name = dn(record)
  +found = p111v_get(right,name)
  nt_choose(KDef,String.eq(dk(found),"P113KFact"),
    u => p113k_put(out,name,p113k_join_fact(P113KFact{da(record),U32.is_eq(dx(record),1),ix(dv(record)),qt(dv(record))},p113k_get(right,name))),
    u => out)

@unsafe
def p113k_join(left: KDef, +right: KDef, out: KDef) -> KDef:
  match left:
    case KIndexLeaf{hash,bucket}: p113k_join_bucket(bucket,right,out)
    case KIndexNode{hash,mask,a,b}: p113k_join(b,right,p113k_join(a,right,out))
    case _: out

@unsafe
def p113k_width(typ: N111Type) -> U32:
  match typ:
    case N111U32{}: 32
    case _: 64

@unsafe
def p113k_limit(fact: P113KFact, +width: U32) -> P113KFact:
  match fact:
    case P113KFact{+bits,+exact,+lo,+hi}:
      nt_choose(P113KFact,exact,
        u => p113k_exact(lo,nt_choose(U32,U32.is_eq(width,32),v => 0,v => hi)),
        u => p113k_bound(U32.min(bits,width)))
