# Ordinary host C workers reuse native value ownership and matching. A local
# destination replaces a continuation frame; an outer destination returns one
# boxed word. Unsupported candidate bodies never enter the admitted closure.
type NC_Target is Data:
  NC_Scheduler{}
  NC_Destination{+words: List<&2, String>, +shape: KTerm, +join: String, +owner: String, +params: List<&2, NC_Binding>, +tail: Bool, +signatures: List<&2, KDef>}

type NF_Worker is Data:
  NF_Worker{+name: String, +params: List<&2, N_Param>, +code: NC_Code, +deps: List<&2, String>, +shape: KTerm}

@unsafe
def nf_scheduler(+target: NC_Target) -> Bool:
  match target:
    case NC_Scheduler{}: True{}
    case _: False{}

@unsafe
def nf_return(+word: String, +n: U32, +target: NC_Target) -> NC_Code:
  nt_choose(NC_Code, nf_scheduler(target), u => nc_return(word, n), u => nq_transfer(atom("Absent"), [word], n, target))

@unsafe
def nf_emitted(emitted: N_Emitted, +target: NC_Target) -> NC_Code:
  match emitted:
    case N_Emitted{code, word, n}: nc_prepend(code, nf_return(word, n, target))

@unsafe
def nf_local(+target: NC_Target, +word: String, +join: String) -> NC_Target:
  nq_local(target, [word], atom("Absent"), join)

@unsafe
def nf_bind_boxed(+book: List<&2, KDef>, +value: KTerm, +body: KTerm, +env: List<&2, NC_Binding>, +id: U32, +n: U32, +target: NC_Target) -> NC_Code:
  +join = "nf_join_" ++ U32.show(n)
  +word = "v_" ++ U32.show(id)
  +bodyUses = nc_uses(body)
  +rest = nc_lower_partition(book, body, U32.inc(n), target, nc_partition_uses(List.append(&2, NC_Binding, nc_live_uses(env, bodyUses), [nk_binding(id, value, env)]), bodyUses))
  +valueEnv = nc_live_env(env, value)
  +val = nc_lower_live_to(book, value, valueEnv, nc_fresh(rest), nf_local(target, word, join))
  NC_Code{nct_cat(nct_leaf(nc_keep_uses(valueEnv, bodyUses) ++ "Term " ++ word ++ ";\n{\n"), nct_cat(nc_text(val), nct_cat(nct_leaf("}\n" ++ join ++ ":;\nif (!seq && err_seen(e.mem)) { return 0; }\n"), nc_text(rest)))), nt_append(N_Segment, nc_segs(val), nc_segs(rest)), nc_fresh(val), nc_first_error(val, rest), List.append(&2, String, nc_calls(val), List.append(&2, String, nc_calls(rest), Nil{}))}

@unsafe
def nf_lets(+book: List<&2, KDef>, +xs: List<&2, KTerm>, +env: List<&2, NC_Binding>, +n: U32, +target: NC_Target) -> NC_Code:
  nt_choose(NC_Code, nf_scheduler(target), u => nc_lets(book, xs, env, n), u => nf_lets_local(book, xs, env, n, target))

@unsafe
def nf_lets_local(+book: List<&2, KDef>, xs: List<&2, KTerm>, +env: List<&2, NC_Binding>, +n: U32, +target: NC_Target) -> NC_Code:
  match xs:
    case Nil{}: nc_fail("empty native let", n)
    case Con{h, Nil{}}: nc_lower_to(book, h, env, n, target)
    case Con{+h, +rest}: nq_bind_choose(book, kid(h, 0), kt("NSeqLet", "", 0, 0, rest), env, ix(h), n, target)

@unsafe
def nf_parallel(+book: List<&2, KDef>, +xs: List<&2, KTerm>, +env: List<&2, NC_Binding>, +n: U32, +target: NC_Target) -> NC_Code:
  nt_choose(NC_Code, nf_scheduler(target), u => nc_parallel(book, xs, env, n), u => nc_fail("flat worker: parallel let", n))

