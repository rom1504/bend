# Finite differential controls, not a proof of comparator equivalence.
# Depends only on typed-v01, the selected compiler p134v_* originals and
# Phase140 p140v_header/p140v_ctor (unchanged scalar definitions).

def p140tc_values() -> List<&2,N111Value>:
  [N111Local{"x"},N111Local{"y"},N111Const{0,0},N111Const{1,0},N111Const{0,1},N111Symbol{"x"},N111FuncId{"x"},N111CtorId{"x"}]

def p140tc_args() -> List<&2,N111Arg>:
  [N111Arg{N111U32{},N111Local{"x"}},N111Arg{N111U64{},N111Local{"x"}},N111Arg{N111Ptr{},N111Symbol{"x"}},N111Arg{N111U32{},N111Const{7,0}}]

def p140tc_bindings() -> List<&2,NC_Binding>:
  [NC_Binding{0,"a",N_W32{}},NC_Binding{0,"a",N_W64{}},NC_Binding{0,"a",N_Box{}},NC_Binding{0,"a",N_Imm64{}},NC_Binding{1,"a",N_W32{}},NC_Binding{0,"b",N_W32{}}]

def p140tc_scalars() -> List<&2,N111Stmt>:
  [N111Set{"x",N111U64{},N111Const{0,0}},
   N111Bin{"x",N111U32{},"eq",N111Local{"a"},N111Const{1,0}},
   N111Call{"x",N111U64{},"helper",p140tc_args()},
   N111If{N111Local{"c"},[N111Return{N111Const{1,0}}],[N111Return{N111Const{0,0}}]},
   N111Return{N111Const{0,0}},N111Load{"x",N111U64{},N111Local{"p"},8},
   N111Store{N111U64{},N111Local{"p"},8,N111Local{"x"}},
   N111Offset{"x",N111Local{"p"},N111Const{8,0}},N111Alloca{"p",16,8},
   N111If{N111Local{"c"},[N111If{N111Local{"d"},[N111Return{N111Const{1,0}}],[]}],[]},
   N111If{N111Local{"c"},[N111If{N111Local{"d"},[N111Return{N111Const{2,0}}],[]}],[]}]

def p140tc_stmts() -> List<&2,P113DStmt>:
  [P113DScalar{N111Return{N111Const{0,0}}},
   P113DIf{N111Local{"c"},[P113DResult{[N111Const{1,0}]}],[P113DResult{[N111Const{0,0}]}]},
   P113DCall{["x","y"],"helper",p140tc_values()},
   P113DResult{[N111Const{0,0}]},P113DAgain{[N111Local{"x"}]},
   P113DIf{N111Local{"c"},[P113DIf{N111Local{"d"},[P113DResult{[N111Const{1,0}]}],[]}],[]},
   P113DIf{N111Local{"c"},[P113DIf{N111Local{"d"},[P113DResult{[N111Const{2,0}]}],[]}],[]}]

def p140tc_functions() -> List<&2,P113DFunction>:
  [P113DFunction{"f",p140tc_bindings(),1,False{},p140tc_stmts()},
   P113DFunction{"f",p140tc_bindings(),1,True{},p140tc_stmts()},
   P113DFunction{"g",p140tc_bindings(),1,False{},p140tc_stmts()},
   P113DFunction{"f",p140tc_bindings(),2,False{},p140tc_stmts()},
   P113DFunction{"f",p140tc_bindings(),1,False{},[]}]

def p140tc_raw_headers() -> List<&2,N111Segment>:
  [N111Segment{"a",1,1,0,0,[]},N111Segment{"a",1,1,0,1,[]},
   N111Segment{"a",1,1,1,0,[]},N111Segment{"a",1,2,0,0,[]},
   N111Segment{"b",1,1,0,0,[]},N111Segment{"a",2,1,0,0,[]},
   N111Segment{"a",1,1,0,0,p140tc_scalars()}]

def p140tc_ctors() -> List<&2,N_Constructor>:
  [N_Constructor{"A",1,False{}},N_Constructor{"A",2,False{}},N_Constructor{"A",1,True{}},N_Constructor{"B",1,False{}}]

@unsafe
def p140tc_values_row(+a: N111Value, bs: List<&2,N111Value>) -> Bool:
  match bs:
    case Nil{}: True{}
    case Con{+b,rest}: p134v_bool(p134v_value(a,b),p140e_value(a,b)) && p140tc_values_row(a,rest)

@unsafe
def p140tc_values_matrix(as: List<&2,N111Value>, +bs: List<&2,N111Value>) -> Bool:
  match as:
    case Nil{}: True{}
    case Con{a,rest}: p140tc_values_row(a,bs) && p140tc_values_matrix(rest,bs)

@unsafe
def p140tc_args_row(+a: N111Arg, bs: List<&2,N111Arg>) -> Bool:
  match bs:
    case Nil{}: True{}
    case Con{+b,rest}: p134v_bool(p134v_arg(a,b),p140e_arg(a,b)) && p140tc_args_row(a,rest)

