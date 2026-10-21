# Exact safe03 p114s_inline retained under an isolated alias.
@unsafe
def p120nr_original_inline(+boundary: P114SBoundary) -> P114SBoundary:
  match boundary:
    case P114SBoundary{original,ids,functions,valid}:
      nt_choose(P114SBoundary,valid,
        u => p114s_commit(boundary,p113i_functions(functions,P113IEmpty{},[])),
        u => boundary)
