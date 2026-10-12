# Late checked observer routing; raw books cannot grant permission.
# Existing ordinary/product workers finish retry and admission before this lane.
type NO_Route is Data:
  NO_Route{+workers: List<&2, NF_Worker>, +ready: List<&2, String>, +entries: List<&2, KDef>}

@unsafe
def no_route_workers(route: NO_Route) -> List<&2, NF_Worker>:
  match route:
    case NO_Route{workers, ready, entries}: workers

@unsafe
def no_route_ready(route: NO_Route) -> List<&2, String>:
  match route:
    case NO_Route{workers, ready, entries}: ready

@unsafe
def no_route_entries(route: NO_Route) -> List<&2, KDef>:
  match route:
    case NO_Route{workers, ready, entries}: entries

# Called inside the checked-permission branch, using the existing live/bang lists.
@unsafe
def no_candidate_names(+book: List<&2, KDef>, names: List<&2, String>, +bangs: List<&2, String>) -> List<&2, String>:
  match names:
    case Nil{}: Nil{}
    case Con{+name, +rest}:
      +d = lookup(book, name)
      nt_choose(List<&2, String>, String.eq(dk(d), "Def") && Bool.not(nc_native_def(d) || nc_foreign(d) || nb_contains(bangs, name)),
        u => Con{name, no_candidate_names(book, rest, bangs)}, u => no_candidate_names(book, rest, bangs))

# Only public direct entries can be selected. Continuations and bang entries
# remain untouched; index once rather than rescanning segments per candidate.
@unsafe
def no_entry_defs(segments: List<&2, N_Segment>) -> List<&2, KDef>:
  match segments:
    case Nil{}: Nil{}
    case Con{N_Segment{+name, params, result, +frame, body, refs, host, spin, fork, +bang}, +rest}:
      +arity = nt_count(N_Param, params)
      nt_choose(List<&2, KDef>, no_direct_frame(frame) && Bool.not(bang) && U32.is_ge(arity, 1) && U32.is_le(arity, 4),
        u => Con{KDef{name, "NOEligibleEntry", arity, 0, atom("Absent"), atom("Absent"), Nil{}, False{}, False{}}, no_entry_defs(rest)}, u => no_entry_defs(rest))

@unsafe
def no_worker_taken(+name: String, workers: List<&2, NF_Worker>) -> Bool:
  match workers:
    case Nil{}: False{}
    case Con{NF_Worker{current, params, code, deps, shape}, rest}: String.eq(name, current) || no_worker_taken(name, rest)

@unsafe
def no_private_free(+book: List<&2, KDef>, +workers: List<&2, NF_Worker>, +name: String) -> Bool:
  String.eq(dk(lookup(book, name)), "Absent") && Bool.not(no_worker_taken(name, workers))

@unsafe
def no_route_pair(+book: List<&2, KDef>, +owner: String, +arity: U32, +pair: List<&2, NF_Worker>, +old: NO_Route, +scalar: Bool, +roots: List<&2, U32>) -> NO_Route:
  +ready = nf_admit(book, pair, no_route_ready(old), 2)
  nt_choose(NO_Route, nb_contains(ready, no_worker_name(owner)) && nb_contains(ready, no_adapter_name(owner)),
    u => NO_Route{List.append(&2, NF_Worker, pair, nt_choose(List<&2, NF_Worker>, scalar, v => no_scalar_redirect(no_route_workers(old), owner, roots), v => no_route_workers(old))), ready, nt_choose(List<&2, KDef>, scalar, v => no_route_entries(old), v => Con{KDef{nd_name(owner), "NOObserverEntry", arity, 0, atom("Absent"), kt("NOOwner", owner, 0, 0, Nil{}), Nil{}, False{}, False{}}, no_route_entries(old)})},
    u => old)

