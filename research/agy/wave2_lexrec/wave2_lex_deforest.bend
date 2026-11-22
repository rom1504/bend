# Wave 2 Track D: General Scalar/Interval Specialization + String Foldl Deforestation (W2D)
#
# 1. p205v (extended): specializes bounded pure helpers on constant/constructor operands,
#    folds total native U32 ops with literal OR sound U32 interval operands (mod/and/add),
#    folds Bool.and/Bool.or, reduces App(Mat, Ctr), and eliminates unused pure Let bindings.
# 2. w2d: general String left-fold shortcut deforestation + Constructor-Loop Unboxing.
#    Every synthesized helper and rewritten definition is mandatorily rechecked by Bend's
#    kernel checker (check_definition_body + ka_def + jl_checked_error), with exact fallback.

type W2Range is Data:
  W2Range{+lo: U32, +hi: U32, +ok: Bool}

@unsafe
def p205v_static(+t: KTerm) -> Bool:
  core_literal(t) || (p98_tag_eq(t,"Ctr") && p205v_statics(ks(t)))
@unsafe
def p205v_statics(+xs: List<&2,KTerm>) -> Bool:
  match xs:
    case Nil{}: True{}
    case Con{x,rest}: p205v_static(x) && p205v_statics(rest)
@unsafe
def p205v_any(+xs: List<&2,KTerm>) -> Bool:
  match xs:
    case Nil{}: False{}
    case Con{x,rest}: p205v_static(x) || p205v_any(rest)
@unsafe
def p205v_allowed(+t: KTerm) -> Bool:
  +tag = tg(t)
  (String.eq(tag,"Var") || String.eq(tag,"Ref") || core_literal(t) || String.eq(tag,"Ctr") ||
    String.eq(tag,"App") || String.eq(tag,"Lam") || String.eq(tag,"Let") || String.eq(tag,"Bind") ||
    String.eq(tag,"Mat") || String.eq(tag,"Efq")) && p205v_allowed_fields(ks(t))
@unsafe
def p205v_allowed_fields(+xs: List<&2,KTerm>) -> Bool:
  match xs:
    case Nil{}: True{}
    case Con{x,rest}: p205v_allowed(x) && p205v_allowed_fields(rest)

law p205v_closed_ty:
  for +book: List<&2,KDef>
  for +t: KTerm
  for +fuel: U32
  Bool

@unsafe
def p205v_closed_sigma(+book: List<&2,KDef>, +call: KTerm, +fuel: U32) -> Bool:
  kc(Bool,p98_tag_eq(call,"Call") && U32.is_eq(terms_len(ks(call)),2),
    u => p205v_closed_ty(book,p205u_at(ks(call),0),fuel) && p205v_closed_ty(book,p205u_at(ks(call),1),fuel),u =>
  kc(Bool,p98_tag_eq(call,"Call") && String.eq(nm(call),"Sigma") && U32.is_eq(terms_len(ks(call)),4),
    u => p205v_closed_ty(book,p205u_at(ks(call),2),fuel) &&
         p98_tag_eq(j_strip(p205u_at(ks(call),3)),"Lam") &&
         p205v_closed_ty(book,kid(j_strip(p205u_at(ks(call),3)),0),fuel),
    u => False{}))

@unsafe
def p205v_closed_ty_go(+book: List<&2,KDef>, +ty: KTerm, +fuel: U32) -> Bool:
  kc(Bool,(p98_tag_eq(ty,"Ref") || p98_tag_eq(ty,"ADT")) && List.is_empty(&2,KTerm,ks(ty)) && String.eq(dk(lookup(book,nm(ty))),"ADT"),
    u => True{},u =>
  kc(Bool,p98_tag_eq(ty,"App"),v => p205v_closed_sigma(book,j_call_spine(ty,[]),fuel),v => False{}))

@unsafe
def p205v_closed_ty(book, t, fuel):
  kc(Bool,U32.is_eq(fuel,0),u => False{},u =>
    p205v_closed_ty_go(book,j_strip(t),U32.sub(fuel,1)))

@unsafe
def p205v_result_type(+book: List<&2,KDef>, +t: KTerm) -> Bool:
  +ty = j_strip(t)
  kc(Bool,p98_tag_eq(ty,"All"),u => p205v_result_type(book,kid(ty,1)),u =>
    p205v_closed_ty(book,ty,4))

@unsafe
def p205v_bool(+b: Bool) -> KTerm:
  kt("Ctr",kc(String,b,u => "True",u => "False"),0,1,[])
@unsafe
def p205v_binary(+op: String, +a: U32, +b: U32) -> KTerm:
  kc(KTerm,String.eq(op,"u32_is_eq"),u => p205v_bool(U32.is_eq(a,b)),u =>
  kc(KTerm,String.eq(op,"u32_is_ne"),v => p205v_bool(U32.is_ne(a,b)),v =>
  kc(KTerm,String.eq(op,"u32_is_lt"),w => p205v_bool(U32.is_lt(a,b)),w =>
  kc(KTerm,String.eq(op,"u32_is_le"),x => p205v_bool(U32.is_le(a,b)),x =>
  kc(KTerm,String.eq(op,"u32_is_gt"),y => p205v_bool(U32.is_gt(a,b)),y =>
  kc(KTerm,String.eq(op,"u32_is_ge"),z => p205v_bool(U32.is_ge(a,b)),z => p205v_arithmetic(op,a,b)))))))
@unsafe
def p205v_arithmetic(+op: String, +a: U32, +b: U32) -> KTerm:
  kc(KTerm,String.eq(op,"u32_add"),u => KLiteral{"U32",U32.add(a,b),"",0,0},u =>
  kc(KTerm,String.eq(op,"u32_sub"),v => KLiteral{"U32",U32.sub(a,b),"",0,0},v =>
  kc(KTerm,String.eq(op,"u32_mul"),w => KLiteral{"U32",U32.mul(a,b),"",0,0},w =>
  kc(KTerm,String.eq(op,"u32_xor"),x => KLiteral{"U32",U32.xor(a,b),"",0,0},x =>
  kc(KTerm,String.eq(op,"u32_and"),y => KLiteral{"U32",U32.and(a,b),"",0,0},y =>
  kc(KTerm,String.eq(op,"u32_or"),z => KLiteral{"U32",U32.or(a,b),"",0,0},z => atom("Absent")))))))

law p205v_range:
  for +book: List<&2,KDef>
  for +t: KTerm
  for +fuel: U32
  W2Range

@unsafe
def p205v_range_add(+a: W2Range, +b: W2Range) -> W2Range:
  match a b:
    case W2Range{la,ha,oka} W2Range{lb,hb,okb}:
      +s_hi = U32.add(ha,hb)
      +s_lo = U32.add(la,lb)
      kc(W2Range,oka && okb && U32.is_ge(s_hi,ha) && U32.is_ge(s_lo,la),
        u => W2Range{s_lo,s_hi,True{}},u => W2Range{0,0,False{}})

@unsafe
def p205v_range_mod(+rhs: Maybe<&2,U32>) -> W2Range:
  match rhs:
    case Some{k}: kc(W2Range,U32.is_gt(k,0),u => W2Range{0,U32.sub(k,1),True{}},u => W2Range{0,0,False{}})
    case None{}: W2Range{0,0,False{}}

@unsafe
def p205v_range_and(+rhs: Maybe<&2,U32>) -> W2Range:
  match rhs:
    case Some{k}: W2Range{0,k,True{}}
    case None{}: W2Range{0,0,False{}}

@unsafe
def p205v_range_op(+book: List<&2,KDef>, +op: String, +a: KTerm, +b: KTerm, +fuel: U32) -> W2Range:
  kc(W2Range,String.eq(op,"u32_mod"),u => p205v_range_mod(j_u32(b)),u =>
  kc(W2Range,String.eq(op,"u32_and"),v => p205v_range_and(j_u32(b)),v =>
  kc(W2Range,String.eq(op,"u32_add"),w => p205v_range_add(p205v_range(book,a,fuel),p205v_range(book,b,fuel)),
    w => W2Range{0,0,False{}})))

@unsafe
def p205v_range_app(+book: List<&2,KDef>, +t: KTerm, +call: KTerm, +fuel: U32) -> W2Range:
  kc(W2Range,p98_tag_eq(call,"Call") && U32.is_eq(terms_len(ks(call)),2),u =>
    p205v_range_op(book,nd_native_call(book,t),p205u_at(ks(call),0),p205u_at(ks(call),1),fuel),
    u => W2Range{0,0,False{}})

@unsafe
def p205v_range_lit(+book: List<&2,KDef>, +t: KTerm, +fuel: U32, +lit: Maybe<&2,U32>) -> W2Range:
  match lit:
    case Some{n}: W2Range{n,n,True{}}
    case None{}:
      kc(W2Range,p98_tag_eq(t,"App"),u => p205v_range_app(book,t,j_call_spine(t,[]),fuel),
        u => W2Range{0,0,False{}})

@unsafe
def p205v_range(book, t, fuel):
  kc(W2Range,U32.is_eq(fuel,0),u => W2Range{0,0,False{}},u =>
    p205v_range_lit(book,j_strip(t),U32.sub(fuel,1),j_u32(j_strip(t))))

@unsafe
def p205v_range_cmp(+op: String, +ra: W2Range, +rb: W2Range) -> KTerm:
  match ra rb:
    case W2Range{la,ha,oka} W2Range{lb,hb,okb}:
      kc(KTerm,oka && okb,u =>
        kc(KTerm,String.eq(op,"u32_is_le"),a =>
          kc(KTerm,U32.is_le(ha,lb),b => p205v_bool(True{}),b =>
          kc(KTerm,U32.is_gt(la,hb),c => p205v_bool(False{}),c => atom("Absent"))),a =>
        kc(KTerm,String.eq(op,"u32_is_lt"),a =>
          kc(KTerm,U32.is_lt(ha,lb),b => p205v_bool(True{}),b =>
          kc(KTerm,U32.is_ge(la,hb),c => p205v_bool(False{}),c => atom("Absent"))),a =>
        kc(KTerm,String.eq(op,"u32_is_ge"),a =>
          kc(KTerm,U32.is_ge(la,hb),b => p205v_bool(True{}),b =>
          kc(KTerm,U32.is_lt(ha,lb),c => p205v_bool(False{}),c => atom("Absent"))),a =>
        kc(KTerm,String.eq(op,"u32_is_gt"),a =>
          kc(KTerm,U32.is_gt(la,hb),b => p205v_bool(True{}),b =>
          kc(KTerm,U32.is_le(ha,lb),c => p205v_bool(False{}),c => atom("Absent"))),a =>
        kc(KTerm,String.eq(op,"u32_is_eq"),a =>
          kc(KTerm,U32.is_lt(ha,lb) || U32.is_gt(la,hb),b => p205v_bool(False{}),b => atom("Absent")),a =>
        kc(KTerm,String.eq(op,"u32_is_ne"),a =>
          kc(KTerm,U32.is_lt(ha,lb) || U32.is_gt(la,hb),b => p205v_bool(True{}),b => atom("Absent")),a => atom("Absent"))))))),
        u => atom("Absent"))

law p205v_pure:
  for +book: List<&2,KDef>
  for +t: KTerm
  for +fuel: U32
  Bool

@unsafe
def p205v_pure_list(+book: List<&2,KDef>, +xs: List<&2,KTerm>, +fuel: U32) -> Bool:
  match xs:
    case Nil{}: True{}
    case Con{x,rest}: p205v_pure(book,x,fuel) && p205v_pure_list(book,rest,fuel)

@unsafe
def p205v_pure_op(+op: String) -> Bool:
  String.eq(op,"u32_add") || String.eq(op,"u32_sub") || String.eq(op,"u32_mul") ||
  String.eq(op,"u32_xor") || String.eq(op,"u32_and") || String.eq(op,"u32_or") ||
  String.eq(op,"u32_shln") || String.eq(op,"u32_shrn") ||
  String.eq(op,"u32_is_eq") || String.eq(op,"u32_is_ne") || String.eq(op,"u32_is_lt") ||
  String.eq(op,"u32_is_le") || String.eq(op,"u32_is_gt") || String.eq(op,"u32_is_ge") ||
  String.eq(op,"u32_inc") || String.eq(op,"u32_dec")

@unsafe
def p205v_pure_nonzero_mod(+op: String, +args: List<&2,KTerm>) -> Bool:
  match args:
    case Con{_,Con{b,Nil{}}}:
      String.eq(op,"u32_mod") && p205v_range_ok(p205v_range_mod(j_u32(b)))
    case _: False{}

@unsafe
def p205v_pure_def(+book: List<&2,KDef>, +name: String, +fuel: U32) -> Bool:
  +d = lookup(book,name)
  kc(Bool,String.eq(dk(d),"Def") && Bool.not(db(d) || du(d)) && U32.is_eq(dx(d),0) &&
    U32.is_eq(p205u_refs(dv(d),name),0) && p205u_room([dv(d)],128),
    u => p205v_pure(book,p205u_clean(dv(d)),fuel),u => False{})

@unsafe
def p205v_pure_call(+book: List<&2,KDef>, +t: KTerm, +call: KTerm, +fuel: U32) -> Bool:
  kc(Bool,p98_tag_eq(call,"Call") && p205v_pure_list(book,ks(call),fuel),u =>
    p205v_pure_op(nd_native_call(book,t)) ||
    p205v_pure_nonzero_mod(nd_native_call(book,t),ks(call)) ||
    String.eq(nm(call),"Bool.and") || String.eq(nm(call),"Bool.or") ||
    p205v_pure_def(book,nm(call),fuel),
    u => False{})

@unsafe
def p205v_pure_go(+book: List<&2,KDef>, +t: KTerm, +fuel: U32) -> Bool:
  +tag = tg(t)
  kc(Bool,String.eq(tag,"Var") || String.eq(tag,"Ref") || core_literal(t),u => True{},u =>
  kc(Bool,String.eq(tag,"Ctr") || String.eq(tag,"Lam") || String.eq(tag,"Let") || String.eq(tag,"Bind"),
    v => p205v_pure_list(book,ks(t),fuel),v =>
  kc(Bool,String.eq(tag,"App"),w => p205v_pure_call(book,t,j_call_spine(t,[]),fuel),w => False{})))

@unsafe
def p205v_pure(book, t, fuel):
  kc(Bool,U32.is_eq(fuel,0),u => False{},u =>
    p205v_pure_go(book,j_strip(t),U32.sub(fuel,1)))

@unsafe
def p205v_bool_val(+t: KTerm) -> U32:
  +s = j_strip(t)
  kc(U32,p98_tag_eq(s,"Ctr") && List.is_empty(&2,KTerm,ks(s)),u =>
    kc(U32,String.eq(nm(s),"True"),v => 2,v =>
    kc(U32,String.eq(nm(s),"False"),w => 1,w => 0)),u => 0)

