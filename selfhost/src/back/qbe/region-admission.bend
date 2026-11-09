

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
def p112_liveness_ctor(+book: List<&2, KDef>, +value: KTerm, +rest: P112Liveness, +env: List<&2, NC_Binding>, +id: U32, +n: U32, literal: NC_Literal) -> P111Code:
  match literal:
    case NC_Literal{+valid, +word}:
      nt_choose(P111Code, valid,
        u => p112_liveness_value(book, value, rest, env, id, n, P111ValueCode{Nil{}, N111Const{word, 0}, ""}),
        u => p112_liveness_lower(book, p112_liveness_args("NCtr", nm(value), ks(value), Nil{}, n, id, rest), env, U32.add(n, terms_len(ks(value)))))


@unsafe
def p112_liveness_let(+book: List<&2,KDef>, +value: KTerm, +rest: P112Liveness, +env: List<&2,NC_Binding>, +id: U32, +n: U32) -> P111Code:
  nt_choose(P111Code,String.eq(tg(value),"NStatic"),u => p112_liveness_value(book,value,rest,env,id,n,p112s_value(book,value)),
    u => p112s_liveness_fallback(book,value,rest,env,id,n))

@unsafe
def p112_liveness_live(+book: List<&2, KDef>, plan: P112Liveness, +env: List<&2, NC_Binding>, +n: U32) -> P111Code:
  match plan:
    case P112LivenessEmpty{}: p111_fail("empty native let", n)
    case P112LivenessLeaf{+term, uses}: p111_live(book, term, env, n)
    case P112LivenessLet{+value, +id, uses, +rest}: p112_liveness_let(book, value, rest, env, id, n)

# Entry dispatch prepares a sequence once before its first partition, avoiding
# the original whole-sequence scan followed by scans of every shrinking suffix.


@unsafe
def p112_liveness_other(+book: List<&2, KDef>, +t: KTerm, env: List<&2, NC_Binding>, +n: U32) -> P111Code:
  match env:
    case Nil{}: p111_live(book, t, Nil{}, n)
    case Con{+head, +rest}: p111_lower_partition(book, t, n, p111_partition(Con{head, rest}, nc_uses(t)))


@unsafe
def p112_intrinsic_fallback(+name: String, +values: List<&2,N111Value>) -> P111ValueCode:
  match values:
    case Con{+value,Nil{}}:
      nt_choose(P111ValueCode,String.eq(name,"u32_to_nat") || String.eq(name,"f32_bits"),
        u => P111ValueCode{[N111Set{"value",N111U64{},value}],N111Local{"value"},""},
        u => p125i_previous_fallback(name,values))
    case _: p125i_previous_fallback(name,values)

@unsafe
def p112_scalar_safe_value(value: N111Value) -> Bool:
  match value:
    case N111Local{+name}: Bool.not(String.eq(name, "p112_s_a") || String.eq(name, "p112_s_b") || String.eq(name, "p112_s_test"))
    case _: True{}


@unsafe
def p112_scalar_safe(values: List<&2, N111Value>) -> Bool:
  match values:
    case Nil{}: True{}
    case Con{head, rest}: p112_scalar_safe_value(head) && p112_scalar_safe(rest)


@unsafe
def p112_scalar_arity(+id: U32) -> U32:
  nt_choose(U32, (U32.is_ge(id, 1) && U32.is_le(id, 12)) || U32.is_eq(id, 16) || U32.is_eq(id, 17), u => 2, u =>
  nt_choose(U32, (U32.is_ge(id, 13) && U32.is_le(id, 15)) || U32.is_eq(id, 20) || U32.is_eq(id, 21), u => 1, u => 0))


@unsafe
def p112_scalar_op(+id: U32) -> String:
  nt_choose(String, U32.is_eq(id, 1), u => "add", u =>
  nt_choose(String, U32.is_eq(id, 2), u => "sub", u =>
  nt_choose(String, U32.is_eq(id, 3), u => "and", u =>
  nt_choose(String, U32.is_eq(id, 4), u => "or", u =>
  nt_choose(String, U32.is_eq(id, 5), u => "xor", u =>
  nt_choose(String, U32.is_eq(id, 6), u => "mul", u =>
  nt_choose(String, U32.is_eq(id, 7), u => "eq", u =>
  nt_choose(String, U32.is_eq(id, 8), u => "ne", u =>
  nt_choose(String, U32.is_eq(id, 9), u => "ult", u =>
  nt_choose(String, U32.is_eq(id, 10), u => "ule", u =>
  nt_choose(String, U32.is_eq(id, 11), u => "ugt", u => "uge")))))))))))


