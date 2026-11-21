# Native checked-term partial evaluation of a bounded, literal String spine.
# Residual calls are never evaluated. Fresh lets retain dynamic argument order.
type P205UResult is Data:
  P205UResult{+term: KTerm, +next: U32, +steps: U32, +ok: Bool}
type P205UFields is Data:
  P205UFields{+terms: List<&2,KTerm>, +next: U32, +steps: U32, +ok: Bool}

@unsafe
def p205u_clean( +t: KTerm) -> KTerm:
  kc(KTerm,p98_tag_eq(t,"Ann"),u => p205u_clean(kid(t,0)),u =>
  kc(KTerm,p98_tag_eq(t,"Var") || p98_tag_eq(t,"Ref"),v => k_with_children(t,[]),v => k_with_children(t,p205u_clean_fields(ks(t)))))
@unsafe
def p205u_clean_fields( +xs: List<&2,KTerm>) -> List<&2,KTerm>:
  match xs:
    case Nil{}: []
    case Con{x,rest}: Con{p205u_clean(x),p205u_clean_fields(rest)}

@unsafe
def p205u_refs(+t: KTerm, +name: String) -> U32:
  kc(U32,p98_tag_eq(t,"Ref"),u => nt_bool(String.eq(nm(t),name)),u => p205u_refs_fields(ks(t),name))
@unsafe
def p205u_refs_fields( +xs: List<&2,KTerm>, +name: String) -> U32:
  match xs:
    case Nil{}: 0
    case Con{x,rest}: U32.min(2,U32.add(p205u_refs(x,name),p205u_refs_fields(rest,name)))
@unsafe
def p205u_vars(+t: KTerm, +id: U32) -> U32:
  kc(U32,p98_tag_eq(t,"Var"),u => nt_bool(U32.is_eq(ix(t),id)),u => p205u_vars_fields(ks(t),id))
@unsafe
def p205u_vars_fields( +xs: List<&2,KTerm>, +id: U32) -> U32:
  match xs:
    case Nil{}: 0
    case Con{x,rest}: U32.min(2,U32.add(p205u_vars(x,id),p205u_vars_fields(rest,id)))
@unsafe
def p205u_call(+t: KTerm, +owner: String) -> KTerm:
  +call = j_call_spine(t,[])
  kc(KTerm,p98_tag_eq(call,"Call") && String.eq(nm(call),owner),u => call,u => p205u_call_fields(ks(t),owner))
@unsafe
def p205u_call_fields( +xs: List<&2,KTerm>, +owner: String) -> KTerm:
  match xs:
    case Nil{}: atom("Absent")
    case Con{x,rest}:
      +found = p205u_call(x,owner)
      kc(KTerm,p98_tag_eq(found,"Absent"),u => p205u_call_fields(rest,owner),u => found)
@unsafe
def p205u_at( +xs: List<&2,KTerm>, +index: U32) -> KTerm:
  match xs index:
    case Con{x,rest} 0: x
    case Con{x,rest} _: p205u_at(rest,U32.sub(index,1))
    case _ _: atom("Absent")

# Leading dynamic parameters are allowed (packet state before the String).
@unsafe
def p205u_shape(+body: KTerm, +owner: String, +arity: U32, +index: U32) -> Bool:
  kc(Bool,p98_tag_eq(body,"Lam") && U32.is_lt(index,4),u => p205u_shape(kid(body,0),owner,arity,U32.inc(index)),u =>
  kc(Bool,p98_tag_eq(body,"Mat") && String.eq(nm(body),"SNil") && U32.is_eq(terms_len(ks(body)),2),v =>
    p205u_cons(kid(body,1),owner,arity,index) && U32.is_eq(p205u_refs(kid(body,0),owner),0),v => False{}))
@unsafe
def p205u_cons(+body: KTerm, +owner: String, +arity: U32, +index: U32) -> Bool:
  p98_tag_eq(body,"Mat") && String.eq(nm(body),"SCon") && U32.is_eq(terms_len(ks(body)),2) &&
    p98_tag_eq(kid(body,1),"Efq") && p205u_character(kid(body,0),owner,arity,index)