@unsafe
def p205v_fold_bool(+book: List<&2,KDef>, +name: String, +a: KTerm, +b: KTerm) -> KTerm:
  +ba = p205v_bool_val(a)
  +bb = p205v_bool_val(b)
  kc(KTerm,String.eq(name,"Bool.and"),u =>
    kc(KTerm,U32.is_eq(ba,2),v => b,v =>
    kc(KTerm,U32.is_eq(ba,1) && p205v_pure(book,b,16),w => p205v_bool(False{}),w =>
    kc(KTerm,U32.is_eq(bb,2),x => a,x =>
    kc(KTerm,U32.is_eq(bb,1) && p205v_pure(book,a,16),y => p205v_bool(False{}),y => atom("Absent"))))),u =>
  kc(KTerm,String.eq(name,"Bool.or"),u =>
    kc(KTerm,U32.is_eq(ba,1),v => b,v =>
    kc(KTerm,U32.is_eq(ba,2) && p205v_pure(book,b,16),w => p205v_bool(True{}),w =>
    kc(KTerm,U32.is_eq(bb,1),x => a,x =>
    kc(KTerm,U32.is_eq(bb,2) && p205v_pure(book,a,16),y => p205v_bool(True{}),y => atom("Absent"))))),u => atom("Absent")))

@unsafe
def p205v_words(+book: List<&2,KDef>, +op: String, +at: KTerm, +bt: KTerm, +a: Maybe<&2,U32>, +b: Maybe<&2,U32>) -> KTerm:
  match a b:
    case Some{x} Some{y}: p205v_binary(op,x,y)
    case _ _: p205v_range_cmp(op,p205v_range(book,at,8),p205v_range(book,bt,8))

@unsafe
def p205v_fold(+book: List<&2,KDef>, +t: KTerm, +call: KTerm, +args: List<&2,KTerm>) -> KTerm:
  match args:
    case Con{a,Con{b,Nil{}}}:
      +bf = p205v_fold_bool(book,nm(call),a,b)
      kc(KTerm,p98_tag_eq(bf,"Absent"),u => p205v_words(book,nd_native_call(book,t),a,b,j_u32(a),j_u32(b)),u => bf)
    case _: atom("Absent")

law p205v_eval:
  for +book: List<&2,KDef>
  for +t: KTerm
  for +next: U32
  for +steps: U32
  for +fuel: U32
  P205UResult

law p205v_apply:
  for +book: List<&2,KDef>
  for +body: KTerm
  for +args: List<&2,KTerm>
  for +next: U32
  for +steps: U32
  for +fuel: U32
  P205UResult

@unsafe
def p205v_field_next(+book: List<&2,KDef>, +rest: List<&2,KTerm>, +fuel: U32, +first: P205UResult) -> P205UFields:
  match first:
    case P205UResult{term,next,steps,ok}:
      kc(P205UFields,ok,u => p205u_field_join(term,True{},p205v_fields(book,rest,next,steps,fuel)),u => P205UFields{[],next,steps,False{}})

@unsafe
def p205v_fields(+book: List<&2,KDef>, +xs: List<&2,KTerm>, +next: U32, +steps: U32, +fuel: U32) -> P205UFields:
  match xs:
    case Nil{}: P205UFields{[],next,steps,True{}}
    case Con{x,rest}: p205v_field_next(book,rest,fuel,p205v_eval(book,x,next,steps,fuel))

@unsafe
def p205v_mat_spine(+t: KTerm, +args: List<&2,KTerm>) -> P205UFields:
  kc(P205UFields,p98_tag_eq(t,"App"),
    u => p205v_mat_spine(kid(t,0),Con{kid(t,1),args}),
    u => P205UFields{Con{t,args},0,0,True{}})

@unsafe
def p205v_try_beta(+book: List<&2,KDef>, +t: KTerm, +next: U32, +steps: U32, +fuel: U32, +sp: P205UFields) -> P205UResult:
  match sp:
    case P205UFields{Con{hd,args},_,_,_}:
      +h = j_strip(hd)
      kc(P205UResult,(p98_tag_eq(h,"Lam") && U32.is_ne(qt(h),0) && U32.is_ne(qt(h),3)) ||
        (p98_tag_eq(h,"Mat") && U32.is_eq(ix(h),0) && U32.is_eq(terms_len(ks(h)),2) &&
          Bool.not(List.is_empty(&2,KTerm,args)) && p98_tag_eq(j_strip(p205u_at(args,0)),"Ctr")),
        u => p205v_apply(book,h,args,next,U32.inc(steps),fuel),
        u => P205UResult{t,next,steps,True{}})
    case _: P205UResult{t,next,steps,True{}}

@unsafe
def p205v_let_step(+book: List<&2,KDef>, +t: KTerm, +b: KTerm, +body: KTerm, +next: U32, +steps: U32, +fuel: U32) -> P205UResult:
  +rhs = kid(b,0)
  +bid = ix(b)
  kc(P205UResult,p205v_static(j_strip(rhs)),
    u => p205v_eval(book,subst(body,bid,j_strip(rhs)),next,U32.inc(steps),fuel),u =>
  kc(P205UResult,U32.is_eq(p205u_vars(body,bid),0) && p205v_pure(book,rhs,16),
    v => p205v_eval(book,body,next,U32.inc(steps),fuel),v =>
    P205UResult{t,next,steps,True{}}))

@unsafe
def p205v_range_ok(+r: W2Range) -> Bool:
  match r:
    case W2Range{_,_,ok}: ok

@unsafe
def p205v_has_range(+book: List<&2,KDef>, +t: KTerm) -> Bool:
  p205v_range_ok(p205v_range(book,t,8))

@unsafe
def p205v_any_with_range(+book: List<&2,KDef>, +xs: List<&2,KTerm>) -> Bool:
  match xs:
    case Nil{}: False{}
    case Con{x,rest}: p205v_static(x) || p205v_has_range(book,x) || p205v_any_with_range(book,rest)

@unsafe
def p205v_after_args(+book: List<&2,KDef>, +t: KTerm, +count: U32) -> KTerm:
  +ty = j_strip(t)
  kc(KTerm,U32.is_eq(count,0),
    u => kc(KTerm,p205v_closed_ty(book,ty,4),v => ty,v => atom("Absent")),
    u => kc(KTerm,p98_tag_eq(ty,"All"),v => p205v_after_args(book,kid(ty,1),U32.sub(count,1)),v => atom("Absent")))

@unsafe
def p205v_typed(+result: P205UResult, +ty: KTerm) -> P205UResult:
  match result:
    case P205UResult{term,next,steps,ok}:
      +need = p98_tag_eq(term,"Let") || (p98_tag_eq(term,"App") && p98_tag_eq(j_strip(kid(term,0)),"Mat"))
      P205UResult{kc(KTerm,need,u => p205u_typed_arg(term,ty),u => term),next,steps,ok}
@unsafe
def p205v_fresh(+book: List<&2,KDef>, +old: KTerm, +args: List<&2,KTerm>, +steps: U32, +fuel: U32, +fresh: FFresh) -> P205UResult:
  match fresh:
    case FFresh{body,next}: p205v_apply(book,body,args,next,U32.inc(steps),fuel)
@unsafe
def p205v_body(+book: List<&2,KDef>, +t: KTerm, +next: U32, +steps: U32, +fuel: U32, +call: KTerm, +d: KDef, +body: KTerm) -> P205UResult:
  kc(P205UResult,p205v_allowed(body) && U32.is_eq(p205u_refs(body,dn(d)),0),u =>
    p205v_typed(p205v_fresh(book,t,ks(call),steps,fuel,f_fresh_term(body,[],next)),p205v_after_args(book,dt(d),terms_len(ks(call)))),u => P205UResult{t,next,steps,True{}})
@unsafe
def p205v_def(+book: List<&2,KDef>, +t: KTerm, +next: U32, +steps: U32, +fuel: U32, +call: KTerm, +d: KDef) -> P205UResult:
  kc(P205UResult,String.eq(dk(d),"Def") && Bool.not(db(d) || du(d)) && U32.is_eq(dx(d),0) &&
    U32.is_eq(da(d),terms_len(ks(call))) && p205u_room([dv(d)],512) && p205v_result_type(book,dt(d)),u =>
      p205v_body(book,t,next,steps,fuel,call,d,p205u_clean(dv(d))),u => P205UResult{t,next,steps,True{}})
@unsafe
def p205v_folded(+book: List<&2,KDef>, +t: KTerm, +next: U32, +steps: U32, +fuel: U32, +call: KTerm, +folded: KTerm) -> P205UResult:
  kc(P205UResult,p98_tag_eq(folded,"Absent"),u =>
    kc(P205UResult,p205v_any_with_range(book,ks(call)),v => p205v_def(book,t,next,steps,fuel,call,lookup(book,nm(call))),v => P205UResult{t,next,steps,True{}}),u =>
    P205UResult{folded,next,U32.inc(steps),True{}})
@unsafe
def p205v_call(+book: List<&2,KDef>, +t: KTerm, +next: U32, +steps: U32, +fuel: U32, +call: KTerm) -> P205UResult:
  kc(P205UResult,p98_tag_eq(call,"Call") && U32.is_eq(qt(nd_head(t)),1) && U32.is_le(terms_len(ks(call)),5),u =>
    p205v_folded(book,t,next,steps,fuel,call,p205v_fold(book,t,call,ks(call))),
    u => p205v_try_beta(book,t,next,steps,fuel,p205v_mat_spine(t,[])))

@unsafe
def p205v_after(+book: List<&2,KDef>, +old: KTerm, +fuel: U32, +fields: P205UFields) -> P205UResult:
  match fields:
    case P205UFields{terms,next,steps,ok}:
      +t = k_with_children(old,terms)
      kc(P205UResult,ok && p98_tag_eq(t,"App"),u => p205v_call(book,t,next,steps,fuel,j_call_spine(t,[])),u =>
        kc(P205UResult,ok && p98_tag_eq(t,"Let") && U32.is_eq(terms_len(ks(t)),2) &&
          p98_tag_eq(kid(t,0),"Bind") && U32.is_eq(terms_len(ks(kid(t,0))),1),v =>
            p205v_let_step(book,t,kid(t,0),kid(t,1),next,steps,fuel),v => P205UResult{t,next,steps,ok}))

@unsafe
def p205v_eval(book, t, next, steps, fuel):
  kc(P205UResult,U32.is_eq(fuel,0) || U32.is_ge(steps,4096),u => P205UResult{t,next,steps,False{}},u =>
    p205v_after(book,t,U32.sub(fuel,1),p205v_fields(book,ks(t),next,steps,U32.sub(fuel,1))))

# Distribute remaining args (when at least one is static) into each arm of a Mat on a dynamic scrutinee.
law p205v_dist_mat:
  for +book: List<&2,KDef>
  for +m: KTerm
  for +rest: List<&2,KTerm>
  for +next: U32
  for +steps: U32
  for +fuel: U32
  P205UResult

@unsafe
def p205v_dist_arm_wrap(+lam: KTerm, +r: P205UResult) -> P205UResult:
  match r:
    case P205UResult{b,next,steps,ok}: P205UResult{k_with_children(lam,[b]),next,steps,ok}

@unsafe
def p205v_dist_arm(+book: List<&2,KDef>, +br: KTerm, +k: U32, +rest: List<&2,KTerm>, +next: U32, +steps: U32, +fuel: U32) -> P205UResult:
  kc(P205UResult,U32.is_eq(k,0),
    u => p205v_apply(book,br,rest,next,steps,fuel),
    u => kc(P205UResult,p98_tag_eq(br,"Lam"),
           v => p205v_dist_arm_wrap(br,p205v_dist_arm(book,kid(br,0),U32.sub(k,1),rest,next,steps,fuel)),
           v => P205UResult{br,next,steps,False{}}))

@unsafe
def p205v_dist_mat_alt(+m: KTerm, +br2: KTerm, +r2: P205UResult) -> P205UResult:
  match r2:
    case P205UResult{alt2,next,steps,ok}: P205UResult{k_with_children(m,[br2,alt2]),next,steps,ok}

@unsafe
def p205v_dist_mat_br(+book: List<&2,KDef>, +m: KTerm, +rest: List<&2,KTerm>, +fuel: U32, +r1: P205UResult) -> P205UResult:
  match r1:
    case P205UResult{br2,next,steps,ok}:
      kc(P205UResult,ok,
        u => p205v_dist_mat_alt(m,br2,p205v_dist_mat(book,kid(m,1),rest,next,steps,fuel)),
        u => P205UResult{m,next,steps,False{}})

@unsafe
def p205v_dist_mat(book, m, rest, next, steps, fuel):
  kc(P205UResult,p98_tag_eq(m,"Efq"),u => P205UResult{m,next,steps,True{}},u =>
  kc(P205UResult,p98_tag_eq(m,"Mat") && U32.is_eq(ix(m),0) && U32.is_eq(terms_len(ks(m)),2),
    v => p205v_dist_mat_br(book,m,rest,fuel,
           p205v_dist_arm(book,kid(m,0),da(j_find_ctor(book,nm(m))),rest,next,steps,fuel)),
    v => P205UResult{m,next,steps,False{}}))

@unsafe
def p205v_dist_wrap(+old: KTerm, +arg: KTerm, +r: P205UResult) -> P205UResult:
  match r:
    case P205UResult{m2,next,steps,ok}:
      kc(P205UResult,ok,u => P205UResult{app(m2,arg),next,steps,True{}},u => P205UResult{old,next,steps,True{}})

@unsafe
def p205v_apply(book, body, args, next, steps, fuel):
  match args:
    case Nil{}: p205v_eval(book,body,next,steps,fuel)
    case Con{arg,rest}:
      +sa = j_strip(arg)
      kc(P205UResult,p98_tag_eq(body,"Lam") && U32.is_ne(qt(body),0) && U32.is_ne(qt(body),3),u =>
        kc(P205UResult,p205v_static(sa) || p98_tag_eq(sa,"Var") || (p205v_has_range(book,sa) && p205u_room([sa],16) && p205v_pure(book,sa,8)),
          v => p205v_apply(book,subst(kid(body,0),ix(body),sa),rest,next,steps,fuel),v =>
          kc(P205UResult,U32.is_eq(p205u_vars(kid(body,0),ix(body)),0) && p205v_pure(book,sa,16),
            w => p205v_apply(book,kid(body,0),rest,next,steps,fuel),
            w => p205u_bound(book,body,arg,p205v_apply(book,kid(body,0),rest,next,steps,fuel)))),u =>
      kc(P205UResult,p98_tag_eq(body,"Mat") && U32.is_eq(ix(body),0) && U32.is_eq(terms_len(ks(body)),2) && p98_tag_eq(sa,"Ctr"),v =>
        kc(P205UResult,String.eq(nm(body),nm(sa)),w => p205v_apply(book,kid(body,0),nt_append(KTerm,ks(sa),rest),next,steps,fuel),w =>
          p205v_apply(book,kid(body,1),args,next,steps,fuel)),v =>
      kc(P205UResult,p98_tag_eq(body,"Mat") && U32.is_eq(ix(body),0) && U32.is_eq(terms_len(ks(body)),2) &&
        Bool.not(List.is_empty(&2,KTerm,rest)) && p205v_any(rest),
        w => p205v_dist_wrap(nd_reapply(body,args),arg,p205v_dist_mat(book,body,rest,next,U32.inc(steps),fuel)),
        w => P205UResult{nd_reapply(body,args),next,steps,True{}})))