def p112_scalar_result(body: List<&2, N111Stmt>) -> P111ValueCode:
  P111ValueCode{body, N111Local{"value"}, ""}


def p112_scalar_mask() -> N111Value:
  N111Const{4294967295, 0}


@unsafe
def p112_scalar_operands(+a: N111Value, +b: N111Value, body: List<&2, N111Stmt>) -> List<&2, N111Stmt>:
  Con{N111Bin{"p112_s_a", N111U64{}, "and", a, p112_scalar_mask()},
    Con{N111Bin{"p112_s_b", N111U64{}, "and", b, p112_scalar_mask()}, body}}


@unsafe
def p112_scalar_binary(op: String, a: N111Value, b: N111Value) -> P111ValueCode:
  p112_scalar_result(p112_scalar_operands(a, b,
    [N111Bin{"value", N111U64{}, op, N111Local{"p112_s_a"}, N111Local{"p112_s_b"}},
     N111Bin{"value", N111U64{}, "and", N111Local{"value"}, p112_scalar_mask()}]))


@unsafe
def p112_scalar_compare(op: String, a: N111Value, b: N111Value) -> P111ValueCode:
  p112_scalar_result(p112_scalar_operands(a, b,
    [N111Bin{"p112_s_test", N111U64{}, op, N111Local{"p112_s_a"}, N111Local{"p112_s_b"}},
     N111If{N111Local{"p112_s_test"},
       [N111Set{"value", N111U64{}, N111Const{1, 0}}],
       [N111Set{"value", N111U64{}, N111Const{0, 0}}]}]))

# The shift count is a full Nat word. Inspect it before narrowing; in particular
# 2^32 must produce zero, not behave like a zero shift. Both branches avoid a
# machine shift by an out-of-range count.


@unsafe
def p112_scalar_shift(op: String, a: N111Value, count: N111Value) -> P111ValueCode:
  p112_scalar_result(
    [N111Bin{"p112_s_a", N111U64{}, "and", a, p112_scalar_mask()},
     N111Set{"p112_s_b", N111U64{}, count},
     N111Bin{"p112_s_test", N111U64{}, "ult", N111Local{"p112_s_b"}, N111Const{32, 0}},
     N111If{N111Local{"p112_s_test"},
       [N111Bin{"value", N111U64{}, op, N111Local{"p112_s_a"}, N111Local{"p112_s_b"}},
        N111Bin{"value", N111U64{}, "and", N111Local{"value"}, p112_scalar_mask()}],
       [N111Set{"value", N111U64{}, N111Const{0, 0}}]}])


@unsafe
def p112_scalar_dispatch(+id: U32, +values: List<&2, N111Value>) -> P111ValueCode:
  +a = p111_head(values)
  +b = p111_head(p111_tail(values))
  nt_choose(P111ValueCode, U32.is_le(id, 6), u => p112_scalar_binary(p112_scalar_op(id), a, b), u =>
  nt_choose(P111ValueCode, U32.is_le(id, 12), u => p112_scalar_compare(p112_scalar_op(id), a, b), u =>
  nt_choose(P111ValueCode, U32.is_eq(id, 13), u => p112_scalar_binary("add", a, N111Const{1, 0}), u =>
  nt_choose(P111ValueCode, U32.is_eq(id, 14), u => p112_scalar_binary("shl", a, N111Const{1, 0}), u =>
  nt_choose(P111ValueCode, U32.is_eq(id, 15), u => p112_scalar_binary("shr", a, N111Const{1, 0}), u =>
  nt_choose(P111ValueCode, U32.is_eq(id, 16), u => p112_scalar_shift("shl", a, b), u =>
  nt_choose(P111ValueCode, U32.is_eq(id, 17), u => p112_scalar_shift("shr", a, b), u =>
  nt_choose(P111ValueCode, U32.is_eq(id, 20), u => p112_scalar_binary("xor", a, p112_scalar_mask()),
    u => p112_scalar_compare("eq", a, N111Const{0, 0})))))))))


