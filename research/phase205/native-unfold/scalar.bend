# Optional stage2: residualize bounded ordinary helpers and fold only authenticated
# native total U32 operations with two literal operands. No division or effects.
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
@unsafe
def p205v_result_type(+book: List<&2,KDef>, +t: KTerm) -> Bool:
  +ty = j_strip(t)
  kc(Bool,p98_tag_eq(ty,"All"),u => p205v_result_type(book,kid(ty,1)),u =>
    (p98_tag_eq(ty,"Ref") || p98_tag_eq(ty,"ADT")) && List.is_empty(&2,KTerm,ks(ty)) && String.eq(dk(lookup(book,nm(ty))),"ADT"))
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
@unsafe
def p205v_words(+op: String, +a: Maybe<&2,U32>, +b: Maybe<&2,U32>) -> KTerm:
  match a b:
    case Some{x} Some{y}: p205v_binary(op,x,y)
    case _ _: atom("Absent")
@unsafe
def p205v_fold(+book: List<&2,KDef>, +t: KTerm, +args: List<&2,KTerm>) -> KTerm:
  match args:
    case Con{a,Con{b,Nil{}}}: p205v_words(nd_native_call(book,t),j_u32(a),j_u32(b))
    case _: atom("Absent")

@unsafe
def p205v_eval(+book: List<&2,KDef>, +t: KTerm, +next: U32, +steps: U32, +fuel: U32) -> P205UResult:
  kc(P205UResult,U32.is_eq(fuel,0) || U32.is_ge(steps,512),u => P205UResult{t,next,steps,False{}},u =>
    p205v_after(book,t,U32.sub(fuel,1),p205v_fields(book,ks(t),next,steps,U32.sub(fuel,1))))
@unsafe
def p205v_fields(+book: List<&2,KDef>, +xs: List<&2,KTerm>, +next: U32, +steps: U32, +fuel: U32) -> P205UFields:
  match xs:
    case Nil{}: P205UFields{[],next,steps,True{}}
    case Con{x,rest}: p205v_field_next(book,rest,fuel,p205v_eval(book,x,next,steps,fuel))
@unsafe
def p205v_field_next(+book: List<&2,KDef>, +rest: List<&2,KTerm>, +fuel: U32, +first: P205UResult) -> P205UFields:
  match first:
    case P205UResult{term,next,steps,ok}:
      kc(P205UFields,ok,u => p205u_field_join(term,True{},p205v_fields(book,rest,next,steps,fuel)),u => P205UFields{[],next,steps,False{}})
@unsafe
def p205v_after(+book: List<&2,KDef>, +old: KTerm, +fuel: U32, +fields: P205UFields) -> P205UResult:
  match fields:
    case P205UFields{terms,next,steps,ok}:
      +t = k_with_children(old,terms)
      kc(P205UResult,ok && p98_tag_eq(t,"App"),u => p205v_call(book,t,next,steps,fuel,j_call_spine(t,[])),u =>
        kc(P205UResult,ok && p98_tag_eq(t,"Let") && U32.is_eq(terms_len(ks(t)),2) &&
          p98_tag_eq(kid(t,0),"Bind") && U32.is_eq(terms_len(ks(kid(t,0))),1) && p205v_static(kid(kid(t,0),0)),v =>
            p205v_eval(book,subst(kid(t,1),ix(kid(t,0)),kid(kid(t,0),0)),next,U32.inc(steps),fuel),v => P205UResult{t,next,steps,ok}))
@unsafe
def p205v_call(+book: List<&2,KDef>, +t: KTerm, +next: U32, +steps: U32, +fuel: U32, +call: KTerm) -> P205UResult:
  kc(P205UResult,p98_tag_eq(call,"Call") && U32.is_eq(qt(nd_head(t)),1) && U32.is_le(terms_len(ks(call)),5),u =>
    p205v_folded(book,t,next,steps,fuel,call,p205v_fold(book,t,ks(call))),u => P205UResult{t,next,steps,True{}})
@unsafe
def p205v_folded(+book: List<&2,KDef>, +t: KTerm, +next: U32, +steps: U32, +fuel: U32, +call: KTerm, +folded: KTerm) -> P205UResult:
  kc(P205UResult,p98_tag_eq(folded,"Absent"),u =>
    kc(P205UResult,p205v_any(ks(call)),v => p205v_def(book,t,next,steps,fuel,call,lookup(book,nm(call))),v => P205UResult{t,next,steps,True{}}),u =>
    P205UResult{folded,next,U32.inc(steps),True{}})