@unsafe
def p205v_finish(+old: KTerm, +result: P205UResult) -> KTerm:
  match result:
    case P205UResult{term,next,steps,ok}:
      kc(KTerm,ok && U32.is_gt(nq_layout_remaining([term],32769),0),u => term,u => old)

@unsafe
def p205v_on(book, first):
  kc(KTerm,p98_tag_eq(first,"Absent"),u => first,u =>
  kc(KTerm,j_u32_native_book(book) && U32.is_lt(U32.max(norm_book_bound(book),norm_max_term(first)),4294800000),v =>
    p205v_finish(first,p205v_eval(book,first,U32.inc(U32.max(norm_book_bound(book),norm_max_term(first))),0,1024)),v => first))

# ==============================================================================
# W2D: General String Foldl Shortcut Deforestation + Constructor-Loop Unboxing
# ==============================================================================

type W2Fold is Data:
  W2Fold{+fname: String, +st_ty: KTerm, +nil_fn: KTerm, +step_fn: KTerm, +ok: Bool}

type W2StepExtract is Data:
  W2StepExtract{+term: KTerm, +found: Bool}

type W2Builder is Data:
  W2Builder{+pname: String, +arity: U32, +rec: Bool, +lams0: List<&2,KTerm>, +lams1: List<&2,KTerm>, +lets: List<&2,KTerm>, +ch_expr: KTerm, +rec_args: List<&2,KTerm>, +ok: Bool}

type W2State is Data:
  W2State{+ctx: List<&2,KDef>, +added: List<&2,KDef>, +next: U32, +term: KTerm, +changed: Bool}

@unsafe
def w2d_last(xs: List<&2,KTerm>) -> KTerm:
  match xs:
    case Nil{}: atom("Absent")
    case Con{x,Nil{}}: x
    case Con{x,rest}: w2d_last(rest)

@unsafe
def w2d_init(xs: List<&2,KTerm>) -> List<&2,KTerm>:
  match xs:
    case Nil{}: []
    case Con{x,Nil{}}: []
    case Con{x,rest}: Con{x,w2d_init(rest)}

law w2d_extract_step:
  for +t: KTerm
  for +fname: String
  for +tid: U32
  W2StepExtract

@unsafe
def w2d_extract_wrap_let(+b: KTerm, +r: W2StepExtract) -> W2StepExtract:
  match r:
    case W2StepExtract{term,found}: W2StepExtract{kt("Let","",0,0,[b,term]),found}

@unsafe
def w2d_extract_step_let(+ks_list: List<&2,KTerm>, +fname: String, +tid: U32) -> W2StepExtract:
  match ks_list:
    case Con{b,Con{body,Nil{}}}:
      kc(W2StepExtract,U32.is_eq(p205u_refs(b,fname),0) && U32.is_eq(p205u_vars(b,tid),0),
        u => w2d_extract_wrap_let(b,w2d_extract_step(body,fname,tid)),
        u => W2StepExtract{body,False{}})
    case _: W2StepExtract{atom("Absent"),False{}}

@unsafe
def w2d_extract_wrap_lam(+lam: KTerm, +r: W2StepExtract) -> W2StepExtract:
  match r:
    case W2StepExtract{term,found}: W2StepExtract{k_with_children(lam,[term]),found}

@unsafe
def w2d_extract_wrap_mat(+mat: KTerm, +alt: KTerm, +r: W2StepExtract) -> W2StepExtract:
  match r:
    case W2StepExtract{term,found}: W2StepExtract{k_with_children(mat,[term,alt]),found}

@unsafe
def w2d_extract_step_call(+t: KTerm, +call: KTerm, +fname: String, +tid: U32) -> W2StepExtract:
  kc(W2StepExtract,p98_tag_eq(call,"Call") && String.eq(nm(call),fname) && U32.is_eq(terms_len(ks(call)),2) &&
    agy_bf_is_var(p205u_at(ks(call),0),tid) &&
    U32.is_eq(p205u_vars(p205u_at(ks(call),1),tid),0) &&
    U32.is_eq(p205u_refs(p205u_at(ks(call),1),fname),0),
    u => W2StepExtract{p205u_at(ks(call),1),True{}},
    u => W2StepExtract{t,False{}})

@unsafe
def w2d_extract_step(t, fname, tid):
  +s = j_strip(t)
  kc(W2StepExtract,p98_tag_eq(s,"App"),u => w2d_extract_step_call(s,j_call_spine(s,[]),fname,tid),u =>
  kc(W2StepExtract,p98_tag_eq(s,"Let"),v => w2d_extract_step_let(ks(s),fname,tid),v =>
  kc(W2StepExtract,p98_tag_eq(s,"Lam"),w => w2d_extract_wrap_lam(s,w2d_extract_step(kid(s,0),fname,tid)),w =>
  kc(W2StepExtract,p98_tag_eq(s,"Mat") && U32.is_eq(terms_len(ks(s)),2) && p98_tag_eq(kid(s,1),"Efq"),
    x => w2d_extract_wrap_mat(s,kid(s,1),w2d_extract_step(kid(s,0),fname,tid)),
    x => W2StepExtract{s,False{}}))))

@unsafe
def w2d_fold_chr_res(+fname: String, +st_ty: KTerm, +nil_br: KTerm, +mchr: KTerm, +lc: KTerm, +r: W2StepExtract) -> W2Fold:
  match r:
    case W2StepExtract{step_body,True{}}:
      W2Fold{fname,st_ty,nil_br,k_with_children(mchr,[k_with_children(lc,[step_body]),kid(mchr,1)]),True{}}
    case _: W2Fold{fname,st_ty,nil_br,atom("Absent"),False{}}

@unsafe
def w2d_fold_lam_res(+fname: String, +st_ty: KTerm, +nil_br: KTerm, +lch: KTerm, +r: W2StepExtract) -> W2Fold:
  match r:
    case W2StepExtract{step_body,True{}}:
      W2Fold{fname,st_ty,nil_br,k_with_children(lch,[step_body]),True{}}
    case _: W2Fold{fname,st_ty,nil_br,atom("Absent"),False{}}

@unsafe
def w2d_fold_scon(+fname: String, +st_ty: KTerm, +nil_br: KTerm, +scon_br: KTerm) -> W2Fold:
  kc(W2Fold,p98_tag_eq(scon_br,"Mat") && String.eq(nm(scon_br),"Chr") && U32.is_eq(terms_len(ks(scon_br)),2) &&
    p98_tag_eq(kid(scon_br,1),"Efq") && p98_tag_eq(kid(scon_br,0),"Lam") && p98_tag_eq(kid(kid(scon_br,0),0),"Lam"),
    u => w2d_fold_chr_res(fname,st_ty,nil_br,scon_br,kid(scon_br,0),
           w2d_extract_step(kid(kid(kid(scon_br,0),0),0),fname,ix(kid(kid(scon_br,0),0)))),u =>
  kc(W2Fold,p98_tag_eq(scon_br,"Lam") && p98_tag_eq(kid(scon_br,0),"Lam"),
    v => w2d_fold_lam_res(fname,st_ty,nil_br,scon_br,
           w2d_extract_step(kid(kid(scon_br,0),0),fname,ix(kid(scon_br,0)))),
    v => W2Fold{fname,st_ty,nil_br,atom("Absent"),False{}}))

@unsafe
def w2d_check_fold_body(+fname: String, +st_ty: KTerm, +body: KTerm) -> W2Fold:
  kc(W2Fold,p98_tag_eq(body,"Mat") && String.eq(nm(body),"SNil") && U32.is_eq(terms_len(ks(body)),2) &&
    U32.is_eq(p205u_refs(kid(body,0),fname),0) &&
    p98_tag_eq(kid(body,1),"Mat") && String.eq(nm(kid(body,1)),"SCon") && U32.is_eq(terms_len(ks(kid(body,1))),2) &&
    p98_tag_eq(kid(kid(body,1),1),"Efq"),
    u => w2d_fold_scon(fname,st_ty,kid(body,0),kid(kid(body,1),0)),
    u => W2Fold{fname,st_ty,atom("Absent"),atom("Absent"),False{}})

@unsafe
def w2d_check_fold(+book: List<&2,KDef>, +d: KDef) -> W2Fold:
  +fname = dn(d)
  +ty0 = j_strip(dt(d))
  kc(W2Fold,String.eq(dk(d),"Def") && Bool.not(db(d) || du(d)) && U32.is_eq(dx(d),0) && U32.is_eq(da(d),2) &&
    p98_tag_eq(ty0,"All") && p198e_owner(kid(ty0,0),"String") && p98_tag_eq(j_strip(kid(ty0,1)),"All") &&
    p205v_closed_ty(book,kid(j_strip(kid(ty0,1)),0),4) && p205u_room([dv(d)],256),
    u => w2d_check_fold_body(fname,kid(j_strip(kid(ty0,1)),0),p205u_clean(dv(d))),
    u => W2Fold{fname,atom("Absent"),atom("Absent"),atom("Absent"),False{}})

type W2Lets is Data:
  W2Lets{+binds: List<&2,KTerm>, +body: KTerm}

@unsafe
def w2d_peel_lets_cons(+b: KTerm, +r: W2Lets) -> W2Lets:
  match r:
    case W2Lets{bs,body}: W2Lets{Con{b,bs},body}

@unsafe
def w2d_peel_lets(+t: KTerm) -> W2Lets:
  +s = j_strip(t)
  kc(W2Lets,p98_tag_eq(s,"Let") && U32.is_eq(terms_len(ks(s)),2) && p98_tag_eq(kid(s,0),"Bind"),
    u => w2d_peel_lets_cons(kid(s,0),w2d_peel_lets(kid(s,1))),
    u => W2Lets{[],s})

@unsafe
def w2d_wrap_lets(bs: List<&2,KTerm>, +body: KTerm) -> KTerm:
  match bs:
    case Nil{}: body
    case Con{b,rest}: kt("Let","",0,0,[b,w2d_wrap_lets(rest,body)])

@unsafe
def w2d_check_builder_ty(+t: KTerm, +rem: U32) -> Bool:
  +s = j_strip(t)
  kc(Bool,U32.is_eq(rem,0),u => p198e_owner(s,"String"),u =>
  kc(Bool,U32.is_eq(rem,1),v => p98_tag_eq(s,"All") && p198e_owner(kid(s,0),"String") && p198e_owner(kid(s,1),"String"),v =>
    p98_tag_eq(s,"All") && w2d_check_builder_ty(kid(s,1),U32.sub(rem,1))))

@unsafe
def w2d_no_var_list(xs: List<&2,KTerm>, +id: U32) -> Bool:
  match xs:
    case Nil{}: True{}
    case Con{x,rest}: U32.is_eq(p205u_vars(x,id),0) && w2d_no_var_list(rest,id)

@unsafe
def w2d_no_ref_list(xs: List<&2,KTerm>, +name: String) -> Bool:
  match xs:
    case Nil{}: True{}
    case Con{x,rest}: U32.is_eq(p205u_refs(x,name),0) && w2d_no_ref_list(rest,name)

@unsafe
def w2d_check_rec_call(+pname: String, +ar: U32, +lams0: List<&2,KTerm>, +lams1: List<&2,KTerm>, +bs: List<&2,KTerm>, +ch_expr: KTerm, +rid: U32, +call: KTerm) -> W2Builder:
  kc(W2Builder,p98_tag_eq(call,"Call") && String.eq(nm(call),pname) && U32.is_eq(terms_len(ks(call)),ar) &&
    agy_bf_is_var(w2d_last(ks(call)),rid) && w2d_no_var_list(w2d_init(ks(call)),rid) && w2d_no_ref_list(ks(call),pname),
    u => W2Builder{pname,ar,True{},lams0,lams1,bs,ch_expr,w2d_init(ks(call)),True{}},
    u => W2Builder{pname,ar,False{},[],[],[],atom("Absent"),[],False{}})

@unsafe
def w2d_check_rec_succ(+pname: String, +ar: U32, +lams0: List<&2,KTerm>, +lams1: List<&2,KTerm>, +rid: U32, +wl: W2Lets) -> W2Builder:
  match wl:
    case W2Lets{bs,inner}:
      kc(W2Builder,p98_tag_eq(inner,"Ctr") && String.eq(nm(inner),"SCon") && U32.is_eq(terms_len(ks(inner)),2) &&
        U32.is_eq(p205u_vars(kid(inner,0),rid),0) && U32.is_eq(p205u_refs(kid(inner,0),pname),0) &&
        w2d_no_var_list(bs,rid) && w2d_no_ref_list(bs,pname) && p98_tag_eq(j_strip(kid(inner,1)),"App"),
        u => w2d_check_rec_call(pname,ar,lams0,lams1,bs,kid(inner,0),rid,j_call_spine(j_strip(kid(inner,1)),[])),
        u => W2Builder{pname,ar,False{},[],[],[],atom("Absent"),[],False{}})

@unsafe
def w2d_check_rec_peels(+pname: String, +ar: U32, +zp: AgyPeel, +sp: AgyPeel) -> W2Builder:
  match zp sp:
    case AgyPeel{lams0,zbody,ok0} AgyPeel{lams1,sbody,ok1}:
      +zrest = w2d_last(lams0)
      +srest = w2d_last(lams1)
      kc(W2Builder,ok0 && ok1 && agy_bf_is_var(zbody,ix(zrest)),
        u => w2d_check_rec_succ(pname,ar,lams0,lams1,ix(srest),w2d_peel_lets(sbody)),
        u => W2Builder{pname,ar,False{},[],[],[],atom("Absent"),[],False{}})