@unsafe
def p112_intrinsic(+name: String, +values: List<&2, N111Value>) -> P111ValueCode:
  +id = p111_op_id(name)
  +arity = p112_scalar_arity(id)
  nt_choose(P111ValueCode, U32.is_gt(arity, 0) && U32.is_eq(arity, nt_count(N111Value, values)) && p112_scalar_safe(values),
    u => p112_scalar_dispatch(id, values),
    u => nt_choose(P111ValueCode, (U32.is_eq(id, 68) || U32.is_eq(id, 69)) &&
      U32.is_eq(nt_count(N111Value, values), 2) && p185_bool_safe(values),
      v => p185_bool_binary(nt_choose(String, U32.is_eq(id, 68), w => "or", w => "xor"),
        p111_head(values), p111_head(p111_tail(values))),
      v => p112_intrinsic_fallback(name, values)))


@unsafe
def p112_special_test_fallback(+name: String, +word: N111Value) -> List<&2, N111Stmt>:
  +kind = p111_special(name)
  nt_choose(List<&2, N111Stmt>, U32.is_eq(kind, 0),
    u => [N111Call{"tag", N111U64{}, "p111_rt_tag", [p111_state(), p111_word(word)]}, N111Bin{"match_condition", N111U64{}, "eq", N111Local{"tag"}, N111CtorId{name}}],
    u => [N111Call{"test", N111U64{}, "p111_rt_special_test", [p111_state(), p111_u32(kind), p111_word(word)]}, N111Bin{"match_condition", N111U64{}, "ne", N111Local{"test"}, N111Const{0, 0}}])


@unsafe
def p112_special_safe(word: N111Value) -> Bool:
  match word:
    case N111Local{+name}:
      Bool.not(String.eq(name, "p112_b_raw") || String.eq(name, "p112_b_bits") || String.eq(name, "p112_b_expected") || String.eq(name, "p112_b_boxed"))
    case _: True{}

# Bits40..55 are aux, bits56..62 are the7-bit tag; bit63 is RFC.
# A packed True may have arbitrary location bits and either RFC bit.


@unsafe
def p112_special_bool(+word: N111Value, invert: Bool) -> List<&2, N111Stmt>:
  nt_append(N111Stmt,
    [N111Bin{"p112_b_raw", N111U64{}, "eq", word, N111Const{1, 0}},
     N111Bin{"p112_b_bits", N111U64{}, "shr", word, N111Const{40, 0}},
     N111Bin{"p112_b_bits", N111U64{}, "and", N111Local{"p112_b_bits"}, N111Const{8388607, 0}},
     N111Bin{"p112_b_expected", N111U64{}, "or", N111CtorId{"True"}, N111Const{65536, 0}},
     N111Bin{"p112_b_boxed", N111U64{}, "eq", N111Local{"p112_b_bits"}, N111Local{"p112_b_expected"}},
     N111Bin{"match_condition", N111U32{}, "or", N111Local{"p112_b_raw"}, N111Local{"p112_b_boxed"}}],
    nt_choose(List<&2, N111Stmt>, invert,
      u => [N111Bin{"match_condition", N111U32{}, "xor", N111Local{"match_condition"}, N111Const{1, 0}}], u => []))


# Bool primitives share the special-pattern truth predicate, including packed
# True with arbitrary location/RFC bits. Snapshot both inputs before any helper
# writes; renaming keeps its U32 comparisons separate from the input U64 words.
# The reserved prefix refuses synthetic IR collisions through the old runtime.
@unsafe
def p185_bool_safe_value(value: N111Value) -> Bool:
  match value:
    case N111Local{name}: Bool.not(String.starts_with(name, "p185_bool_"))
    case _: True{}


@unsafe
def p185_bool_safe(values: List<&2, N111Value>) -> Bool:
  match values:
    case Nil{}: True{}
    case Con{head, rest}: p185_bool_safe_value(head) && p185_bool_safe(rest)


@unsafe
def p185_bool_binary(op: String, a: N111Value, b: N111Value) -> P111ValueCode:
  p112_scalar_result(nt_append(N111Stmt,
    [N111Set{"p185_bool_a_local_input", N111U64{}, a},
     N111Set{"p185_bool_b_local_input", N111U64{}, b}],
    nt_append(N111Stmt, p112f_rename(p112_special_bool(N111Local{"input"}, False{}), "p185_bool_a_"),
    nt_append(N111Stmt, p112f_rename(p112_special_bool(N111Local{"input"}, False{}), "p185_bool_b_"),
      [N111Bin{"p185_bool_test", N111U32{}, op,
         N111Local{"p185_bool_a_local_match_condition"}, N111Local{"p185_bool_b_local_match_condition"}},
       N111If{N111Local{"p185_bool_test"},
         [N111Set{"value", N111U64{}, N111Const{1, 0}}],
         [N111Set{"value", N111U64{}, N111Const{0, 0}}]}]))))


