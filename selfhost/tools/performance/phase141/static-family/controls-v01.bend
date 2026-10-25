# All finite fixtures are distinct under full equality. Header comparisons
# additionally equate fixture0 with fixture4 (direct) or fixture6 (raw), because
# those fixtures differ only in their ignored body. No comparator is used to
# manufacture this expected truth table. Preserve the 19 historical row names.
def p141sf_expected(+row: U32, +column: U32, +alias: U32) -> Bool:
  U32.is_eq(row,column) || (U32.is_gt(alias,0) &&
    ((U32.is_eq(row,0) && U32.is_eq(column,alias)) ||
     (U32.is_eq(column,0) && U32.is_eq(row,alias))))

@unsafe
def p141sf_row(~A: Data, ~same: A -> A -> Bool, +a: A, bs: List<&2,A>, +row: U32, +column: U32, +alias: U32) -> Bool:
  match bs:
    case Nil{}: True{}
    case Con{b,rest}: p134v_bool(same(a,b),p141sf_expected(row,column,alias)) && p141sf_row(~A,~same,a,rest,row,U32.inc(column),alias)

@unsafe
def p141sf_matrix(~A: Data, ~same: A -> A -> Bool, as: List<&2,A>, +bs: List<&2,A>, +row: U32, +alias: U32) -> Bool:
  match as:
    case Nil{}: True{}
    case Con{a,rest}: p141sf_row(~A,~same,a,bs,row,0,alias) && p141sf_matrix(~A,~same,rest,bs,U32.inc(row),alias)

@unsafe
def p140tc_controls() -> List<&2,String>:
  [p128bs_control_row("typed-values-all-pairs",p141sf_matrix(~N111Value,~p134v_value,p140tc_values(),p140tc_values(),0,0)),
   p128bs_control_row("typed-args-all-pairs",p141sf_matrix(~N111Arg,~p134v_arg,p140tc_args(),p140tc_args(),0,0)),
   p128bs_control_row("typed-bindings-all-pairs",p141sf_matrix(~NC_Binding,~p134v_binding,p140tc_bindings(),p140tc_bindings(),0,0)),
   p128bs_control_row("typed-scalars-all-pairs",p141sf_matrix(~N111Stmt,~p134v_scalar,p140tc_scalars(),p140tc_scalars(),0,0)),
   p128bs_control_row("typed-stmts-all-pairs",p141sf_matrix(~P113DStmt,~p134v_stmt,p140tc_stmts(),p140tc_stmts(),0,0)),
   p128bs_control_row("typed-functions-all-pairs",p141sf_matrix(~P113DFunction,~p134v_function,p140tc_functions(),p140tc_functions(),0,0)),
   p128bs_control_row("typed-headers-all-pairs",p141sf_matrix(~P113DFunction,~p134v_header,p140tc_functions(),p140tc_functions(),0,4)),
   p128bs_control_row("typed-raw_headers-all-pairs",p141sf_matrix(~N111Segment,~p140v_header,p140tc_raw_headers(),p140tc_raw_headers(),0,6)),
   p128bs_control_row("typed-ctors-all-pairs",p141sf_matrix(~N_Constructor,~p140v_ctor,p140tc_ctors(),p140tc_ctors(),0,0)),
   p128bs_control_row("typed-values-list",p134v_list(~N111Value,~p134v_value,p140tc_values(),p140tc_values()) && Bool.not(p134v_list(~N111Value,~p134v_value,[],p140tc_values())) && Bool.not(p134v_list(~N111Value,~p134v_value,p140tc_values(),[])) && p134v_list(~N111Value,~p134v_value,[],[])),
   p128bs_control_row("typed-args-list",p134v_list(~N111Arg,~p134v_arg,p140tc_args(),p140tc_args()) && Bool.not(p134v_list(~N111Arg,~p134v_arg,[],p140tc_args())) && Bool.not(p134v_list(~N111Arg,~p134v_arg,p140tc_args(),[])) && p134v_list(~N111Arg,~p134v_arg,[],[])),
   p128bs_control_row("typed-bindings-list",p134v_list(~NC_Binding,~p134v_binding,p140tc_bindings(),p140tc_bindings()) && Bool.not(p134v_list(~NC_Binding,~p134v_binding,[],p140tc_bindings())) && Bool.not(p134v_list(~NC_Binding,~p134v_binding,p140tc_bindings(),[])) && p134v_list(~NC_Binding,~p134v_binding,[],[])),
   p128bs_control_row("typed-scalars-list",p134v_list(~N111Stmt,~p134v_scalar,p140tc_scalars(),p140tc_scalars()) && Bool.not(p134v_list(~N111Stmt,~p134v_scalar,[],p140tc_scalars())) && Bool.not(p134v_list(~N111Stmt,~p134v_scalar,p140tc_scalars(),[])) && p134v_list(~N111Stmt,~p134v_scalar,[],[])),
   p128bs_control_row("typed-stmts-list",p134v_list(~P113DStmt,~p134v_stmt,p140tc_stmts(),p140tc_stmts()) && Bool.not(p134v_list(~P113DStmt,~p134v_stmt,[],p140tc_stmts())) && Bool.not(p134v_list(~P113DStmt,~p134v_stmt,p140tc_stmts(),[])) && p134v_list(~P113DStmt,~p134v_stmt,[],[])),
   p128bs_control_row("typed-headers-list",p134v_list(~P113DFunction,~p134v_header,p140tc_functions(),p140tc_functions()) && Bool.not(p134v_list(~P113DFunction,~p134v_header,[],p140tc_functions())) && Bool.not(p134v_list(~P113DFunction,~p134v_header,p140tc_functions(),[])) && p134v_list(~P113DFunction,~p134v_header,[],[])),
   p128bs_control_row("typed-raw_headers-list",p134v_list(~N111Segment,~p140v_header,p140tc_raw_headers(),p140tc_raw_headers()) && Bool.not(p134v_list(~N111Segment,~p140v_header,[],p140tc_raw_headers())) && Bool.not(p134v_list(~N111Segment,~p140v_header,p140tc_raw_headers(),[])) && p134v_list(~N111Segment,~p140v_header,[],[])),
   p128bs_control_row("typed-ctors-list",p134v_list(~N_Constructor,~p140v_ctor,p140tc_ctors(),p140tc_ctors()) && Bool.not(p134v_list(~N_Constructor,~p140v_ctor,[],p140tc_ctors())) && Bool.not(p134v_list(~N_Constructor,~p140v_ctor,p140tc_ctors(),[])) && p134v_list(~N_Constructor,~p140v_ctor,[],[])),
   p128bs_control_row("typed-strings-list",p134v_list(~String,~String.eq,["a","b"],["a","b"]) && Bool.not(p134v_list(~String,~String.eq,["a","b"],["a","c"])) && Bool.not(p134v_list(~String,~String.eq,["a"],[])) && p134v_list(~String,~String.eq,[],[])),
   p128bs_control_row("typed-u32-list",p134v_list(~U32,~U32.is_eq,[0,1,4294967295],[0,1,4294967295]) && Bool.not(p134v_list(~U32,~U32.is_eq,[0,1],[0,2])) && Bool.not(p134v_list(~U32,~U32.is_eq,[],[0])) && p134v_list(~U32,~U32.is_eq,[],[]))]
