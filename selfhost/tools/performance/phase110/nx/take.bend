# Optional pair-take ablation. The reconstruction-only pair transform stays
# unchanged. The generic adjacent take2/field0/field1 protocol becomes an
# atomic two-result statement, then restores the scalar status result (zero).
def nx110_take_import() -> Nx110ImportPair:
  Nx110ImportPair{"rt_pair_take2",[NxParam{"ctx",NxPtr{}},NxParam{"parent",NxU64{}}],NxU64{},NxU64{}}

@unsafe
def nx110_take_stmt(+stmt: Nx110Stmt) -> Nx110Stmt:
  match stmt:
    case Nx110If{condition,yes,no}: Nx110If{condition,nx110_take_body(yes),nx110_take_body(no)}
    case Nx110While{condition,body}: Nx110While{condition,nx110_take_body(body)}
    case _: stmt

@unsafe
def nx110_take_fallback(+body: List<&2,Nx110Stmt>) -> List<&2,Nx110Stmt>:
  match body:
    case Nil{}: []
    case Con{head,rest}: Con{nx110_take_stmt(head),nx110_take_body(rest)}

@unsafe
def nx110_take_body(+body: List<&2,Nx110Stmt>) -> List<&2,Nx110Stmt>:
  match body:
    case Con{Nx110Scalar{NxSet{status,NxCall{take,Con{NxVar{ctx},Con{NxVar{parent},Nil{}}}}}},Con{Nx110Scalar{NxSet{first,NxCall{field0,Con{NxVar{ctx0},Con{NxConst{NxU32{},index0},Nil{}}}}}},Con{Nx110Scalar{NxSet{second,NxCall{field1,Con{NxVar{ctx1},Con{NxConst{NxU32{},index1},Nil{}}}}}},rest}}}:
      nx_choose(List<&2,Nx110Stmt>,String.eq(take,"rt_fast_take2") && String.eq(field0,"rt_fast_field") && String.eq(field1,"rt_fast_field") &&
        String.eq(ctx,ctx0) && String.eq(ctx,ctx1) && U32.is_eq(index0,0) && U32.is_eq(index1,1) && Bool.not(String.eq(first,second)),
        u => Con{Nx110CallPair{first,second,"rt_pair_take2",[NxVar{ctx},NxVar{parent}]},Con{Nx110Scalar{NxSet{status,NxConst{NxU32{},0}}},nx110_take_body(rest)}},
        u => nx110_take_fallback(body))
    case _: nx110_take_fallback(body)

@unsafe
def nx110_take_functions(+functions: List<&2,Nx110Function>) -> List<&2,Nx110Function>:
  match functions:
    case Nil{}: []
    case Con{Nx110Function{name,params,result,locals,body},rest}:
      Con{Nx110Function{name,params,result,locals,nx110_take_body(body)},nx110_take_functions(rest)}

@unsafe
def nx110_take_upgrade(+library: Nx110Library) -> Nx110Library:
  match library:
    case Nx110Library{imports,pairs,functions,exports}:
      Nx110Library{imports,Con{nx110_take_import(),pairs},nx110_take_functions(functions),exports}

@unsafe
def nx110_take_pair_library(+library: NxLibrary) -> Nx110Library:
  nx110_take_upgrade(nx110_pair_library(library))

def nx110_take_control_start() -> Nx110Stmt:
  Nx110Scalar{NxSet{"status",NxCall{"rt_fast_take2",[NxVar{"ctx"},NxVar{"term"}]}}}

def nx110_take_control_field(context: String, index: U32, dest: String) -> Nx110Stmt:
  Nx110Scalar{nx110_control_field(context,index,dest)}

@unsafe
def nx110_take_control(name: String, body: List<&2,Nx110Stmt>, expected: U32) -> String:
  nxlib_control_result(name,U32.is_eq(nx110_pair_count(nx110_take_body(body)),expected))

@unsafe
def nx110_take_control_status(+body: List<&2,Nx110Stmt>) -> Bool:
  match body:
    case Con{Nx110CallPair{first,second,name,args},Con{Nx110Scalar{NxSet{status,NxConst{NxU32{},zero}}},Nil{}}}:
      String.eq(status,"status") && U32.is_eq(zero,0)
    case _: False{}