@unsafe
def p140tc_args_matrix(as: List<&2,N111Arg>, +bs: List<&2,N111Arg>) -> Bool:
  match as:
    case Nil{}: True{}
    case Con{a,rest}: p140tc_args_row(a,bs) && p140tc_args_matrix(rest,bs)

@unsafe
def p140tc_bindings_row(+a: NC_Binding, bs: List<&2,NC_Binding>) -> Bool:
  match bs:
    case Nil{}: True{}
    case Con{+b,rest}: p134v_bool(p134v_binding(a,b),p140e_binding(a,b)) && p140tc_bindings_row(a,rest)

@unsafe
def p140tc_bindings_matrix(as: List<&2,NC_Binding>, +bs: List<&2,NC_Binding>) -> Bool:
  match as:
    case Nil{}: True{}
    case Con{a,rest}: p140tc_bindings_row(a,bs) && p140tc_bindings_matrix(rest,bs)

@unsafe
def p140tc_scalars_row(+a: N111Stmt, bs: List<&2,N111Stmt>) -> Bool:
  match bs:
    case Nil{}: True{}
    case Con{+b,rest}: p134v_bool(p134v_scalar(a,b),p140e_scalar(a,b)) && p140tc_scalars_row(a,rest)

@unsafe
def p140tc_scalars_matrix(as: List<&2,N111Stmt>, +bs: List<&2,N111Stmt>) -> Bool:
  match as:
    case Nil{}: True{}
    case Con{a,rest}: p140tc_scalars_row(a,bs) && p140tc_scalars_matrix(rest,bs)

@unsafe
def p140tc_stmts_row(+a: P113DStmt, bs: List<&2,P113DStmt>) -> Bool:
  match bs:
    case Nil{}: True{}
    case Con{+b,rest}: p134v_bool(p134v_stmt(a,b),p140e_stmt(a,b)) && p140tc_stmts_row(a,rest)

@unsafe
def p140tc_stmts_matrix(as: List<&2,P113DStmt>, +bs: List<&2,P113DStmt>) -> Bool:
  match as:
    case Nil{}: True{}
    case Con{a,rest}: p140tc_stmts_row(a,bs) && p140tc_stmts_matrix(rest,bs)

@unsafe
def p140tc_functions_row(+a: P113DFunction, bs: List<&2,P113DFunction>) -> Bool:
  match bs:
    case Nil{}: True{}
    case Con{+b,rest}: p134v_bool(p134v_function(a,b),p140e_function(a,b)) && p140tc_functions_row(a,rest)

@unsafe
def p140tc_functions_matrix(as: List<&2,P113DFunction>, +bs: List<&2,P113DFunction>) -> Bool:
  match as:
    case Nil{}: True{}
    case Con{a,rest}: p140tc_functions_row(a,bs) && p140tc_functions_matrix(rest,bs)

@unsafe
def p140tc_headers_row(+a: P113DFunction, bs: List<&2,P113DFunction>) -> Bool:
  match bs:
    case Nil{}: True{}
    case Con{+b,rest}: p134v_bool(p134v_header(a,b),p140e_header(a,b)) && p140tc_headers_row(a,rest)

@unsafe
def p140tc_headers_matrix(as: List<&2,P113DFunction>, +bs: List<&2,P113DFunction>) -> Bool:
  match as:
    case Nil{}: True{}
    case Con{a,rest}: p140tc_headers_row(a,bs) && p140tc_headers_matrix(rest,bs)

@unsafe
def p140tc_raw_headers_row(+a: N111Segment, bs: List<&2,N111Segment>) -> Bool:
  match bs:
    case Nil{}: True{}
    case Con{+b,rest}: p134v_bool(p140v_header(a,b),p140e_raw_header(a,b)) && p140tc_raw_headers_row(a,rest)

@unsafe
def p140tc_raw_headers_matrix(as: List<&2,N111Segment>, +bs: List<&2,N111Segment>) -> Bool:
  match as:
    case Nil{}: True{}
    case Con{a,rest}: p140tc_raw_headers_row(a,bs) && p140tc_raw_headers_matrix(rest,bs)

@unsafe
def p140tc_ctors_row(+a: N_Constructor, bs: List<&2,N_Constructor>) -> Bool:
  match bs:
    case Nil{}: True{}
    case Con{+b,rest}: p134v_bool(p140v_ctor(a,b),p140e_ctor(a,b)) && p140tc_ctors_row(a,rest)

@unsafe
def p140tc_ctors_matrix(as: List<&2,N_Constructor>, +bs: List<&2,N_Constructor>) -> Bool:
  match as:
    case Nil{}: True{}
    case Con{a,rest}: p140tc_ctors_row(a,bs) && p140tc_ctors_matrix(rest,bs)

