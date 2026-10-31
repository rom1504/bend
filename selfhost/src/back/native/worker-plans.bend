
# Three immutable dependency passes force only small leaves and two caller
# levels. Admission and generated bodies are unchanged; C budgets deeper calls.
@unsafe
def nfi_deps(deps: List<&2, String>, +previous: List<&2, String>) -> Bool:
  match deps:
    case Nil{}: True{}
    case Con{name, rest}: nb_contains(previous, name) && nfi_deps(rest, previous)

@unsafe
def nfi_eligible(+ready: List<&2, String>, worker: NF_Worker) -> Bool:
  match worker:
    case NF_Worker{name, params, code, deps, shape}: nb_contains(ready, name) && nct_within(nc_text(code), 8192)

@unsafe
def nfi_filter(workers: List<&2, NF_Worker>, +ready: List<&2, String>) -> List<&2, NF_Worker>:
  match workers:
    case Nil{}: Nil{}
    case Con{+worker, +rest}:
      nt_choose(List<&2, NF_Worker>, nfi_eligible(ready, worker),
        u => Con{worker, nfi_filter(rest, ready)}, u => nfi_filter(rest, ready))

@unsafe
def nfi_pass(workers: List<&2, NF_Worker>, +previous: List<&2, String>) -> List<&2, String>:
  match workers:
    case Nil{}: Nil{}
    case Con{NF_Worker{+name, params, code, deps, shape}, +rest}:
      nt_choose(List<&2, String>, nfi_deps(deps, previous),
        u => Con{name, nfi_pass(rest, previous)}, u => nfi_pass(rest, previous))

@unsafe
def nf_plan_scoped(+book: List<&2, KDef>, +names: List<&2, String>, +bangs: List<&2, String>, +observers: Bool, +checked: Bool) -> NF_Plan:
  +signatures = book_cached(nq_signatures(book, names), 0)
  +observer_names = nt_choose(List<&2, String>, observers, u => no_candidate_names(book, names, bangs), u => Nil{})
  nfo_plan(book, nf_plan_workers(book, List.append(&2, NF_Worker, nf_candidates(book, names, bangs, signatures), nq_candidates_mode(book, names, bangs, signatures, checked)), signatures, observer_names))


# A scheduler parent may call an already admitted ordinary worker locally.
# Private plans are attached only for checked, provider-certified books without
# reachable bangs. This call permission does not grant layout/sharing changes.
@unsafe
def nf_scheduler_payload(children: List<&2, KDef>) -> KDef:
  match children:
    case Con{source, Con{statics, Con{+plan, rest}}}:
      nt_choose(KDef, p88_string_eq(dk(plan), "NativeLocalPlan") && p88_string_eq(dn(plan), "$native.local.plan"), u => index_first(dc(plan)), u => nf_host_payload(children))
    case _: missing()

@unsafe
def nf_scheduler_selected(+book: List<&2, KDef>, +name: String, +arity: U32) -> Bool:
  +d = index_find(nf_scheduler_payload(dc(index_first(book))), name, index_hash(name, 2166136261), 32)
  U32.is_gt(arity, 0) && p88_string_eq(dk(d), "NativeHostWorker") && U32.is_eq(da(d), arity)

@unsafe
def nf_scheduler_name(+book: List<&2, KDef>, +value: KTerm) -> String:
  +head = nd_head(value)
  nt_choose(String, p88_string_eq(tg(value), "App") && p88_string_eq(tg(head), "Ref") && Bool.not(U32.is_eq(qt(head), 3)),
    u => nt_choose(String, nf_scheduler_selected(book, nm(head), terms_len(nd_args(value, Nil{}))), v => nm(head), v => ""), u => "")

@unsafe
def nf_scheduler_bind(+book: List<&2, KDef>, +value: KTerm, +body: KTerm, +env: List<&2, NC_Binding>, +id: U32, +n: U32) -> NC_Code:
  +name = nf_scheduler_name(book, value)
  nt_choose(NC_Code, p88_string_eq(name, ""), u => nc_let_cut(book, value, body, env, id, n), u =>
    nc_lower(book, nd_bind_value("NFCall", name, nd_args(value, Nil{}), Nil{}, n, id, body), env, U32.add(n, terms_len(nd_args(value, Nil{})))))

