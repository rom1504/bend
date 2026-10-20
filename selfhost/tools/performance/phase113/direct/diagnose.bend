# Untimed transport diagnostics use the same checked/static preparation as the
# production lowerer. A diagnostic sentinel is never an emitted worker.
def p113d_diagnostic_error(error: String) -> List<&2,P113DCandidate>:
  [P113DCandidate{P113DFunction{"$p113.diagnostic",[],1,False{},[]},error,[]}]

@unsafe
def p113d_inspect_prepared(+names: List<&2,String>, prepared: P112SPrepared) -> List<&2,P113DCandidate>:
  match prepared:
    case P112SPrepared{+book,nodes,+error}:
      nt_choose(List<&2,P113DCandidate>,String.is_empty(error),
        u => p113d_candidates(book,names,nc_bangs_names(book,names)),
        u => p113d_diagnostic_error(error))

@unsafe
def p113d_inspect_request(request: NR_Request) -> List<&2,P113DCandidate>:
  match request:
    case NR_Request{+source,+book,+names,paths,scope,+bound}:
      +error = nc_compile_error_known(source,bound)
      nt_choose(List<&2,P113DCandidate>,String.is_empty(error),
        u => p113d_inspect_prepared(names,p112s_prepare(book,names,nc_add_ctors(nc_default_ctors(),nc_constructors(source,source)))),
        u => p113d_diagnostic_error(error))
