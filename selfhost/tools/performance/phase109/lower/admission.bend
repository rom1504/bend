# This small gate validates the exact runtime catalogue and the child shapes
# consumed by owned lowering. It is not a replacement for source checking or
# authentication of NativeErasedBody facts by the frontend/transport boundary.
@unsafe
def nxo_catalogue_ok(+ctors: List<&2,NxoCtor>) -> Bool:
  match ctors:
    case Con{NxoCtor{n0,c0,a0},Con{NxoCtor{n1,c1,a1},Con{NxoCtor{n2,c2,a2},Con{NxoCtor{n3,c3,a3},Nil{}}}}}:
      String.eq(n0,"Nil") && U32.is_eq(c0,0) && U32.is_eq(a0,0) &&
      String.eq(n1,"Con") && U32.is_eq(c1,1) && U32.is_eq(a1,2) &&
      String.eq(n2,"SNil") && U32.is_eq(c2,2) && U32.is_eq(a2,0) &&
      String.eq(n3,"SCon") && U32.is_eq(c3,3) && U32.is_eq(a3,2)
    case _: False{}

@unsafe
def nxo_source_ctor_ok(+t: KTerm, +ctors: List<&2,NxoCtor>) -> Bool:
  nxo_source_ctor_shape(t,nxo_ctor(nm(t),ctors))

@unsafe
def nxo_source_ctor_shape(+t: KTerm, +ctor: NxoCtor) -> Bool:
  match ctor:
    case NxoCtor{name,cid,arity}:
      Bool.not(String.eq(name,"")) && nx_choose(Bool,String.eq(tg(t),"Mat"),
        u => U32.is_eq(nxo_size(KTerm,ks(t)),2) && U32.is_eq(ix(t),U32.inc(arity)),
        u => U32.is_eq(nxo_size(KTerm,ks(t)),arity))

@unsafe
def nxo_source_node_ok(+t: KTerm, +ctors: List<&2,NxoCtor>) -> Bool:
  +tag = tg(t)
  +count = nxo_size(KTerm,ks(t))
  nx_choose(Bool,String.eq(tag,"Var") || String.eq(tag,"Ref") || String.eq(tag,"Efq"),u => U32.is_eq(count,0),u =>
  nx_choose(Bool,String.eq(tag,"Lam"),u => U32.is_eq(count,1) && (U32.is_eq(qt(t),1) || U32.is_eq(qt(t),2)),u =>
  nx_choose(Bool,String.eq(tag,"App"),u => U32.is_eq(count,2),u =>
  nx_choose(Bool,String.eq(tag,"Mat") || String.eq(tag,"Ctr"),u => nxo_source_ctor_ok(t,ctors),u => False{}))))

@unsafe
def nxo_source_shape(+t: KTerm, +ctors: List<&2,NxoCtor>) -> Bool:
  nxo_source_node_ok(t,ctors) && nxo_source_shapes(ks(t),ctors)

@unsafe
def nxo_source_shapes(+terms: List<&2,KTerm>, +ctors: List<&2,NxoCtor>) -> Bool:
  match terms:
    case Nil{}: True{}
    case Con{term,rest}: nxo_source_shape(term,ctors) && nxo_source_shapes(rest,ctors)

@unsafe
def nxo_admit(+fact: KDef, +ctors: List<&2,NxoCtor>) -> Bool:
  String.eq(dk(fact),"NativeErasedBody") && U32.is_gt(da(fact),0) && U32.is_lt(da(fact),9) &&
  nxo_catalogue_ok(ctors) && nxo_source_shape(dv(fact),ctors)
