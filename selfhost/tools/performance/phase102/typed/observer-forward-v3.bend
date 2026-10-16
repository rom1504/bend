# Reuse an already proved owning observer adapter as the ordinary NF worker.
# This can break a reconstruction-only dependency cycle without admitting C
# recursion, changing scalar observer guards or inventing a borrowed call ABI.
@unsafe
def nfo_entries(workers: List<&2, NF_Worker>, +ready: List<&2, String>) -> List<&2, KDef>:
  match workers:
    case Nil{}: Nil{}
    case Con{NF_Worker{+name, +params, +code, deps, +shape}, +rest}:
      +arity = nt_count(N_Param, params)
      +eligible = Bool.not(nb_contains(ready, name) || String.starts_with(name, "$")) && String.eq(tg(shape), "Absent") && String.eq(nc_error(code), "") && List.is_empty(&2, N_Segment, nc_segs(code)) && U32.is_ge(arity, 1) && U32.is_le(arity, 4)
      nt_choose(List<&2, KDef>, eligible,
        u => Con{KDef{nd_name(name), "NOEligibleEntry", arity, 0, atom("Absent"), atom("Absent"), Nil{}, False{}, False{}}, nfo_entries(rest, ready)},
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
      +selected = String.eq(dk(entry), "NOObserverEntry") && Bool.not(nb_contains(oldReady, name)) && U32.is_eq(da(entry), nt_count(N_Param, params)) && String.eq(tg(shape), "Absent") && nb_contains(ready, no_adapter_name(name)) && nb_contains(ready, no_worker_name(name))
      Con{nt_choose(NF_Worker, selected,
        u => nfo_alias_worker(name, params, shape),
        u => NF_Worker{name, params, code, deps, shape}), nfo_aliases(rest, entries, oldReady, ready)}

@unsafe
def nfo_finish(+book: List<&2, KDef>, +oldReady: List<&2, String>, +observers: List<&2, String>, route: NO_Route) -> NF_Plan:
  match route:
    case NO_Route{+workers, +ready, +entries}:
      nt_choose(NF_Plan, List.is_empty(&2, KDef, entries), u => NF_Plan{workers, ready, observers}, u =>
        nfo_admit(book, nfo_aliases(workers, book_cached(entries, 0), oldReady, ready), ready, observers))

@unsafe
def nfo_admit(+book: List<&2, KDef>, +workers: List<&2, NF_Worker>, +ready: List<&2, String>, observers: List<&2, String>) -> NF_Plan:
  NF_Plan{workers, nf_admit(book, workers, ready, nt_count(NF_Worker, workers)), observers}

@unsafe
def nfo_plan(+book: List<&2, KDef>, plan: NF_Plan) -> NF_Plan:
  match plan:
    case NF_Plan{+workers, +ready, +observers}:
      nt_choose(NF_Plan, List.is_empty(&2, String, observers), u => NF_Plan{workers, ready, observers}, u =>
        nfo_finish(book, ready, observers, no_route_names(book, observers, book_cached(nfo_entries(workers, ready), 0), NO_Route{workers, ready, Nil{}})))