@unsafe
def p205u_character(+body: KTerm, +owner: String, +arity: U32, +index: U32) -> Bool:
  kc(Bool,p98_tag_eq(body,"Mat") && String.eq(nm(body),"Chr") && U32.is_eq(terms_len(ks(body)),2) && p98_tag_eq(kid(body,1),"Efq"),
    u => p205u_binders(kid(body,0),owner,arity,index),u => p205u_binders(body,owner,arity,index))
@unsafe
def p205u_binders(+body: KTerm, +owner: String, +arity: U32, +index: U32) -> Bool:
  +tail = kid(body,0)
  +call = p205u_call(kid(tail,0),owner)
  +arg = p205u_at(ks(call),index)
  p98_tag_eq(body,"Lam") && p98_tag_eq(tail,"Lam") &&
    U32.is_eq(p205u_refs(body,owner),1) && U32.is_eq(p205u_vars(kid(tail,0),ix(tail)),1) &&
    p98_tag_eq(call,"Call") && U32.is_eq(terms_len(ks(call)),arity) &&
    p98_tag_eq(arg,"Var") && U32.is_eq(ix(arg),ix(tail))

@unsafe
def p205u_literal(+book: List<&2,KDef>, +t: KTerm) -> KTerm:
  kc(KTerm,core_literal(t) && String.eq(nm(t),"String"),u => t,u =>
  kc(KTerm,p98_tag_eq(t,"Ref"),v => p205u_literal_def(lookup(book,nm(t))),v => atom("Absent")))
@unsafe
def p205u_literal_def(+d: KDef) -> KTerm:
  +t = j_strip(dv(d))
  kc(KTerm,String.eq(dk(d),"Def") && U32.is_eq(da(d),0) && U32.is_eq(dx(d),0) && Bool.not(db(d) || du(d)) &&
    core_literal(t) && String.eq(nm(t),"String"),u => t,u => atom("Absent"))
@unsafe
def p205u_length( +text: String, +fuel: U32) -> Bool:
  match text fuel:
    case SNil{} _: True{}
    case SCon{c,rest} 0: False{}
    case SCon{c,rest} _: p205u_length(rest,U32.sub(fuel,1))

# All failure results are propagated to the outer absent sentinel.
@unsafe
def p205u_headshape( +t: KTerm, +fuel: U32) -> Bool:
  +body = j_strip(t)
  kc(Bool,U32.is_eq(fuel,0),u => False{},u =>
  kc(Bool,p98_tag_eq(body,"Lam"),v => p205u_headshape(kid(body,0),U32.sub(fuel,1)),v =>
    p98_tag_eq(body,"Mat") && String.eq(nm(body),"SNil")))
@unsafe
def p205u_any_static(+book: List<&2,KDef>, +xs: List<&2,KTerm>) -> Bool:
  match xs:
    case Nil{}: False{}
    case Con{x,rest}: p205u_literal_good(p205u_literal(book,x)) || p205u_any_static(book,rest)
@unsafe
def p205u_eval(+book: List<&2,KDef>, +t: KTerm, +next: U32, +steps: U32, +fuel: U32) -> P205UResult:
  kc(P205UResult,U32.is_eq(fuel,0) || U32.is_ge(steps,65),u => P205UResult{t,next,steps,False{}},u =>
    kc(P205UResult,p98_tag_eq(t,"App"),v => p205u_call_eval(book,t,next,steps,U32.sub(fuel,1),j_call_spine(t,[])),v =>
      p205u_rebuilt(t,p205u_fields(book,ks(t),next,steps,U32.sub(fuel,1)))))
