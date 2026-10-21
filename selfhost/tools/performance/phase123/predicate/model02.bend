# Phase123 model02: same predicates/output, stage expensive record lookups lazily.
# Phase123: versioned canonical-predicate origins within the existing range scan.
# Only comparison results seed origins. No type inference from N_W32 or low bits.
# Composition overrides exactly p113l_record and p113k_scalar_bin.

@unsafe
def p123p_old_record(stmt: N111Stmt, before: KDef, after: KDef) -> KDef:
  match stmt:
    case N111Set{name,typ,value}: p113l_copy_relation(before,after,name,value,False{})
    case N111Bin{name,typ,op,left,right}: p113l_bin_relation(before,after,name,op,left,right)
    case _: after

@unsafe
def p123p_old_bin(+name: String, +typ: N111Type, +op: String, +left: N111Value, +right: N111Value, +facts: KDef, +lf: P113KFact, +rf: P113KFact) -> P113KScalar:
  +answer = p113k_bin_fact(typ,op,lf,rf)
  P113KScalar{[p113k_bin_stmt(name,typ,op,p113k_replace(left,facts),p113k_replace(right,facts),lf,rf,answer)],p113k_put(facts,name,answer)}

@unsafe
def p123p_get(+facts: KDef, +name: String) -> KDef:
  +found = p111v_get(facts,"@p123predicate:" ++ name)
  nt_choose(KDef,String.eq(dk(found),"P123Predicate"),u =>
    nt_choose(KDef,U32.is_eq(ix(dt(found)),p113l_version(facts,nm(dv(found)))) &&
      U32.is_eq(qt(dt(found)),p113l_version(facts,name)),v => found,v => missing()),u => missing())

@unsafe
def p123p_put(+facts: KDef, +name: String, +root: String, invert: U32) -> KDef:
  +key = "@p123predicate:" ++ name
  index_set(facts,KDef{key,"P123Predicate",invert,0,
    kt("Epoch","",p113l_version(facts,root),p113l_version(facts,name),[]),
    kt("Root",root,0,0,[]),[],False{},False{}},index_hash(key,2166136261),32)

@unsafe
def p123p_copy(+before: KDef, +after: KDef, +name: String, value: N111Value) -> KDef:
  match value:
    case N111Local{source}:
      +record = p123p_get(before,source)
      nt_choose(KDef,String.eq(dk(record),"P123Predicate"),u =>
        nt_choose(KDef,U32.is_eq(ix(dt(record)),p113l_version(after,nm(dv(record)))),
          v => p123p_put(after,name,nm(dv(record)),da(record)),v => after),u => after)
    case _: after

# A recognized diamond writes only its destination. The join may reset epochs,
# but cannot alter the separately named root value; capture the new epoch.
@unsafe
def p123p_diamond(+before: KDef, +after: KDef, condition: N111Value, diamond: P113BQDiamond) -> KDef:
  match condition diamond:
    case N111Local{source} P113BQYes{+name,invert}:
      +record = p123p_get(before,source)
      nt_choose(KDef,String.eq(dk(record),"P123Predicate") && Bool.not(String.eq(name,nm(dv(record)))),
        u => p123p_put(after,name,nm(dv(record)),U32.xor(da(record),Bool.to_u32(invert))),u => after)
    case _ _: after

@unsafe
def p123p_record(stmt: N111Stmt, +before: KDef, +after: KDef) -> KDef:
  match stmt:
    case N111Set{name,typ,value}: p123p_copy(before,after,name,value)
    case N111Bin{+name,typ,op,left,right}:
      nt_choose(KDef,p111v_comparison(op),u => p123p_put(after,name,name,0),u => after)
    case N111If{condition,yes,no}: p123p_diamond(before,after,condition,p113bq_scalar(yes,no))
    case _: after

@unsafe
def p113l_record(+stmt: N111Stmt, +before: KDef, after: KDef) -> KDef:
  p123p_record(stmt,before,p123p_old_record(stmt,before,after))

@unsafe
def p123p_test_origin(+op: String, +lo: U32, +record: KDef) -> KDef:
  nt_choose(KDef,String.eq(dk(record),"P123Predicate"),
    u => KDef{"","P123Test",U32.xor(da(record),U32.xor(lo,Bool.to_u32(String.eq(op,"eq")))),0,
      atom("Absent"),dv(record),[],False{},False{}},u => missing())

@unsafe
def p123p_test(+op: String, value: N111Value, constant: N111Value, +facts: KDef) -> KDef:
  match value constant:
    case N111Local{source} N111Const{+lo,+hi}:
      nt_choose(KDef,(String.eq(op,"eq") || String.eq(op,"ne")) && U32.is_eq(hi,0) && U32.is_le(lo,1),
        u => p123p_test_origin(op,lo,p123p_get(facts,source)),u => missing())
    case _ _: missing()

@unsafe
def p123p_pick(+op: String, +left: N111Value, +right: N111Value, +facts: KDef) -> KDef:
  +forward = p123p_test(op,left,right,facts)
  nt_choose(KDef,String.eq(dk(forward),"P123Test"),u => forward,u => p123p_test(op,right,left,facts))

@unsafe
def p123p_bin(+name: String, +typ: N111Type, +op: String, +left: N111Value, +right: N111Value, +facts: KDef, +lf: P113KFact, +rf: P113KFact, +record: KDef) -> P113KScalar:
  nt_choose(P113KScalar,String.eq(dk(record),"P123Test"),
    u => P113KScalar{[nt_choose(N111Stmt,U32.is_eq(da(record),0),
      v => N111Set{name,N111U32{},N111Local{nm(dv(record))}},
      v => N111Bin{name,N111U32{},"xor",N111Local{nm(dv(record))},N111Const{1,0}})],
      p113k_put(facts,name,p113k_bin_fact(typ,op,lf,rf))},
    u => p123p_old_bin(name,typ,op,left,right,facts,lf,rf))

@unsafe
def p113k_scalar_bin(+name: String, +typ: N111Type, +op: String, +left: N111Value, +right: N111Value, +facts: KDef, +lf: P113KFact, +rf: P113KFact) -> P113KScalar:
  p123p_bin(name,typ,op,left,right,facts,lf,rf,p123p_pick(op,left,right,facts))