@unsafe
def w2d_check_rec_body(+pname: String, +ar: U32, +body: KTerm) -> W2Builder:
  kc(W2Builder,p98_tag_eq(body,"Mat") && String.eq(nm(body),"Zero") && U32.is_eq(terms_len(ks(body)),2) &&
    p98_tag_eq(kid(body,1),"Mat") && String.eq(nm(kid(body,1)),"Succ") && U32.is_eq(terms_len(ks(kid(body,1))),2) &&
    p98_tag_eq(kid(kid(body,1),1),"Efq"),
    u => w2d_check_rec_peels(pname,ar,agy_bf_peel(kid(body,0),U32.sub(ar,1)),agy_bf_peel(kid(kid(body,1),0),ar)),
    u => W2Builder{pname,ar,False{},[],[],[],atom("Absent"),[],False{}})

@unsafe
def w2d_check_rec_builder(+d: KDef) -> W2Builder:
  +pname = dn(d)
  +ar = da(d)
  +ty0 = j_strip(dt(d))
  kc(W2Builder,String.eq(dk(d),"Def") && Bool.not(db(d) || du(d)) && U32.is_eq(dx(d),0) &&
    U32.is_ge(ar,2) && U32.is_le(ar,5) &&
    p98_tag_eq(ty0,"All") && p198e_owner(kid(ty0,0),"Nat") &&
    w2d_check_builder_ty(kid(ty0,1),U32.sub(ar,1)) && p205u_room([dv(d)],256),
    u => w2d_check_rec_body(pname,ar,p205u_clean(dv(d))),
    u => W2Builder{pname,ar,False{},[],[],[],atom("Absent"),[],False{}})

@unsafe
def w2d_builder_fused_ty(+t: KTerm, +rem: U32, +st_ty: KTerm) -> KTerm:
  +s = j_strip(t)
  kc(KTerm,U32.is_eq(rem,1),
    u => all(2,nm(s),ix(s),st_ty,st_ty),
    u => all(qt(s),nm(s),ix(s),kid(s,0),w2d_builder_fused_ty(kid(s,1),U32.sub(rem,1),st_ty)))

# ==============================================================================
# General Constructor-Loop Unboxing
# ==============================================================================
type W2UnboxArm is Data:
  W2UnboxArm{+cname: String, +hid: U32, +h_next: KTerm, +rec_args: List<&2,KTerm>, +ok: Bool}

law w2d_find_self_arm:
  for +t: KTerm
  for +hname: String
  for +ar: U32
  for +acc_id: U32
  W2UnboxArm

@unsafe
def w2d_check_self_arm_ctr(+cname: String, +hid: U32, +rargs: List<&2,KTerm>, +m_expr: KTerm, +acc_id: U32) -> W2UnboxArm:
  kc(W2UnboxArm,p98_tag_eq(m_expr,"Ctr") && String.eq(nm(m_expr),cname) && U32.is_eq(terms_len(ks(m_expr)),1) &&
    U32.is_eq(p205u_vars(kid(m_expr,0),acc_id),0),
    u => W2UnboxArm{cname,hid,kid(m_expr,0),rargs,True{}},
    u => W2UnboxArm{"",0,atom("Absent"),[],False{}})

@unsafe
def w2d_check_self_arm_st(+cname: String, +hid: U32, +rargs: List<&2,KTerm>, +st: KTerm, +acc_id: U32) -> W2UnboxArm:
  kc(W2UnboxArm,p98_tag_eq(st,"Ctr") && String.eq(nm(st),"Tuple") && U32.is_eq(terms_len(ks(st)),2) &&
    agy_bf_is_var(kid(st,1),acc_id) && w2d_no_var_list(rargs,acc_id) && w2d_no_var_list(rargs,hid),
    u => w2d_check_self_arm_ctr(cname,hid,rargs,j_strip(kid(st,0)),acc_id),
    u => W2UnboxArm{"",0,atom("Absent"),[],False{}})

@unsafe
def w2d_check_self_arm_call(+cname: String, +hid: U32, +call: KTerm, +hname: String, +ar: U32, +acc_id: U32) -> W2UnboxArm:
  kc(W2UnboxArm,p98_tag_eq(call,"Call") && String.eq(nm(call),hname) && U32.is_eq(terms_len(ks(call)),ar),
    u => w2d_check_self_arm_st(cname,hid,w2d_init(ks(call)),j_strip(w2d_last(ks(call))),acc_id),
    u => W2UnboxArm{"",0,atom("Absent"),[],False{}})

@unsafe
def w2d_pick_arm(+cur: W2UnboxArm, +alt: KTerm, +hname: String, +ar: U32, +acc_id: U32) -> W2UnboxArm:
  match cur:
    case W2UnboxArm{_,_,_,_,True{}}: cur
    case _: w2d_find_self_arm(alt,hname,ar,acc_id)

@unsafe
def w2d_find_self_arm_branch(+cname: String, +br: KTerm, +alt: KTerm, +hname: String, +ar: U32, +acc_id: U32) -> W2UnboxArm:
  +sb = j_strip(br)
  w2d_pick_arm(
    kc(W2UnboxArm,p98_tag_eq(sb,"Lam") && p98_tag_eq(j_strip(kid(sb,0)),"App"),
      u => w2d_check_self_arm_call(cname,ix(sb),j_call_spine(j_strip(kid(sb,0)),[]),hname,ar,acc_id),
      u => W2UnboxArm{"",0,atom("Absent"),[],False{}}),
    alt,hname,ar,acc_id)

@unsafe
def w2d_find_self_arm(t, hname, ar, acc_id):
  +s = j_strip(t)
  kc(W2UnboxArm,p98_tag_eq(s,"Mat") && U32.is_eq(terms_len(ks(s)),2),
    u => w2d_find_self_arm_branch(nm(s),kid(s,0),kid(s,1),hname,ar,acc_id),
    u => W2UnboxArm{"",0,atom("Absent"),[],False{}})

law w2d_rewrite_to_inner:
  for +t: KTerm
  for +hname: String
  for +cname: String
  for +iname: String
  for +ar: U32
  KTerm

@unsafe
def w2d_rewrite_to_inner_list(xs: List<&2,KTerm>, +hname: String, +cname: String, +iname: String, +ar: U32) -> List<&2,KTerm>:
  match xs:
    case Nil{}: []
    case Con{x,rest}: Con{w2d_rewrite_to_inner(x,hname,cname,iname,ar),w2d_rewrite_to_inner_list(rest,hname,cname,iname,ar)}

@unsafe
def w2d_rewrite_to_inner_st(+t: KTerm, +rargs: List<&2,KTerm>, +st: KTerm, +cname: String, +iname: String) -> KTerm:
  kc(KTerm,p98_tag_eq(st,"Ctr") && String.eq(nm(st),"Tuple") && U32.is_eq(terms_len(ks(st)),2) &&
    p98_tag_eq(j_strip(kid(st,0)),"Ctr") && String.eq(nm(j_strip(kid(st,0))),cname) &&
    U32.is_eq(terms_len(ks(j_strip(kid(st,0)))),1),
    u => kt("Ctr","Tuple",0,1,[
           kt("Ctr",cname,0,1,[agy_bf_apps(ref(iname),nt_append(KTerm,rargs,[kid(j_strip(kid(st,0)),0)]))]),
           kid(st,1)]),
    u => t)

@unsafe
def w2d_rewrite_to_inner_call(+t: KTerm, +call: KTerm, +hname: String, +cname: String, +iname: String, +ar: U32) -> KTerm:
  kc(KTerm,p98_tag_eq(call,"Call") && String.eq(nm(call),hname) && U32.is_eq(terms_len(ks(call)),ar),
    u => w2d_rewrite_to_inner_st(t,w2d_init(ks(call)),j_strip(w2d_last(ks(call))),cname,iname),
    u => k_with_children(t,w2d_rewrite_to_inner_list(ks(t),hname,cname,iname,ar)))

@unsafe
def w2d_rewrite_to_inner(t, hname, cname, iname, ar):
  kc(KTerm,p98_tag_eq(t,"App"),
    u => w2d_rewrite_to_inner_call(t,j_call_spine(t,[]),hname,cname,iname,ar),
    u => k_with_children(t,w2d_rewrite_to_inner_list(ks(t),hname,cname,iname,ar)))

@unsafe
def w2d_ctor_field_ty(+book: List<&2,KDef>, +cname: String) -> KTerm:
  +cd = j_find_ctor(book,cname)
  +cty = j_strip(dt(cd))
  kc(KTerm,p98_tag_eq(cty,"All"),u => kid(cty,0),u => atom("Absent"))

@unsafe
def w2d_emit_unboxed_outer(+ctx: List<&2,KDef>, +added: List<&2,KDef>, +hdef: KDef, +raw_body: KTerm, +hname: String, +cname: String, +iname: String, +ar: U32, +next: U32, +chk_i: KDef) -> W2State:
  +ctx1 = agy_bf_add_def(ctx,chk_i)
  +new_body = w2d_rewrite_to_inner(raw_body,hname,cname,iname,ar)
  +hdef2 = dg_event_output(hdef,new_body)
  +ctx2 = agy_bf_add_def(ctx1,hdef2)
  +chk_h = agy_bf_check_one(ctx2,hdef2)
  kc(W2State,String.eq(dk(chk_h),"Absent"),
    u => W2State{ctx,added,next,atom("Absent"),False{}},
    u => W2State{agy_bf_add_def(ctx1,chk_h),Con{chk_h,Con{chk_i,added}},next,atom("Absent"),True{}})

@unsafe
def w2d_emit_unboxed(+ctx: List<&2,KDef>, +added: List<&2,KDef>, +hdef: KDef, +raw_body: KTerm, +hname: String, +cname: String, +iname: String, +fty: KTerm, +ar: U32, +next: U32, +zbr: KTerm, +lams1: List<&2,KTerm>, +bs: List<&2,KTerm>, +hid: U32, +h_next: KTerm, +rargs: List<&2,KTerm>) -> W2State:
  +zvs = agy_bf_fresh_lams(U32.sub(ar,1),next,0)
  +z_body = agy_bf_wrap_vars(zvs,w2d_last(zvs))
  +s_lams = nt_append(KTerm,w2d_init(lams1),[agy_bf_lam("$w2h",hid,2,atom("Absent"))])
  +rec_call = agy_bf_apps(ref(iname),nt_append(KTerm,rargs,[h_next]))
  +s_body = agy_bf_wrap_lams(s_lams,w2d_wrap_lets(bs,rec_call))
  +ibody = kt("Mat","Zero",0,0,[z_body,kt("Mat","Succ",0,0,[s_body,atom("Efq")])])
  +ity = w2d_builder_fused_ty(dt(hdef),ar,fty)
  +idef = {KDef{iname,"Def",ar,0,ity,ibody,[],False{},False{}} : KDef}
  +ctx1 = agy_bf_add_def(ctx,idef)
  +chk_i = agy_bf_check_one(ctx1,idef)
  kc(W2State,String.eq(dk(chk_i),"Absent"),
    u => W2State{ctx,added,U32.add(next,16),atom("Absent"),False{}},
    u => w2d_emit_unboxed_outer(ctx,added,hdef,raw_body,hname,cname,iname,ar,U32.add(next,16),chk_i))

@unsafe
def w2d_try_unbox_arm(+ctx: List<&2,KDef>, +added: List<&2,KDef>, +hdef: KDef, +raw_body: KTerm, +hname: String, +ar: U32, +next: U32, +zbr: KTerm, +lams1: List<&2,KTerm>, +bs: List<&2,KTerm>, +tapp: KTerm, +acc_id: U32, +arm: W2UnboxArm) -> W2State:
  match arm:
    case W2UnboxArm{cname,hid,h_next,rargs,True{}}:
      +fty = w2d_ctor_field_ty(ctx,cname)
      +iname = hname ++ "$c"
      kc(W2State,Bool.not(p98_tag_eq(fty,"Absent")) && String.eq(dk(lookup(ctx,iname)),"Absent"),
        u => w2d_emit_unboxed(ctx,added,hdef,raw_body,hname,cname,iname,fty,ar,next,zbr,lams1,bs,hid,h_next,rargs),
        u => W2State{ctx,added,next,atom("Absent"),False{}})
    case _: W2State{ctx,added,next,atom("Absent"),False{}}

@unsafe
def w2d_try_unbox_tuple_lets(+ctx: List<&2,KDef>, +added: List<&2,KDef>, +hdef: KDef, +raw_body: KTerm, +hname: String, +ar: U32, +next: U32, +zbr: KTerm, +lams1: List<&2,KTerm>, +lm: KTerm, +lacc: KTerm, +wl: W2Lets) -> W2State:
  match wl:
    case W2Lets{bs,inner}:
      +tbody = j_strip(inner)
      kc(W2State,p98_tag_eq(tbody,"App") && agy_bf_is_var(kid(tbody,1),ix(lm)),
        u => w2d_try_unbox_arm(ctx,added,hdef,raw_body,hname,ar,next,zbr,nt_append(KTerm,lams1,[lm]),bs,tbody,ix(lacc),
          w2d_find_self_arm(kid(tbody,0),hname,ar,ix(lacc))),
        u => W2State{ctx,added,next,atom("Absent"),False{}})

@unsafe
def w2d_try_unbox_peel(+ctx: List<&2,KDef>, +added: List<&2,KDef>, +hdef: KDef, +raw_body: KTerm, +hname: String, +ar: U32, +next: U32, +zbr: KTerm, +sp: AgyPeel) -> W2State:
  match sp:
    case AgyPeel{lams1,sbody,True{}}:
      +si = j_strip(sbody)
      kc(W2State,p98_tag_eq(si,"Mat") && String.eq(nm(si),"Tuple") &&
        p98_tag_eq(kid(si,0),"Lam") && p98_tag_eq(kid(kid(si,0),0),"Lam"),
        u => w2d_try_unbox_tuple_lets(ctx,added,hdef,raw_body,hname,ar,next,zbr,lams1,
          kid(si,0),kid(kid(si,0),0),w2d_peel_lets(kid(kid(kid(si,0),0),0))),
        u => W2State{ctx,added,next,atom("Absent"),False{}})
    case _: W2State{ctx,added,next,atom("Absent"),False{}}

@unsafe
def w2d_try_unbox_loop(+ctx: List<&2,KDef>, +added: List<&2,KDef>, +hdef: KDef, +raw_body: KTerm, +hname: String, +ar: U32, +next: U32) -> W2State:
  +body = p205u_clean(dv(hdef))
  kc(W2State,p98_tag_eq(body,"Mat") && String.eq(nm(body),"Zero") &&
    p98_tag_eq(kid(body,1),"Mat") && String.eq(nm(kid(body,1)),"Succ"),
    u => w2d_try_unbox_peel(ctx,added,hdef,raw_body,hname,ar,next,kid(body,0),agy_bf_peel(kid(kid(body,1),0),U32.sub(ar,1))),
    u => W2State{ctx,added,next,atom("Absent"),False{}})