@unsafe
def p205u_call_eval(+book: List<&2,KDef>, +t: KTerm, +next: U32, +steps: U32, +fuel: U32, +call: KTerm) -> P205UResult:
  kc(P205UResult,p98_tag_eq(call,"Call") && U32.is_eq(qt(nd_head(t)),1) && U32.is_le(terms_len(ks(call)),5) && p205u_any_static(book,ks(call)),u =>
    p205u_definition(book,t,next,steps,fuel,call,lookup(book,nm(call))),u =>
    p205u_rebuilt(t,p205u_fields(book,ks(t),next,steps,fuel)))
@unsafe
def p205u_definition(+book: List<&2,KDef>, +t: KTerm, +next: U32, +steps: U32, +fuel: U32, +call: KTerm, +d: KDef) -> P205UResult:
  kc(P205UResult,String.eq(dk(d),"Def") && Bool.not(db(d) || du(d)) &&
    U32.is_eq(dx(d),0) && U32.is_eq(terms_len(ks(call)),da(d)) && p205u_headshape(dv(d),5) && p205u_room([dv(d)],512),u =>
      p205u_definition_body(book,t,next,steps,fuel,call,d,p205u_clean(dv(d))),u =>
      p205u_rebuilt(t,p205u_fields(book,ks(t),next,steps,fuel)))
@unsafe
def p205u_definition_body(+book: List<&2,KDef>, +t: KTerm, +next: U32, +steps: U32, +fuel: U32, +call: KTerm, +d: KDef, +body: KTerm) -> P205UResult:
  kc(P205UResult,U32.is_gt(nq_layout_remaining([body],513),0) && p205u_shape(body,dn(d),da(d),0) &&
    p205u_static_arg(book,body,ks(call)),u =>
      p205u_fresh(book,ks(call),next,steps,fuel,f_fresh_term(body,[],next)),u =>
      p205u_rebuilt(t,p205u_fields(book,ks(t),next,steps,fuel)))
@unsafe
def p205u_static_arg(+book: List<&2,KDef>, +body: KTerm, +args: List<&2,KTerm>) -> Bool:
  match args:
    case Nil{}: False{}
    case Con{arg,rest}:
      kc(Bool,p98_tag_eq(body,"Lam"),u => p205u_static_arg(book,kid(body,0),rest),u =>
        p205u_literal_good(p205u_literal(book,arg)))
@unsafe
def p205u_literal_good( +t: KTerm) -> Bool:
  Bool.not(p98_tag_eq(t,"Absent")) && p205u_length(kl_text(t),64)
@unsafe
def p205u_fresh( +book: List<&2,KDef>, +args: List<&2,KTerm>, +old: U32, +steps: U32, +fuel: U32, +fresh: FFresh) -> P205UResult:
  match fresh:
    case FFresh{body,next}: p205u_apply(book,body,args,next,steps,fuel)

@unsafe
def p205u_apply(+book: List<&2,KDef>, +body: KTerm, +args: List<&2,KTerm>, +next: U32, +steps: U32, +fuel: U32) -> P205UResult:
  match args:
    case Nil{}: p205u_eval(book,body,next,steps,fuel)
    case Con{+arg,+rest}:
      kc(P205UResult,p98_tag_eq(body,"Lam") && U32.is_ne(qt(body),0) && U32.is_ne(qt(body),3),u =>
        kc(P205UResult,core_literal(arg),v => p205u_apply(book,subst(kid(body,0),ix(body),arg),rest,next,steps,fuel),v =>
          p205u_bound(book,body,arg,p205u_apply(book,kid(body,0),rest,next,steps,fuel))),u =>
      kc(P205UResult,p98_tag_eq(body,"Mat") && String.eq(nm(body),"SNil"),v =>
        p205u_string(book,body,rest,next,steps,fuel,p205u_literal(book,arg)),v =>
      kc(P205UResult,p98_tag_eq(body,"Mat") && String.eq(nm(body),"Chr") && j_fusion_ctor(arg,"Chr",1),w =>
        p205u_apply(book,kid(body,0),Con{kid(arg,0),rest},next,steps,fuel),w => P205UResult{body,next,steps,False{}})))
