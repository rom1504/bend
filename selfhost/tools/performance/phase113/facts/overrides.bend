# Optional exact declarations: only the result binding producer changes.

@unsafe
def p111_bind_value(+book: List<&2, KDef>, +value: KTerm, +body: KTerm, +env: List<&2, NC_Binding>, +id: U32, +n: U32, emitted: P111ValueCode) -> P111Code:
  match emitted:
    case P111ValueCode{+prefix, +word, +error}:
      +uses = nc_uses(body)
      +held = nc_live_uses(env, uses)
      +rest = p111_lower(book, body, nt_append(NC_Binding, held, [p113_binding(book, id, value, env)]), n)
      nt_choose(P111Code, String.eq(error, ""),
        u => p111_prepend(nt_append(N111Stmt, p111_keep(nc_live_env(env, value), uses), nt_append(N111Stmt, prefix, [N111Set{"v_" ++ U32.show(id), N111U64{}, word}])), rest),
        u => p111_fail(error, n))

@unsafe
def p112_liveness_value(+book: List<&2, KDef>, +value: KTerm, +rest: P112Liveness, +env: List<&2, NC_Binding>, +id: U32, +n: U32, emitted: P111ValueCode) -> P111Code:
  match emitted:
    case P111ValueCode{+prefix, +word, +error}:
      +uses = p112_liveness_uses(rest)
      +held = nc_live_uses(env, uses)
      +body = p112_liveness_lower(book, rest, nt_append(NC_Binding, held, [p113_binding(book, id, value, env)]), n)
      nt_choose(P111Code, String.eq(error, ""),
        u => p111_prepend(nt_append(N111Stmt, p111_keep(nc_live_env(env, value), uses), nt_append(N111Stmt, prefix, [N111Set{"v_" ++ U32.show(id), N111U64{}, word}])), body),
        u => p111_fail(error, n))

@unsafe
def p112_liveness_cut(+book: List<&2, KDef>, +value: KTerm, +rest: P112Liveness, +env: List<&2, NC_Binding>, +id: U32, +n: U32) -> P111Code:
  +next = p111_name(n)
  +uses = p112_liveness_uses(rest)
  +held = nc_live_uses(env, uses)
  +params = nt_append(NC_Binding, held, [p113_binding(book, id, value, env)])
  +body = p112_liveness_lower(book, rest, params, U32.inc(n))
  +value_env = nc_live_env(env, value)
  +val = p111_live(book, value, value_env, p111_fresh(body))
  +seg : N111Segment = p111_segment(next, params, nt_count(NC_Binding, held), 1, p111_body(body))
  P111Code{nt_append(N111Stmt, p111_keep(value_env, uses), nt_append(N111Stmt, p111_frame(held, next), p111_body(val))), Con{seg, nt_append(N111Segment, p111_segments(body), p111_segments(val))}, p111_fresh(val), p111_first(p111_error(body), p111_error(val))}

@unsafe
def p111_let_cut(+book: List<&2, KDef>, +value: KTerm, +body: KTerm, +env: List<&2, NC_Binding>, +id: U32, +n: U32) -> P111Code:
  +next = p111_name(n)
  +uses = nc_uses(body)
  +held = nc_live_uses(env, uses)
  +params = nt_append(NC_Binding, held, [p113_binding(book, id, value, env)])
  +rest = p111_lower(book, body, params, U32.inc(n))
  +value_env = nc_live_env(env, value)
  +val = p111_live(book, value, value_env, p111_fresh(rest))
  +seg : N111Segment = p111_segment(next, params, nt_count(NC_Binding, held), 1, p111_body(rest))
  P111Code{nt_append(N111Stmt, p111_keep(value_env, uses), nt_append(N111Stmt, p111_frame(held, next), p111_body(val))), Con{seg, nt_append(N111Segment, p111_segments(rest), p111_segments(val))}, p111_fresh(val), p111_first(p111_error(rest), p111_error(val))}
