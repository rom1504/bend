# The same prepared book/signature catalogue as p113pl_lower_request. Refused
# candidates remain diagnostic records and never enter emitted functions.
@unsafe
def p113pl_inspect_prepared(+names: List<&2,String>, prepared: P112SPrepared) -> List<&2,P113DCandidate>:
  match prepared:
    case P112SPrepared{+book,nodes,+error}:
      nt_choose(List<&2,P113DCandidate>,String.is_empty(error),
        u => p113pl_candidates(book,names,nc_bangs_names(book,names),nq_signatures(book,names)),
        u => p113d_diagnostic_error(error))

@unsafe
def p113pl_inspect_request(request: NR_Request) -> List<&2,P113DCandidate>:
  match request:
    case NR_Request{+source,+book,+names,paths,scope,+bound}:
      +error = nc_compile_error_known(source,bound)
      nt_choose(List<&2,P113DCandidate>,String.is_empty(error),
        u => p113pl_inspect_prepared(names,p112s_prepare(book,names,nc_add_ctors(nc_default_ctors(),nc_constructors(source,source)))),
        u => p113d_diagnostic_error(error))
