# The ten complete Phase140 typed list traversals share p141st_list.
# These new names preserve the original typed helpers as differential oracles.
# Production replacement would replace their bodies, not retain both families.
@unsafe
def p141st_strings(a: List<&2,String>, b: List<&2,String>) -> Bool:
  p141st_list(~String,~String.eq,a,b)

@unsafe
def p141st_u32s(a: List<&2,U32>, b: List<&2,U32>) -> Bool:
  p141st_list(~U32,~U32.is_eq,a,b)

@unsafe
def p141st_args(a: List<&2,N111Arg>, b: List<&2,N111Arg>) -> Bool:
  p141st_list(~N111Arg,~p140e_arg,a,b)

@unsafe
def p141st_scalars(a: List<&2,N111Stmt>, b: List<&2,N111Stmt>) -> Bool:
  p141st_list(~N111Stmt,~p140e_scalar,a,b)

@unsafe
def p141st_stmts(a: List<&2,P113DStmt>, b: List<&2,P113DStmt>) -> Bool:
  p141st_list(~P113DStmt,~p140e_stmt,a,b)

@unsafe
def p141st_values(a: List<&2,N111Value>, b: List<&2,N111Value>) -> Bool:
  p141st_list(~N111Value,~p140e_value,a,b)

@unsafe
def p141st_bindings(a: List<&2,NC_Binding>, b: List<&2,NC_Binding>) -> Bool:
  p141st_list(~NC_Binding,~p140e_binding,a,b)

@unsafe
def p141st_headers(a: List<&2,P113DFunction>, b: List<&2,P113DFunction>) -> Bool:
  p141st_list(~P113DFunction,~p140e_header,a,b)

@unsafe
def p141st_raw_headers(a: List<&2,N111Segment>, b: List<&2,N111Segment>) -> Bool:
  p141st_list(~N111Segment,~p140e_raw_header,a,b)

@unsafe
def p141st_ctors(a: List<&2,N_Constructor>, b: List<&2,N_Constructor>) -> Bool:
  p141st_list(~N_Constructor,~p140e_ctor,a,b)
