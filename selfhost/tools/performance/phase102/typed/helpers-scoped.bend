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
      Con{KDef{dn(cache), dk(cache), da(cache), dx(cache), dt(cache), dv(cache), [index_first(dc(cache)), ns_context(book), KDef{"$native.local.plan", "NativeLocalPlan", 0, 0, atom("Absent"), atom("Absent"), [index], False{}, False{}}], db(cache), du(cache)}, rest}

@unsafe
def nf_scheduler_compile(+book: List<&2, KDef>, +names: List<&2, String>, +bangs: List<&2, String>, +runtime: NE_Runtime, +requests: String, +observers: Bool, +sharing: Bool) -> NC_Result:
  +plan = nf_plan_scoped(book, names, bangs, observers, sharing)
  +selected = nf_scheduler_attach(book, plan)
  nc_finish(selected, ne_runtime_prepend(runtime, nh_macros(selected, names, sharing)), requests, nc_compile_defs(selected, ["main"], Nil{}, 0, bangs), observers, plan)
