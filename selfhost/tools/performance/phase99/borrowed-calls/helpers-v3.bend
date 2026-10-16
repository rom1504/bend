# Phase99 candidate: certificates are compiler products, never book markers.
# Current schemas contain only plain, nondependent nominal parameter types.
type NO_Callee is Data:
  NO_Callee{+owner: String, +schema: NO_Schema}

@unsafe
def no_route_callees(route: NO_Route) -> List<&2, NO_Callee>:
  match route:
    case NO_Route{workers, ready, entries, callees, pending}: callees

@unsafe
def no_route_pending(route: NO_Route) -> List<&2, String>:
  match route:
    case NO_Route{workers, ready, entries, callees, pending}: pending

@unsafe
def noa_callees(ctx: NO_Context) -> List<&2, NO_Callee>:
  match ctx:
    case NO_Context{book, owner, schema, callees}: callees

@unsafe
def nob_find(+name: String, callees: List<&2, NO_Callee>) -> NO_Schema:
  match callees:
    case Nil{}: nol_failure("observer: uncertified call", 0)
    case Con{NO_Callee{owner, schema}, rest}:
      nt_choose(NO_Schema, p88_string_eq(name, owner), u => schema, u => nob_find(name, rest))

# Each actual may borrow from any matching caller entry root, including aliases.
# Only the existing plain root schemas are supported; no erased applied types.
@unsafe
def nob_live_root(+ctx: NO_Context, +actual: KTerm, params: List<&2, KTerm>, +i: U32) -> Bool:
  match params:
    case Nil{}: False{}
    case Con{+param, +rest}:
      nt_choose(Bool, no_root_index(no_schema_roots(noa_schema(ctx)), i) && p88_string_eq(nm(actual), nm(param)),
        u => nt_choose(Bool, noa_below(noa_origin(actual), kt("OArg", "", i, 0, Nil{})), v => True{}, v => nob_live_root(ctx, actual, rest, U32.inc(i))),
        u => nob_live_root(ctx, actual, rest, U32.inc(i)))

@unsafe
def nob_arg_word(+ctx: NO_Context, +param: KTerm, +actual: KTerm, +root: Bool) -> KTerm:
  nt_choose(KTerm, p88_string_eq(noa_value_type(ctx, actual), nm(param)),
    u => nt_choose(KTerm, root,
      v => nt_choose(KTerm, p98_tag_eq(actual, "OA") && p98_tag_eq(kid(actual, 1), "Var"),
        w => nt_choose(KTerm, nob_live_root(ctx, actual, no_schema_params(noa_schema(ctx)), 0), x => kid(actual, 1), x => atom("Absent")), w => atom("Absent")),
      v => noa_scalar(ctx, actual)), u => atom("Absent"))

@unsafe
def nob_words_cons(+word: KTerm, +rest: KTerm) -> KTerm:
  nt_choose(KTerm, Bool.not(p98_tag_eq(word, "Absent")) && p98_tag_eq(rest, "NO_Args"),
    u => k_with_children(rest, Con{word, ks(rest)}), u => atom("Absent"))

@unsafe
def nob_arg_words(+ctx: NO_Context, params: List<&2, KTerm>, args: List<&2, KTerm>, +roots: List<&2, U32>, +i: U32) -> KTerm:
  match params, args:
    case Nil{}, Nil{}: kt("NO_Args", "", 0, 0, Nil{})
    case Con{p, ps}, Con{a, more}: nob_words_cons(nob_arg_word(ctx, p, a, no_root_index(roots, i)), nob_arg_words(ctx, ps, more, roots, U32.inc(i)))
    case _, _: atom("Absent")

@unsafe
def nob_call_args(+ctx: NO_Context, +schema: NO_Schema, +args: List<&2, KTerm>) -> KTerm:
  nt_choose(KTerm, p88_string_eq(no_schema_error(schema), "") && p98_tag_eq(no_schema_wrapper(schema), "Var") && nol_scalar(noa_book(ctx), kt("ADT", no_schema_observation(schema), 0, 0, Nil{})),
    u => nob_arg_words(ctx, no_schema_params(schema), args, no_schema_roots(schema), 0), u => atom("Absent"))

@unsafe
def nob_prepend_call(+name: String, +id: U32, +args: KTerm, rest: NO_Analysis) -> NO_Analysis:
  match rest:
    case NO_Analysis{body, n, fuel, error}: NO_Analysis{kt("NO_Call", name, id, 0, [args, body]), n, fuel, error}

@unsafe
def noa_borrow_call(+ctx: NO_Context, +name: String, +schema: NO_Schema, +words: KTerm, +facts: List<&2, KTerm>, +n: U32, +fuel: U32, +k: NO_Cont) -> NO_Analysis:
  +id = nc_id(n)
  nob_prepend_call(name, id, words, noa_continue(ctx, k, NO_Input{noa_atom(no_schema_observation(schema), kt("OUnique", "", id, 0, Nil{}), var("", id)), facts, U32.inc(n), fuel}))