# Arguments have been evaluated in source order. The existing local-producer
# rule handles sharing with the remaining body, result drops and fresh scopes.
@unsafe
def nf_scheduler_emitted(+name: String, +words: List<&2, String>, +n: U32) -> N_Emitted:
  +result = "nf_local_" ++ U32.show(n)
  N_Emitted{"Term " ++ result ++ "[1];\nif (!" ++ nf_name(name) ++ "(e, seq, " ++ result ++ nf_arg_c(words) ++ ")) { return 0; }\n", result ++ "[0]", U32.inc(n)}

# These request-local plans require checked providers and no reachable bangs.
# Their segments cannot be offloaded. Use existing host metadata so local NF
# calls never appear in a device switch where NF declarations are unavailable.
@unsafe
def nf_scheduler_host(children: List<&2, KDef>) -> Bool:
  match children:
    case Con{source, Con{statics, Con{+plan, rest}}}:
      (p88_string_eq(dk(plan), "NativeLocalPlan") && p88_string_eq(dn(plan), "$native.local.plan")) || (p88_string_eq(dk(plan), "NativeHostPlan") && p88_string_eq(dn(plan), "$native.host.plan"))
    case _: False{}

@unsafe
def nf_scheduler_host_rev(ss: List<&2, N_Segment>, acc: List<&2, N_Segment>) -> List<&2, N_Segment>:
  match ss:
    case Nil{}: nt_reverse(N_Segment, acc, Nil{})
    case Con{N_Segment{name, params, result, frame, body, refs, host, spin, fork, bang}, rest}:
      nf_scheduler_host_rev(rest, Con{N_Segment{name, params, result, frame, body, refs, True{}, spin, fork, bang}, acc})

@unsafe
def nf_scheduler_segments(+book: List<&2, KDef>, +ss: List<&2, N_Segment>) -> List<&2, N_Segment>:
  nt_choose(List<&2, N_Segment>, nf_scheduler_host(dc(index_first(book))), u => nf_scheduler_host_rev(ss, Nil{}), u => ss)

# Phase98 has a weaker checked observer permission for native File providers.
# Build the same existing NF plan before scheduler lowering, attaching only
# local-call permission. Do not enable host factories, scalar arrays or packing.
@unsafe
def nf_scheduler_attach(+book: List<&2, KDef>, plan: NF_Plan) -> List<&2, KDef>:
  match plan:
    case NF_Plan{workers, ready, observers}:
      nf_scheduler_attach_index(book, index_build(nf_host_defs(workers, ready, missing())))

@unsafe
def nf_scheduler_attach_index(+book: List<&2, KDef>, +index: KDef) -> List<&2, KDef>:
  match book:
    case Nil{}: book
    case Con{cache, rest}:
      Con{KDef{dn(cache), dk(cache), da(cache), dx(cache), dt(cache), dv(cache), [index_first(dc(cache)), ns_context(book), KDef{"$native.local.plan", "NativeLocalPlan", 0, 0, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, [index], False{}, False{}}], db(cache), du(cache)}, rest}

@unsafe
def nf_scheduler_compile(+book: List<&2, KDef>, +names: List<&2, String>, +bangs: List<&2, String>, +runtime: NE_Runtime, +requests: String, +observers: Bool, +sharing: Bool) -> NC_Result:
  +plan = nf_plan_scoped(book, names, bangs, observers, sharing)
  +selected = nf_scheduler_attach(book, plan)
  nc_finish(selected, ne_runtime_prepend(runtime, nh_macros(selected, names, sharing)), requests, nc_compile_defs(selected, ["main"], Nil{}, 0, bangs), observers, plan)

# Reuse an already proved owning observer adapter as the ordinary NF worker.
# This can break a reconstruction-only dependency cycle without admitting C
# recursion, changing scalar observer guards or inventing a borrowed call ABI.
@unsafe
def nfo_entries(workers: List<&2, NF_Worker>, +ready: List<&2, String>) -> List<&2, KDef>:
  match workers:
    case Nil{}: Nil{}
    case Con{NF_Worker{+name, +params, +code, deps, +shape}, +rest}:
      +arity = nt_count(N_Param, params)
      +eligible = Bool.not(nb_contains(ready, name) || String.starts_with(name, "$")) && p88_string_eq(tg(shape), "Absent") && p88_string_eq(nc_error(code), "") && List.is_empty(&2, N_Segment, nc_segs(code)) && U32.is_ge(arity, 1) && U32.is_le(arity, 4)
      nt_choose(List<&2, KDef>, eligible,
        u => Con{KDef{nd_name(name), "NOEligibleEntry", arity, 0, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, Nil{}, False{}, False{}}, nfo_entries(rest, ready)},
        u => nfo_entries(rest, ready))

