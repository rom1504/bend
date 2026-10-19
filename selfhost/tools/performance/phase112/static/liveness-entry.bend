# Optional adapter after the frozen backward-liveness module.
@unsafe
def p112s_liveness_fallback(+book: List<&2, KDef>, +value: KTerm, +rest: P112Liveness, +env: List<&2, NC_Binding>, +id: U32, +n: U32) -> P111Code:
  +tag = tg(value)
  +prim = nd_native_call(book, value)
  nt_choose(P111Code, String.eq(tag, "Var") || String.eq(tag, "NWord") || String.eq(tag, "NCtr") || String.eq(tag, "NOp"),
    u => p112_liveness_value(book, value, rest, env, id, n, p111_value(value, env)), u =>
  nt_choose(P111Code, String.eq(tag, "Ctr"), u => p112_liveness_ctor(book, value, rest, env, id, n, nc_literal(value)), u =>
  nt_choose(P111Code, Bool.not(String.eq(prim, "")),
    u => p112_liveness_lower(book, p112_liveness_args("NOp", prim, nd_args(value, Nil{}), Nil{}, n, id, rest), env, U32.add(n, terms_len(nd_args(value, Nil{})))),
    u => p112_liveness_cut(book, value, rest, env, id, n))))


@unsafe
def p112_liveness_let(+book: List<&2,KDef>, +value: KTerm, +rest: P112Liveness, +env: List<&2,NC_Binding>, +id: U32, +n: U32) -> P111Code:
  nt_choose(P111Code,String.eq(tg(value),"NStatic"),u => p112_liveness_value(book,value,rest,env,id,n,p112s_value(book,value)),
    u => p112s_liveness_fallback(book,value,rest,env,id,n))