@unsafe
def nf_lambda(+book: List<&2, KDef>, +t: KTerm, +env: List<&2, NC_Binding>, +n: U32, +target: NC_Target) -> NC_Code:
  nt_choose(NC_Code, nf_scheduler(target), u => nc_lambda(book, t, env, n), u => nc_fail("flat worker: escaping closure", n))

@unsafe
def nf_match_value(+book: List<&2, KDef>, +t: KTerm, +env: List<&2, NC_Binding>, +n: U32, +target: NC_Target) -> NC_Code:
  nt_choose(NC_Code, nf_scheduler(target), u => nc_match(book, t, env, n), u => nc_fail("flat worker: escaping matcher", n))

@unsafe
def nf_slow_app(+book: List<&2, KDef>, +t: KTerm, +env: List<&2, NC_Binding>, +n: U32, +target: NC_Target) -> NC_Code:
  nt_choose(NC_Code, nf_scheduler(target), u => nc_app_slow(book, t, env, n), u => nc_fail("flat worker: partial, dynamic or bang call", n))

@unsafe
def nf_name(+name: String) -> String:
  "NF_" ++ nt_fid(name)

@unsafe
def nf_param_c(params: List<&2, N_Param>) -> String:
  match params:
    case Nil{}: ""
    case Con{N_Param{word, kind}, rest}: ", " ++ nf_param_type(kind) ++ " " ++ word ++ nf_param_c(rest)

@unsafe
def nf_param_type(kind: N_WordKind) -> String:
  match kind:
    case N_W32{}: "NF_SCALAR"
    case _: "Term"

# Private C argument facts come from the original telescope, before erasure.
# The checked-entry macro enables narrowing; raw lowering keeps full Terms.
@unsafe
def nf_scalar_kind(+book: List<&2, KDef>, +ty: KTerm) -> N_WordKind:
  +head = nq_layout_type(book, ty)
  +owner = lookup(book, nm(head))
  nt_choose(N_WordKind, String.eq(tg(head), "ADT") && String.eq(dk(owner), "ADT") && db(owner) && List.is_empty(&2, String, rm(head)) && List.is_empty(&2, KTerm, ks(head)) && nb_contains(["U32", "F32", "Char", "Bool"], nm(head)), u => N_W32{}, u => N_W64{})

@unsafe
def nf_opaque_kinds(+left: U32) -> List<&2, N_WordKind>:
  nt_choose(List<&2, N_WordKind>, U32.is_eq(left, 0), u => Nil{}, u => Con{N_W64{}, nf_opaque_kinds(U32.sub(left, 1))})

@unsafe
def nf_kind_tele(+book: List<&2, KDef>, +ty: KTerm, +left: U32, +fuel: U32) -> List<&2, N_WordKind>:
  nt_choose(List<&2, N_WordKind>, U32.is_eq(left, 0), u => Nil{}, u =>
    nt_choose(List<&2, N_WordKind>, U32.is_eq(fuel, 0), v => nf_opaque_kinds(left), v => nf_kind_head(book, nq_layout_type(book, ty), left, U32.sub(fuel, 1))))

@unsafe
def nf_kind_head(+book: List<&2, KDef>, +head: KTerm, +left: U32, +fuel: U32) -> List<&2, N_WordKind>:
  nt_choose(List<&2, N_WordKind>, String.eq(tg(head), "All"),
    u => nt_choose(List<&2, N_WordKind>, U32.is_eq(qt(head), 0), v => nf_kind_tele(book, kid(head, 1), left, fuel), v => Con{nf_scalar_kind(book, kid(head, 0)), nf_kind_tele(book, kid(head, 1), U32.sub(left, 1), fuel)}),
    u => nf_opaque_kinds(left))