# ==============================================================================
# Build & check fused worker P$w2d$F
# ==============================================================================
@unsafe
def w2d_after_fused_res(+ctx: List<&2,KDef>, +added: List<&2,KDef>, +next: U32, +chk: KDef, +hname: String, +unb: W2State) -> W2State:
  match unb:
    case W2State{ctx2,added2,next2,_,True{}}: W2State{ctx2,added2,next2,ref(hname),True{}}
    case _: W2State{agy_bf_add_def(ctx,chk),Con{chk,added},next,ref(hname),True{}}

@unsafe
def w2d_wrap_rec_in_step(+t: KTerm, +hname: String, +rargs: List<&2,KTerm>, +bs: List<&2,KTerm>) -> KTerm:
  +s = j_strip(t)
  kc(KTerm,p98_tag_eq(s,"Mat") && String.eq(nm(s),"Tuple") && U32.is_eq(terms_len(ks(s)),2) &&
    p98_tag_eq(kid(s,0),"Lam") && p98_tag_eq(kid(kid(s,0),0),"Lam"),
    u => k_with_children(s,[
           k_with_children(kid(s,0),[
             k_with_children(kid(kid(s,0),0),[
               w2d_wrap_lets(bs,agy_bf_apps(ref(hname),nt_append(KTerm,rargs,[kid(kid(kid(s,0),0),0)])))])]),
           kid(s,1)]),
    u => kc(KTerm,p98_tag_eq(s,"Lam"),
           v => k_with_children(s,[w2d_wrap_lets(bs,agy_bf_apps(ref(hname),nt_append(KTerm,rargs,[kid(s,0)])))]),
           v => atom("Absent")))

@unsafe
def w2d_strip_alls(+t: KTerm) -> KTerm:
  +s = j_strip(t)
  kc(KTerm,p98_tag_eq(s,"All"),u => w2d_strip_alls(kid(s,1)),u => s)

@unsafe
def w2d_ctor_owner_ty(+book: List<&2,KDef>, +cname: String) -> KTerm:
  +cd = j_find_ctor(book,cname)
  +cty = j_strip(dt(cd))
  w2d_strip_alls(cty)

@unsafe
def w2d_mat_type(+book: List<&2,KDef>, +m: KTerm, +st_ty: KTerm, +ret_ty: KTerm) -> KTerm:
  +sm = j_strip(m)
  kc(KTerm,p98_tag_eq(sm,"Mat") && U32.is_eq(terms_len(ks(sm)),2),u =>
    w2d_mat_type_go(book,sm,st_ty,ret_ty,
      kc(KTerm,String.eq(nm(sm),"Tuple"),v => st_ty,v => w2d_ctor_owner_ty(book,nm(sm)))),
    u => ret_ty)

@unsafe
def w2d_mat_type_go(+book: List<&2,KDef>, +sm: KTerm, +st_ty: KTerm, +ret_ty: KTerm, +dom: KTerm) -> KTerm:
  kc(KTerm,p98_tag_eq(dom,"Absent"),u => atom("Absent"),u =>
    all(1,"$w2m",0,dom,w2d_mat_type_cod(book,j_strip(kid(sm,0)),st_ty,ret_ty)))

@unsafe
def w2d_mat_type_cod(+book: List<&2,KDef>, +br: KTerm, +st_ty: KTerm, +ret_ty: KTerm) -> KTerm:
  kc(KTerm,p98_tag_eq(br,"Mat"),u => w2d_mat_type(book,br,st_ty,ret_ty),u => ret_ty)

@unsafe
def w2d_ann_mat(+book: List<&2,KDef>, +m: KTerm, +st_ty: KTerm, +ret_ty: KTerm) -> KTerm:
  +sm = j_strip(m)
  kc(KTerm,p98_tag_eq(sm,"Mat"),u =>
    w2d_ann_mat_res(sm,w2d_mat_type(book,sm,st_ty,ret_ty)),u => sm)

@unsafe
def w2d_ann_mat_res(+sm: KTerm, +ty: KTerm) -> KTerm:
  kc(KTerm,p98_tag_eq(ty,"Absent"),u => sm,u => kt("Ann","",0,0,[sm,ty]))

@unsafe
def w2d_push_rec_in_mat(+book: List<&2,KDef>, +t: KTerm, +hname: String, +rargs: List<&2,KTerm>, +ret_ty: KTerm) -> KTerm:
  +s = j_strip(t)
  kc(KTerm,p98_tag_eq(s,"Efq"),u => s,u =>
  kc(KTerm,p98_tag_eq(s,"Lam"),v => k_with_children(s,[w2d_push_rec_in_mat(book,kid(s,0),hname,rargs,ret_ty)]),v =>
  kc(KTerm,p98_tag_eq(s,"Let") && U32.is_eq(terms_len(ks(s)),2),w => kt("Let","",0,0,[kid(s,0),w2d_push_rec_in_mat(book,kid(s,1),hname,rargs,ret_ty)]),w =>
  kc(KTerm,p98_tag_eq(s,"Mat") && U32.is_eq(terms_len(ks(s)),2),x => k_with_children(s,[w2d_push_rec_in_mat(book,kid(s,0),hname,rargs,ret_ty),w2d_push_rec_in_mat(book,kid(s,1),hname,rargs,ret_ty)]),x =>
  kc(KTerm,p98_tag_eq(s,"App") && p98_tag_eq(j_strip(kid(s,0)),"Mat"),y => app(w2d_ann_mat(book,w2d_push_rec_in_mat(book,kid(s,0),hname,rargs,ret_ty),ret_ty,ret_ty),kid(s,1)),y =>
    agy_bf_apps(ref(hname),nt_append(KTerm,rargs,[s])))))))

@unsafe
def w2d_wrap_rec_in_step_opt(+book: List<&2,KDef>, +t: KTerm, +hname: String, +rargs: List<&2,KTerm>, +bs: List<&2,KTerm>, +ret_ty: KTerm) -> KTerm:
  +s = j_strip(t)
  kc(KTerm,p98_tag_eq(s,"Let") && U32.is_eq(terms_len(ks(s)),2),
    u => w2d_wrap_rec_in_step_opt(book,kid(s,1),hname,rargs,nt_append(KTerm,bs,[kid(s,0)]),ret_ty),u =>
  kc(KTerm,p98_tag_eq(s,"Mat") && String.eq(nm(s),"Tuple") && U32.is_eq(terms_len(ks(s)),2) &&
    p98_tag_eq(kid(s,0),"Lam") && p98_tag_eq(kid(kid(s,0),0),"Lam"),
    u => k_with_children(s,[
           k_with_children(kid(s,0),[
             k_with_children(kid(kid(s,0),0),[
               w2d_wrap_lets(bs,w2d_push_rec_in_mat(book,kid(kid(kid(s,0),0),0),hname,rargs,ret_ty))])]),
           kid(s,1)]),
    u => kc(KTerm,p98_tag_eq(s,"Lam"),
           v => k_with_children(s,[w2d_wrap_lets(bs,w2d_push_rec_in_mat(book,kid(s,0),hname,rargs,ret_ty))]),
           v => atom("Absent"))))

@unsafe
def w2d_build_fused_check(+ctx: List<&2,KDef>, +added: List<&2,KDef>, +hname: String, +ar: U32, +hty: KTerm, +z_body: KTerm, +s_lams_init: List<&2,KTerm>, +wrapped: KTerm, +next3: U32) -> W2State:
  +raw_s = agy_bf_wrap_lams(s_lams_init,wrapped)
  +opt_body = kt("Mat","Zero",0,0,[z_body,kt("Mat","Succ",0,0,[raw_s,atom("Efq")])])
  +hdef = {KDef{hname,"Def",ar,0,hty,opt_body,[],False{},False{}} : KDef}
  +ctx1 = agy_bf_add_def(ctx,hdef)
  +chk = agy_bf_check_one(ctx1,hdef)
  kc(W2State,String.eq(dk(chk),"Absent"),
    u => W2State{ctx,added,next3,atom("Absent"),False{}},
    u => w2d_after_fused_res(ctx,added,next3,chk,hname,w2d_try_unbox_loop(ctx,added,chk,opt_body,hname,ar,next3)))

@unsafe
def w2d_build_fused_opt(+ctx: List<&2,KDef>, +added: List<&2,KDef>, +hname: String, +ar: U32, +hty: KTerm, +st_ty: KTerm, +z_body: KTerm, +s_lams_init: List<&2,KTerm>, +bs: List<&2,KTerm>, +rargs: List<&2,KTerm>, +step_ch: KTerm, +next2: U32) -> W2State:
  +ev = p205v_eval(ctx,step_ch,U32.inc(U32.max(next2,norm_max_term(step_ch))),0,256)
  +sc1 = p205v_finish(step_ch,ev)
  +wrapped = w2d_wrap_rec_in_step_opt(ctx,sc1,hname,rargs,bs,st_ty)
  kc(W2State,p98_tag_eq(wrapped,"Absent"),
    u => W2State{ctx,added,U32.add(next2,64),atom("Absent"),False{}},
    u => w2d_build_fused_check(ctx,added,hname,ar,hty,z_body,s_lams_init,wrapped,U32.add(next2,64)))

@unsafe
def w2d_build_fused_apply_ch(+ctx: List<&2,KDef>, +added: List<&2,KDef>, +hname: String, +ar: U32, +hty: KTerm, +st_ty: KTerm, +z_body: KTerm, +s_lams_init: List<&2,KTerm>, +bs: List<&2,KTerm>, +rargs: List<&2,KTerm>, +ev: P205UResult) -> W2State:
  match ev:
    case P205UResult{step_ch,n2,_,_}:
      w2d_build_fused_opt(ctx,added,hname,ar,hty,st_ty,z_body,s_lams_init,bs,rargs,step_ch,n2)

@unsafe
def w2d_build_fused_fresh(+ctx: List<&2,KDef>, +added: List<&2,KDef>, +hname: String, +ar: U32, +hty: KTerm, +st_ty: KTerm, +z_body: KTerm, +s_lams_init: List<&2,KTerm>, +bs: List<&2,KTerm>, +ch_expr: KTerm, +rargs: List<&2,KTerm>, +fr: FFresh) -> W2State:
  match fr:
    case FFresh{step_fresh,next2}:
      w2d_build_fused_apply_ch(ctx,added,hname,ar,hty,st_ty,z_body,s_lams_init,bs,rargs,
        p205v_apply(ctx,step_fresh,[ch_expr],next2,0,128))

@unsafe
def w2d_build_fused(+ctx: List<&2,KDef>, +added: List<&2,KDef>, +next: U32, +hname: String, +pname: String, +ar: U32, +st_ty: KTerm, +step_fn: KTerm, +lams0: List<&2,KTerm>, +lams1: List<&2,KTerm>, +bs: List<&2,KTerm>, +ch_expr: KTerm, +rargs: List<&2,KTerm>) -> W2State:
  +pd = lookup(ctx,pname)
  +hty = w2d_builder_fused_ty(dt(pd),ar,st_ty)
  +zvs = agy_bf_fresh_lams(U32.sub(ar,1),next,0)
  +z_body = agy_bf_wrap_vars(zvs,w2d_last(zvs))
  w2d_build_fused_fresh(ctx,added,hname,ar,hty,st_ty,z_body,w2d_init(lams1),bs,ch_expr,rargs,f_fresh_term(step_fn,[],U32.add(next,16)))

@unsafe
def w2d_ensure_fused(+ctx: List<&2,KDef>, +added: List<&2,KDef>, +next: U32, +fold: W2Fold, +b: W2Builder) -> W2State:
  match fold b:
    case W2Fold{fname,st_ty,_,step_fn,_} W2Builder{pname,ar,_,lams0,lams1,bs,ch_expr,rargs,_}:
      +hname = pname ++ "$w2d$" ++ fname
      kc(W2State,Bool.not(String.eq(dk(lookup(ctx,hname)),"Absent")),
        u => W2State{ctx,added,next,ref(hname),False{}},
        u => w2d_build_fused(ctx,added,next,hname,pname,ar,st_ty,step_fn,lams0,lams1,bs,ch_expr,rargs))

# ==============================================================================
# Common-Tuple-Fst Hoisting & Branch-Push
# ==============================================================================
type W2Hoist is Data:
  W2Hoist{+cname: String, +term: KTerm, +ok: Bool}

law w2d_hoist_mat:
  for +ctx: List<&2,KDef>
  for +st_ty: KTerm
  for +acc_ty: KTerm
  for +t: KTerm
  W2Hoist

@unsafe
def w2d_hoist_mat_pair(+m: KTerm, +h0: W2Hoist, +h1: W2Hoist) -> W2Hoist:
  match h0 h1:
    case W2Hoist{c0,t0,True{}} W2Hoist{c1,t1,True{}}:
      kc(W2Hoist,String.eq(c0,c1) || String.is_empty(c1),
        u => W2Hoist{c0,k_with_children(m,[t0,t1]),True{}},
        u => kc(W2Hoist,String.is_empty(c0),v => W2Hoist{c1,k_with_children(m,[t0,t1]),True{}},v => W2Hoist{"",m,False{}}))
    case _ _: W2Hoist{"",m,False{}}

@unsafe
def w2d_hoist_wrap_lam(+lam: KTerm, +h: W2Hoist) -> W2Hoist:
  match h:
    case W2Hoist{c,t,ok}: W2Hoist{c,k_with_children(lam,[t]),ok}

@unsafe
def w2d_hoist_wrap_let(+b: KTerm, +h: W2Hoist) -> W2Hoist:
  match h:
    case W2Hoist{c,t,ok}: W2Hoist{c,kt("Let","",0,0,[b,t]),ok}

@unsafe
def w2d_hoist_wrap_app(+ctx: List<&2,KDef>, +st_ty: KTerm, +acc_ty: KTerm, +arg: KTerm, +h: W2Hoist) -> W2Hoist:
  match h:
    case W2Hoist{c,t,ok}:
      W2Hoist{c,app(w2d_ann_mat(ctx,t,st_ty,acc_ty),arg),ok}

@unsafe
def w2d_is_mat_head(+t: KTerm) -> Bool:
  +s = j_strip(t)
  kc(Bool,p98_tag_eq(s,"Mat"),u => True{},u =>
    kc(Bool,p98_tag_eq(s,"App"),v => w2d_is_mat_head(kid(s,0)),v => False{}))

