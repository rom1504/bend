# Phase128: do not lower a late flat candidate whose exact symbol is ready.
# Boxed factories may return several workers, so their bundles stay unchanged.

@unsafe
def p128prep_flat_needed(+info: KDef, +ready: KDef) -> Bool:
  String.eq(tg(dv(info)),"NQSig") && Bool.not(p113d_ready(ready,nm(dv(info))))

@unsafe
def p128prep_candidates(+book: List<&2,KDef>, names: List<&2,String>, +bangs: List<&2,String>, +signatures: List<&2,KDef>, +ready: KDef) -> List<&2,P113DCandidate>:
  match names:
    case Nil{}: []
    case Con{+name,+rest}:
      +definition = lookup(book,name)
      +info = lookup(signatures,name)
      nt_choose(List<&2,P113DCandidate>,String.eq(dk(definition),"Def") &&
        Bool.not(nc_native_def(definition) || nc_foreign(definition) || nb_contains(bangs,name)) && U32.is_le(nd_arity(book,name),32),
        u => nt_append(P113DCandidate,p121f_selected(book,name,signatures,p121f_plan(book,definition)),
          nt_choose(List<&2,P113DCandidate>,p128prep_flat_needed(info,ready),
            v => Con{p113pl_flat_candidate(book,name,signatures),p128prep_candidates(book,rest,bangs,signatures,ready)},
            v => p128prep_candidates(book,rest,bangs,signatures,ready))),
        u => p128prep_candidates(book,rest,bangs,signatures,ready))

@unsafe
def p128prep_inspect_prepared(+names: List<&2,String>, +ready: KDef, prepared: P112SPrepared) -> List<&2,P113DCandidate>:
  match prepared:
    case P112SPrepared{+book,nodes,+error}:
      nt_choose(List<&2,P113DCandidate>,String.is_empty(error),
        u => p128prep_candidates(book,names,nc_bangs_names(book,names),
          book_cached(nq_signatures(book,names),0),ready),
        u => p113d_diagnostic_error(error))

@unsafe
def p128prep_inspect_request(request: NR_Request, +ready: KDef) -> List<&2,P113DCandidate>:
  match request:
    case NR_Request{+source,+book,+names,paths,scope,+bound}:
      +error = nc_compile_error_known(source,bound)
      nt_choose(List<&2,P113DCandidate>,String.is_empty(error),
        u => p128prep_inspect_prepared(names,ready,p112s_prepare(book,names,nc_add_ctors(nc_default_ctors(),nc_constructors(source,source)))),
        u => p113d_diagnostic_error(error))

@unsafe
def p126bp_close(+request: NR_Request, original: P113AProgram, +added: List<&2,P113DFunction>) -> P111Emission:
  match original:
    case P113AProgram{P113DProgram{+static,+functions},+certificate}:
      +merged = nt_append(P113DFunction,added,p118b_without(functions,p113e_signatures(added,missing())))
      +ready = p113e_signatures(merged,missing())
      p126bp_complete(static,certificate,
        p113d_passes(p128prep_inspect_request(request,ready),ready,
          nt_reverse(P113DFunction,merged,[]),32))
