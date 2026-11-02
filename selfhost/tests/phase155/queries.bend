# Phase155 IDs08-10. Additive probes over the maintained KDef/KTerm/index ABI.
# No production verifier or runtime changes. A scalar return is an opportunity
# for borrowing, not a claim about the worker the selected backend will emit.

@unsafe
def p155q_mix(+acc: U32, +value: U32) -> U32:
  U32.xor(U32.mul(acc,16777619),value)

@unsafe
def p155q_name(+i: U32) -> String:
  "p155q_" ++ U32.show(i)

@unsafe
def p155q_fact_tree(+left: U32, tree: KDef) -> KDef:
  match left:
    case 0: tree
    case n:
      +i = U32.sub(n,1)
      p155q_fact_tree(i,p111v_put(tree,p155q_name(i),"local",U32.inc(i),U32.mul(i,8)))

# Scalar form of da(index_find(...)), including the retained legacy tree,
# zero-mask nodes, collision buckets and missing/first-match semantics.
@unsafe
def p155q_width_bucket(rows: List<&2,KDef>, +name: String) -> U32:
  match rows:
    case Nil{}: 0
    case Con{+head,rest}:
      nt_choose(U32,p137q_name_eq(name,head),u => da(head),u => p155q_width_bucket(rest,name))

@unsafe
def p155q_width(+tree: KDef, +name: String, +hash: U32) -> U32:
  match tree:
    case KDef{label,kind,arity,+templates,typ,value,+ctors,native,uns}:
      nt_choose(U32,p88_string_eq(kind,"Absent"),u => 0,u =>
        nt_choose(U32,U32.is_eq(templates,0),v =>
          nt_choose(U32,U32.is_eq(arity,hash),w => p155q_width_bucket(ctors,name),w => 0),v =>
          p155q_width(index_child_list(ctors,Bool.not(U32.is_eq(U32.and(hash,templates),0))),name,hash)))
    case KIndexLeaf{stored,bucket}:
      nt_choose(U32,U32.is_eq(stored,hash),u => p155q_width_bucket(bucket,name),u => 0)
    case KIndexNode{stored,+mask,+left,+right}:
      nt_choose(U32,U32.is_eq(mask,0),u =>
        nt_choose(U32,U32.is_eq(stored,hash),v => p155q_width_bucket([left,right],name),v => 0),u =>
        nt_choose(U32,U32.is_eq(U32.and(hash,mask),0),v => p155q_width(left,name,hash),v => p155q_width(right,name,hash)))

@unsafe
def p155q_08_loop(+tree: KDef, +left: U32, +i: U32, +acc: U32, +new: Bool) -> U32:
  match left:
    case 0: acc
    case n:
      +name = p155q_name(U32.mod(i,35))
      +value = nt_choose(U32,new,
        u => p155q_width(tree,name,index_hash(name,2166136261)),
        u => da(p111v_get(tree,name)))
      p155q_08_loop(tree,U32.sub(n,1),U32.inc(i),p155q_mix(acc,value),new)

@unsafe
def p155q_08_old(+n: U32) -> String:
  U32.show(p155q_08_loop(p155q_fact_tree(32,missing()),n,0,2166136261,False{}))

@unsafe
def p155q_08_new(+n: U32) -> String:
  U32.show(p155q_08_loop(p155q_fact_tree(32,missing()),n,0,2166136261,True{}))

# The root stays held for all repetitions; the old path returns owned type,
# child-list and child values before observing ix. The new path keeps the
# observation inside each matching scope and returns only a scalar.
@unsafe
def p155q_terms(+left: U32) -> List<&2,KTerm>:
  match left:
    case 0: []
    case n:
      +i = U32.sub(n,1)
      Con{kt("Var",p155q_name(i),U32.add(101,i),0,[atom("Type")]),p155q_terms(i)}

@unsafe
def p155q_root() -> KDef:
  KDef{"p155q_owner","Def",8,3,kt("App","held",0,0,p155q_terms(8)),
    kt("Lam","body",44,1,[atom("Type"),atom("Body")]),[],False{},True{}}

@unsafe
def p155q_term_ix(term: KTerm) -> U32:
  match term:
    case KTerm{tag,name,id,quant,kids,removed,begin,end}: id
    case KLambda{name,id,quant,kids,removed,begin,end,present}: id
    case KLiteral{kind,number,text,begin,end}: 0

@unsafe
def p155q_child_ix(terms: List<&2,KTerm>, +index: U32) -> U32:
  match terms:
    case Nil{}: 0
    case Con{head,rest}:
      nt_choose(U32,U32.is_eq(index,0),u => p155q_term_ix(head),u => p155q_child_ix(rest,U32.sub(index,1)))

@unsafe
def p155q_type_child_ix(term: KTerm, +index: U32) -> U32:
  match term:
    case KTerm{tag,name,id,quant,kids,removed,begin,end}: p155q_child_ix(kids,index)
    case KLambda{name,id,quant,kids,removed,begin,end,present}: p155q_child_ix(kids,index)
    case KLiteral{kind,number,text,begin,end}: 0

@unsafe
def p155q_root_child_ix(root: KDef, +index: U32) -> U32:
  match root:
    case KDef{name,kind,arity,templates,typ,value,ctors,native,uns}: p155q_type_child_ix(typ,index)
    case KIndexLeaf{hash,bucket}: 0
    case KIndexNode{hash,mask,left,right}: 0