@unsafe
def nx110_take_control_report() -> String:
  +body : List<&2,Nx110Stmt> = [nx110_take_control_start(),nx110_take_control_field("ctx",0,"first"),nx110_take_control_field("ctx",1,"second")]
  nx110_take_control("pair-take-adjacent",body,1) ++
  nx110_take_control("pair-take-exact-first-index",[nx110_take_control_start(),nx110_take_control_field("ctx",1,"first"),nx110_take_control_field("ctx",1,"second")],0) ++
  nx110_take_control("pair-take-exact-second-index",[nx110_take_control_start(),nx110_take_control_field("ctx",0,"first"),nx110_take_control_field("ctx",0,"second")],0) ++
  nx110_take_control("pair-take-first-context",[nx110_take_control_start(),nx110_take_control_field("other_ctx",0,"first"),nx110_take_control_field("ctx",1,"second")],0) ++
  nx110_take_control("pair-take-second-context",[nx110_take_control_start(),nx110_take_control_field("ctx",0,"first"),nx110_take_control_field("other_ctx",1,"second")],0) ++
  nx110_take_control("pair-take-distinct-outputs",[nx110_take_control_start(),nx110_take_control_field("ctx",0,"first"),nx110_take_control_field("ctx",1,"first")],0) ++
  nx110_take_control("pair-take-no-effect-crossing",[nx110_take_control_start(),nx110_take_control_field("ctx",0,"first"),Nx110Scalar{NxSet{"status",NxCall{"rt_fast_sink",[NxVar{"ctx"},NxVar{"term"}]}}},nx110_take_control_field("ctx",1,"second")],0) ++
  nxlib_control_result("pair-take-status-zero",nx110_take_control_status(nx110_take_body(body))) ++
  nxlib_control_result("pair-take-typed-graph",nx110_verify(nx110_control_library([nx110_take_import()],nxo_join(Nx110Stmt,nx110_take_body(body),[Nx110Scalar{NxReturn{NxVar{"first"}}}]))))

def nx110_alias_source(body: List<&2,NxStmt>) -> NxLibrary:
  NxLibrary{nxlib_runtime110_imports_policy("specialized"),
    [NxFunction{"worker",[NxParam{"ctx",NxPtr{}},NxParam{"term",NxU64{}}],NxU64{},
      [NxParam{"first",NxU64{}},NxParam{"second",NxU64{}},NxParam{"status",NxU32{}}],body}],["worker"]}

@unsafe
def nx110_alias_control_report() -> String:
  nxlib_control_result("pair-first-cannot-overwrite-context",Bool.not(nx110_verify(nx110_control_library([nx110_pair_import("pair")],nx110_control_pair("ctx","second","pair",nx110_control_args()))))) ++
  nxlib_control_result("pair-second-cannot-overwrite-context",Bool.not(nx110_verify(nx110_control_library([nx110_pair_import("pair")],nx110_control_pair("first","ctx","pair",nx110_control_args()))))) ++
  nxlib_control_result("pair-may-overwrite-evaluated-input",nx110_verify(nx110_control_library([nx110_pair_import("pair")],nx110_control_pair("term","second","pair",nx110_control_args())))) ++
  nxlib_control_result("rebuild-upgrade-rejects-context-alias",Bool.not(nx110_verify(nx110_pair_library(nx110_alias_source([
    NxSet{"ctx",NxCall{"rt_rebuild2_c1_k0",nx110_control_args()}},nx110_control_field("ctx",0,"second"),NxReturn{NxVar{"term"}}]))))) ++
  nxlib_control_result("take-upgrade-rejects-context-alias",Bool.not(nx110_verify(nx110_take_pair_library(nx110_alias_source([
    NxSet{"status",NxCall{"rt_fast_take2",[NxVar{"ctx"},NxVar{"term"}]}},nx110_control_field("ctx",0,"ctx"),nx110_control_field("ctx",1,"second"),NxReturn{NxVar{"term"}}]))))) ++
  nxlib_control_result("take-upgrade-rejects-status-child-alias",Bool.not(nx110_verify(nx110_take_pair_library(nx110_alias_source([
    NxSet{"first",NxCall{"rt_fast_take2",[NxVar{"ctx"},NxVar{"term"}]}},nx110_control_field("ctx",0,"first"),nx110_control_field("ctx",1,"second"),NxReturn{NxVar{"first"}}])))))