# Recover only closed monomorphic result domains. Unknown/dependent/function
# types remain unannotated and the ordinary whole-definition recheck decides.
@unsafe
def p205u_closed_type(+book: List<&2,KDef>, +t: KTerm) -> KTerm:
  +ty = j_strip(t)
  kc(KTerm,(p98_tag_eq(ty,"Ref") || p98_tag_eq(ty,"ADT")) && List.is_empty(&2,KTerm,ks(ty)) &&
    String.eq(dk(lookup(book,nm(ty))),"ADT"),u => ty,u => atom("Absent"))
@unsafe
def p205u_after_args(+book: List<&2,KDef>, +t: KTerm, +count: U32) -> KTerm:
  +ty = j_strip(t)
  kc(KTerm,U32.is_eq(count,0),u => p205u_closed_type(book,ty),u =>
    kc(KTerm,p98_tag_eq(ty,"All"),v => p205u_after_args(book,kid(ty,1),U32.sub(count,1)),v => atom("Absent")))
@unsafe
def p205u_bind_type(+book: List<&2,KDef>, +t: KTerm) -> KTerm:
  kc(KTerm,p98_tag_eq(t,"Ann"),u => p205u_closed_type(book,kid(t,1)),u =>
  kc(KTerm,core_literal(t),v => p205u_closed_type(book,ref(nm(t))),v =>
  kc(KTerm,p98_tag_eq(t,"Let"),w => p205u_let_type(book,ks(t)),w =>
  kc(KTerm,p98_tag_eq(t,"App"),x => p205u_call_type(book,j_call_spine(t,[])),x =>
  kc(KTerm,p98_tag_eq(t,"Ctr"),y => p205u_after_args(book,dt(j_find_ctor(book,nm(t))),terms_len(ks(t))),y =>
  kc(KTerm,p98_tag_eq(t,"Ref"),z => p205u_closed_type(book,dt(lookup(book,nm(t)))),z => atom("Absent")))))))
@unsafe
def p205u_call_type(+book: List<&2,KDef>, +call: KTerm) -> KTerm:
  kc(KTerm,p98_tag_eq(call,"Call"),u => p205u_after_args(book,dt(lookup(book,nm(call))),terms_len(ks(call))),u => atom("Absent"))
@unsafe
def p205u_let_type(+book: List<&2,KDef>, +xs: List<&2,KTerm>) -> KTerm:
  match xs:
    case Con{last,Nil{}}: p205u_bind_type(book,last)
    case Con{binding,rest}: p205u_let_type(book,rest)
    case _: atom("Absent")
@unsafe
def p205u_typed_arg(+arg: KTerm, +ty: KTerm) -> KTerm:
  kc(KTerm,p98_tag_eq(ty,"Absent"),u => arg,u => kt("Ann","",0,0,[arg,ty]))

@unsafe
def p205u_bound(+book: List<&2,KDef>, +binder: KTerm, +arg: KTerm, +result: P205UResult) -> P205UResult:
  match result:
    case P205UResult{body,next,steps,ok}:
      P205UResult{kt("Let","",0,0,[kt("Bind",nm(binder),ix(binder),2,[p205u_typed_arg(arg,p205u_bind_type(book,arg))]),body]),next,steps,ok}
@unsafe
def p205u_string( +book: List<&2,KDef>, +body: KTerm, +rest: List<&2,KTerm>, +next: U32, +steps: U32, +fuel: U32, +literal: KTerm) -> P205UResult:
  kc(P205UResult,p98_tag_eq(literal,"Absent"),u => P205UResult{body,next,steps,False{}},u =>
    p205u_string_chars(book,body,rest,next,steps,fuel,kl_text(literal)))