@unsafe
def p112_special_selected(+kind: U32, +word: N111Value) -> List<&2, N111Stmt>:
  nt_choose(List<&2, N111Stmt>, U32.is_le(kind, 2), u => p112_special_bool(word, U32.is_eq(kind, 1)), u =>
  nt_choose(List<&2, N111Stmt>, U32.is_eq(kind, 3), u => [N111Bin{"match_condition", N111U64{}, "eq", word, N111Const{0, 0}}], u =>
  nt_choose(List<&2, N111Stmt>, U32.is_eq(kind, 4), u => [N111Bin{"match_condition", N111U64{}, "ne", word, N111Const{0, 0}}],
    u => [N111Bin{"match_condition", N111U64{}, "eq", word, word}])))


@unsafe
def p112_special_test(+name: String, +word: N111Value) -> List<&2, N111Stmt>:
  +kind = p111_special(name)
  nt_choose(List<&2, N111Stmt>, U32.is_gt(kind, 0) && U32.is_le(kind, 7) && p112_special_safe(word),
    u => p112_special_selected(kind, word), u => p112_special_test_fallback(name, word))


def p112e_tail_valid(body: P112TailBody) -> Bool:
  match body:
    case P112TailBody{valid,loops,nodes}: valid


def p112e_worker_valid(body: P112WorkerBody) -> Bool:
  match body:
    case P112WorkerBody{valid,calls,nodes}: valid


@unsafe
def p112e_tail_scalar(+stmt: N111Stmt, tail: P112TailBody) -> P112TailBody:
  match tail:
    case P112TailBody{+valid,+loops,+body}:
      nt_choose(P112TailBody,valid,u => P112TailBody{True{},loops,Con{P112TailScalar{stmt},body}},
        u => P112TailBody{False{},0,[]})


@unsafe
def p112e_worker_scalar(+stmt: N111Stmt, tail: P112WorkerBody) -> P112WorkerBody:
  match tail:
    case P112WorkerBody{+valid,+calls,+body}:
      nt_choose(P112WorkerBody,valid,u => P112WorkerBody{True{},calls,Con{P112WorkerScalar{stmt},body}},
        u => P112WorkerBody{False{},0,[]})


@unsafe
def p112e_tail_yes(+condition: N111Value, +no: List<&2,N111Stmt>, +rest: List<&2,N111Stmt>,
  +owner: String, +arity: U32, +yes: P112TailBody) -> P112TailBody:
  nt_choose(P112TailBody,p112e_tail_valid(yes),
    u => p112e_tail_no(condition,rest,owner,arity,yes,p112t_scan(no,owner,arity)),
    u => P112TailBody{False{},0,[]})


@unsafe
def p112e_tail_no(+condition: N111Value, +rest: List<&2,N111Stmt>, +owner: String, +arity: U32,
  +yes: P112TailBody, +no: P112TailBody) -> P112TailBody:
  nt_choose(P112TailBody,p112e_tail_valid(no),
    u => p112e_tail_rest(condition,yes,no,p112t_scan(rest,owner,arity)),u => P112TailBody{False{},0,[]})


@unsafe
def p112e_tail_rest(+condition: N111Value, +yes: P112TailBody, +no: P112TailBody, +rest: P112TailBody) -> P112TailBody:
  nt_choose(P112TailBody,p112e_tail_valid(rest),u => p112t_branch(condition,yes,no,rest),u => P112TailBody{False{},0,[]})


@unsafe
def p112e_worker_yes(+condition: N111Value, +no: List<&2,N111Stmt>, +rest: List<&2,N111Stmt>,
  +owner: String, +arity: U32, +ready: KDef, +yes: P112WorkerBody) -> P112WorkerBody:
  nt_choose(P112WorkerBody,p112e_worker_valid(yes),
    u => p112e_worker_no(condition,rest,owner,arity,ready,yes,p112w_scan(no,owner,arity,ready)),
    u => P112WorkerBody{False{},0,[]})