@unsafe
def p155q_09_loop(+root: KDef, +left: U32, +i: U32, +acc: U32, +new: Bool) -> U32:
  match left:
    case 0: acc
    case n:
      +slot = U32.mod(i,10)
      +value = nt_choose(U32,new,u => p155q_root_child_ix(root,slot),u => ix(kid(dt(root),slot)))
      p155q_09_loop(root,U32.sub(n,1),U32.inc(i),p155q_mix(acc,value),new)

@unsafe
def p155q_09_old(+n: U32) -> String:
  U32.show(p155q_09_loop(p155q_root(),n,0,2166136261,False{}))

@unsafe
def p155q_09_new(+n: U32) -> String:
  U32.show(p155q_09_loop(p155q_root(),n,0,2166136261,True{}))

# Three independent layout consumers versus one located constructor whose
# metadata is consumed together. The existing j_layout_ctor remains the sole
# lookup/fallback authority in both paths; this does not assume unique names.
@unsafe
def p155q_ctors(+left: U32) -> List<&2,KDef>:
  match left:
    case 0: []
    case n:
      +i = U32.sub(n,1)
      Con{KDef{p155q_name(i),"Ctr",U32.inc(i),U32.mod(i,3),
        kt("All","field",U32.add(200,i),0,[atom("Type"),atom("End")]),atom("Absent"),[],False{},False{}},p155q_ctors(i)}

@unsafe
def p155q_ctor_book() -> List<&2,KDef>:
  book_cached([KDef{"p155q_owner","ADT",0,0,atom("Type"),atom("Absent"),
    book_cached(p155q_ctors(16),0),False{},False{}}],0)

@unsafe
def p155q_meta(+arity: U32, +templates: U32, +id: U32) -> U32:
  U32.add(U32.add(arity,U32.mul(templates,1024)),U32.mul(id,65536))

@unsafe
def p155q_meta_found(found: KDef) -> U32:
  match found:
    case KDef{name,kind,arity,templates,typ,value,ctors,native,uns}: p155q_meta(arity,templates,ix(typ))
    case KIndexLeaf{hash,bucket}: p155q_meta(hash,0,0)
    case KIndexNode{hash,mask,left,right}: p155q_meta(hash,mask,0)

@unsafe
def p155q_10_loop(+book: List<&2,KDef>, +domain: KTerm, +left: U32, +i: U32, +acc: U32, +new: Bool) -> U32:
  match left:
    case 0: acc
    case n:
      +name = p155q_name(U32.mod(i,18))
      +value = nt_choose(U32,new,u => p155q_meta_found(j_layout_ctor(book,domain,name)),u =>
        p155q_meta(da(j_layout_ctor(book,domain,name)),dx(j_layout_ctor(book,domain,name)),ix(dt(j_layout_ctor(book,domain,name)))))
      p155q_10_loop(book,domain,U32.sub(n,1),U32.inc(i),p155q_mix(acc,value),new)

@unsafe
def p155q_10_old(+n: U32) -> String:
  U32.show(p155q_10_loop(p155q_ctor_book(),kt("ADT","p155q_owner",0,0,[]),n,0,2166136261,False{}))

@unsafe
def p155q_10_new(+n: U32) -> String:
  U32.show(p155q_10_loop(p155q_ctor_book(),kt("ADT","p155q_owner",0,0,[]),n,0,2166136261,True{}))

@unsafe
def p155q_width_agrees(+tree: KDef, +name: String, +hash: U32) -> Bool:
  U32.is_eq(da(index_find(tree,name,hash,32)),p155q_width(tree,name,hash))

@unsafe
def p155q_descendant_agrees(+root: KDef, +slot: U32) -> Bool:
  U32.is_eq(ix(kid(dt(root),slot)),p155q_root_child_ix(root,slot))

# Supplementary structural controls are separate from timed repetitions.
# They cover public legacy representations and full-width IDs, not just the
# well-formed fixture tree emitted by index_set.
@unsafe
def p155q_controls(+unused: U32) -> String:
  +a : KDef = KDef{"same","local",17,3,atom("Type"),atom("Value"),[],False{},False{}}
  +b : KDef = KDef{"same","local",23,9,atom("Type"),atom("Value"),[],False{},False{}}
  +legacy : KDef = KDef{"","IndexLeaf",77,0,atom("Absent"),atom("Absent"),[a,b],False{},False{}}
  +node : KDef = KIndexNode{77,0,a,b}
  +lambda : KDef = KDef{"lambda","Def",0,0,KLambda{"x",4294967295,1,
    [KLiteral{"Nat",7,"7",0,0},kt("Var","id",4294967295,0,[])],[],0,0,True{}},atom("Absent"),[],False{},False{}}
  +ok = p155q_width_agrees(missing(),"x",0) &&
    p155q_width_agrees(KIndexLeaf{77,[a,b]},"same",77) &&
    p155q_width_agrees(KIndexLeaf{77,[a,b]},"missing",77) &&
    p155q_width_agrees(KIndexLeaf{77,[a,b]},"same",78) &&
    p155q_width_agrees(legacy,"same",77) && p155q_width_agrees(legacy,"same",78) &&
    p155q_width_agrees(node,"same",77) && p155q_width_agrees(node,"same",78) &&
    p155q_width_agrees(KIndexLeaf{77,[KIndexLeaf{99,[]}]},"",77) &&
    p155q_descendant_agrees(lambda,0) && p155q_descendant_agrees(lambda,1) &&
    p155q_descendant_agrees(lambda,2) && p155q_descendant_agrees(KIndexNode{7,1,a,b},0)
  nt_choose(String,ok,u => "ok",u => "mismatch")