@unsafe
def p205u_string_chars(+book: List<&2,KDef>, +body: KTerm, +rest: List<&2,KTerm>, +next: U32, +steps: U32, +fuel: U32, +text: String) -> P205UResult:
  match text:
    case SNil{}: p205u_apply(book,kid(body,0),rest,next,U32.inc(steps),fuel)
    case SCon{c,tail}:
      p205u_apply(book,kid(kid(body,1),0),Con{kt("Ctr","Chr",0,1,[KLiteral{"U32",Char.to_u32(c),"",0,0}]),Con{KLiteral{"String",0,tail,0,0},rest}},next,U32.inc(steps),fuel)

@unsafe
def p205u_fields(+book: List<&2,KDef>, +xs: List<&2,KTerm>, +next: U32, +steps: U32, +fuel: U32) -> P205UFields:
  match xs:
    case Nil{}: P205UFields{[],next,steps,True{}}
    case Con{x,rest}: p205u_field_next(book,rest,fuel,p205u_eval(book,x,next,steps,fuel))
@unsafe
def p205u_field_next( +book: List<&2,KDef>, +rest: List<&2,KTerm>, +fuel: U32, +first: P205UResult) -> P205UFields:
  match first:
    case P205UResult{term,next,steps,ok}:
      kc(P205UFields,ok,u => p205u_field_join(term,ok,p205u_fields(book,rest,next,steps,fuel)),u => P205UFields{[],next,steps,False{}})
@unsafe
def p205u_field_join( +term: KTerm, +good: Bool, +rest: P205UFields) -> P205UFields:
  match rest:
    case P205UFields{terms,next,steps,ok}: P205UFields{Con{term,terms},next,steps,good && ok}
@unsafe
def p205u_rebuilt( +parent: KTerm, +fields: P205UFields) -> P205UResult:
  match fields:
    case P205UFields{terms,next,steps,ok}: P205UResult{k_with_children(parent,terms),next,steps,ok}
@unsafe
def p205u_finished( +result: P205UResult) -> KTerm:
  match result:
    case P205UResult{term,next,steps,ok}:
      kc(KTerm,ok && U32.is_gt(steps,0) && U32.is_gt(nq_layout_remaining([term],8193),0),u => term,u => atom("Absent"))
# Bound the semantic input walk before cleaning; cached Var/type shadows are
# not executable syntax. This also avoids name lookup for ordinary leaves.
@unsafe
def p205u_children(+t: KTerm) -> List<&2,KTerm>:
  kc(List<&2,KTerm>,p98_tag_eq(t,"Ann"),u => [kid(t,0)],u =>
    kc(List<&2,KTerm>,p98_tag_eq(t,"Var") || p98_tag_eq(t,"Ref"),v => [],v => ks(t)))
@unsafe
def p205u_room( +todo: List<&2,KTerm>, +fuel: U32) -> Bool:
  match todo fuel:
    case Nil{} _: True{}
    case _ 0: False{}
    case Con{t,rest} _: p205u_room(nt_append(KTerm,p205u_children(t),rest),U32.sub(fuel,1))
@unsafe
def p205u_exists(+book: List<&2,KDef>, +todo: List<&2,KTerm>, +fuel: U32) -> Bool:
  match todo fuel:
    case Nil{} _: False{}
    case _ 0: False{}
    case Con{t,rest} _:
      p205u_literal_good(p205u_literal(book,j_strip(t))) ||
        p205u_exists(book,nt_append(KTerm,p205u_children(t),rest),U32.sub(fuel,1))
@unsafe
def p205u_attempt(+book: List<&2,KDef>, +input: KTerm) -> KTerm:
  kc(KTerm,p205u_room([input],2048) && p205u_exists(book,[input],2048),u =>
    p205u_bounded(book,p205u_clean(input),norm_book_bound(book)),u => atom("Absent"))
@unsafe
def p205u_bounded(+book: List<&2,KDef>, +clean: KTerm, +bound: U32) -> KTerm:
  kc(KTerm,db(lookup(book,"String")) && db(lookup(book,"Char")) && db(lookup(book,"U32")) &&
    U32.is_lt(bound,4294900000),u => p205u_finished(p205u_eval(book,clean,U32.inc(bound),0,256)),u => atom("Absent"))
