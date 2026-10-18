@unsafe
def nx110ctx_control_source() -> Nx110RtLibrary:
  Nx110RtLibrary{
    [nx110rt_call_control_worker("identity",1,0,[NxoReturn{"p0"}]),
     nx110rt_call_control_worker("caller",1,1,[NxoCall{"v0","identity",["p0"]},NxoReturn{"v0"}])],
    ["caller"]}

@unsafe
def nx110ctx_control_expr(+expr: NxExpr, +fault: String) -> NxExpr:
  match expr:
    case NxCall{name,args}:
      nx_choose(NxExpr,String.eq(fault,"runtime") && String.eq(name,"rt_ir_heap"),u => NxCall{"ctx110_rt_ir_heap",args},u =>
      nx_choose(NxExpr,String.eq(name,"ctx110_identity") && String.eq(fault,"pointers"),u =>
        NxCall{name,[NxVar{"ctx"},NxVar{"ir_alc"},NxVar{"ir_heap"},NxVar{"p0"}]},u =>
      nx_choose(NxExpr,String.eq(name,"ctx110_identity") && String.eq(fault,"missing"),u =>
        NxCall{name,[NxVar{"ctx"},NxVar{"ir_heap"},NxVar{"p0"}]},u =>
      nx_choose(NxExpr,String.eq(name,"rt_ir_heap") && String.eq(fault,"getter"),u => NxVar{"ctx"},u => expr))))
    case NxLoad{typ,ptr,offset}:
      nx_choose(NxExpr,String.eq(fault,"offset"),u => NxLoad{typ,ptr,16},u => expr)
    case _: expr

@unsafe
def nx110ctx_control_stmts(+body: List<&2,NxStmt>, +fault: String) -> List<&2,NxStmt>:
  match body:
    case Nil{}: []
    case Con{head,rest}: Con{nx110ctx_control_stmt(head,fault),nx110ctx_control_stmts(rest,fault)}

@unsafe
def nx110ctx_control_stmt(+stmt: NxStmt, +fault: String) -> NxStmt:
  match stmt:
    case NxSet{name,value}: NxSet{name,nx110ctx_control_expr(value,fault)}
    case NxIf{condition,yes,no}: NxIf{condition,nx110ctx_control_stmts(yes,fault),nx110ctx_control_stmts(no,fault)}
    case NxWhile{condition,body}: NxWhile{condition,nx110ctx_control_stmts(body,fault)}
    case _: stmt

@unsafe
def nx110ctx_control_functions(+functions: List<&2,NxFunction>, +fault: String) -> List<&2,NxFunction>:
  match functions:
    case Nil{}: []
    case Con{NxFunction{name,params,result,locals,body},rest}:
      Con{NxFunction{name,params,result,locals,nx110ctx_control_stmts(body,fault)},nx110ctx_control_functions(rest,fault)}

@unsafe
def nx110ctx_control_bad(+library: Nx110CtxLibrary, +fault: String) -> Nx110CtxLibrary:
  match library:
    case Nx110CtxLibrary{source,mode,NxLibrary{imports,functions,exports}}:
      Nx110CtxLibrary{source,mode,NxLibrary{imports,nx110ctx_control_functions(functions,fault),
        nx_choose(List<&2,String>,String.eq(fault,"export"),u => ["ctx110_caller"],u => exports)}}

def nx110ctx_control_machine(library: Nx110CtxLibrary) -> NxLibrary:
  match library:
    case Nx110CtxLibrary{source,mode,machine}: machine

@unsafe
def nx110ctx_control_body(+name: String, +functions: List<&2,NxFunction>) -> List<&2,NxStmt>:
  match functions:
    case Nil{}: []
    case Con{NxFunction{symbol,params,result,locals,body},rest}:
      nx_choose(List<&2,NxStmt>,String.eq(name,symbol),u => body,u => nx110ctx_control_body(name,rest))

@unsafe
def nx110ctx_control_calls(+library: Nx110CtxLibrary, +name: String, +callee: String) -> U32:
  match library:
    case Nx110CtxLibrary{source,mode,NxLibrary{imports,functions,exports}}:
      nxo_p_calls(nx110ctx_control_body(name,functions),callee)

