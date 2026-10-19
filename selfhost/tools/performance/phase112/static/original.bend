# Exact Phase111 declarations renamed for non-static delegation.
law p112s_live_fallback:
  for +book: List<&2, KDef>
  for +t: KTerm
  for +env: List<&2, NC_Binding>
  for +n: U32
  P111Code

@unsafe
def p112s_live_fallback(book, t, env, n):
  +tag = tg(t)
  nt_choose(P111Code, String.eq(tag, "NWord") || String.eq(tag, "Var"), u => p111_value_return(p111_value(t, env), n), u =>
  nt_choose(P111Code, String.eq(tag, "Ref"), u => p111_jump(nc_ref_name(book, nm(t)), Nil{}, n), u =>
  nt_choose(P111Code, String.eq(tag, "Ann") || String.eq(tag, "Loc") || String.eq(tag, "Src") || String.eq(tag, "Cut") || String.eq(tag, "Slf") || String.eq(tag, "Ins"), u => p111_lower(book, kid(t, 0), env, n), u =>
  nt_choose(P111Code, String.eq(tag, "Lam"), u => p111_lambda(book, t, env, n), u =>
  nt_choose(P111Code, String.eq(tag, "App"), u => p111_app(book, t, env, n), u =>
  nt_choose(P111Code, String.eq(tag, "Let") || String.eq(tag, "NSeqLet"), u => p111_lets(book, ks(t), env, n), u =>
  nt_choose(P111Code, String.eq(tag, "NNatAdd"), u => p111_lower(book, nc_sequence("NNatSum", nm(t), ks(t), Nil{}, n), env, U32.inc(n)), u =>
  nt_choose(P111Code, String.eq(tag, "NNatSum"), u => p111_nat_sum_finish(p111_values(ks(t), env), n, U32.read(nm(t))), u =>
  nt_choose(P111Code, String.eq(tag, "Ctr"), u => p111_lower_ctor(book, t, env, n, nc_literal(t)), u =>
  nt_choose(P111Code, String.eq(tag, "NCtr") || String.eq(tag, "NOp"), u => p111_value_return(p111_value(t, env), n), u =>
  nt_choose(P111Code, String.eq(tag, "NApply"), u => p111_apply(p111_values(ks(t), env), n), u =>
  nt_choose(P111Code, String.eq(tag, "NCall"), u => p111_jump(nm(t), p111_values(ks(t), env), n), u =>
  nt_choose(P111Code, String.eq(tag, "Rfl") || String.eq(tag, "Typ") || String.eq(tag, "All") || String.eq(tag, "Qua") || String.eq(tag, "ADT") || String.eq(tag, "Eql"), u => p111_return(N111Const{0, 0}, n), u =>
  nt_choose(P111Code, String.eq(tag, "Mat"), u => p111_match_value(book, t, env, n), u =>
  nt_choose(P111Code, String.eq(tag, "NMatch"), u => p111_match_apply(book, t, env, n), u =>
  nt_choose(P111Code, String.eq(tag, "Efq"), u => P111Code{[N111Call{"reply", N111U64{}, "p111_rt_fail", [p111_state(), p111_u32(4)]}, N111Return{N111Local{"reply"}}], Nil{}, n, ""}, u =>
  nt_choose(P111Code, String.eq(tag, "Rwt"), u => p111_lower(book, kid(t, 2), env, n), u =>
    p111_fail("structured native lowering does not support core node " ++ tag, n))))))))))))))))))


# Phase111 module: selfhost/tools/performance/phase111/segment/lower-book.bend
# Request source remains authoritative for validation and metadata. Cached
# NativeErasedBody facts are reused without adding optional optimizer forms.

@unsafe
def p112s_let_fallback(+book: List<&2, KDef>, +value: KTerm, +body: KTerm, +env: List<&2, NC_Binding>, +id: U32, +n: U32) -> P111Code:
  +tag = tg(value)
  +prim = nd_native_call(book, value)
  nt_choose(P111Code, String.eq(tag, "Var") || String.eq(tag, "NWord") || String.eq(tag, "NCtr") || String.eq(tag, "NOp"),
    u => p111_bind_value(book, value, body, env, id, n, p111_value(value, env)), u =>
  nt_choose(P111Code, String.eq(tag, "Ctr"), u => p111_let_ctor(book, value, body, env, id, n, nc_literal(value)), u =>
  nt_choose(P111Code, Bool.not(String.eq(prim, "")),
    u => p111_lower(book, nd_bind_value("NOp", prim, nd_args(value, Nil{}), Nil{}, n, id, body), env, U32.add(n, terms_len(nd_args(value, Nil{})))),
    u => p111_let_cut(book, value, body, env, id, n))))