@unsafe
def w2d_hoist_mat(ctx, st_ty, acc_ty, t):
  +s = j_strip(t)
  kc(W2Hoist,p98_tag_eq(s,"Efq"),u => W2Hoist{"",s,True{}},u =>
  kc(W2Hoist,p98_tag_eq(s,"Ctr") && String.eq(nm(s),"Tuple") && U32.is_eq(terms_len(ks(s)),2) &&
    p98_tag_eq(j_strip(kid(s,0)),"Ctr") && List.is_empty(&2,KTerm,ks(j_strip(kid(s,0)))),
    v => W2Hoist{nm(j_strip(kid(s,0))),kid(s,1),True{}},v =>
  kc(W2Hoist,p98_tag_eq(s,"Lam"),w => w2d_hoist_wrap_lam(s,w2d_hoist_mat(ctx,st_ty,acc_ty,kid(s,0))),w =>
  kc(W2Hoist,p98_tag_eq(s,"Let") && U32.is_eq(terms_len(ks(s)),2),
    x => w2d_hoist_wrap_let(kid(s,0),w2d_hoist_mat(ctx,st_ty,acc_ty,kid(s,1))),x =>
  kc(W2Hoist,p98_tag_eq(s,"Mat") && U32.is_eq(terms_len(ks(s)),2),
    y => w2d_hoist_mat_pair(s,w2d_hoist_mat(ctx,st_ty,acc_ty,kid(s,0)),w2d_hoist_mat(ctx,st_ty,acc_ty,kid(s,1))),y =>
  kc(W2Hoist,p98_tag_eq(s,"App") && w2d_is_mat_head(kid(s,0)),
    z => w2d_hoist_wrap_app(ctx,st_ty,acc_ty,kid(s,1),w2d_hoist_mat(ctx,st_ty,acc_ty,kid(s,0))),z => W2Hoist{"",s,False{}}))))))

@unsafe
def w2d_hoist_fst_res(+orig: KTerm, +h: W2Hoist) -> KTerm:
  match h:
    case W2Hoist{cname,inner,True{}}:
      kc(KTerm,Bool.not(String.is_empty(cname)),
        u => kt("Ctr","Tuple",0,1,[kt("Ctr",cname,0,1,[]),inner]),
        u => orig)
    case _: orig

@unsafe
def w2d_hoist_fst(+ctx: List<&2,KDef>, +st_ty: KTerm, +acc_ty: KTerm, +t: KTerm) -> KTerm:
  +s = j_strip(t)
  kc(KTerm,p98_tag_eq(s,"Ctr") && String.eq(nm(s),"Tuple"),u => s,u =>
    w2d_hoist_fst_res(s,w2d_hoist_mat(ctx,st_ty,acc_ty,s)))

law w2d_push_into_mat:
  for +fn_term: KTerm
  for +t: KTerm
  for +next: U32
  FFresh

@unsafe
def w2d_pim_lam(+lam: KTerm, +r: FFresh) -> FFresh:
  match r:
    case FFresh{b,n1}: FFresh{k_with_children(lam,[b]),n1}

@unsafe
def w2d_pim_let(+bind: KTerm, +r: FFresh) -> FFresh:
  match r:
    case FFresh{b,n1}: FFresh{kt("Let","",0,0,[bind,b]),n1}

@unsafe
def w2d_pim_app(+arg: KTerm, +r: FFresh) -> FFresh:
  match r:
    case FFresh{m2,n1}: FFresh{app(m2,arg),n1}

@unsafe
def w2d_pim_leaf(+leaf: KTerm, +r: FFresh) -> FFresh:
  match r:
    case FFresh{fn_f,n1}: FFresh{app(fn_f,leaf),n1}

@unsafe
def w2d_pim_pair2(+m: KTerm, +t0: KTerm, +r1: FFresh) -> FFresh:
  match r1:
    case FFresh{t1,n2}: FFresh{k_with_children(m,[t0,t1]),n2}

@unsafe
def w2d_pim_pair1(+fn_term: KTerm, +m: KTerm, +r0: FFresh) -> FFresh:
  match r0:
    case FFresh{t0,n1}: w2d_pim_pair2(m,t0,w2d_push_into_mat(fn_term,kid(m,1),n1))

@unsafe
def w2d_push_into_mat(fn_term, t, next):
  +s = j_strip(t)
  kc(FFresh,p98_tag_eq(s,"Efq"),u => FFresh{s,next},u =>
  kc(FFresh,p98_tag_eq(s,"Lam"),v => w2d_pim_lam(s,w2d_push_into_mat(fn_term,kid(s,0),next)),v =>
  kc(FFresh,p98_tag_eq(s,"Let") && U32.is_eq(terms_len(ks(s)),2),w => w2d_pim_let(kid(s,0),w2d_push_into_mat(fn_term,kid(s,1),next)),w =>
  kc(FFresh,p98_tag_eq(s,"Mat") && U32.is_eq(terms_len(ks(s)),2),x => w2d_pim_pair1(fn_term,s,w2d_push_into_mat(fn_term,kid(s,0),next)),x =>
  kc(FFresh,p98_tag_eq(s,"App") && w2d_is_mat_head(kid(s,0)),y => w2d_pim_app(kid(s,1),w2d_push_into_mat(fn_term,kid(s,0),next)),y =>
    w2d_pim_leaf(s,f_fresh_term(fn_term,[],next)))))))

@unsafe
def w2d_is_small_mat(+t: KTerm) -> Bool:
  +s = j_strip(t)
  p98_tag_eq(s,"App") && w2d_is_mat_head(kid(s,0)) && p205u_room([s],128)

# ==============================================================================
# Core Deforestation Pusher (with linear String continuation env `senv`)
# ==============================================================================
type W2Bind is Data:
  W2Bind{+bid: U32, +rhs: KTerm}

@unsafe
def w2d_senv_get(+senv: List<&2,W2Bind>, +id: U32) -> KTerm:
  match senv:
    case Nil{}: atom("Absent")
    case Con{W2Bind{bid,rhs},rest}:
      kc(KTerm,U32.is_eq(bid,id),u => rhs,u => w2d_senv_get(rest,id))

@unsafe
def w2d_senv_del(+senv: List<&2,W2Bind>, +id: U32) -> List<&2,W2Bind>:
  match senv:
    case Nil{}: []
    case Con{W2Bind{bid,rhs},rest}:
      kc(List<&2,W2Bind>,U32.is_eq(bid,id),u => rest,u => Con{W2Bind{bid,rhs},w2d_senv_del(rest,id)})

@unsafe
def w2d_rebind_senv(+senv: List<&2,W2Bind>, +body: KTerm) -> KTerm:
  match senv:
    case Nil{}: body
    case Con{W2Bind{bid,rhs},rest}:
      kc(KTerm,U32.is_gt(p205u_vars(body,bid),0),
        u => kt("Let","",0,0,[kt("Bind","$w2r",bid,2,[rhs]),w2d_rebind_senv(rest,body)]),
        u => w2d_rebind_senv(rest,body))

@unsafe
def w2d_hoist_fst_ann(+ctx: List<&2,KDef>, +t: KTerm, +st_ty: KTerm, +acc_ty: KTerm) -> KTerm:
  w2d_hoist_fst(ctx,st_ty,acc_ty,t)

@unsafe
def w2d_st_snd_ty_call(+call: KTerm) -> KTerm:
  kc(KTerm,p98_tag_eq(call,"Call") && U32.is_eq(terms_len(ks(call)),2),u => p205u_at(ks(call),1),u =>
  kc(KTerm,p98_tag_eq(call,"Call") && String.eq(nm(call),"Sigma") && U32.is_eq(terms_len(ks(call)),4) &&
    p98_tag_eq(j_strip(p205u_at(ks(call),3)),"Lam"),
    v => kid(j_strip(p205u_at(ks(call),3)),0),v => atom("Absent")))

@unsafe
def w2d_st_snd_ty(+st_ty: KTerm) -> KTerm:
  +s = j_strip(st_ty)
  kc(KTerm,p98_tag_eq(s,"App"),u => w2d_st_snd_ty_call(j_call_spine(s,[])),u => atom("Absent"))

law w2d_push:
  for +ctx: List<&2,KDef>
  for +added: List<&2,KDef>
  for +senv: List<&2,W2Bind>
  for +next: U32
  for +fold: W2Fold
  for +prod: KTerm
  for +st: KTerm
  for +fuel: U32
  W2State

@unsafe
def w2d_reduce_step_raw(+ctx: List<&2,KDef>, +st_ty: KTerm, +acc_ty: KTerm, +raw: FFresh) -> FFresh:
  match raw:
    case FFresh{e0,n2}:
      +ev = p205v_eval(ctx,e0,U32.inc(U32.max(n2,norm_max_term(e0))),0,512)
      +e1 = p205v_finish(e0,ev)
      +e2 = w2d_hoist_fst_ann(ctx,e1,st_ty,acc_ty)
      FFresh{e2,U32.inc(U32.max(n2,norm_max_term(e2)))}

@unsafe
def w2d_reduce_step_fr(+ctx: List<&2,KDef>, +st_ty: KTerm, +acc_ty: KTerm, +ch: KTerm, +st: KTerm, +fr: FFresh) -> FFresh:
  match fr:
    case FFresh{sf,n1}:
      w2d_reduce_step_raw(ctx,st_ty,acc_ty,kc(FFresh,w2d_is_small_mat(st),
        u => w2d_push_into_mat(app(sf,ch),st,n1),
        u => FFresh{app(app(sf,ch),st),n1}))

@unsafe
def w2d_reduce_step(+ctx: List<&2,KDef>, +st_ty: KTerm, +acc_ty: KTerm, +next: U32, +step_fn: KTerm, +ch: KTerm, +st: KTerm) -> FFresh:
  w2d_reduce_step_fr(ctx,st_ty,acc_ty,ch,st,f_fresh_term(step_fn,[],next))

@unsafe
def w2d_bind_acc_wrap(+aid: U32, +acc_expr: KTerm, +acc_ty: KTerm, +res: W2State) -> W2State:
  match res:
    case W2State{ctx2,added2,next2,body2,ch2}:
      +ty_acc = kc(KTerm,p98_tag_eq(acc_ty,"Absent"),u => p205u_bind_type(ctx2,acc_expr),u => acc_ty)
      +b = kt("Bind","$w2a",aid,2,[p205u_typed_arg(acc_expr,ty_acc)])
      W2State{ctx2,added2,next2,kt("Let","",0,0,[b,body2]),ch2}

@unsafe
def w2d_bind_acc_and_go(+ctx: List<&2,KDef>, +added: List<&2,KDef>, +senv: List<&2,W2Bind>, +next: U32, +fold: W2Fold, +tail: KTerm, +c_fst: KTerm, +acc_expr: KTerm, +acc_ty: KTerm, +fuel: U32) -> W2State:
  +st_v = kt("Ctr","Tuple",0,1,[c_fst,var("$w2a",next)])
  w2d_bind_acc_wrap(next,acc_expr,acc_ty,w2d_push(ctx,added,senv,U32.inc(next),fold,tail,st_v,fuel))

@unsafe
def w2d_bind_state_and_go(+ctx: List<&2,KDef>, +added: List<&2,KDef>, +senv: List<&2,W2Bind>, +next: U32, +fold: W2Fold, +tail: KTerm, +st_expr: KTerm, +fuel: U32) -> W2State:
  match fold:
    case W2Fold{_,st_ty,_,_,_}:
      +se = j_strip(st_expr)
      +acc_ty = w2d_st_snd_ty(st_ty)
      kc(W2State,p98_tag_eq(se,"Ctr") && String.eq(nm(se),"Tuple") && U32.is_eq(terms_len(ks(se)),2) &&
        p98_tag_eq(j_strip(kid(se,0)),"Ctr") && List.is_empty(&2,KTerm,ks(j_strip(kid(se,0)))) &&
        Bool.not(p98_tag_eq(j_strip(kid(se,1)),"Var") || p205v_static(j_strip(kid(se,1)))),
        u => w2d_bind_acc_and_go(ctx,added,senv,next,fold,tail,j_strip(kid(se,0)),kid(se,1),acc_ty,fuel),
        u => w2d_push(ctx,added,senv,next,fold,tail,se,fuel))

@unsafe
def w2d_inline_char_res(+orig: KTerm, +ev: P205UResult) -> FFresh:
  match ev:
    case P205UResult{term,n2,_,True{}}: FFresh{term,n2}
    case P205UResult{_,n2,_,False{}}: FFresh{orig,n2}

@unsafe
def w2d_inline_char_fr(+ctx: List<&2,KDef>, +orig: KTerm, +args: List<&2,KTerm>, +fr: FFresh) -> FFresh:
  match fr:
    case FFresh{fb,n1}: w2d_inline_char_res(orig,p205v_apply(ctx,fb,args,n1,0,256))

@unsafe
def w2d_inline_small_char_def(+ctx: List<&2,KDef>, +sc: KTerm, +call: KTerm, +d: KDef, +next: U32) -> FFresh:
  kc(FFresh,String.eq(dk(d),"Def") && Bool.not(db(d) || du(d)) && U32.is_eq(dx(d),0) &&
    U32.is_eq(da(d),terms_len(ks(call))) && U32.is_eq(p205u_refs(dv(d),dn(d)),0) &&
    p205u_room([dv(d)],128) && p198e_owner(p205u_after_args(ctx,dt(d),da(d)),"Char"),
    u => w2d_inline_char_fr(ctx,sc,ks(call),f_fresh_term(p205u_clean(dv(d)),[],next)),
    u => FFresh{sc,next})

@unsafe
def w2d_inline_small_char_call(+ctx: List<&2,KDef>, +sc: KTerm, +call: KTerm, +next: U32) -> FFresh:
  kc(FFresh,p98_tag_eq(call,"Call") && U32.is_le(terms_len(ks(call)),4),u =>
    w2d_inline_small_char_def(ctx,sc,call,lookup(ctx,nm(call)),next),
    u => FFresh{sc,next})

@unsafe
def w2d_inline_small_char(+ctx: List<&2,KDef>, +ch: KTerm, +next: U32) -> FFresh:
  +sc = j_strip(ch)
  kc(FFresh,p98_tag_eq(sc,"App"),u =>
    w2d_inline_small_char_call(ctx,sc,j_call_spine(sc,[]),next),
    u => FFresh{sc,next})

@unsafe
def w2d_u32_or0(+m: Maybe<&2,U32>) -> U32:
  match m:
    case Some{v}: v
    case None{}: 0

# Lift a closed 1-arg Mat (e.g. step on Space over dynamic state) to a top-level Def so p113d compiles the caller directly!
@unsafe
def w2d_lift_closed_mat_build(+ctx: List<&2,KDef>, +added: List<&2,KDef>, +hname: String, +dom_ty: KTerm, +ret_ty: KTerm, +m: KTerm, +arg: KTerm) -> W2State:
  +ty = all(1,"$w2x",0,dom_ty,ret_ty)
  +hdef = {KDef{hname,"Def",1,0,ty,j_strip(m),[],False{},False{}} : KDef}
  +ctx1 = agy_bf_add_def(ctx,hdef)
  +chk = agy_bf_check_one(ctx1,hdef)
  kc(W2State,String.eq(dk(chk),"Absent"),
    u => W2State{ctx,added,0,app(m,arg),False{}},
    u => W2State{agy_bf_add_def(ctx,chk),Con{chk,added},0,app(ref(hname),arg),True{}})