@unsafe
def p112e_worker_no(+condition: N111Value, +rest: List<&2,N111Stmt>, +owner: String, +arity: U32,
  +ready: KDef, +yes: P112WorkerBody, +no: P112WorkerBody) -> P112WorkerBody:
  nt_choose(P112WorkerBody,p112e_worker_valid(no),
    u => p112e_worker_rest(condition,yes,no,p112w_scan(rest,owner,arity,ready)),u => P112WorkerBody{False{},0,[]})


@unsafe
def p112e_worker_rest(+condition: N111Value, +yes: P112WorkerBody, +no: P112WorkerBody, +rest: P112WorkerBody) -> P112WorkerBody:
  nt_choose(P112WorkerBody,p112e_worker_valid(rest),u => p112w_branch(condition,yes,no,rest),u => P112WorkerBody{False{},0,[]})

# Ordinary worker recursion intentionally bypasses only the block-entry failure
# scan, just as the frozen fail-stop planner does. Branches re-enter full scan.


@unsafe
def p112e_worker_normal(+body: List<&2,N111Stmt>, +owner: String, +arity: U32, +ready: KDef) -> P112WorkerBody:
  nt_choose(P112WorkerBody,p112t_tail(body,owner,arity,0),
    u => P112WorkerBody{True{},0,p112w_nodes(body,arity,P112WorkerAgain{})},u =>
    nt_choose(P112WorkerBody,p112w_result(body),
      u => P112WorkerBody{True{},0,p112w_nodes(body,1,P112WorkerResult{})},u =>
      p112w_scan_target(body,owner,arity,ready,p112w_target(body))))


@unsafe
def p112b_original_ref_app(+book: List<&2, KDef>, +t: KTerm, +head: KTerm, +args: List<&2, KTerm>, +env: List<&2, NC_Binding>, +n: U32) -> P111Code:
  nt_choose(P111Code, U32.is_eq(qt(head), 3), u => p111_slow_app(book, t, env, n),
    u => nt_choose(P111Code, U32.is_eq(terms_len(args), nd_arity(book, nm(head))),
      v => p111_lower(book, nc_sequence("NCall", nd_name(nc_ref_name(book, nm(head))), args, Nil{}, n), env, U32.add(n, terms_len(args))),
      v => p111_slow_app(book, t, env, n)))


@unsafe
def p112b_guard(+args: List<&2,KTerm>, +n: U32, +count: U32) -> Bool:
  U32.is_gt(count,0) && U32.is_le(count,4) && U32.is_lt(n,4294967231) && nd_comb_literal(args)


@unsafe
def p112b_selected(+book: List<&2,KDef>, +t: KTerm, +head: KTerm, +args: List<&2,KTerm>, +env: List<&2,NC_Binding>, +n: U32, +selected: KTerm) -> P111Code:
  nt_choose(P111Code,p98_tag_eq(selected,"Absent"),
    u => p112b_original_ref_app(book,t,head,args,env,n),
    u => p111_lower(book,selected,env,U32.add(n,64)))


@unsafe
def p112b_ref_app(+book: List<&2,KDef>, +t: KTerm, +head: KTerm, +args: List<&2,KTerm>, +env: List<&2,NC_Binding>, +n: U32) -> P111Code:
  nt_choose(P111Code,U32.is_eq(qt(head),3),
    u => p112b_original_ref_app(book,t,head,args,env,n),
    u => nt_choose(P111Code,p112b_guard(args,n,terms_len(args)),
      v => nt_choose(P111Code,U32.is_eq(terms_len(args),nd_arity(book,nm(head))),
        w => p112b_selected(book,t,head,args,env,n,nbc_definition(book,lookup(book,nm(head)),args,env,n,terms_len(args))),
        w => p112b_original_ref_app(book,t,head,args,env,n)),
      v => p112b_original_ref_app(book,t,head,args,env,n)))


