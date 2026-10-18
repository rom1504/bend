law p111_lower:
  for +book: List<&2, KDef>
  for +t: KTerm
  for +env: List<&2, NC_Binding>
  for +n: U32
  P111Code

law p111_live:
  for +book: List<&2, KDef>
  for +t: KTerm
  for +env: List<&2, NC_Binding>
  for +n: U32
  P111Code

@unsafe
def p111_lower_partition(+book: List<&2, KDef>, +t: KTerm, +n: U32, parts: P111Partition) -> P111Code:
  match parts:
    case P111Partition{+live, +drop}: p111_prepend(drop, p111_live(book, t, live, n))

@unsafe
def p111_lower(book, t, env, n):
  p111_lower_partition(book, t, n, p111_partition(env, nc_uses(t)))

@unsafe
def p111_bind_value(+book: List<&2, KDef>, +value: KTerm, +body: KTerm, +env: List<&2, NC_Binding>, +id: U32, +n: U32, emitted: P111ValueCode) -> P111Code:
  match emitted:
    case P111ValueCode{+prefix, +word, +error}:
      +uses = nc_uses(body)
      +held = nc_live_uses(env, uses)
      +rest = p111_lower(book, body, nt_append(NC_Binding, held, [nc_binding(id)]), n)
      nt_choose(P111Code, String.eq(error, ""),
        u => p111_prepend(nt_append(N111Stmt, p111_keep(nc_live_env(env, value), uses), nt_append(N111Stmt, prefix, [N111Set{"v_" ++ U32.show(id), N111U64{}, word}])), rest),
        u => p111_fail(error, n))

@unsafe
def p111_let_cut(+book: List<&2, KDef>, +value: KTerm, +body: KTerm, +env: List<&2, NC_Binding>, +id: U32, +n: U32) -> P111Code:
  +next = p111_name(n)
  +uses = nc_uses(body)
  +held = nc_live_uses(env, uses)
  +params = nt_append(NC_Binding, held, [nc_binding(id)])
  +rest = p111_lower(book, body, params, U32.inc(n))
  +value_env = nc_live_env(env, value)
  +val = p111_live(book, value, value_env, p111_fresh(rest))
  +seg : N111Segment = p111_segment(next, params, nt_count(NC_Binding, held), 1, p111_body(rest))
  P111Code{nt_append(N111Stmt, p111_keep(value_env, uses), nt_append(N111Stmt, p111_frame(held, next), p111_body(val))), Con{seg, nt_append(N111Segment, p111_segments(rest), p111_segments(val))}, p111_fresh(val), p111_first(p111_error(rest), p111_error(val))}

@unsafe
def p111_let_ctor(+book: List<&2, KDef>, +value: KTerm, +body: KTerm, +env: List<&2, NC_Binding>, +id: U32, +n: U32, literal: NC_Literal) -> P111Code:
  match literal:
    case NC_Literal{+valid, +word}:
      nt_choose(P111Code, valid,
        u => p111_bind_value(book, value, body, env, id, n, P111ValueCode{Nil{}, N111Const{word, 0}, ""}),
        u => p111_lower(book, nd_bind_value("NCtr", nm(value), ks(value), Nil{}, n, id, body), env, U32.add(n, terms_len(ks(value)))))

@unsafe
def p111_let(+book: List<&2, KDef>, +value: KTerm, +body: KTerm, +env: List<&2, NC_Binding>, +id: U32, +n: U32) -> P111Code:
  +tag = tg(value)
  +prim = nd_native_call(book, value)
  nt_choose(P111Code, String.eq(tag, "Var") || String.eq(tag, "NWord") || String.eq(tag, "NCtr") || String.eq(tag, "NOp"),
    u => p111_bind_value(book, value, body, env, id, n, p111_value(value, env)), u =>
  nt_choose(P111Code, String.eq(tag, "Ctr"), u => p111_let_ctor(book, value, body, env, id, n, nc_literal(value)), u =>
  nt_choose(P111Code, Bool.not(String.eq(prim, "")),
    u => p111_lower(book, nd_bind_value("NOp", prim, nd_args(value, Nil{}), Nil{}, n, id, body), env, U32.add(n, terms_len(nd_args(value, Nil{})))),
    u => p111_let_cut(book, value, body, env, id, n))))

@unsafe
def p111_lets(+book: List<&2, KDef>, terms: List<&2, KTerm>, +env: List<&2, NC_Binding>, +n: U32) -> P111Code:
  match terms:
    case Nil{}: p111_fail("empty native let", n)
    case Con{+head, Nil{}}: p111_lower(book, head, env, n)
    case Con{+head, +rest}: p111_let(book, kid(head, 0), kt("NSeqLet", "", 0, 0, rest), env, ix(head), n)

@unsafe
def p111_lambda(+book: List<&2, KDef>, +t: KTerm, +env: List<&2, NC_Binding>, +n: U32) -> P111Code:
  +name = p111_name(n)
  +params = nt_append(NC_Binding, env, [nc_binding(ix(t))])
  +body = p111_lower(book, kid(t, 0), params, U32.inc(n))
  +seg : N111Segment = p111_segment(name, params, 0, 0, p111_body(body))
  +result = p111_prepend(nt_append(N111Stmt, p111_store(p111_env_words(env), 0), [N111Call{"value", N111U64{}, "p111_rt_closure", [p111_state(), N111Arg{N111U32{}, N111FuncId{name}}, p111_scratch(), p111_u32(nt_count(NC_Binding, env))]}]), p111_return(N111Local{"value"}, p111_fresh(body)))
  P111Code{p111_body(result), Con{seg, p111_segments(body)}, p111_fresh(body), p111_error(body)}

