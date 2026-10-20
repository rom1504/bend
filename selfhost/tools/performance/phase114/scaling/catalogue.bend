# Restore the mature nf_plan_scoped catalogue representation: build one exact
# first-definition-wins index for the unchanged nq_signatures list. All
# candidate, shape, call and constructor queries still use ordinary lookup.
@unsafe
def p113pl_plan(+book: List<&2,KDef>, +names: List<&2,String>) -> List<&2,P113DFunction>:
  p113d_passes(p113pl_candidates(book,names,nc_bangs_names(book,names),
    book_cached(nq_signatures(book,names),0)),missing(),[],32)

# Keep diagnostic candidate discovery on the same catalogue representation.
@unsafe
def p113pl_inspect_prepared(+names: List<&2,String>, prepared: P112SPrepared) -> List<&2,P113DCandidate>:
  match prepared:
    case P112SPrepared{+book,nodes,+error}:
      nt_choose(List<&2,P113DCandidate>,String.is_empty(error),
        u => p113pl_candidates(book,names,nc_bangs_names(book,names),
          book_cached(nq_signatures(book,names),0)),
        u => p113d_diagnostic_error(error))
