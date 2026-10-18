# Experimental ABI specialization of an already admitted ownership library.
# Only the adjacent specialized rebuild; field(ctx,0) protocol is replaced.
# No effects are crossed, no source names are inspected, and unmatched scalar
# code keeps its original graph. The checked ownership graph remains separate.
def nx110_pair_source(+name: String) -> Bool:
  String.eq(name,"rt_rebuild2_c1_k0") || String.eq(name,"rt_rebuild2_c1_k1") ||
  String.eq(name,"rt_rebuild2_c3_k0") || String.eq(name,"rt_rebuild2_c3_k1")

def nx110_pair_name(+name: String) -> String:
  nx_choose(String,String.eq(name,"rt_rebuild2_c1_k0"),u => "rt_pair_rebuild2_c1_k0",u =>
  nx_choose(String,String.eq(name,"rt_rebuild2_c1_k1"),u => "rt_pair_rebuild2_c1_k1",u =>
  nx_choose(String,String.eq(name,"rt_rebuild2_c3_k0"),u => "rt_pair_rebuild2_c3_k0",u => "rt_pair_rebuild2_c3_k1")))

def nx110_pair_import(+name: String) -> Nx110ImportPair:
  Nx110ImportPair{name,[NxParam{"ctx",NxPtr{}},NxParam{"parent",NxU64{}},NxParam{"other",NxU64{}}],NxU64{},NxU64{}}

def nx110_runtime_pairs() -> List<&2,Nx110ImportPair>:
  [nx110_pair_import("rt_pair_rebuild2_c1_k0"),nx110_pair_import("rt_pair_rebuild2_c1_k1"),
   nx110_pair_import("rt_pair_rebuild2_c3_k0"),nx110_pair_import("rt_pair_rebuild2_c3_k1")]

@unsafe
def nx110_pair_stmt(+stmt: NxStmt) -> Nx110Stmt:
  match stmt:
    case NxIf{condition,yes,no}: Nx110If{condition,nx110_pair_body(yes),nx110_pair_body(no)}
    case NxWhile{condition,body}: Nx110While{condition,nx110_pair_body(body)}
    case _: Nx110Scalar{stmt}

@unsafe
def nx110_pair_body(+body: List<&2,NxStmt>) -> List<&2,Nx110Stmt>:
  match body:
    case Con{NxSet{first,NxCall{name,Con{NxVar{ctx},Con{NxVar{parent},Con{NxVar{other},Nil{}}}}}},Con{NxSet{second,NxCall{field,Con{NxVar{ctx2},Con{NxConst{NxU32{},index},Nil{}}}}},rest}}:
      nx_choose(List<&2,Nx110Stmt>,nx110_pair_source(name) && String.eq(field,"rt_fast_field") && String.eq(ctx,ctx2) && U32.is_eq(index,0) && Bool.not(String.eq(first,second)),
        u => Con{Nx110CallPair{first,second,nx110_pair_name(name),[NxVar{ctx},NxVar{parent},NxVar{other}]},nx110_pair_body(rest)},
        u => nx110_pair_fallback(body))
    case _: nx110_pair_fallback(body)

@unsafe
def nx110_pair_fallback(+body: List<&2,NxStmt>) -> List<&2,Nx110Stmt>:
  match body:
    case Nil{}: []
    case Con{head,rest}: Con{nx110_pair_stmt(head),nx110_pair_body(rest)}

@unsafe
def nx110_pair_functions(+functions: List<&2,NxFunction>) -> List<&2,Nx110Function>:
  match functions:
    case Nil{}: []
    case Con{NxFunction{name,params,result,locals,body},rest}:
      Con{Nx110Function{name,params,result,locals,nx110_pair_body(body)},nx110_pair_functions(rest)}

@unsafe
def nx110_pair_library(+library: NxLibrary) -> Nx110Library:
  match library:
    case NxLibrary{imports,functions,exports}:
      nx_choose(Nx110Library,nxlib_verify(library),
        u => Nx110Library{imports,nx110_runtime_pairs(),nx110_pair_functions(functions),exports},
        u => Nx110Library{[],[],[],[]})