# The emitter rechecks certificate membership, shape, arity and bound atoms.
# Scalar type and entry-root ancestry were established by the checked analysis.
@unsafe
def nob_emit_call(+callees: List<&2, NO_Callee>, +t: KTerm, +env: List<&2, NC_Binding>, +params: List<&2, NC_Binding>, +layouts: List<&2, NO_Layout>, +n: U32) -> NC_Code:
  +schema = nob_find(nm(t), callees)
  +args = kid(t, 0)
  nt_choose(NC_Code, p88_string_eq(no_schema_error(schema), "") && p98_tag_eq(no_schema_wrapper(schema), "Var") && U32.is_eq(terms_len(ks(t)), 2) && p98_tag_eq(args, "NO_Args") && U32.is_eq(terms_len(ks(args)), terms_len(no_schema_params(schema))) && no_atoms_valid(ks(args), env) && p88_string_eq(nc_word(ix(t), env), "NATIVE_UNBOUND_VARIABLE"),
    u => nob_emit_call_ready(callees, t, env, params, layouts, n), u => nc_fail("observer: uncertified or invalid borrowed call", n))

@unsafe
def nob_emit_call_ready(+callees: List<&2, NO_Callee>, +t: KTerm, +env: List<&2, NC_Binding>, +params: List<&2, NC_Binding>, +layouts: List<&2, NO_Layout>, +n: U32) -> NC_Code:
  +callee = no_worker_name(nm(t))
  +result = "no_call_" ++ U32.show(n)
  +rest = no_emit_calls(callees, kid(t, 1), Con{nc_binding(ix(t)), env}, params, layouts, U32.inc(n))
  +prefix = "if (!seq && err_seen(e.mem)) { return 0; }\nTerm " ++ result ++ "[1];\nif (!" ++ nf_name(callee) ++ "(e, seq, " ++ result ++ nf_arg_c(no_words(ks(kid(t, 0)), env)) ++ ")) { return 0; }\nif (!seq && err_seen(e.mem)) { return 0; }\nTerm v_" ++ U32.show(ix(t)) ++ " = " ++ result ++ "[0];\n"
  NC_Code{nct_cat(nct_leaf(prefix), nc_text(rest)), Nil{}, nc_fresh(rest), nc_error(rest), Con{callee, nc_calls(rest)}}

# Preserve existing entry points: empty registries cannot grant calls.
@unsafe
def no_emit(+t: KTerm, +env: List<&2, NC_Binding>, +params: List<&2, NC_Binding>, +layouts: List<&2, NO_Layout>, +n: U32) -> NC_Code:
  no_emit_calls(Nil{}, t, env, params, layouts, n)

@unsafe
def no_worker(+owner: String, +params: List<&2, NC_Binding>, +layouts: List<&2, NO_Layout>, +body: KTerm) -> NF_Worker:
  no_worker_calls(Nil{}, owner, params, layouts, body)

@unsafe
def noa_analyze_calls(+book: List<&2, KDef>, +name: String, +schema: NO_Schema, +permission: Bool, +callees: List<&2, NO_Callee>) -> NO_Analysis:
  nt_choose(NO_Analysis, permission && p88_string_eq(no_schema_error(schema), ""),
    u => noa_analyze_ready(NO_Context{book, name, schema, callees}),
    u => noa_fail("observer: absent checked permission or schema", no_schema_fresh(schema), 4096))

@unsafe
def no_plan_schema_calls(+book: List<&2, KDef>, +name: String, +schema: NO_Schema, +callees: List<&2, NO_Callee>) -> NO_Plan:
  nt_choose(NO_Plan, p88_string_eq(no_schema_error(schema), ""),
    u => no_plan_result(name, schema, noa_analyze_calls(book, name, schema, True{}, callees)),
    u => NO_Plan{name, schema, noa_fail(no_schema_error(schema), no_schema_fresh(schema), 4096), no_schema_error(schema)})

# Retry only helper-cycle/depth refusals, once. Layout/typing refusals do not
# enter this list. Certificates are added only by successful no_route_pair.
@unsafe
def nob_defer(+old: NO_Route, +owner: String, +error: String) -> NO_Route:
  nt_choose(NO_Route, p88_string_eq(error, "observer: helper effect, cycle or depth") && Bool.not(nb_contains(no_route_pending(old), owner)),
    u => NO_Route{no_route_workers(old), no_route_ready(old), no_route_entries(old), no_route_callees(old), Con{owner, no_route_pending(old)}}, u => old)

@unsafe
def nob_retry(+book: List<&2, KDef>, +index: List<&2, KDef>, +first: NO_Route) -> NO_Route:
  no_route_names(book, no_route_pending(first), index, NO_Route{no_route_workers(first), no_route_ready(first), no_route_entries(first), no_route_callees(first), Nil{}})