@unsafe
def nf_worker_kinds(+book: List<&2, KDef>, +name: String, +arity: U32) -> List<&2, N_WordKind>:
  +d = lookup(book, name)
  nt_choose(List<&2, N_WordKind>, U32.is_eq(arity, jd_live_arity(book, dt(d), jd_arity(book, d))), u => nf_kind_tele(book, dt(d), arity, 256), u => nf_opaque_kinds(arity))

@unsafe
def nf_typed_params(+params: List<&2, NC_Binding>, +kinds: List<&2, N_WordKind>) -> List<&2, N_Param>:
  nt_choose(List<&2, N_Param>, U32.is_eq(nt_count(NC_Binding, params), nt_count(N_WordKind, kinds)), u => nf_params_zip(params, kinds), u => nc_params(params))

@unsafe
def nf_params_zip(params: List<&2, NC_Binding>, kinds: List<&2, N_WordKind>) -> List<&2, N_Param>:
  match params, kinds:
    case Nil{}, _: Nil{}
    case Con{NC_Binding{id, word, old}, rest}, Con{kind, more}: Con{N_Param{word, kind}, nf_params_zip(rest, more)}
    case Con{NC_Binding{id, word, kind}, rest}, Nil{}: Con{N_Param{word, N_W64{}}, nf_params_zip(rest, Nil{})}

# A shell's fields remain opaque. Only nonflattened scalar arguments inherit
# the original argument kind; expanding a product must not shift later slots.
@unsafe
def nf_expand_kinds(shapes: List<&2, KTerm>, kinds: List<&2, N_WordKind>) -> List<&2, N_WordKind>:
  match shapes, kinds:
    case Con{+shape, rest}, Con{kind, more}: nt_append(N_WordKind, nt_choose(List<&2, N_WordKind>, String.eq(tg(shape), "NQShape"), u => nf_opaque_kinds(ix(shape)), u => [kind]), nf_expand_kinds(rest, more))
    case _, _: Nil{}

@unsafe
def nf_arg_c(words: List<&2, String>) -> String:
  match words:
    case Nil{}: ""
    case Con{word, rest}: ", " ++ word ++ nf_arg_c(rest)

@unsafe
def nf_self_moves(params: List<&2, NC_Binding>, words: List<&2, String>, +i: U32) -> String:
  match params, words:
    case Con{NC_Binding{id, word, kind}, rest}, Con{value, more}: word ++ " = nf_arg_" ++ U32.show(i) ++ ";\n" ++ nf_self_moves(rest, more, U32.inc(i))
    case _, _: ""

@unsafe
def nf_self_temps(words: List<&2, String>, +i: U32) -> String:
  match words:
    case Nil{}: ""
    case Con{word, rest}: "Term nf_arg_" ++ U32.show(i) ++ " = " ++ word ++ ";\n" ++ nf_self_temps(rest, U32.inc(i))

@unsafe
def nf_call_local(+book: List<&2, KDef>, +name: String, +words: List<&2, String>, +n: U32, +target: NC_Target) -> NC_Code:
  match target:
    case NC_Scheduler{}: nc_fail("flat worker: scheduler destination", n)
    case NC_Destination{dests, shape, join, +owner, +params, +tail, signatures}:
      nt_choose(NC_Code, String.eq(name, owner),
        u => nt_choose(NC_Code, tail && U32.is_eq(nt_count(NC_Binding, params), nt_count(String, words)),
          u => NC_Code{nct_leaf("{\n" ++ nf_self_temps(words, 0) ++ nf_self_moves(params, words, 0) ++ "goto nf_again;\n}\n"), Nil{}, n, "", Nil{}},
          u => nc_fail("flat worker: non-tail self call", n)),
        u => nq_call_result(name, words, n, target))

@unsafe
def nf_call(+book: List<&2, KDef>, +name: String, +words: List<&2, String>, +n: U32, +target: NC_Target) -> NC_Code:
  +d = lookup(book, name)
  nt_choose(NC_Code, nc_native_def(d), u => nq_intrinsic(nc_primitive_name(name), words, n, target), u =>
    nt_choose(NC_Code, String.eq(dk(d), "Def") && Bool.not(nc_foreign(d)), u => nf_call_local(book, name, words, n, target), u => nc_fail("flat worker: foreign or absent call", n)))