@unsafe
def p112m_original_match_apply(+book: List<&2, KDef>, +t: KTerm, +env: List<&2, NC_Binding>, +n: U32) -> P111Code:
  +mat = kid(t, 0)
  +arg = kid(t, 1)
  +word : N111Value = N111Local{nc_word(ix(arg), env)}
  +count = nt_choose(U32, U32.is_eq(ix(mat), 0), u => nc_field_count(book, nm(mat)), u => U32.sub(ix(mat), 1))
  +hit = p111_lower(book, nd_reapply(nc_field_apps(kid(mat, 0), count, 0, n), nd_match_rest(t)), nt_append(NC_Binding, nc_remove_env(env, ix(arg)), p111_field_env(count, 0, n)), U32.add(n, count))
  +miss = p111_lower(book, nd_reapply(app(kid(mat, 1), arg), nd_match_rest(t)), env, p111_fresh(hit))
  +branch = nt_append(N111Stmt, p111_test(nm(mat), word), [N111If{N111Local{"match_condition"}, nt_append(N111Stmt, p111_take(nm(mat), word, count, n), p111_body(hit)), p111_body(miss)}])
  P111Code{p111_guard_io(nm(mat), word, branch), nt_append(N111Segment, p111_segments(hit), p111_segments(miss)), p111_fresh(miss), p111_first(p111_error(hit), p111_error(miss))}


@unsafe
def p112m_fresh_terms(ts: List<&2,KTerm>, +low: U32, +high: U32) -> Bool:
  match ts:
    case Nil{}: True{}
    case Con{+t,+rest}:
      (Bool.not(String.eq(tg(t),"Var") || String.eq(tg(t),"Lam") || String.eq(tg(t),"Bind")) || U32.is_lt(ix(t),low) || U32.is_gt(ix(t),high)) &&
        p112m_fresh_terms(ks(t),low,high) && p112m_fresh_terms(rest,low,high)


@unsafe
def p112m_fresh_env(env: List<&2,NC_Binding>, +n: U32) -> Bool:
  match env:
    case Nil{}: True{}
    case Con{NC_Binding{+id,+word,kind},rest}:
      (U32.is_lt(id,nc_id(U32.add(n,2))) || U32.is_gt(id,nc_id(n))) &&
        Bool.not(String.eq(word,"v_" ++ U32.show(nc_id(n))) || String.eq(word,"v_" ++ U32.show(nc_id(U32.inc(n)))) || String.eq(word,"v_" ++ U32.show(nc_id(U32.add(n,2))))) && p112m_fresh_env(rest,n)


@unsafe
def p112m_body(+row: KTerm, +rest: List<&2,KTerm>, +n: U32) -> KTerm:
  nt_choose(KTerm,U32.is_eq(qt(row),0),u => nd_reapply(kid(row,0),rest),
    u => nd_reapply(nw_restore(nd_beta(kid(row,0),nt_choose(List<&2,KTerm>,U32.is_eq(qt(row),1),
      v => [var("",nc_id(U32.add(n,2)))],v => [var("",nc_id(U32.inc(n))),var("",nc_id(U32.add(n,2)))])),
      nw_prefix(ix(row),nw_value(row),nt_choose(KTerm,U32.is_eq(qt(row),1),
        v => var("",nc_id(U32.add(n,2))),v => nw_word(var("",nc_id(U32.inc(n))),var("",nc_id(U32.add(n,2)))))),nc_id(n)),rest))


@unsafe
def p112m_planned_row(+row: KTerm, +body: KTerm, +n: U32) -> NW_Rows:
  +uses = nc_uses(body)
  NW_Rows{Bool.not(nc_uses_has(uses,nc_id(U32.add(n,2)))),
    [kt("P112MRow",nm(row),ix(row),Bool.to_u32(nc_uses_has(uses,nc_id(U32.inc(n)))),[body])]}


@unsafe
def p112m_plan_rows(rows: List<&2,KTerm>, +rest: List<&2,KTerm>, +n: U32) -> NW_Rows:
  match rows:
    case Nil{}: NW_Rows{True{},[]}
    case Con{+row,more}: nw_join(p112m_planned_row(row,p112m_body(row,rest,n),n),p112m_plan_rows(more,rest,n))


@unsafe
def p112m_mask(+depth: U32) -> U32:
  nt_choose(U32,U32.is_eq(depth,32),u => 4294967295,u => U32.sub(U32.shln(1,U32.to_nat(depth)),1))


