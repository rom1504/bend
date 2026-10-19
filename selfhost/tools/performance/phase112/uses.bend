# Reuse deterministic body analysis; emitted operations and order are unchanged.
@unsafe
def p111_lower(book, t, env, n):
  match env:
    case Nil{}: p111_live(book, t, env, n)
    case Con{head, rest}: p111_lower_partition(book, t, n, p111_partition(env, nc_uses(t)))

@unsafe
def p111_bind_value(+book: List<&2, KDef>, +value: KTerm, +body: KTerm, +env: List<&2, NC_Binding>, +id: U32, +n: U32, emitted: P111ValueCode) -> P111Code:
  match emitted:
    case P111ValueCode{+prefix, +word, +error}:
      +uses = nc_uses(body)
      +held = nc_live_uses(env, uses)
      +rest = p111_lower_partition(book, body, n, p111_partition(nt_append(NC_Binding, held, [nc_binding(id)]), uses))
      nt_choose(P111Code, String.eq(error, ""),
        u => p111_prepend(nt_append(N111Stmt, p111_keep(nc_live_env(env, value), uses), nt_append(N111Stmt, prefix, [N111Set{"v_" ++ U32.show(id), N111U64{}, word}])), rest),
        u => p111_fail(error, n))

@unsafe
def p111_let_cut(+book: List<&2, KDef>, +value: KTerm, +body: KTerm, +env: List<&2, NC_Binding>, +id: U32, +n: U32) -> P111Code:
  +next = p111_name(n)
  +uses = nc_uses(body)
  +held = nc_live_uses(env, uses)
  +params = nt_append(NC_Binding, held, [nc_binding(id)])
  +rest = p111_lower_partition(book, body, U32.inc(n), p111_partition(params, uses))
  +value_env = nc_live_env(env, value)
  +val = p111_live(book, value, value_env, p111_fresh(rest))
  +seg : N111Segment = p111_segment(next, params, nt_count(NC_Binding, held), 1, p111_body(rest))
  P111Code{nt_append(N111Stmt, p111_keep(value_env, uses), nt_append(N111Stmt, p111_frame(held, next), p111_body(val))), Con{seg, nt_append(N111Segment, p111_segments(rest), p111_segments(val))}, p111_fresh(val), p111_first(p111_error(rest), p111_error(val))}

