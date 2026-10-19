# Experimental suffix liveness for Phase111 let lowering.
# No KTerm fields are changed. Every stored set is the mature all-Var analysis;
# binder identifiers are not removed. NU_Set suffixes share persistent tries.
type P112Liveness is Data:
  P112LivenessEmpty{}
  P112LivenessLeaf{+term: KTerm, +uses: NU_Set}
  P112LivenessLet{+value: KTerm, +id: U32, +uses: NU_Set, +rest: P112Liveness}

def p112_liveness_uses(plan: P112Liveness) -> NU_Set:
  match plan:
    case P112LivenessEmpty{}: NU_Empty{}
    case P112LivenessLeaf{term, uses}: uses
    case P112LivenessLet{value, id, uses, rest}: uses

# Scan each original binding once, backwards. Using the complete original head
# retains nc_uses' behavior even for extra children in a raw Bind-shaped node.
@unsafe
def p112_liveness_head(+head: KTerm, +rest: P112Liveness) -> P112Liveness:
  P112LivenessLet{kid(head, 0), ix(head), nc_uses_term(head, p112_liveness_uses(rest)), rest}

@unsafe
def p112_liveness_terms(terms: List<&2, KTerm>) -> P112Liveness:
  match terms:
    case Nil{}: P112LivenessEmpty{}
    case Con{+head, Nil{}}: p112_liveness_term(head)
    case Con{+head, +rest}: p112_liveness_head(head, p112_liveness_terms(rest))

@unsafe
def p112_liveness_term(+t: KTerm) -> P112Liveness:
  nt_choose(P112Liveness, p98_tag_eq(t, "Let") || p98_tag_eq(t, "NSeqLet"),
    u => p112_liveness_terms(ks(t)), u => P112LivenessLeaf{t, nc_uses(t)})

# Equivalent to adding nc_mklet(id, value, continuation), without reconstructing
# and rescanning the old continuation. A generated Bind has only this child.
@unsafe
def p112_liveness_bind(+value: KTerm, +id: U32, +rest: P112Liveness) -> P112Liveness:
  P112LivenessLet{value, id, nc_uses_term(value, p112_liveness_uses(rest)), rest}

# Preserve nd_bind_value's ordered argument bindings and exact fresh identifiers.
@unsafe
def p112_liveness_args(+tag: String, +name: String, args: List<&2, KTerm>, +acc: List<&2, KTerm>, +n: U32, +id: U32, +rest: P112Liveness) -> P112Liveness:
  match args:
    case Nil{}: p112_liveness_bind(kt(tag, name, 0, 0, List.reverse(&2, KTerm, acc)), id, rest)
    case Con{+head, +tail}: p112_liveness_bind(head, nc_id(n), p112_liveness_args(tag, name, tail, Con{var("", nc_id(n)), acc}, U32.inc(n), id, rest))

@unsafe
def p112_liveness_lower_partition(+book: List<&2, KDef>, +plan: P112Liveness, +n: U32, parts: P111Partition) -> P111Code:
  match parts:
    case P111Partition{+live, +drop}: p111_prepend(drop, p112_liveness_live(book, plan, live, n))

@unsafe
def p112_liveness_lower(+book: List<&2, KDef>, +plan: P112Liveness, +env: List<&2, NC_Binding>, +n: U32) -> P111Code:
  p112_liveness_lower_partition(book, plan, n, p111_partition(env, p112_liveness_uses(plan)))

@unsafe
def p112_liveness_value(+book: List<&2, KDef>, +value: KTerm, +rest: P112Liveness, +env: List<&2, NC_Binding>, +id: U32, +n: U32, emitted: P111ValueCode) -> P111Code:
  match emitted:
    case P111ValueCode{+prefix, +word, +error}:
      +uses = p112_liveness_uses(rest)
      +held = nc_live_uses(env, uses)
      +body = p112_liveness_lower(book, rest, nt_append(NC_Binding, held, [nc_binding(id)]), n)
      nt_choose(P111Code, String.eq(error, ""),
        u => p111_prepend(nt_append(N111Stmt, p111_keep(nc_live_env(env, value), uses), nt_append(N111Stmt, prefix, [N111Set{"v_" ++ U32.show(id), N111U64{}, word}])), body),
        u => p111_fail(error, n))