@unsafe
def p140tc_controls() -> List<&2,String>:
  [p128bs_control_row("typed-values-all-pairs",p140tc_values_matrix(p140tc_values(),p140tc_values())),
   p128bs_control_row("typed-args-all-pairs",p140tc_args_matrix(p140tc_args(),p140tc_args())),
   p128bs_control_row("typed-bindings-all-pairs",p140tc_bindings_matrix(p140tc_bindings(),p140tc_bindings())),
   p128bs_control_row("typed-scalars-all-pairs",p140tc_scalars_matrix(p140tc_scalars(),p140tc_scalars())),
   p128bs_control_row("typed-stmts-all-pairs",p140tc_stmts_matrix(p140tc_stmts(),p140tc_stmts())),
   p128bs_control_row("typed-functions-all-pairs",p140tc_functions_matrix(p140tc_functions(),p140tc_functions())),
   p128bs_control_row("typed-headers-all-pairs",p140tc_headers_matrix(p140tc_functions(),p140tc_functions())),
   p128bs_control_row("typed-raw_headers-all-pairs",p140tc_raw_headers_matrix(p140tc_raw_headers(),p140tc_raw_headers())),
   p128bs_control_row("typed-ctors-all-pairs",p140tc_ctors_matrix(p140tc_ctors(),p140tc_ctors())),
   p128bs_control_row("typed-values-list",p134v_bool(p134v_list(N111Value,p134v_value,p140tc_values(),p140tc_values()),p140e_values(p140tc_values(),p140tc_values())) && Bool.not(p140e_values([],p140tc_values())) && Bool.not(p140e_values(p140tc_values(),[])) && p140e_values([],[])),
   p128bs_control_row("typed-args-list",p134v_bool(p134v_list(N111Arg,p134v_arg,p140tc_args(),p140tc_args()),p140e_args(p140tc_args(),p140tc_args())) && Bool.not(p140e_args([],p140tc_args())) && Bool.not(p140e_args(p140tc_args(),[])) && p140e_args([],[])),
   p128bs_control_row("typed-bindings-list",p134v_bool(p134v_list(NC_Binding,p134v_binding,p140tc_bindings(),p140tc_bindings()),p140e_bindings(p140tc_bindings(),p140tc_bindings())) && Bool.not(p140e_bindings([],p140tc_bindings())) && Bool.not(p140e_bindings(p140tc_bindings(),[])) && p140e_bindings([],[])),
   p128bs_control_row("typed-scalars-list",p134v_bool(p134v_list(N111Stmt,p134v_scalar,p140tc_scalars(),p140tc_scalars()),p140e_scalars(p140tc_scalars(),p140tc_scalars())) && Bool.not(p140e_scalars([],p140tc_scalars())) && Bool.not(p140e_scalars(p140tc_scalars(),[])) && p140e_scalars([],[])),
   p128bs_control_row("typed-stmts-list",p134v_bool(p134v_list(P113DStmt,p134v_stmt,p140tc_stmts(),p140tc_stmts()),p140e_stmts(p140tc_stmts(),p140tc_stmts())) && Bool.not(p140e_stmts([],p140tc_stmts())) && Bool.not(p140e_stmts(p140tc_stmts(),[])) && p140e_stmts([],[])),
   p128bs_control_row("typed-headers-list",p134v_bool(p134v_list(P113DFunction,p134v_header,p140tc_functions(),p140tc_functions()),p140e_headers(p140tc_functions(),p140tc_functions())) && Bool.not(p140e_headers([],p140tc_functions())) && Bool.not(p140e_headers(p140tc_functions(),[])) && p140e_headers([],[])),
   p128bs_control_row("typed-raw_headers-list",p134v_bool(p134v_list(N111Segment,p140v_header,p140tc_raw_headers(),p140tc_raw_headers()),p140e_raw_headers(p140tc_raw_headers(),p140tc_raw_headers())) && Bool.not(p140e_raw_headers([],p140tc_raw_headers())) && Bool.not(p140e_raw_headers(p140tc_raw_headers(),[])) && p140e_raw_headers([],[])),
   p128bs_control_row("typed-ctors-list",p134v_bool(p134v_list(N_Constructor,p140v_ctor,p140tc_ctors(),p140tc_ctors()),p140e_ctors(p140tc_ctors(),p140tc_ctors())) && Bool.not(p140e_ctors([],p140tc_ctors())) && Bool.not(p140e_ctors(p140tc_ctors(),[])) && p140e_ctors([],[])),
   p128bs_control_row("typed-strings-list",p140e_strings(["a","b"],["a","b"]) && Bool.not(p140e_strings(["a","b"],["a","c"])) && Bool.not(p140e_strings(["a"],[])) && p140e_strings([],[])),
   p128bs_control_row("typed-u32-list",p140e_u32s([0,1,4294967295],[0,1,4294967295]) && Bool.not(p140e_u32s([0,1],[0,2])) && Bool.not(p140e_u32s([],[0])) && p140e_u32s([],[]))]