@unsafe
def p112m_row_code(+book: List<&2,KDef>, +row: KTerm, +env: List<&2,NC_Binding>, +base: U32, +fresh: U32) -> P111Code:
  +word = "v_" ++ U32.show(nc_id(base))
  +bit = "v_" ++ U32.show(nc_id(U32.inc(base)))
  +bindings : List<&2,NC_Binding> = Con{NC_Binding{nc_id(base),word,N_W32{}},nt_choose(List<&2,NC_Binding>,U32.is_eq(qt(row),1),u => Con{NC_Binding{nc_id(U32.inc(base)),bit,N_W32{}},env},u => env)}
  +prefix : List<&2,N111Stmt> = nt_choose(List<&2,N111Stmt>,U32.is_eq(qt(row),1),
    u => [N111Bin{bit,N111U64{},"shr",N111Local{word},N111Const{ix(row),0}},N111Bin{bit,N111U64{},"and",N111Local{bit},N111Const{1,0}}],u => [])
  p111_prepend(prefix,p111_lower(book,kid(row,0),bindings,fresh))


law p112m_emit:
  for +book: List<&2,KDef>
  for rows: List<&2,KTerm>
  for +env: List<&2,NC_Binding>
  for +base: U32
  for +fresh: U32
  P111Code


@unsafe
def p112m_join(+row: KTerm, +base: U32, +yes: P111Code, +no: P111Code) -> P111Code:
  +masked = "p112m_mask_" ++ U32.show(base)
  +condition = "p112m_hit_" ++ U32.show(base)
  P111Code{[N111Bin{masked,N111U64{},"and",N111Local{"v_" ++ U32.show(nc_id(base))},N111Const{p112m_mask(ix(row)),0}},
    N111Bin{condition,N111U64{},"eq",N111Local{masked},N111Const{nw_value(row),0}},
    N111If{N111Local{condition},p111_body(yes),p111_body(no)}],
    nt_append(N111Segment,p111_segments(yes),p111_segments(no)),p111_fresh(no),p111_first(p111_error(yes),p111_error(no))}


@unsafe
def p112m_emit_more(+book: List<&2,KDef>, +row: KTerm, rows: List<&2,KTerm>, +env: List<&2,NC_Binding>, +base: U32, +yes: P111Code) -> P111Code:
  p112m_join(row,base,yes,p112m_emit(book,rows,env,base,p111_fresh(yes)))


@unsafe
def p112m_emit(book,rows,env,base,fresh):
  match rows:
    case Nil{}: P111Code{[N111Call{"reply",N111U64{},"p111_rt_fail",[p111_state(),p111_u32(4)]},N111Return{N111Local{"reply"}}],[],fresh,""}
    case Con{+row,more}: p112m_emit_more(book,row,more,env,base,p112m_row_code(book,row,env,base,fresh))


@unsafe
def p112m_planned(+book: List<&2,KDef>, +t: KTerm, +env: List<&2,NC_Binding>, +n: U32, plan: NW_Rows) -> P111Code:
  match plan:
    case NW_Rows{valid,rows}:
      nt_choose(P111Code,valid,
        u => p111_prepend([N111Bin{"v_" ++ U32.show(nc_id(n)),N111U64{},"and",N111Local{nc_word(ix(kid(t,1)),env)},N111Const{4294967295,0}}],
          p112m_emit(book,rows,nc_remove_env(env,ix(kid(t,1))),n,U32.add(n,3))),
        u => p112m_original_match_apply(book,t,env,n))


@unsafe
def p112m_recognized(+book: List<&2,KDef>, +t: KTerm, +env: List<&2,NC_Binding>, +n: U32, recognized: NW_Rows) -> P111Code:
  match recognized:
    case NW_Rows{valid,+rows}:
      nt_choose(P111Code,valid && Bool.not(List.is_empty(&2,KTerm,rows)),
        u => p112m_planned(book,t,env,n,p112m_plan_rows(rows,nd_match_rest(t),n)),
        u => p112m_original_match_apply(book,t,env,n))


@unsafe
def p112m_match_apply(+book: List<&2,KDef>, +t: KTerm, +env: List<&2,NC_Binding>, +n: U32) -> P111Code:
  nt_choose(P111Code,nw_applicable(kid(t,0)) && U32.is_lt(n,4294967293),
    u => nt_choose(P111Code,p112m_fresh_terms([t],nc_id(U32.add(n,2)),nc_id(n)) && p112m_fresh_env(env,n),
      v => p112m_recognized(book,t,env,n,nw_walk(kid(kid(t,0),0),0,0,NW_None{})),
      v => p112m_original_match_apply(book,t,env,n)),
    u => p112m_original_match_apply(book,t,env,n))