@unsafe
def no_route_plan(+book: List<&2, KDef>, +entry: KDef, +old: NO_Route, +plan: NO_Plan) -> NO_Route:
  +schema = no_plan_schema(plan)
  +analysis = no_plan_analysis(plan)
  +owner = no_plan_owner(plan)
  +params = no_plan_params(no_schema_params(schema))
  +scalar = String.eq(tg(no_schema_wrapper(schema)), "Var")
  nt_choose(NO_Route, (Bool.not(scalar) || nb_contains(no_route_ready(old), owner)) && String.eq(no_plan_error(plan), "") && String.eq(no_schema_error(schema), "") && String.eq(noa_error(analysis), "") && U32.is_eq(nt_count(NC_Binding, params), da(entry)),
    u => nt_choose(NO_Route, no_private_free(book, no_route_workers(old), no_worker_name(owner)) && no_private_free(book, no_route_workers(old), no_adapter_name(owner)),
      v => no_route_pair(book, owner, da(entry), [no_worker(owner, params, no_schema_specs_layouts(no_schema_specs(schema)), noa_body(analysis)), no_adapter(book, owner, params, no_schema_roots(schema), no_schema_result(schema), no_schema_wrapper(schema), noa_fresh(analysis))], old, scalar, no_schema_roots(schema)), v => old), u => old)

@unsafe
def no_route_one(+book: List<&2, KDef>, +name: String, +entry: KDef, +old: NO_Route) -> NO_Route:
  nt_choose(NO_Route, String.eq(dk(entry), "NOEligibleEntry"),
    u => no_route_plan(book, entry, old, no_observer_plan(book, name, True{})), u => old)

@unsafe
def no_route_names(+book: List<&2, KDef>, names: List<&2, String>, +index: List<&2, KDef>, +old: NO_Route) -> NO_Route:
  match names:
    case Nil{}: old
    case Con{+name, rest}: no_route_names(book, rest, index, no_route_one(book, name, lookup(index, nd_name(name)), old))

@unsafe
def no_route(+book: List<&2, KDef>, +segments: List<&2, N_Segment>, +names: List<&2, String>, +workers: List<&2, NF_Worker>, +ready: List<&2, String>, +permission: Bool) -> NO_Route:
  +old : NO_Route = NO_Route{workers, ready, Nil{}}
  nt_choose(NO_Route, permission, u => no_route_names(book, names, book_cached(no_entry_defs(segments), 0), old), u => old)

@unsafe
def no_wrap_registered(segments: List<&2, N_Segment>, +index: List<&2, KDef>, +ready: List<&2, String>) -> List<&2, N_Segment>:
  match segments:
    case Nil{}: Nil{}
    case Con{+segment, rest}:
      match segment:
        case N_Segment{name, params, result, frame, body, refs, host, spin, fork, bang}:
          +d = lookup(index, name)
          Con{nt_choose(N_Segment, String.eq(dk(d), "NOObserverEntry"), u => no_wrap_adapter(nm(dv(d)), da(d), ready, segment), u => segment), no_wrap_registered(rest, index, ready)}

@unsafe
def no_wrap_routes(+segments: List<&2, N_Segment>, +entries: List<&2, KDef>, +ready: List<&2, String>) -> List<&2, N_Segment>:
  nt_choose(List<&2, N_Segment>, List.is_empty(&2, KDef, entries), u => segments, u => no_wrap_registered(segments, book_cached(entries, 0), ready))

# Scalar observers borrow only shared roots. Keep the existing owned worker
# for unique inputs, including its tail loop, ownership and error checks.
@unsafe
def no_shared_roots(params: List<&2, N_Param>, +roots: List<&2, U32>, +i: U32) -> String:
  match params:
    case Nil{}: "1"
    case Con{N_Param{+word, kind}, rest}:
      nt_choose(String, no_root_index(roots, i), u => "(term_rfc(" ++ word ++ ") && (rfc_view(e, term_loc(" ++ word ++ ")) & RFC_CNT) > 1) && ", u => "") ++ no_shared_roots(rest, roots, U32.inc(i))

@unsafe
def no_scalar_redirect(workers: List<&2, NF_Worker>, +owner: String, +roots: List<&2, U32>) -> List<&2, NF_Worker>:
  match workers:
    case Nil{}: Nil{}
    case Con{NF_Worker{+name, +params, +code, +deps, +shape}, rest}:
      +redirect = "if (" ++ no_shared_roots(params, roots, 0) ++ ") { return " ++ nf_name(no_adapter_name(owner)) ++ "(e, seq, nf_out" ++ nf_arg_c(nf_segment_args(params)) ++ "); }\n"
      Con{NF_Worker{name, params, nt_choose(NC_Code, String.eq(name, owner), u => nc_prepend(redirect, code), u => code), nt_choose(List<&2, String>, String.eq(name, owner), u => Con{no_adapter_name(owner), deps}, u => deps), shape}, no_scalar_redirect(rest, owner, roots)}