@unsafe
def nx110ctx_control_report() -> String:
  +threaded = nx110ctx_prepare(nx110ctx_control_source(),"threaded")
  +context = nx110ctx_prepare(nx110ctx_control_source(),"context")
  +recursive : Nx110RtLibrary = Nx110RtLibrary{[nx110rt_call_control_worker("recursive",1,1,
    [NxoBranch{"p0",0,[NxoReturn{"p0"}],[NxoCall{"v0","recursive",["p0"]},NxoReturn{"v0"}]}])],["recursive"]}
  +collision : Nx110RtLibrary = Nx110RtLibrary{[nx110rt_call_control_worker("identity",1,0,[NxoReturn{"p0"}]),
    nx110rt_call_control_worker("ctx110_identity",1,0,[NxoReturn{"p0"}])],["ctx110_identity"]}
  nxlib_control_result("context-threaded-closed-call",nx110ctx_verify(threaded)) ++
  nxlib_control_result("context-direct-load-closed-call",nx110ctx_verify(context)) ++
  nxlib_control_result("context-threaded-ordinary-recursion",nx110ctx_verify(nx110ctx_prepare(recursive,"threaded"))) ++
  nxlib_control_result("context-direct-load-ordinary-recursion",nx110ctx_verify(nx110ctx_prepare(recursive,"context"))) ++
  nxlib_control_result("context-threaded-tail-loop",nx110ctx_verify(nx110ctx_prepare(Nx110RtLibrary{[nx110rt_control_worker("single")],["ir_worker"]},"threaded"))) ++
  nxlib_control_result("context-atomic-view-preserved",nx110ctx_verify(nx110ctx_prepare(Nx110RtLibrary{[nx110rt_control_worker("atomic")],["ir_worker"]},"threaded"))) ++
  nxlib_control_result("context-wrapper-heap-once",U32.is_eq(nx110ctx_control_calls(threaded,"caller","rt_ir_heap"),1)) ++
  nxlib_control_result("context-wrapper-allocator-once",U32.is_eq(nx110ctx_control_calls(threaded,"caller","rt_ir_alc"),1)) ++
  nxlib_control_result("context-private-no-heap-accessor",U32.is_eq(nx110ctx_control_calls(threaded,"ctx110_caller","rt_ir_heap"),0)) ++
  nxlib_control_result("context-private-no-allocator-accessor",U32.is_eq(nx110ctx_control_calls(context,"ctx110_caller","rt_ir_alc"),0)) ++
  nxlib_control_result("context-call-renamed",U32.is_eq(nx110ctx_control_calls(threaded,"ctx110_caller","ctx110_identity"),1)) ++
  nxlib_control_result("context-two-owned-args-preserve-order",String.eq(
    nx_json_expr(NxCall{"target",nx110ctx_args([NxVar{"ctx"},NxVar{"p0"},NxVar{"p1"}],"threaded")}),
    nx_json_expr(NxCall{"target",[NxVar{"ctx"},NxVar{"ir_heap"},NxVar{"ir_alc"},NxVar{"p0"},NxVar{"p1"}]}))) ++
  nxlib_control_result("context-direct-owned-args-preserve-order",String.eq(
    nx_json_expr(NxCall{"target",nx110ctx_args([NxVar{"ctx"},NxVar{"p0"},NxVar{"p1"}],"context")}),
    nx_json_expr(NxCall{"target",[NxVar{"ctx"},NxVar{"p0"},NxVar{"p1"}]}))) ++
  nxlib_control_result("context-reject-missing-getter-prefix",Bool.not(nx110ctx_getter_prefix([NxReturn{NxVar{"p0"}}]))) ++
  nxlib_control_result("context-reject-pointer-permutation",Bool.not(nx110ctx_verify(nx110ctx_control_bad(threaded,"pointers")))) ++
  nxlib_control_result("context-pointer-permutation-typechecks",nx110rt_machine_ok(nx110ctx_control_machine(nx110ctx_control_bad(threaded,"pointers")))) ++
  nxlib_control_result("context-reject-missing-forwarded-pointer",Bool.not(nx110ctx_verify(nx110ctx_control_bad(threaded,"missing")))) ++
  nxlib_control_result("context-reject-unchecked-wrapper",Bool.not(nx110ctx_verify(nx110ctx_control_bad(threaded,"getter")))) ++
  nxlib_control_result("context-reject-private-export",Bool.not(nx110ctx_verify(nx110ctx_control_bad(context,"export")))) ++
  nxlib_control_result("context-reject-runtime-import-rewrite",Bool.not(nx110ctx_verify(nx110ctx_control_bad(threaded,"runtime")))) ++
  nxlib_control_result("context-reject-wrong-layout-offset",Bool.not(nx110ctx_verify(nx110ctx_control_bad(context,"offset")))) ++
  nxlib_control_result("context-reject-generated-name-collision",Bool.not(nx110ctx_verify(nx110ctx_prepare(collision,"threaded")))) ++
  nxlib_control_result("context-reject-unknown-mode",Bool.not(nx110ctx_verify(nx110ctx_prepare(nx110ctx_control_source(),"unchecked")))) ++
  nxlib_control_result("context-private-memory-not-public",Bool.not(nxlib_verify(nx110ctx_control_machine(nx110ctx_prepare(Nx110RtLibrary{[nx110rt_control_worker("single")],["ir_worker"]},"threaded"))))) ++
  nxlib_control_result("context-owning-word-cannot-be-borrow",Bool.not(nx110rtn_check([NxoReturn{"ir_heap"}],1,1))) ++
  nxlib_control_result("context-exact-empty",nx110ctx_exact("","")) ++
  nxlib_control_result("context-exact-equal-unicode",nx110ctx_exact("plain🙂Ω","plain🙂Ω")) ++
  nxlib_control_result("context-exact-first-mismatch",Bool.not(nx110ctx_exact("Axyz","Bxyz"))) ++
  nxlib_control_result("context-exact-last-mismatch",Bool.not(nx110ctx_exact("xyzA","xyzB"))) ++
  nxlib_control_result("context-exact-length-mismatch",Bool.not(nx110ctx_exact("prefix","prefixx"))) ++
  nxlib_control_result("context-exact-full-unicode-scalar",Bool.not(nx110ctx_exact("Ā","Ȁ")))
