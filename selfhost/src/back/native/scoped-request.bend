
@unsafe
def ns_compile_scoped(+book: List<&2, KDef>, +runtime: NE_Runtime, +requests: String, +observers: Bool, +sharing: Bool) -> NC_Result:
  +source = ns_source(book)
  +names = nc_live_names(source, ["main"], Nil{})
  ns_compile_named_scoped(source, names, runtime, requests, observers, sharing)

@unsafe
def ns_compile_named_scoped(+source: List<&2, KDef>, +names: List<&2, String>, +runtime: NE_Runtime, +requests: String, +observers: Bool, +sharing: Bool) -> NC_Result:
  +prepared = ns_prepare(source, names)
  +bangs = nc_bangs_names(prepared, names)
  nt_choose(NC_Result, sharing && List.is_empty(&2, String, bangs),
    u => ns_compile_planned_scoped(prepared, names, bangs, runtime, requests, observers, sharing),
    u => nt_choose(NC_Result, observers && List.is_empty(&2, String, bangs),
      v => nf_scheduler_compile(prepared, names, bangs, runtime, requests, observers, sharing),
      v => ns_compile_fallback_scoped(prepared, names, bangs, ne_runtime_prepend(runtime, nh_macros(prepared, names, sharing)), requests, observers, sharing, nc_compile_defs(prepared, ["main"], Nil{}, 0, bangs))))

@unsafe
def ns_compile_planned_scoped(+book: List<&2, KDef>, +names: List<&2, String>, +bangs: List<&2, String>, +runtime: NE_Runtime, +requests: String, +observers: Bool, +sharing: Bool) -> NC_Result:
  +plan = nf_plan_scoped(book, names, bangs, observers, sharing)
  +selected = nf_host_context(book, True{}, plan)
  nc_finish(selected, ne_runtime_prepend(runtime, nh_macros(selected, names, sharing)), requests, nc_compile_defs(selected, ["main"], Nil{}, 0, bangs), observers, plan)

@unsafe
def ns_compile_fallback_scoped(+book: List<&2, KDef>, +names: List<&2, String>, +bangs: List<&2, String>, +runtime: NE_Runtime, +requests: String, +observers: Bool, +sharing: Bool, compiled: NC_Book) -> NC_Result:
  match compiled:
    case NC_Book{ss, fresh, +error}:
      nt_choose(NC_Result, p88_string_eq(error, ""),
        u => nc_finish(book, runtime, requests, NC_Book{ss, fresh, error}, observers, nf_plan_scoped(book, names, bangs, observers, sharing)),
        u => NC_Result{"", error})
