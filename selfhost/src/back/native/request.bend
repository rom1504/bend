# One private checked-request product. Source validation always sees the source
# book, never erased/generated binder IDs. Raw emission retains its own path.
type NR_Closure is Data:
  NR_Closure{+names: List<&2, String>, +facts: List<&2, KDef>}

type NR_Request is Data:
  NR_Request{+source: List<&2, KDef>, +book: List<&2, KDef>, +names: List<&2, String>, +paths: List<&2, String>, +scope: List<&2, KDef>, +bound: Maybe<&2, U32>}

@unsafe
def nr_walk(+book: List<&2, KDef>, todo: List<&2, String>, +done: List<&2, String>, +facts: List<&2, KDef>) -> NR_Closure:
  match todo:
    case Nil{}: NR_Closure{done, facts}
    case Con{+name, +rest}:
      nt_choose(NR_Closure, nb_contains(done, name), u => nr_walk(book, rest, done, facts),
        u => nr_visit(book, name, rest, done, facts, lookup(book, name)))

@unsafe
def nr_visit(+book: List<&2, KDef>, +name: String, +todo: List<&2, String>, +done: List<&2, String>, +facts: List<&2, KDef>, +d: KDef) -> NR_Closure:
  +body = nc_definition_plain(book, d, 0)
  +more = nt_choose(List<&2, KDef>, String.eq(dk(d), "Def") && Bool.not(nc_native_def(d) || nc_foreign(d)),
    u => Con{KDef{name, "NativeErasedBody", nd_arity_plain(book, name), 1, atom("Absent"), body, Nil{}, False{}, False{}}, facts}, u => facts)
  nr_walk(book, nt_append(String, nc_refs(body), todo), Con{name, done}, more)

@unsafe
def nr_prepare(+book: List<&2, KDef>) -> NR_Request:
  +source = ns_source(book)
  nr_prepared(source, nr_walk(source, ["main"], Nil{}, Nil{}), None{})

@unsafe
def nr_prepared(+source: List<&2, KDef>, closure: NR_Closure, bound: Maybe<&2, U32>) -> NR_Request:
  match closure:
    case NR_Closure{+names, facts}:
      NR_Request{source, ns_attach_book(source, facts, 0, Nil{}), names, nc_paths_of(source, names), kr_filter(source, names), bound}

@unsafe
def nr_unshared(+book: List<&2, KDef>, names: List<&2, String>) -> Bool:
  match names:
    case Nil{}: True{}
    case Con{name, rest}:
      +d = lookup(book, name)
      nt_choose(Bool, nt_choose(Bool, nc_native_def(d) || nc_foreign(d), u => True{}, u => ns_unshared_terms(book, nc_definition(book, d, 0), [dv(d)])),
        u => nr_unshared(book, rest), u => False{})

@unsafe
def nr_compile(request: NR_Request, runtime: String, requests: String, effects_safe: Bool) -> NC_Result:
  nr_compile_prepared(request, NE_Text{runtime}, requests, effects_safe)

@unsafe
def nr_compile_prepared(request: NR_Request, +runtime: NE_Runtime, +requests: String, +effects_safe: Bool) -> NC_Result:
  match request:
    case NR_Request{+source, +book, +names, paths, scope, bound}:
      +packed = nt_choose(Bool, effects_safe, u => ns_definitions(book, names), u => False{})
      +unshared = nt_choose(Bool, packed, u => nr_unshared(book, names), u => False{})
      +header = ne_runtime_prepend(runtime, ns_checked_runtime(book, "", packed, unshared))
      +error = nc_compile_error_known(source, bound)
      nt_choose(NC_Result, String.eq(error, ""),
        u => ns_compile_named(book, names, header, requests, packed), u => NC_Result{"", error})

# Owned annotation creates a plain merged book and a fresh mirror index. Its
# exact bound also bounds that index; erased/generated facts are not source.
# Raw nr_prepare retains the independent source-bound scan at compile time.
@unsafe
def nr_prepare_annotated(+book: List<&2, KDef>, annotated: List<&2, KDef>) -> NR_Request:
  +merged = nc_context_defs(book, nc_context_index(annotated))
  +bound = norm_max_book(merged)
  +source = book_cached(merged, bound)
  nr_prepared(source, nr_walk(source, ["main"], Nil{}, Nil{}), Some{bound})