@unsafe
def nfo_alias_code(+name: String, +params: List<&2, N_Param>) -> NC_Code:
  +adapter = no_adapter_name(name)
  nfo_alias_edges(adapter, nc_prepend("return " ++ nf_name(adapter) ++ "(e, seq, nf_out" ++ nf_arg_c(nf_segment_args(params)) ++ ");\n", nc_fail("", 0)))

@unsafe
def nfo_alias_edges(adapter: String, code: NC_Code) -> NC_Code:
  match code:
    case NC_Code{body, segments, fresh, error, calls}:
      NC_Code{body, segments, fresh, error, [adapter]}

@unsafe
def nfo_alias_worker(+name: String, +params: List<&2, N_Param>, shape: KTerm) -> NF_Worker:
  +code = nfo_alias_code(name, params)
  NF_Worker{name, params, code, nc_calls(code), shape}

@unsafe
def nfo_aliases(workers: List<&2, NF_Worker>, +entries: List<&2, KDef>, +oldReady: List<&2, String>, +ready: List<&2, String>) -> List<&2, NF_Worker>:
  match workers:
    case Nil{}: Nil{}
    case Con{NF_Worker{+name, +params, +code, +deps, +shape}, rest}:
      +entry = lookup(entries, nd_name(name))
      +selected = p88_string_eq(dk(entry), "NOObserverEntry") && Bool.not(nb_contains(oldReady, name)) && U32.is_eq(da(entry), nt_count(N_Param, params)) && p88_string_eq(tg(shape), "Absent") && nb_contains(ready, no_adapter_name(name)) && nb_contains(ready, no_worker_name(name))
      Con{nt_choose(NF_Worker, selected,
        u => nfo_alias_worker(name, params, shape),
        u => NF_Worker{name, params, code, deps, shape}), nfo_aliases(rest, entries, oldReady, ready)}

@unsafe
def nfo_finish(+book: List<&2, KDef>, +oldReady: List<&2, String>, +observers: List<&2, String>, route: NO_Route) -> NF_Plan:
  match route:
    case NO_Route{+workers, +ready, +entries}:
      nt_choose(NF_Plan, List.is_empty(&2, KDef, entries), u => NF_Plan{workers, ready, observers}, u =>
        nfp_finish(book, book_cached(entries, 0), nfo_admit(book, nfo_aliases(workers, book_cached(entries, 0), oldReady, ready), ready, observers)))

@unsafe
def nfo_admit(+book: List<&2, KDef>, +workers: List<&2, NF_Worker>, +ready: List<&2, String>, observers: List<&2, String>) -> NF_Plan:
  NF_Plan{workers, nf_admit(book, workers, ready, nt_count(NF_Worker, workers)), observers}

@unsafe
def nfo_plan(+book: List<&2, KDef>, plan: NF_Plan) -> NF_Plan:
  match plan:
    case NF_Plan{+workers, +ready, +observers}:
      nt_choose(NF_Plan, List.is_empty(&2, String, observers), u => NF_Plan{workers, ready, observers}, u =>
        nfo_finish(book, ready, observers, no_route_names(book, observers, book_cached(nfo_entries(workers, ready), 0), NO_Route{workers, ready, Nil{}})))

# Compose a proved owning observer with a pure projection of its known wrapper.
# Admission uses the route's actual NOObserverEntry, never a source-name list.
# The public worker keeps its owned inputs/result and existing cleanup emitter.
@unsafe
def nfp_identity(args: List<&2, KTerm>, +i: U32) -> Bool:
  match args:
    case Nil{}: True{}
    case Con{+arg, rest}: p98_tag_eq(arg, "Var") && U32.is_eq(ix(arg), nc_id(i)) && nfp_identity(rest, U32.inc(i))

