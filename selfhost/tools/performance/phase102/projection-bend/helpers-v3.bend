# Compose a proved owning observer with a pure projection of its known wrapper.
# Admission uses the route's actual NOObserverEntry, never a source-name list.
# The public worker keeps its owned inputs/result and existing cleanup emitter.
@unsafe
def nfp_identity(args: List<&2, KTerm>, +i: U32) -> Bool:
  match args:
    case Nil{}: True{}
    case Con{arg, rest}: p98_tag_eq(arg, "Var") && U32.is_eq(ix(arg), nc_id(i)) && nfp_identity(rest, U32.inc(i))

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
  nt_choose(KTerm, U32.is_eq(fuel, 0), u => atom("Absent"), u =>
    nfp_reduce_head(nd_head(nc_unann(term)), List.append(&2, KTerm, nd_args(nc_unann(term), Nil{}), args), U32.sub(fuel, 1), known))

@unsafe
def nfp_reduce_head(+head: KTerm, args: List<&2, KTerm>, +fuel: U32, +known: List<&2, KTerm>) -> KTerm:
  match args:
    case Nil{}: nt_choose(KTerm, p98_tag_eq(head, "Var"), u => head, u => atom("Absent"))
    case Con{+arg, +rest}:
      nt_choose(KTerm, nfp_known(arg, known, 32),
        u => nt_choose(KTerm, p98_tag_eq(head, "Lam") && nq_layout_subst_small(kid(head, 0), arg),
          v => nfp_reduce_known(nq_layout_subst(kid(head, 0), ix(head), arg), rest, fuel, known), v =>
        nt_choose(KTerm, p98_tag_eq(head, "Mat") && p98_tag_eq(arg, "Ctr") && p88_string_eq(nm(head), nm(arg)) && U32.is_eq(ix(head), U32.inc(terms_len(ks(arg)))),
          w => nfp_reduce_known(kid(head, 0), List.append(&2, KTerm, ks(arg), rest), fuel, known), w => atom("Absent"))),
        u => atom("Absent"))

@unsafe
def nfp_replace(+book: List<&2, KDef>, +old: NF_Worker, +producer: String, +schema: NO_Schema, +selected: KTerm) -> NF_Worker:
  match old:
    case NF_Worker{name, params, code, deps, shape}:
      match no_adapter(book, producer, no_plan_params(no_schema_params(schema)), no_schema_roots(schema), no_schema_result(schema), selected, no_schema_fresh(schema)):
        case NF_Worker{ignored, ignoredParams, +newCode, +newDeps, ignoredShape}:
          nt_choose(NF_Worker, p88_string_eq(nc_error(newCode), "") && List.is_empty(&2, N_Segment, nc_segs(newCode)),
            u => NF_Worker{name, params, newCode, newDeps, shape}, u => old)

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