@unsafe
def nf_ref(+book: List<&2, KDef>, +t: KTerm, +n: U32, +target: NC_Target) -> NC_Code:
  nt_choose(NC_Code, nf_scheduler(target), u => NC_Code{nct_leaf(ne_jump(Nil{}, nc_ref_name(book, nm(t)))), Nil{}, n, "", Nil{}}, u =>
    nt_choose(NC_Code, U32.is_eq(nd_arity(book, nm(t)), 0) && Bool.not(U32.is_eq(qt(t), 3)), u => nq_call(book, kt("NFCall", nm(t), 0, 0, Nil{}), Nil{}, n, target), u => nc_fail("flat worker: unsaturated or bang reference", n)))

@unsafe
def nf_candidate(+book: List<&2, KDef>, +name: String, +signatures: List<&2, KDef>) -> NF_Worker:
  +params = nk_typed_bindings(nd_entry_params(nd_arity(book, name), 0), nf_worker_kinds(book, name, nd_arity(book, name)))
  +body = nc_compact_definition(book, lookup(book, name), 0)
  +shape = atom("Absent")
  +code = nc_lower_to(book, nd_reapply(body, nd_entry_args(params)), params, nt_count(NC_Binding, params), NC_Destination{nq_words("nf_out", nq_width(shape), 0), shape, "", name, params, True{}, signatures})
  NF_Worker{name, nc_params(params), code, nc_calls(code), shape}

@unsafe
def nf_candidates(+book: List<&2, KDef>, names: List<&2, String>, +bangs: List<&2, String>, +signatures: List<&2, KDef>) -> List<&2, NF_Worker>:
  match names:
    case Nil{}: Nil{}
    case Con{+name, +rest}:
      +d = lookup(book, name)
      nt_choose(List<&2, NF_Worker>, String.eq(dk(d), "Def") && Bool.not(nc_native_def(d) || nc_foreign(d) || nb_contains(bangs, name)),
        u => Con{nf_candidate(book, name, signatures), nf_candidates(book, rest, bangs, signatures)}, u => nf_candidates(book, rest, bangs, signatures))

@unsafe
def nf_deps_ready(+book: List<&2, KDef>, deps: List<&2, String>, +owner: String, +ready: List<&2, String>) -> Bool:
  match deps:
    case Nil{}: True{}
    case Con{+name, rest}:
      +ok = nt_choose(Bool, String.eq(name, owner), u => True{}, u =>
        nt_choose(Bool, nb_contains(ready, name), u => True{}, u => nc_native_def(lookup(book, name))))
      nt_choose(Bool, ok, u => nf_deps_ready(book, rest, owner, ready), u => False{})

@unsafe
def nf_admit_pass(+book: List<&2, KDef>, workers: List<&2, NF_Worker>, +ready: List<&2, String>) -> List<&2, String>:
  match workers:
    case Nil{}: ready
    case Con{NF_Worker{+name, params, +code, +deps, shape}, rest}:
      nf_admit_pass(book, rest, nt_choose(List<&2, String>, nb_contains(ready, name), u => ready, u =>
        nt_choose(List<&2, String>, String.eq(nc_error(code), "") && List.is_empty(&2, N_Segment, nc_segs(code)),
          u => nt_choose(List<&2, String>, nf_deps_ready(book, deps, name, ready), u => Con{name, ready}, u => ready), u => ready)))

law nf_admit_next:
  for +book: List<&2, KDef>
  for +workers: List<&2, NF_Worker>
  for +old: List<&2, String>
  for +next: List<&2, String>
  for +fuel: U32
  List<&2, String>

@unsafe
def nf_admit(+book: List<&2, KDef>, +workers: List<&2, NF_Worker>, +ready: List<&2, String>, +fuel: U32) -> List<&2, String>:
  nt_choose(List<&2, String>, U32.is_eq(fuel, 0), u => ready, u => nf_admit_next(book, workers, ready, nf_admit_pass(book, workers, ready), U32.sub(fuel, 1)))