@unsafe
def nfp_params(params: List<&2, N_Param>, +i: U32) -> Bool:
  match params:
    case Nil{}: True{}
    case Con{N_Param{name, kind}, rest}:
      match kind:
        case N_W64{}: p88_string_eq(name, "v_" ++ U32.show(nc_id(i))) && nfp_params(rest, U32.inc(i))
        case _: False{}

# This is a finite syntax certificate, not evaluation of arbitrary Bend code.
# Only already-known constructor fields are substituted or matched. A match on
# a root/scalar Var, references, effects, arithmetic and opaque syntax refuse.
# Every consumed argument must come from the immutable admitted wrapper.
# Projector-created expressions must never disappear through beta reduction.
@unsafe
def nfp_known(+arg: KTerm, values: List<&2, KTerm>, +fuel: U32) -> Bool:
  match values:
    case Nil{}: False{}
    case Con{+value, +rest}:
      nt_choose(Bool, U32.is_eq(fuel, 0), u => False{}, u =>
        norm_exact(arg, value) || nfp_known(arg, List.append(&2, KTerm, ks(value), rest), U32.sub(fuel, 1)))

@unsafe
def nfp_reduce(+term: KTerm, +args: List<&2, KTerm>, +fuel: U32) -> KTerm:
  nfp_reduce_known(term, args, fuel, args)

@unsafe
def nfp_reduce_known(+term: KTerm, +args: List<&2, KTerm>, +fuel: U32, +known: List<&2, KTerm>) -> KTerm:
  nt_choose(KTerm, U32.is_eq(fuel, 0), u => {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm}, u =>
    nfp_reduce_head(nd_head(nc_unann(term)), List.append(&2, KTerm, nd_args(nc_unann(term), Nil{}), args), U32.sub(fuel, 1), known))

@unsafe
def nfp_reduce_head(+head: KTerm, args: List<&2, KTerm>, +fuel: U32, +known: List<&2, KTerm>) -> KTerm:
  match args:
    case Nil{}: nt_choose(KTerm, p98_tag_eq(head, "Var"), u => head, u => {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm})
    case Con{+arg, +rest}:
      nt_choose(KTerm, nfp_known(arg, known, 32),
        u => nt_choose(KTerm, p98_tag_eq(head, "Lam") && nq_layout_subst_small(kid(head, 0), arg),
          v => nfp_reduce_known(nq_layout_subst(kid(head, 0), ix(head), arg), rest, fuel, known), v =>
        nt_choose(KTerm, p98_tag_eq(head, "Mat") && p98_tag_eq(arg, "Ctr") && p88_string_eq(nm(head), nm(arg)) && U32.is_eq(ix(head), U32.inc(terms_len(ks(arg)))),
          w => nfp_reduce_known(kid(head, 0), List.append(&2, KTerm, ks(arg), rest), fuel, known), w => {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm})),
        u => {KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm})

@unsafe
def nfp_replace(+book: List<&2, KDef>, +old: NF_Worker, +producer: String, +schema: NO_Schema, +selected: KTerm) -> NF_Worker:
  nfp_replaced(old, no_adapter(book, producer, no_plan_params(no_schema_params(schema)), no_schema_roots(schema), no_schema_result(schema), selected, no_schema_fresh(schema)))

@unsafe
def nfp_replaced(+old: NF_Worker, replacement: NF_Worker) -> NF_Worker:
  match old:
    case NF_Worker{name, params, code, deps, shape}:
      match replacement:
        case NF_Worker{ignored, ignoredParams, +newCode, +newDeps, ignoredShape}:
          nt_choose(NF_Worker, p88_string_eq(nc_error(newCode), "") && List.is_empty(&2, N_Segment, nc_segs(newCode)),
            # Retain the original dependency horizon after eliminating wrappers.
            # This is conservative cost metadata; every actual new call stays present.
            u => NF_Worker{name, params, newCode, List.append(&2, String, deps, newDeps), shape}, u => old)

# Source substitution must not capture injected schema roots/result. The
# generic occurrence scan misses unused binders, so inspect Lam IDs as well.
@unsafe
def nfp_capture_free(+term: KTerm, +arity: U32) -> Bool:
  (Bool.not(p98_tag_eq(term, "Var") || p98_tag_eq(term, "Lam")) || U32.is_lt(ix(term), nc_id(arity))) && nfp_capture_children(ks(term), arity)