@unsafe
def p111_slow_app(+book: List<&2, KDef>, +t: KTerm, +env: List<&2, NC_Binding>, +n: U32) -> P111Code:
  +f = nc_id(n)
  +a = nc_id(U32.inc(n))
  p111_lower(book, nc_mklet(f, kid(t, 0), nc_mklet(a, kid(t, 1), kt("NApply", "", 0, 0, [var("", f), var("", a)]))), env, U32.add(n, 2))

@unsafe
def p111_app(+book: List<&2, KDef>, +t: KTerm, +env: List<&2, NC_Binding>, +n: U32) -> P111Code:
  +head = nd_head(t)
  +args = nd_args(t, Nil{})
  +prim = nd_native_call(book, t)
  nt_choose(P111Code, Bool.not(String.eq(prim, "")),
    u => p111_lower(book, nc_sequence("NOp", prim, args, Nil{}, n), env, U32.add(n, terms_len(args))), u =>
  nt_choose(P111Code, String.eq(tg(head), "Lam"), u => p111_lower(book, nd_beta(head, args), env, n), u =>
  nt_choose(P111Code, String.eq(tg(head), "Mat"),
    u => nt_choose(P111Code, U32.is_eq(terms_len(args), 1) || nd_match_vars(args),
      v => p111_lower(book, nd_match_sequence(head, args, Nil{}, n), env, U32.add(n, terms_len(args))),
      v => p111_slow_app(book, t, env, n)), u =>
  nt_choose(P111Code, String.eq(tg(head), "Ref"),
    u => p111_ref_app(book, t, head, args, env, n),
    u => p111_slow_app(book, t, env, n)))))

@unsafe
def p111_ref_app(+book: List<&2, KDef>, +t: KTerm, +head: KTerm, +args: List<&2, KTerm>, +env: List<&2, NC_Binding>, +n: U32) -> P111Code:
  nt_choose(P111Code, U32.is_eq(qt(head), 3), u => p111_slow_app(book, t, env, n),
    u => nt_choose(P111Code, U32.is_eq(terms_len(args), nd_arity(book, nm(head))),
      v => p111_lower(book, nc_sequence("NCall", nd_name(nc_ref_name(book, nm(head))), args, Nil{}, n), env, U32.add(n, terms_len(args))),
      v => p111_slow_app(book, t, env, n)))

@unsafe
def p111_apply(+values: List<&2, N111Value>, +n: U32) -> P111Code:
  P111Code{[N111Call{"reply", N111U64{}, "p111_rt_apply", [p111_state(), p111_word(p111_head(values)), p111_word(p111_head(p111_tail(values)))]}, N111Return{N111Local{"reply"}}], Nil{}, n, ""}

@unsafe
def p111_guard_io(+name: String, +word: N111Value, +body: List<&2, N111Stmt>) -> List<&2, N111Stmt>:
  nt_choose(List<&2, N111Stmt>, String.eq(name, "Emit") || String.eq(name, "Halt"),
    u => [N111Call{"tag", N111U64{}, "p111_rt_tag", [p111_state(), p111_word(word)]}, N111Bin{"tag_hit", N111U64{}, "eq", N111Local{"tag"}, N111CtorId{"Emit"}}, N111Bin{"tag_other", N111U64{}, "eq", N111Local{"tag"}, N111CtorId{"Halt"}}, N111Bin{"valid_tag", N111U32{}, "or", N111Local{"tag_hit"}, N111Local{"tag_other"}}, N111If{N111Local{"valid_tag"}, body, [N111Call{"reply", N111U64{}, "p111_rt_fail", [p111_state(), p111_u32(2)]}, N111Return{N111Local{"reply"}}]}],
    u => body)

@unsafe
def p111_match_apply(+book: List<&2, KDef>, +t: KTerm, +env: List<&2, NC_Binding>, +n: U32) -> P111Code:
  +mat = kid(t, 0)
  +arg = kid(t, 1)
  +word : N111Value = N111Local{nc_word(ix(arg), env)}
  +count = nt_choose(U32, U32.is_eq(ix(mat), 0), u => nc_field_count(book, nm(mat)), u => U32.sub(ix(mat), 1))
  +hit = p111_lower(book, nd_reapply(nc_field_apps(kid(mat, 0), count, 0, n), nd_match_rest(t)), nt_append(NC_Binding, nc_remove_env(env, ix(arg)), p111_field_env(count, 0, n)), U32.add(n, count))
  +miss = p111_lower(book, nd_reapply(app(kid(mat, 1), arg), nd_match_rest(t)), env, p111_fresh(hit))
  +branch = nt_append(N111Stmt, p111_test(nm(mat), word), [N111If{N111Local{"match_condition"}, nt_append(N111Stmt, p111_take(nm(mat), word, count, n), p111_body(hit)), p111_body(miss)}])
  P111Code{p111_guard_io(nm(mat), word, branch), nt_append(N111Segment, p111_segments(hit), p111_segments(miss)), p111_fresh(miss), p111_first(p111_error(hit), p111_error(miss))}

@unsafe
def p111_match_value(+book: List<&2, KDef>, +t: KTerm, +env: List<&2, NC_Binding>, +n: U32) -> P111Code:
  p111_lambda(book, k_lam("", nc_id(n), 1, [kt("NMatch", "", 0, 0, [t, var("", nc_id(n))])], 0, 0, False{}), env, U32.inc(n))