@unsafe
def nf_admit_next(book, workers, old, next, fuel):
  nt_choose(List<&2, String>, U32.is_eq(nt_count(String, old), nt_count(String, next)), u => next, u => nf_admit(book, workers, next, fuel))

# The explicit inline hint has a local source-size cutoff. Admission already
# excludes C recursion cycles; this is not a transitive code-growth bound.
@unsafe
def nf_inline(+code: NC_Code) -> String:
  nt_choose(String, nct_within(nc_text(code), 4096), u => "NF_INLINE", u => "INLINE")

@unsafe
def nf_prototypes(workers: List<&2, NF_Worker>, +ready: List<&2, String>) -> String:
  match workers:
    case Nil{}: ""
    case Con{NF_Worker{+name, +params, code, deps, +shape}, +rest}:
      nt_choose(String, nb_contains(ready, name), u => nf_inline(code) ++ " Term " ++ nf_name(name) ++ "(Env e, bool seq, Term* nf_out" ++ nf_param_c(params) ++ ");\n", u => "") ++ nf_prototypes(rest, ready)

@unsafe
def nf_bodies(workers: List<&2, NF_Worker>, +ready: List<&2, String>) -> String:
  match workers:
    case Nil{}: ""
    case Con{NF_Worker{+name, +params, +code, deps, shape}, rest}:
      nt_choose(String, nb_contains(ready, name), u => nf_inline(code) ++ " Term " ++ nf_name(name) ++ "(Env e, bool seq, Term* nf_out" ++ nf_param_c(params) ++ ") {\nu32 nf_poll = 0;\nnf_again:;\nif (err_spun(e.mem, &nf_poll)) { return 0; }\n{\n" ++ nc_body(code) ++ "}\nreturn 0;\n}\n", u => "") ++ nf_bodies(rest, ready)

@unsafe
def nf_adapter_defs(workers: List<&2, NF_Worker>, +ready: List<&2, String>) -> List<&2, KDef>:
  match workers:
    case Nil{}: Nil{}
    case Con{NF_Worker{+name, +params, code, deps, +shape}, +rest}:
      nt_choose(List<&2, KDef>, nb_contains(ready, name), u => Con{KDef{nt_choose(String, List.is_empty(&2, N_Param, params), v => name, v => nd_name(name)), "NFWorker", nt_count(N_Param, params), 0, shape, kt("NFName", name, 0, 0, Nil{}), Nil{}, False{}, False{}}, nf_adapter_defs(rest, ready)}, u => nf_adapter_defs(rest, ready))

@unsafe
def nf_segment_args(params: List<&2, N_Param>) -> List<&2, String>:
  match params:
    case Nil{}: Nil{}
    case Con{N_Param{name, kind}, rest}: Con{name, nf_segment_args(rest)}

@unsafe
def nf_wrap_segments(segments: List<&2, N_Segment>, +index: List<&2, KDef>) -> List<&2, N_Segment>:
  match segments:
    case Nil{}: Nil{}
    case Con{N_Segment{+name, +params, result, frame, +body, refs, host, spin, fork, bang}, rest}:
      +d = lookup(index, name)
      +wrapped = nt_choose(String, String.eq(dk(d), "NFWorker") && U32.is_eq(da(d), nt_count(N_Param, params)),
        u => nq_wrap_segment(d, params, body), u => body)
      Con{N_Segment{name, params, result, frame, wrapped, refs, host, spin, fork, bang}, nf_wrap_segments(rest, index)}