@unsafe
def p205v_def(+book: List<&2,KDef>, +t: KTerm, +next: U32, +steps: U32, +fuel: U32, +call: KTerm, +d: KDef) -> P205UResult:
  kc(P205UResult,String.eq(dk(d),"Def") && Bool.not(db(d) || du(d)) && U32.is_eq(dx(d),0) &&
    U32.is_eq(da(d),terms_len(ks(call))) && p205u_room([dv(d)],128) && p205v_result_type(book,dt(d)),u =>
      p205v_body(book,t,next,steps,fuel,call,d,p205u_clean(dv(d))),u => P205UResult{t,next,steps,True{}})
@unsafe
def p205v_body(+book: List<&2,KDef>, +t: KTerm, +next: U32, +steps: U32, +fuel: U32, +call: KTerm, +d: KDef, +body: KTerm) -> P205UResult:
  kc(P205UResult,p205v_allowed(body) && U32.is_eq(p205u_refs(body,dn(d)),0),u =>
    p205v_typed(p205v_fresh(book,t,ks(call),steps,fuel,f_fresh_term(body,[],next)),p205u_after_args(book,dt(d),terms_len(ks(call)))),u => P205UResult{t,next,steps,True{}})
# Inlining can expose a non-inferable Let (e.g. terminal local variable).
# Retain only the original callee's authenticated closed result domain.
@unsafe
def p205v_typed(+result: P205UResult, +ty: KTerm) -> P205UResult:
  match result:
    case P205UResult{term,next,steps,ok}:
      P205UResult{kc(KTerm,p98_tag_eq(term,"Let"),u => p205u_typed_arg(term,ty),u => term),next,steps,ok}
@unsafe
def p205v_fresh(+book: List<&2,KDef>, +old: KTerm, +args: List<&2,KTerm>, +steps: U32, +fuel: U32, +fresh: FFresh) -> P205UResult:
  match fresh:
    case FFresh{body,next}: p205v_apply(book,body,args,next,U32.inc(steps),fuel)
@unsafe
def p205v_apply(+book: List<&2,KDef>, +body: KTerm, +args: List<&2,KTerm>, +next: U32, +steps: U32, +fuel: U32) -> P205UResult:
  match args:
    case Nil{}: p205v_eval(book,body,next,steps,fuel)
    case Con{arg,rest}:
      kc(P205UResult,p98_tag_eq(body,"Lam") && U32.is_ne(qt(body),0) && U32.is_ne(qt(body),3),u =>
        kc(P205UResult,p205v_static(arg),v => p205v_apply(book,subst(kid(body,0),ix(body),arg),rest,next,steps,fuel),v =>
          p205u_bound(book,body,arg,p205v_apply(book,kid(body,0),rest,next,steps,fuel))),u =>
      kc(P205UResult,p98_tag_eq(body,"Mat") && U32.is_eq(ix(body),0) && U32.is_eq(terms_len(ks(body)),2) && p98_tag_eq(arg,"Ctr"),v =>
        kc(P205UResult,String.eq(nm(body),nm(arg)),w => p205v_apply(book,kid(body,0),nt_append(KTerm,ks(arg),rest),next,steps,fuel),w =>
          p205v_apply(book,kid(body,1),args,next,steps,fuel)),v =>
        P205UResult{nd_reapply(body,args),next,steps,True{}}))
@unsafe
def p205v_finish(+old: KTerm, +result: P205UResult) -> KTerm:
  match result:
    case P205UResult{term,next,steps,ok}:
      kc(KTerm,ok && U32.is_gt(nq_layout_remaining([term],16385),0),u => term,u => old)
@unsafe
def p205v_on(+book: List<&2,KDef>, +first: KTerm) -> KTerm:
  kc(KTerm,p98_tag_eq(first,"Absent"),u => first,u =>
  kc(KTerm,j_u32_native_book(book) && U32.is_lt(U32.max(norm_book_bound(book),norm_max_term(first)),4294800000),v =>
    p205v_finish(first,p205v_eval(book,first,U32.inc(U32.max(norm_book_bound(book),norm_max_term(first))),0,192)),v => first))