@unsafe
def w2d_lift_closed_mat(+ctx: List<&2,KDef>, +added: List<&2,KDef>, +hname: String, +dom_ty: KTerm, +ret_ty: KTerm, +m: KTerm, +arg: KTerm) -> W2State:
  kc(W2State,Bool.not(String.eq(dk(lookup(ctx,hname)),"Absent")),
    u => W2State{ctx,added,0,app(m,arg),False{}},
    u => w2d_lift_closed_mat_build(ctx,added,hname,dom_ty,ret_ty,m,arg))

# Lift a 2-arg Mat with 1 free var `acc_id` (e.g. op.pick fused with step on Gap{}) to a top-level 3-arg Def!
@unsafe
def w2d_mat_add_lam(+m: KTerm, +acc_id: U32) -> KTerm:
  +s = j_strip(m)
  kc(KTerm,p98_tag_eq(s,"Efq"),u => s,u =>
  kc(KTerm,p98_tag_eq(s,"Mat") && U32.is_eq(terms_len(ks(s)),2),
    v => k_with_children(s,[w2d_mat_add_lam(kid(s,0),acc_id),w2d_mat_add_lam(kid(s,1),acc_id)]),
    v => agy_bf_lam("$w2acc",acc_id,2,s)))

@unsafe
def w2d_lift_mat2_build(+ctx: List<&2,KDef>, +added: List<&2,KDef>, +hname: String, +mat: KTerm, +a0: KTerm, +a1: KTerm, +acc_id: U32, +acc_ty: KTerm, +acc_arg: KTerm) -> W2State:
  +d0 = w2d_ctor_owner_ty(ctx,nm(mat))
  +d1 = w2d_ctor_owner_ty(ctx,nm(j_strip(kid(mat,0))))
  +ty = all(1,"$w2b0",0,d0,all(1,"$w2b1",0,d1,all(2,"$w2acc",acc_id,acc_ty,acc_ty)))
  +body = w2d_mat_add_lam(mat,acc_id)
  +hdef = {KDef{hname,"Def",3,0,ty,body,[],False{},False{}} : KDef}
  +ctx1 = agy_bf_add_def(ctx,hdef)
  +chk = agy_bf_check_one(ctx1,hdef)
  kc(W2State,String.eq(dk(chk),"Absent"),
    u => W2State{ctx,added,0,app(app(w2d_ann_mat(ctx,mat,acc_ty,acc_ty),a0),a1),False{}},
    u => W2State{agy_bf_add_def(ctx,chk),Con{chk,added},0,app(app(app(ref(hname),a0),a1),acc_arg),True{}})

@unsafe
def w2d_lift_mat2_go(+ctx: List<&2,KDef>, +added: List<&2,KDef>, +hname: String, +mat: KTerm, +a0: KTerm, +a1: KTerm, +acc_id: U32, +acc_ty: KTerm, +acc_arg: KTerm) -> W2State:
  kc(W2State,Bool.not(String.eq(dk(lookup(ctx,hname)),"Absent")),
    u => W2State{ctx,added,0,app(app(w2d_ann_mat(ctx,mat,acc_ty,acc_ty),a0),a1),False{}},
    u => w2d_lift_mat2_build(ctx,added,hname,mat,a0,a1,acc_id,acc_ty,acc_arg))

@unsafe
def w2d_lift_mat2_acc(+ctx: List<&2,KDef>, +added: List<&2,KDef>, +hname: String, +m_expr: KTerm, +acc_id: U32, +acc_ty: KTerm, +acc_arg: KTerm) -> W2State:
  +s = j_strip(m_expr)
  kc(W2State,p98_tag_eq(s,"App") && p98_tag_eq(j_strip(kid(s,0)),"App") && p98_tag_eq(j_strip(kid(j_strip(kid(s,0)),0)),"Mat"),
    u => w2d_lift_mat2_go(ctx,added,hname,j_strip(kid(j_strip(kid(s,0)),0)),kid(j_strip(kid(s,0)),1),kid(s,1),acc_id,acc_ty,acc_arg),
    u => W2State{ctx,added,0,m_expr,False{}})

@unsafe
def w2d_scon_mat_ch_lifted(+ctx: List<&2,KDef>, +added: List<&2,KDef>, +senv: List<&2,W2Bind>, +next: U32, +fold: W2Fold, +tail: KTerm, +c_fst: KTerm, +fuel: U32, +lifted: W2State) -> W2State:
  match lifted:
    case W2State{ctx2,added2,_,acc2,_}:
      w2d_bind_state_and_go(ctx2,added2,senv,next,fold,tail,kt("Ctr","Tuple",0,1,[c_fst,acc2]),fuel)

@unsafe
def w2d_scon_mat_ch_raw(+ctx: List<&2,KDef>, +added: List<&2,KDef>, +senv: List<&2,W2Bind>, +fold: W2Fold, +st_ty: KTerm, +acc_ty: KTerm, +tail: KTerm, +st: KTerm, +fuel: U32, +raw: FFresh) -> W2State:
  match raw:
    case FFresh{e0,n2}:
      +ev = p205v_eval(ctx,e0,U32.inc(U32.max(n2,norm_max_term(e0))),0,512)
      +e1 = w2d_hoist_fst_ann(ctx,p205v_finish(e0,ev),st_ty,acc_ty)
      +se = j_strip(e1)
      +sst = j_strip(st)
      +n3 = U32.inc(U32.max(n2,norm_max_term(e1)))
      # If e1 = Tuple{C, App(App(Mat, a0), a1)} and st = Tuple{_, Var acc_id}, lift Mat to a top-level Def!
      kc(W2State,p98_tag_eq(se,"Ctr") && String.eq(nm(se),"Tuple") && U32.is_eq(terms_len(ks(se)),2) &&
        p98_tag_eq(sst,"Ctr") && String.eq(nm(sst),"Tuple") && p98_tag_eq(j_strip(kid(sst,1)),"Var"),
        u => w2d_scon_mat_ch_lifted(ctx,added,senv,U32.inc(n3),fold,tail,kid(se,0),fuel,
               w2d_lift_mat2_acc(ctx,added,"$w2d$m2$" ++ nm(j_strip(kid(se,0))) ++ "$" ++ U32.show(n3) ++ "$" ++ U32.show(nt_count(KDef,ctx)),kid(se,1),ix(j_strip(kid(sst,1))),acc_ty,j_strip(kid(sst,1)))),
        u => w2d_bind_state_and_go(ctx,added,senv,n3,fold,tail,e1,fuel))

@unsafe
def w2d_scon_mat_ch_fr(+ctx: List<&2,KDef>, +added: List<&2,KDef>, +senv: List<&2,W2Bind>, +cid: U32, +fold: W2Fold, +st_ty: KTerm, +acc_ty: KTerm, +ch_mat: KTerm, +tail: KTerm, +st: KTerm, +fuel: U32, +fr: FFresh) -> W2State:
  match fr:
    case FFresh{sf,n1}:
      +fn_c = agy_bf_lam("$w2c",cid,2,app(app(sf,var("$w2c",cid)),st))
      w2d_scon_mat_ch_raw(ctx,added,senv,fold,st_ty,acc_ty,tail,st,fuel,w2d_push_into_mat(fn_c,ch_mat,n1))

@unsafe
def w2d_scon_direct_lifted(+ctx: List<&2,KDef>, +added: List<&2,KDef>, +senv: List<&2,W2Bind>, +n1: U32, +fold: W2Fold, +tail: KTerm, +c_fst: KTerm, +fuel: U32, +lifted: W2State) -> W2State:
  match lifted:
    case W2State{ctx2,added2,_,acc2,_}:
      w2d_bind_state_and_go(ctx2,added2,senv,n1,fold,tail,kt("Ctr","Tuple",0,1,[c_fst,acc2]),fuel)

@unsafe
def w2d_scon_direct_res(+ctx: List<&2,KDef>, +added: List<&2,KDef>, +senv: List<&2,W2Bind>, +fold: W2Fold, +st_ty: KTerm, +acc_ty: KTerm, +ch: KTerm, +tail: KTerm, +fuel: U32, +r: FFresh) -> W2State:
  match r:
    case FFresh{st1,n1}:
      +se = j_strip(st1)
      # If st1 = Tuple{C, App(Ann(Mat "Tuple" ...), arg)} where ch is literal Chr{code}, lift Mat to $w2d$ch$<code>!
      kc(W2State,p98_tag_eq(se,"Ctr") && String.eq(nm(se),"Tuple") && U32.is_eq(terms_len(ks(se)),2) &&
        p98_tag_eq(j_strip(kid(se,1)),"App") && p98_tag_eq(j_strip(kid(j_strip(kid(se,1)),0)),"Mat") &&
        String.eq(nm(j_strip(kid(j_strip(kid(se,1)),0))),"Tuple") &&
        p98_tag_eq(j_strip(ch),"Ctr") && String.eq(nm(j_strip(ch)),"Chr") && p205v_static(j_strip(ch)),
        u => w2d_scon_direct_lifted(ctx,added,senv,U32.inc(n1),fold,tail,kid(se,0),fuel,
               w2d_lift_closed_mat(ctx,added,"$w2d$ch$" ++ U32.show(w2d_u32_or0(j_u32(j_strip(kid(j_strip(ch),0))))) ++ "$" ++ U32.show(n1) ++ "$" ++ U32.show(nt_count(KDef,ctx)),st_ty,acc_ty,
                 kid(j_strip(kid(se,1)),0),kid(j_strip(kid(se,1)),1))),
        u => w2d_bind_state_and_go(ctx,added,senv,n1,fold,tail,st1,fuel))

@unsafe
def w2d_push_scon_ch(+ctx: List<&2,KDef>, +added: List<&2,KDef>, +senv: List<&2,W2Bind>, +fold: W2Fold, +st_ty: KTerm, +acc_ty: KTerm, +step_fn: KTerm, +tail: KTerm, +st: KTerm, +fuel: U32, +ch_opt: FFresh) -> W2State:
  match ch_opt:
    case FFresh{ch2,n1}:
      kc(W2State,w2d_is_small_mat(ch2),
        u => w2d_scon_mat_ch_fr(ctx,added,senv,n1,fold,st_ty,acc_ty,ch2,tail,st,fuel,f_fresh_term(step_fn,[],U32.inc(n1))),
        u => w2d_scon_direct_res(ctx,added,senv,fold,st_ty,acc_ty,ch2,tail,fuel,w2d_reduce_step(ctx,st_ty,acc_ty,n1,step_fn,ch2,st)))

@unsafe
def w2d_push_scon(+ctx: List<&2,KDef>, +added: List<&2,KDef>, +senv: List<&2,W2Bind>, +next: U32, +fold: W2Fold, +ch: KTerm, +tail: KTerm, +st: KTerm, +fuel: U32) -> W2State:
  match fold:
    case W2Fold{_,st_ty,_,step_fn,_}:
      w2d_push_scon_ch(ctx,added,senv,fold,st_ty,w2d_st_snd_ty(st_ty),step_fn,tail,st,fuel,w2d_inline_small_char(ctx,ch,next))

@unsafe
def w2d_push_let_keep(+b: KTerm, +res: W2State) -> W2State:
  match res:
    case W2State{ctx2,added2,next2,t2,ch2}: W2State{ctx2,added2,next2,kt("Let","",0,0,[b,t2]),ch2}

@unsafe
def w2d_is_str_rhs(+ctx: List<&2,KDef>, +rhs: KTerm) -> Bool:
  +ty = j_strip(p205u_bind_type(ctx,rhs))
  ((p98_tag_eq(ty,"Ref") || p98_tag_eq(ty,"ADT")) && String.eq(nm(ty),"String")) ||
    (p98_tag_eq(j_strip(rhs),"Ctr") && (String.eq(nm(j_strip(rhs)),"SCon") || String.eq(nm(j_strip(rhs)),"SNil")))

@unsafe
def w2d_push_let(+ctx: List<&2,KDef>, +added: List<&2,KDef>, +senv: List<&2,W2Bind>, +next: U32, +fold: W2Fold, +b: KTerm, +body: KTerm, +st: KTerm, +fuel: U32) -> W2State:
  +rhs = kid(b,0)
  +bid = ix(b)
  +uses = p205u_vars(body,bid)
  kc(W2State,U32.is_eq(uses,0) && p205v_pure(ctx,rhs,16),
    u => w2d_push(ctx,added,senv,next,fold,body,st,fuel),u =>
  kc(W2State,U32.is_eq(uses,1) && w2d_is_str_rhs(ctx,rhs),
    v => w2d_push(ctx,added,Con{W2Bind{bid,rhs},senv},next,fold,body,st,fuel),
    v => w2d_push_let_keep(b,w2d_push(ctx,added,senv,next,fold,body,st,fuel))))

@unsafe
def w2d_push_fallback(+ctx: List<&2,KDef>, +added: List<&2,KDef>, +senv: List<&2,W2Bind>, +next: U32, +fold: W2Fold, +prod: KTerm, +st: KTerm) -> W2State:
  match fold:
    case W2Fold{fname,_,_,_,_}:
      W2State{ctx,added,next,w2d_rebind_senv(senv,app(app(ref(fname),prod),st)),True{}}

@unsafe
def w2d_push_inline_res(+ctx: List<&2,KDef>, +added: List<&2,KDef>, +senv: List<&2,W2Bind>, +fold: W2Fold, +prod: KTerm, +st: KTerm, +fuel: U32, +ev: P205UResult) -> W2State:
  match ev:
    case P205UResult{term,n2,_,True{}}: w2d_push(ctx,added,senv,n2,fold,term,st,fuel)
    case P205UResult{_,n2,_,False{}}: w2d_push_fallback(ctx,added,senv,n2,fold,prod,st)

@unsafe
def w2d_push_inline_fr(+ctx: List<&2,KDef>, +added: List<&2,KDef>, +senv: List<&2,W2Bind>, +fold: W2Fold, +prod: KTerm, +args: List<&2,KTerm>, +st: KTerm, +fuel: U32, +fr: FFresh) -> W2State:
  match fr:
    case FFresh{fb,n1}: w2d_push_inline_res(ctx,added,senv,fold,prod,st,fuel,p205v_apply(ctx,fb,args,n1,0,256))