@unsafe
def nf_finish_ready(+book: List<&2, KDef>, +ss: List<&2, N_Segment>, +cs: List<&2, N_Constructor>, runtime: NE_Runtime, requests: String, pure: Bool, show: NC_Show, +workers: List<&2, NF_Worker>, +ready: List<&2, String>, +image: List<&2, String>, +observer_names: List<&2, String>, +observers: Bool) -> NC_Result:
  +ordinary = nf_wrap_segments(ss, book_cached(nf_adapter_defs(workers, ready), 0))
  +route = no_route(book, ordinary, observer_names, workers, ready, observers)
  nc_with_show(no_wrap_routes(ordinary, no_route_entries(route), no_route_ready(route)), cs, runtime, requests, pure, show, nh_observer_macros(book, no_route_entries(route), no_route_ready(route)) ++ "#if !DEVICE\n#if NATIVE_TYPED_SCALARS\n#define NF_SCALAR u32\n#else\n#define NF_SCALAR Term\n#endif\n#if defined(__GNUC__) || defined(__clang__)\n#define NF_INLINE INLINE __attribute__((always_inline))\n#else\n#define NF_INLINE INLINE\n#endif\n" ++ nf_prototypes(no_route_workers(route), no_route_ready(route)) ++ nf_bodies(no_route_workers(route), no_route_ready(route)) ++ "#undef NF_INLINE\n#undef NF_SCALAR\n#endif\n", image)

# A failed optional product route must not poison the ordinary worker. Retain
# admitted code and retry ordinary candidates against only admitted signatures.
# Constructor shape facts remain available; no demand or stack rule is relaxed.
@unsafe
def nf_ready_signatures(ds: List<&2, KDef>, +ready: List<&2, String>) -> List<&2, KDef>:
  match ds:
    case Nil{}: Nil{}
    case Con{+d, +rest}:
      nt_choose(List<&2, KDef>, String.eq(dk(d), "BookCache") || (String.eq(tg(dv(d)), "NQSig") && Bool.not(nb_contains(ready, nm(dv(d))))),
        u => nf_ready_signatures(rest, ready), u => Con{d, nf_ready_signatures(rest, ready)})

# A retry only changes withdrawn product signatures. Constructor facts and all
# other lowering inputs remain identical; avoid rebuilding unaffected workers.
@unsafe
def nf_removed_signatures(ds: List<&2, KDef>, +ready: List<&2, String>) -> List<&2, String>:
  match ds:
    case Nil{}: Nil{}
    case Con{+d, +rest}:
      nt_choose(List<&2, String>, String.eq(tg(dv(d)), "NQSig") && Bool.not(nb_contains(ready, nm(dv(d)))),
        u => Con{dn(d), nf_removed_signatures(rest, ready)}, u => nf_removed_signatures(rest, ready))

@unsafe
def nf_retry_refs(refs: List<&2, String>, +removed: List<&2, String>) -> Bool:
  match refs:
    case Nil{}: False{}
    case Con{name, rest}: nb_contains(removed, name) || nf_retry_refs(rest, removed)

@unsafe
def nf_retry(+book: List<&2, KDef>, workers: List<&2, NF_Worker>, +ready: List<&2, String>, +signatures: List<&2, KDef>, +removed: List<&2, String>) -> List<&2, NF_Worker>:
  match workers:
    case Nil{}: Nil{}
    case Con{NF_Worker{+name, params, +code, deps, shape}, rest}:
      +old : NF_Worker = NF_Worker{name, params, code, deps, shape}
      +retry = Bool.not(nb_contains(ready, name) || String.starts_with(name, "$product.")) && String.eq(nc_error(code), "")
      Con{nt_choose(NF_Worker, retry && nf_retry_refs(nc_refs(nc_compact_definition(book, lookup(book, name), 0)), removed), u => nf_candidate(book, name, signatures), u => old), nf_retry(book, rest, ready, signatures, removed)}

# Admission precedes scheduler lowering. The same workers and retry rules feed
# the final renderer; the plan only allows proven redundant work to be skipped.
type NF_Plan is Data:
  NF_Plan{+workers: List<&2, NF_Worker>, +ready: List<&2, String>, +observers: List<&2, String>}

