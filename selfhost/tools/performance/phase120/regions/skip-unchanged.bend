# Compile-cost shortcut only. A copied body still uses the original stack
# guard, cleanup and full-library commit. No-rewrite returns the original.
@unsafe
def p120nr_function_scanned(+function: P113DFunction, scan: P113IScan) -> P113DFunction:
  match function scan:
    case _ P113IScan{body,0,budget}: function
    case P113DFunction{name,params,result,public,old} P113IScan{body,next,budget}:
      p113i_function_done(function,name,params,result,public,P113IScan{body,next,budget})

@unsafe
def p120nr_function(+function: P113DFunction, +table: P113ITable) -> P113DFunction:
  match function:
    case P113DFunction{+name,+params,+result,+public,+body}:
      nt_choose(P113DFunction,p120nr_params(params) && p120nr_clean(body) && U32.is_le(p113i_size(body),4096),
        u => p120nr_function_scanned(function,p120nr_scan(body,table,0,1024)),u => function)

@unsafe
def p120nr_boundary_table(+boundary: P114SBoundary, +table: P113ITable) -> P114SBoundary:
  match boundary table:
    case _ P113IEmpty{}: boundary
    case P114SBoundary{original,ids,functions,valid} _:
      p114s_commit(boundary,p120nr_functions(functions,table,[]))

@unsafe
def p120nr_boundary(+boundary: P114SBoundary) -> P114SBoundary:
  match boundary:
    case P114SBoundary{original,ids,+functions,valid}:
      nt_choose(P114SBoundary,valid,
        u => p120nr_boundary_table(boundary,p120nr_table(functions,P113IEmpty{})),u => boundary)