@unsafe
def w2d_push_after_builder(+ctx: List<&2,KDef>, +added: List<&2,KDef>, +senv: List<&2,W2Bind>, +next: U32, +fold: W2Fold, +href: KTerm, +bargs: List<&2,KTerm>, +rest_str: KTerm, +st: KTerm, +fuel: U32) -> W2State:
  +raw_call = agy_bf_apps(href,nt_append(KTerm,bargs,[st]))
  +ev = p205v_eval(ctx,raw_call,U32.inc(U32.max(next,norm_max_term(raw_call))),0,256)
  +st1 = p205v_finish(raw_call,ev)
  +n2 = U32.inc(U32.max(next,norm_max_term(st1)))
  w2d_push(ctx,added,senv,n2,fold,rest_str,st1,fuel)

@unsafe
def w2d_push_rec_ens(+ctx: List<&2,KDef>, +added: List<&2,KDef>, +senv: List<&2,W2Bind>, +next: U32, +fold: W2Fold, +prod: KTerm, +call: KTerm, +st: KTerm, +fuel: U32, +ens: W2State) -> W2State:
  match ens:
    case W2State{ctx2,added2,next2,href,_}:
      kc(W2State,p98_tag_eq(href,"Absent"),
        u => w2d_push_fallback(ctx,added,senv,next,fold,prod,st),
        u => w2d_push_after_builder(ctx2,added2,senv,next2,fold,href,w2d_init(ks(call)),w2d_last(ks(call)),st,fuel))

@unsafe
def w2d_push_rec_builder(+ctx: List<&2,KDef>, +added: List<&2,KDef>, +senv: List<&2,W2Bind>, +next: U32, +fold: W2Fold, +prod: KTerm, +call: KTerm, +b: W2Builder, +st: KTerm, +fuel: U32) -> W2State:
  match b:
    case W2Builder{_,_,_,_,_,_,_,_,True{}}:
      w2d_push_rec_ens(ctx,added,senv,next,fold,prod,call,st,fuel,w2d_ensure_fused(ctx,added,next,fold,b))
    case _: w2d_push_fallback(ctx,added,senv,next,fold,prod,st)

@unsafe
def w2d_push_call_def(+ctx: List<&2,KDef>, +added: List<&2,KDef>, +senv: List<&2,W2Bind>, +next: U32, +fold: W2Fold, +prod: KTerm, +call: KTerm, +d: KDef, +st: KTerm, +fuel: U32) -> W2State:
  kc(W2State,String.eq(dk(d),"Def") && Bool.not(db(d) || du(d)) && U32.is_eq(dx(d),0) &&
    U32.is_eq(da(d),terms_len(ks(call))) && U32.is_eq(p205u_refs(dv(d),dn(d)),0) &&
    p205u_room([dv(d)],128) && p198e_owner(p205u_after_args(ctx,dt(d),da(d)),"String"),
    u => w2d_push_inline_fr(ctx,added,senv,fold,prod,ks(call),st,fuel,f_fresh_term(p205u_clean(dv(d)),[],next)),
    u => w2d_push_rec_builder(ctx,added,senv,next,fold,prod,call,w2d_check_rec_builder(d),st,fuel))

@unsafe
def w2d_push_call(+ctx: List<&2,KDef>, +added: List<&2,KDef>, +senv: List<&2,W2Bind>, +next: U32, +fold: W2Fold, +prod: KTerm, +call: KTerm, +st: KTerm, +fuel: U32) -> W2State:
  kc(W2State,p98_tag_eq(call,"Call") && U32.is_ge(terms_len(ks(call)),2) && U32.is_le(terms_len(ks(call)),5),
    u => w2d_push_call_def(ctx,added,senv,next,fold,prod,call,lookup(ctx,nm(call)),st,fuel),
    u => w2d_push_fallback(ctx,added,senv,next,fold,prod,st))

@unsafe
def w2d_push_nil_raw(+ctx: List<&2,KDef>, +added: List<&2,KDef>, +senv: List<&2,W2Bind>, +raw: FFresh) -> W2State:
  match raw:
    case FFresh{e0,n2}:
      +ev = p205v_eval(ctx,e0,U32.inc(U32.max(n2,norm_max_term(e0))),0,256)
      +e1 = p205v_finish(e0,ev)
      W2State{ctx,added,U32.inc(U32.max(n2,norm_max_term(e1))),w2d_rebind_senv(senv,e1),True{}}

@unsafe
def w2d_push_nil_fr(+ctx: List<&2,KDef>, +added: List<&2,KDef>, +senv: List<&2,W2Bind>, +st: KTerm, +fr: FFresh) -> W2State:
  match fr:
    case FFresh{nf,n1}:
      w2d_push_nil_raw(ctx,added,senv,kc(FFresh,w2d_is_small_mat(st),
        u => w2d_push_into_mat(nf,st,n1),
        u => FFresh{app(nf,st),n1}))

@unsafe
def w2d_push_nil(+ctx: List<&2,KDef>, +added: List<&2,KDef>, +senv: List<&2,W2Bind>, +next: U32, +fold: W2Fold, +st: KTerm) -> W2State:
  match fold:
    case W2Fold{_,_,nil_fn,_,_}:
      w2d_push_nil_fr(ctx,added,senv,st,f_fresh_term(nil_fn,[],next))

@unsafe
def w2d_push_var(+ctx: List<&2,KDef>, +added: List<&2,KDef>, +senv: List<&2,W2Bind>, +next: U32, +fold: W2Fold, +prod: KTerm, +st: KTerm, +fuel: U32) -> W2State:
  +found = w2d_senv_get(senv,ix(prod))
  kc(W2State,p98_tag_eq(found,"Absent"),
    u => w2d_push_fallback(ctx,added,senv,next,fold,prod,st),
    u => w2d_push(ctx,added,w2d_senv_del(senv,ix(prod)),next,fold,found,st,fuel))

@unsafe
def w2d_let_rest(+xs: List<&2,KTerm>) -> KTerm:
  match xs:
    case Con{last,Nil{}}: last
    case _: kt("Let","",0,0,xs)

@unsafe
def w2d_push_go(+ctx: List<&2,KDef>, +added: List<&2,KDef>, +senv: List<&2,W2Bind>, +next: U32, +fold: W2Fold, +prod: KTerm, +st: KTerm, +fuel: U32) -> W2State:
  kc(W2State,p98_tag_eq(prod,"Var"),
    u => w2d_push_var(ctx,added,senv,next,fold,prod,st,fuel),u =>
  kc(W2State,p98_tag_eq(prod,"Ctr") && String.eq(nm(prod),"SNil") && List.is_empty(&2,KTerm,ks(prod)),
    u => w2d_push_nil(ctx,added,senv,next,fold,st),u =>
  kc(W2State,p98_tag_eq(prod,"Ctr") && String.eq(nm(prod),"SCon") && U32.is_eq(terms_len(ks(prod)),2),
    v => w2d_push_scon(ctx,added,senv,next,fold,kid(prod,0),kid(prod,1),st,fuel),v =>
  kc(W2State,p98_tag_eq(prod,"Let") && U32.is_ge(terms_len(ks(prod)),2) && p98_tag_eq(kid(prod,0),"Bind"),
    w => w2d_push_let(ctx,added,senv,next,fold,kid(prod,0),w2d_let_rest(List.tail(&2,KTerm,ks(prod))),st,fuel),w =>
  kc(W2State,p98_tag_eq(prod,"App"),
    x => w2d_push_call(ctx,added,senv,next,fold,prod,j_call_spine(prod,[]),st,fuel),
    x => w2d_push_fallback(ctx,added,senv,next,fold,prod,st))))))

@unsafe
def w2d_push(ctx, added, senv, next, fold, prod, st, fuel):
  kc(W2State,U32.is_eq(fuel,0),u => w2d_push_fallback(ctx,added,senv,next,fold,prod,st),u =>
    w2d_push_go(ctx,added,senv,next,fold,j_strip(prod),st,U32.sub(fuel,1)))

# ==============================================================================
# Top-level W2D Walker and Plan Integration
# ==============================================================================
law w2d_walk:
  for +ctx: List<&2,KDef>
  for +added: List<&2,KDef>
  for +next: U32
  for +t: KTerm
  for +fuel: U32
  W2State

@unsafe
def w2d_is_fusable_prod(+prod: KTerm) -> Bool:
  +s = j_strip(prod)
  (p98_tag_eq(s,"Ctr") && (String.eq(nm(s),"SCon") || String.eq(nm(s),"SNil"))) ||
  p98_tag_eq(s,"Let") || p98_tag_eq(s,"App")

@unsafe
def w2d_walk_step(+parent: KTerm, +rest: List<&2,KTerm>, +acc: List<&2,KTerm>, +ch: Bool, +fuel: U32, +r: W2State) -> W2State:
  match r:
    case W2State{ctx2,added2,next2,x2,ch2}:
      w2d_walk_list(ctx2,added2,next2,parent,rest,Con{x2,acc},ch || ch2,fuel)

@unsafe
def w2d_walk_list(+ctx: List<&2,KDef>, +added: List<&2,KDef>, +next: U32, +parent: KTerm, +xs: List<&2,KTerm>, +acc: List<&2,KTerm>, +ch: Bool, +fuel: U32) -> W2State:
  match xs:
    case Nil{}: W2State{ctx,added,next,k_with_children(parent,nt_reverse(KTerm,acc,[])),ch}
    case Con{x,rest}: w2d_walk_step(parent,rest,acc,ch,fuel,w2d_walk(ctx,added,next,x,fuel))

@unsafe
def w2d_walk_children(+ctx: List<&2,KDef>, +added: List<&2,KDef>, +next: U32, +parent: KTerm, +xs: List<&2,KTerm>, +fuel: U32) -> W2State:
  w2d_walk_list(ctx,added,next,parent,xs,[],False{},fuel)

@unsafe
def w2d_walk_check_fold(+ctx: List<&2,KDef>, +added: List<&2,KDef>, +next: U32, +t: KTerm, +call: KTerm, +fold: W2Fold, +fuel: U32) -> W2State:
  match fold:
    case W2Fold{_,_,_,_,True{}}:
      w2d_push(ctx,added,[],next,fold,p205u_at(ks(call),0),p205u_at(ks(call),1),256)
    case _: w2d_walk_children(ctx,added,next,t,ks(t),fuel)

@unsafe
def w2d_walk_call(+ctx: List<&2,KDef>, +added: List<&2,KDef>, +next: U32, +t: KTerm, +call: KTerm, +fuel: U32) -> W2State:
  kc(W2State,p98_tag_eq(call,"Call") && U32.is_eq(terms_len(ks(call)),2) && w2d_is_fusable_prod(p205u_at(ks(call),0)),
    u => w2d_walk_check_fold(ctx,added,next,t,call,w2d_check_fold(ctx,lookup(ctx,nm(call))),fuel),
    u => w2d_walk_children(ctx,added,next,t,ks(t),fuel))

@unsafe
def w2d_walk(ctx, added, next, t, fuel):
  kc(W2State,U32.is_eq(fuel,0),u => W2State{ctx,added,next,t,False{}},u =>
  kc(W2State,p98_tag_eq(t,"Ann"),
    a => w2d_walk_ann(ctx,added,next,t,U32.sub(fuel,1)),u =>
  kc(W2State,p98_tag_eq(t,"App"),
    v => w2d_walk_call(ctx,added,next,t,j_call_spine(t,[]),U32.sub(fuel,1)),
    v => w2d_walk_children(ctx,added,next,t,ks(t),U32.sub(fuel,1)))))

@unsafe
def w2d_walk_ann_res(+orig: KTerm, +r: W2State) -> W2State:
  match r:
    case W2State{ctx2,added2,next2,t2,ch2}:
      W2State{ctx2,added2,next2,kc(KTerm,ch2,u => kt("Ann","",0,0,[t2,kid(orig,1)]),u => orig),ch2}

@unsafe
def w2d_walk_ann(+ctx: List<&2,KDef>, +added: List<&2,KDef>, +next: U32, +t: KTerm, +fuel: U32) -> W2State:
  w2d_walk_ann_res(t,w2d_walk(ctx,added,next,kid(t,0),fuel))

@unsafe
def w2d_try_def_res(+ctx: List<&2,KDef>, +orig_d: KDef, +raw: KDef, +rest: List<&2,KDef>, +r: W2State) -> AgyBFResult:
  match r:
    case W2State{ctx2,added2,_,term2,True{}}:
      +cand_d = dg_event_output(raw,term2)
      +ctx3 = p205z_advance(ctx2,cand_d)
      +chk = agy_bf_check_one(ctx3,cand_d)
      kc(AgyBFResult,String.eq(dk(chk),"Absent"),
        u => AgyBFResult{ctx,Con{orig_d,rest},False{}},
        u => AgyBFResult{p205z_advance(ctx3,chk),nt_append(KDef,nt_reverse(KDef,added2,[]),Con{chk,rest}),True{}})
    case _: AgyBFResult{ctx,Con{orig_d,rest},False{}}

@unsafe
def w2d_try_def(+ctx: List<&2,KDef>, +orig_d: KDef, +raw: KDef, +rest: List<&2,KDef>) -> AgyBFResult:
  +body = dv(raw)
  +next0 = U32.inc(U32.max(norm_book_bound(ctx),norm_max_term(body)))
  w2d_try_def_res(ctx,orig_d,raw,rest,w2d_walk(ctx,[],next0,body,256))

@unsafe
def w2d_pass_step(+d: KDef, +tail_res: AgyBFResult) -> AgyBFResult:
  match tail_res:
    case AgyBFResult{ctx1,out1,ch1}:
      agy_bf_join(ch1,kc(AgyBFResult,String.eq(dk(d),"Def") && Bool.not(db(d) || du(d)) && U32.is_eq(dx(d),0),
        u => w2d_try_def(ctx1,d,d,out1),
        u => AgyBFResult{ctx1,Con{d,out1},False{}}))

@unsafe
def w2d_pass(+ctx: List<&2,KDef>, defs: List<&2,KDef>) -> AgyBFResult:
  match defs:
    case Nil{}: AgyBFResult{ctx,[],False{}}
    case Con{+d,rest}: w2d_pass_step(d,w2d_pass(ctx,rest))

@unsafe
def w2d_plan_res(+ctx: List<&2,KDef>, +stops: List<&2,String>, +verdict: String, +defs: List<&2,KDef>, +res: AgyBFResult) -> P86Plan:
  match res:
    case AgyBFResult{ctx1,defs1,True{}}:
      kc(P86Plan,String.is_empty(jl_checked_error(ctx1,defs1,["main"],stops)),
        u => P86PlanReady{nr_prepare_annotated(ctx1,defs1),verdict},
        u => P86PlanReady{nr_prepare_annotated(ctx,defs),verdict})
    case _: P86PlanReady{nr_prepare_annotated(ctx,defs),verdict}

@unsafe
def w2d_plan(ctx, stops, verdict, defs):
  w2d_plan_res(ctx,stops,verdict,defs,w2d_pass(ctx,defs))