@unsafe
def nfp_capture_children(terms: List<&2, KTerm>, +arity: U32) -> Bool:
  match terms:
    case Nil{}: True{}
    case Con{head, rest}: nfp_capture_free(head, arity) && nfp_capture_children(rest, arity)

@unsafe
def nfp_schema(+book: List<&2, KDef>, +old: NF_Worker, +producer: String, +projector: String, +arity: U32, +schema: NO_Schema) -> NF_Worker:
  +body = nc_compact_definition(book, lookup(book, projector), 0)
  +valid = p88_string_eq(no_schema_error(schema), "") && U32.is_eq(terms_len(no_schema_params(schema)), arity) && U32.is_eq(nt_count(U32, no_schema_roots(schema)), arity) && U32.is_le(nq_layout_size([body], 4097), 256) && nfp_capture_free(body, arity)
  nt_choose(NF_Worker, valid,
    u => nfp_selected(book, old, producer, schema, nfp_reduce(body, [no_schema_wrapper(schema)], 32)), u => old)

@unsafe
def nfp_selected(+book: List<&2, KDef>, +old: NF_Worker, +producer: String, +schema: NO_Schema, +selected: KTerm) -> NF_Worker:
  nt_choose(NF_Worker, p98_tag_eq(selected, "Var") && U32.is_eq(ix(selected), no_schema_result(schema)),
    u => nfp_replace(book, old, producer, schema, selected), u => old)

@unsafe
def nfp_composition(+book: List<&2, KDef>, +old: NF_Worker, +entries: List<&2, KDef>, +ready: List<&2, String>, +arity: U32, +body: KTerm) -> NF_Worker:
  +outer = nd_head(body)
  +outerArgs = nd_args(body, Nil{})
  +inner = terms_at(outerArgs, 0)
  +producer = nd_head(inner)
  +actuals = nd_args(inner, Nil{})
  +entry = lookup(entries, nd_name(nm(producer)))
  +projection = lookup(book, nm(outer))
  +valid = p98_tag_eq(outer, "Ref") && Bool.not(U32.is_eq(qt(outer), 3)) && U32.is_eq(terms_len(outerArgs), 1) && p88_string_eq(dk(projection), "Def") && Bool.not(nc_native_def(projection) || nc_foreign(projection)) && U32.is_eq(nd_arity(book, nm(outer)), 1) && p98_tag_eq(producer, "Ref") && Bool.not(U32.is_eq(qt(producer), 3)) && p88_string_eq(dk(entry), "NOObserverEntry") && p88_string_eq(nm(dv(entry)), nm(producer)) && U32.is_eq(da(entry), arity) && U32.is_eq(terms_len(actuals), arity) && nfp_identity(actuals, 0) && nb_contains(ready, no_adapter_name(nm(producer))) && nb_contains(ready, no_worker_name(nm(producer)))
  nt_choose(NF_Worker, valid,
    u => nfp_schema(book, old, nm(producer), nm(outer), arity, no_schema(book, lookup(book, nm(producer)), 0)), u => old)

@unsafe
def nfp_workers(+book: List<&2, KDef>, workers: List<&2, NF_Worker>, +ready: List<&2, String>, +entries: List<&2, KDef>) -> List<&2, NF_Worker>:
  match workers:
    case Nil{}: Nil{}
    case Con{NF_Worker{+name, +params, +code, +deps, +shape}, rest}:
      +old : NF_Worker = NF_Worker{name, params, code, deps, shape}
      +arity = nt_count(N_Param, params)
      +eligible = nb_contains(ready, name) && Bool.not(String.starts_with(name, "$")) && p98_tag_eq(shape, "Absent") && U32.is_ge(arity, 1) && U32.is_le(arity, 2) && nfp_params(params, 0)
      Con{nt_choose(NF_Worker, eligible,
        u => nfp_composition(book, old, entries, ready, arity, nd_beta(nc_compact_definition(book, lookup(book, name), 0), nd_entry_args(nd_entry_params(arity, 0)))), u => old),
        nfp_workers(book, rest, ready, entries)}

@unsafe
def nfp_finish(+book: List<&2, KDef>, +entries: List<&2, KDef>, plan: NF_Plan) -> NF_Plan:
  match plan:
    case NF_Plan{workers, +ready, observers}: NF_Plan{nfp_workers(book, workers, ready, entries), ready, observers}
