@unsafe
def p111_lower_ctor(+book: List<&2, KDef>, +t: KTerm, +env: List<&2, NC_Binding>, +n: U32, literal: NC_Literal) -> P111Code:
  match literal:
    case NC_Literal{+valid, +value}:
      nt_choose(P111Code, valid, u => p111_return(N111Const{value, 0}, n),
        u => p111_lower(book, nc_sequence("NCtr", nm(t), ks(t), Nil{}, n), env, U32.add(n, terms_len(ks(t)))))

@unsafe
def p111_nat_sum_finish(+values: List<&2, N111Value>, +n: U32, offset: Maybe<&2, U32>) -> P111Code:
  match offset:
    case None{}: p111_fail("invalid native Nat offset", n)
    case Some{+value}:
      +first = p111_constructor("Succ", values)
      p111_nat_sum_join(first, value, n)

@unsafe
def p111_nat_sum_join(first: P111ValueCode, +offset: U32, +n: U32) -> P111Code:
  match first:
    case P111ValueCode{+body, +word, +error}:
      p111_prepend(body, p111_value_return(p111_intrinsic("nat_add", [word, N111Const{offset, 0}]), n))

@unsafe
def p111_live(book, t, env, n):
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