@unsafe
def nf_plan_retry(+book: List<&2, KDef>, +workers: List<&2, NF_Worker>, +ready: List<&2, String>, +signatures: List<&2, KDef>, +observers: List<&2, String>) -> NF_Plan:
  +retried = nf_retry(book, workers, ready, book_cached(nf_ready_signatures(signatures, ready), 0), nf_removed_signatures(signatures, ready))
  NF_Plan{retried, nf_admit(book, retried, ready, nt_count(NF_Worker, retried)), observers}

@unsafe
def nf_plan_workers(+book: List<&2, KDef>, +workers: List<&2, NF_Worker>, +signatures: List<&2, KDef>, +observers: List<&2, String>) -> NF_Plan:
  nf_plan_retry(book, workers, nf_admit(book, workers, Nil{}, nt_count(NF_Worker, workers)), signatures, observers)

@unsafe
def nf_plan(+book: List<&2, KDef>, +names: List<&2, String>, +bangs: List<&2, String>, +observers: Bool) -> NF_Plan:
  +signatures = book_cached(nq_signatures(book, names), 0)
  +observer_names = nt_choose(List<&2, String>, observers, u => no_candidate_names(book, names, bangs), u => Nil{})
  nf_plan_workers(book, List.append(&2, NF_Worker, nf_candidates(book, names, bangs, signatures), nq_candidates_mode(book, names, bangs, signatures, observers)), signatures, observer_names)

@unsafe
def nf_finish_plan(+book: List<&2, KDef>, +ss: List<&2, N_Segment>, +cs: List<&2, N_Constructor>, runtime: NE_Runtime, requests: String, pure: Bool, show: NC_Show, +observers: Bool, plan: NF_Plan) -> NC_Result:
  match plan:
    case NF_Plan{workers, ready, observer_names}: nf_finish_ready(book, ss, cs, runtime, requests, pure, show, workers, ready, ns_image(book), observer_names, observers)


# Private request permission, attached only after ns_source clears caller facts.
# No bang roots means the runtime cannot offload. Keep all device fallbacks for
# any program with bangs, and keep raw API emission on its original lowering.
@unsafe
def nf_host_defs(workers: List<&2, NF_Worker>, +ready: List<&2, String>, +escapes: KDef) -> List<&2, KDef>:
  match workers:
    case Nil{}: Nil{}
    case Con{NF_Worker{+name, +params, code, deps, shape}, +rest}:
      +arity = nt_count(N_Param, params)
      nt_choose(List<&2, KDef>, U32.is_gt(arity, 0) && Bool.not(String.starts_with(name, "$product.")) && nb_contains(ready, name),
        u => Con{KDef{name, "NativeHostWorker", arity, nt_bool(String.eq(dk(index_find(escapes, name, index_hash(name, 2166136261), 32)), "Absent")), atom("Absent"), atom("Absent"), Nil{}, False{}, False{}}, nf_host_defs(rest, ready, escapes)}, u => nf_host_defs(rest, ready, escapes))

@unsafe
def nf_host_context(+book: List<&2, KDef>, +permission: Bool, plan: NF_Plan) -> List<&2, KDef>:
  match plan:
    case NF_Plan{workers, ready, observers}:
      nt_choose(List<&2, KDef>, permission, u => nf_host_calls(book, workers, ready, nc_live_names(book, ["main"], Nil{})), u => book)

@unsafe
def nf_host_attach(+book: List<&2, KDef>, +index: KDef) -> List<&2, KDef>:
  match book:
    case Nil{}: book
    case Con{cache, rest}: Con{KDef{dn(cache), dk(cache), da(cache), dx(cache), dt(cache), dv(cache), [index_first(dc(cache)), ns_context(book), KDef{"$native.host.plan", "NativeHostPlan", 0, 0, atom("Absent"), atom("Absent"), [index], False{}, False{}}], db(cache), du(cache)}, rest}

