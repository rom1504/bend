# Hidden keys contain @, which admitted IR local identifiers cannot contain.
@unsafe
def p113l_version(+facts: KDef, +name: String) -> U32:
  ix(dt(p111v_get(facts,name)))

@unsafe
def p113k_put(+facts: KDef, +name: String, fact: P113KFact) -> KDef:
  match fact:
    case P113KFact{bits,exact,lo,hi}:
      index_set(facts,KDef{name,"P113KFact",bits,Bool.to_u32(exact),kt("Epoch","",U32.inc(p113l_version(facts,name)),0,[]),kt("P113KValue","",lo,hi,[]),[],False{},False{}},index_hash(name,2166136261),32)

@unsafe
def p113l_relation(+facts: KDef, +name: String) -> KDef:
  +found = p111v_get(facts,"@condition:" ++ name)
  nt_choose(KDef,String.eq(dk(found),"P113LRelation") &&
    U32.is_eq(ix(dt(found)),p113l_version(facts,nm(dv(found)))) &&
    U32.is_eq(qt(dt(found)),p113l_version(facts,name)),u => found,u => missing())

@unsafe
def p113l_relate(+facts: KDef, +name: String, subject: String, version: U32, truth: U32) -> KDef:
  +key = "@condition:" ++ name
  index_set(facts,KDef{key,"P113LRelation",truth,0,kt("Epoch","",version,p113l_version(facts,name),[]),kt("Subject",subject,0,0,[]),[],False{},False{}},index_hash(key,2166136261),32)

@unsafe
def p113l_copy_relation(+before: KDef, +after: KDef, +name: String, value: N111Value, +invert: Bool) -> KDef:
  match value:
    case N111Local{source}:
      +record = p113l_relation(before,source)
      nt_choose(KDef,String.eq(dk(record),"P113LRelation"),u =>
        p113l_relate(after,name,nm(dv(record)),ix(dt(record)),U32.xor(da(record),Bool.to_u32(invert))),u => after)
    case _: after

@unsafe
def p113l_comparison(+before: KDef, +after: KDef, +name: String, +op: String, left: N111Value, right: N111Value) -> KDef:
  match left right:
    case N111Local{+subject} N111Const{+lo,+hi}:
      nt_choose(KDef,(String.eq(op,"eq") || String.eq(op,"ne")) && U32.is_eq(hi,0) && U32.is_le(lo,1) && U32.is_le(p113k_bits_of(p113k_get(before,subject)),1),
        u => p113l_relate(after,name,subject,p113l_version(before,subject),U32.xor(lo,Bool.to_u32(String.eq(op,"ne")))),u => after)
    case _: after

@unsafe
def p113l_bin_relation(+before: KDef, +after: KDef, +name: String, +op: String, +left: N111Value, +right: N111Value) -> KDef:
  nt_choose(KDef,(String.eq(op,"or") || String.eq(op,"xor") || String.eq(op,"add")) && p113k_zero(p113k_value(right,before)),
    u => p113l_copy_relation(before,after,name,left,False{}),u =>
  nt_choose(KDef,(String.eq(op,"or") || String.eq(op,"xor") || String.eq(op,"add")) && p113k_zero(p113k_value(left,before)),
    u => p113l_copy_relation(before,after,name,right,False{}),u =>
  nt_choose(KDef,String.eq(op,"xor") && p113l_exact_one(p113k_value(right,before)),
    u => p113l_copy_relation(before,after,name,left,True{}),u =>
    p113l_comparison(before,after,name,op,p113k_replace(left,before),p113k_replace(right,before)))))

@unsafe
def p113l_exact_one(fact: P113KFact) -> Bool:
  match fact:
    case P113KFact{bits,exact,lo,hi}: exact && U32.is_eq(lo,1) && U32.is_eq(hi,0)

@unsafe
def p113l_record(stmt: N111Stmt, before: KDef, after: KDef) -> KDef:
  match stmt:
    case N111Set{name,typ,value}: p113l_copy_relation(before,after,name,value,False{})
    case N111Bin{name,typ,op,left,right}: p113l_bin_relation(before,after,name,op,left,right)
    case _: after

@unsafe
def p113l_scalar_done(stmt: N111Stmt, before: KDef, result: P113KScalar) -> P113KScalar:
  match result:
    case P113KScalar{body,facts}: P113KScalar{body,p113l_record(stmt,before,facts)}

@unsafe
def p113k_scalar(+stmt: N111Stmt, +facts: KDef) -> P113KScalar:
  p113l_scalar_done(stmt,facts,p113l_base_scalar(stmt,facts))

@unsafe
def p113l_assume(+facts: KDef, condition: N111Value, +truth: Bool) -> KDef:
  match condition:
    case N111Local{name}:
      +record = p113l_relation(facts,name)
      nt_choose(KDef,String.eq(dk(record),"P113LRelation") && U32.is_le(p113k_bits_of(p113k_get(facts,nm(dv(record)))),1),
        u => p113k_put(facts,nm(dv(record)),p113k_exact(U32.xor(da(record),Bool.to_u32(Bool.not(truth))),0)),u => facts)
    case _: facts