@unsafe
def p112_liveness_cut(+book: List<&2, KDef>, +value: KTerm, +rest: P112Liveness, +env: List<&2, NC_Binding>, +id: U32, +n: U32) -> P111Code:
  +next = p111_name(n)
  +uses = p112_liveness_uses(rest)
  +held = nc_live_uses(env, uses)
  +params = nt_append(NC_Binding, held, [nc_binding(id)])
  +body = p112_liveness_lower(book, rest, params, U32.inc(n))
  +value_env = nc_live_env(env, value)
  +val = p111_live(book, value, value_env, p111_fresh(body))
  +seg : N111Segment = p111_segment(next, params, nt_count(NC_Binding, held), 1, p111_body(body))
  P111Code{nt_append(N111Stmt, p111_keep(value_env, uses), nt_append(N111Stmt, p111_frame(held, next), p111_body(val))), Con{seg, nt_append(N111Segment, p111_segments(body), p111_segments(val))}, p111_fresh(val), p111_first(p111_error(body), p111_error(val))}

@unsafe
def p112_liveness_ctor(+book: List<&2, KDef>, +value: KTerm, +rest: P112Liveness, +env: List<&2, NC_Binding>, +id: U32, +n: U32, literal: NC_Literal) -> P111Code:
  match literal:
    case NC_Literal{+valid, +word}:
      nt_choose(P111Code, valid,
        u => p112_liveness_value(book, value, rest, env, id, n, P111ValueCode{Nil{}, N111Const{word, 0}, ""}),
        u => p112_liveness_lower(book, p112_liveness_args("NCtr", nm(value), ks(value), Nil{}, n, id, rest), env, U32.add(n, terms_len(ks(value)))))

@unsafe
def p112_liveness_let(+book: List<&2, KDef>, +value: KTerm, +rest: P112Liveness, +env: List<&2, NC_Binding>, +id: U32, +n: U32) -> P111Code:
  +tag = tg(value)
  +prim = nd_native_call(book, value)
  nt_choose(P111Code, String.eq(tag, "Var") || String.eq(tag, "NWord") || String.eq(tag, "NCtr") || String.eq(tag, "NOp"),
    u => p112_liveness_value(book, value, rest, env, id, n, p111_value(value, env)), u =>
  nt_choose(P111Code, String.eq(tag, "Ctr"), u => p112_liveness_ctor(book, value, rest, env, id, n, nc_literal(value)), u =>
  nt_choose(P111Code, Bool.not(String.eq(prim, "")),
    u => p112_liveness_lower(book, p112_liveness_args("NOp", prim, nd_args(value, Nil{}), Nil{}, n, id, rest), env, U32.add(n, terms_len(nd_args(value, Nil{})))),
    u => p112_liveness_cut(book, value, rest, env, id, n))))

@unsafe
def p112_liveness_live(+book: List<&2, KDef>, plan: P112Liveness, +env: List<&2, NC_Binding>, +n: U32) -> P111Code:
  match plan:
    case P112LivenessEmpty{}: p111_fail("empty native let", n)
    case P112LivenessLeaf{+term, uses}: p111_live(book, term, env, n)
    case P112LivenessLet{+value, +id, uses, +rest}: p112_liveness_let(book, value, rest, env, id, n)

# Entry dispatch prepares a sequence once before its first partition, avoiding
# the original whole-sequence scan followed by scans of every shrinking suffix.
@unsafe
def p111_lower(book, t, env, n):
  nt_choose(P111Code, p98_tag_eq(t, "Let") || p98_tag_eq(t, "NSeqLet"),
    u => p112_liveness_lower(book, p112_liveness_terms(ks(t)), env, n),
    u => p112_liveness_other(book, t, env, n))

@unsafe
def p112_liveness_other(+book: List<&2, KDef>, +t: KTerm, env: List<&2, NC_Binding>, +n: U32) -> P111Code:
  match env:
    case Nil{}: p111_live(book, t, Nil{}, n)
    case Con{+head, +rest}: p111_lower_partition(book, t, n, p111_partition(Con{head, rest}, nc_uses(t)))

@unsafe
def p111_lets(+book: List<&2, KDef>, terms: List<&2, KTerm>, +env: List<&2, NC_Binding>, +n: U32) -> P111Code:
  p112_liveness_live(book, p112_liveness_terms(terms), env, n)