@unsafe
def nf_host_payload(children: List<&2, KDef>) -> KDef:
  match children:
    case Con{source, Con{statics, Con{+plan, rest}}}: nt_choose(KDef, String.eq(dk(plan), "NativeHostPlan") && String.eq(dn(plan), "$native.host.plan"), u => index_first(dc(plan)), u => missing())
    case _: missing()

@unsafe
def nf_host_selected(+book: List<&2, KDef>, +name: String, +arity: U32) -> Bool:
  +d = index_find(nf_host_payload(dc(index_first(book))), name, index_hash(name, 2166136261), 32)
  U32.is_gt(arity, 0) && String.eq(dk(d), "NativeHostWorker") && U32.is_eq(da(d), arity)

@unsafe
def nf_escape_add(+name: String, +index: KDef) -> KDef:
  index_set(index, nv_id(name), index_hash(name, 2166136261), 32)


@unsafe
def nf_escape_terms(+book: List<&2, KDef>, ts: List<&2, KTerm>, +index: KDef) -> KDef:
  match ts:
    case Nil{}: index
    case Con{+t, +rest}:
      nt_choose(KDef, String.eq(tg(t), "App"),
        u => nf_escape_app(book, nd_head(t), nd_args(t, Nil{}), rest, index),
        u => nt_choose(KDef, String.eq(tg(t), "Ref"),
          v => nf_escape_terms(book, rest, nf_escape_add(nm(t), index)),
          v => nf_escape_terms(book, nt_append(KTerm, ks(t), rest), index)))


@unsafe
def nf_escape_app(+book: List<&2, KDef>, +head: KTerm, +args: List<&2, KTerm>, +rest: List<&2, KTerm>, +index: KDef) -> KDef:
  nt_choose(KDef, String.eq(tg(head), "Ref"),
    u => nf_escape_terms(book, nt_append(KTerm, args, rest),
      nt_choose(KDef, Bool.not(U32.is_eq(qt(head), 3)) && U32.is_eq(terms_len(args), nd_arity(book, nm(head))), v => index, v => nf_escape_add(nm(head), index))),
    u => nf_escape_terms(book, Con{head, nt_append(KTerm, args, rest)}, index))


@unsafe
def nf_escape_names(+book: List<&2, KDef>, names: List<&2, String>, +index: KDef) -> KDef:
  match names:
    case Nil{}: index
    case Con{name, rest}: nf_escape_names(book, rest, nf_escape_terms(book, [nc_definition(book, lookup(book, name), 0)], index))


@unsafe
def nf_host_no_factory(+book: List<&2, KDef>, +name: String, +arity: U32) -> Bool:
  +d = index_find(nf_host_payload(dc(index_first(book))), name, index_hash(name, 2166136261), 32)
  U32.is_gt(arity, 0) && (String.eq(dk(d), "NativeHostWorker") || String.eq(dk(d), "NativeCallOnly")) && U32.is_eq(da(d), arity) && U32.is_eq(dx(d), 1)


@unsafe
def nf_host_calls(+book: List<&2, KDef>, +workers: List<&2, NF_Worker>, +ready: List<&2, String>, +names: List<&2, String>) -> List<&2, KDef>:
  +escapes = nf_escape_names(book, names, missing())
  nf_host_attach(book, index_build(nt_append(KDef, nf_host_defs(workers, ready, escapes), nf_call_only_defs(book, names, escapes))))


@unsafe
def nf_call_only_defs(+book: List<&2, KDef>, names: List<&2, String>, +escapes: KDef) -> List<&2, KDef>:
  match names:
    case Nil{}: Nil{}
    case Con{+name, +rest}:
      nt_choose(List<&2, KDef>, String.eq(dk(index_find(escapes, name, index_hash(name, 2166136261), 32)), "Absent"),
        u => Con{KDef{name, "NativeCallOnly", nd_arity(book, name), 1, atom("Absent"), atom("Absent"), Nil{}, False{}, False{}}, nf_call_only_defs(book, rest, escapes)},
        u => nf_call_only_defs(book, rest, escapes))
