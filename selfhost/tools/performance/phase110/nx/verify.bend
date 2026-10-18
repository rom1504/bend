# Structural and exact call-signature checking only. Semantic ownership is
# checked before lowering; this layer does not prove runtime representation.
@unsafe
def nx110_pair_missing(+found: Maybe<&2,Nx110ImportPair>) -> Bool:
  match found:
    case None{}: True{}
    case Some{value}: False{}

@unsafe
def nx110_pair_imports_ok(+pairs: List<&2,Nx110ImportPair>, +fs: List<&2,NxFunction>) -> Bool:
  match pairs:
    case Nil{}: True{}
    case Con{Nx110ImportPair{name,params,first,second},rest}:
      nx_ident(name) && nx_params_ok(params) &&
      nx_type_equal(first,NxU64{}) && nx_type_equal(second,NxU64{}) &&
      nx110_pair_missing(nx110_find_pair(name,rest)) && nx_unique_function(name,fs) &&
      nx110_pair_imports_ok(rest,fs)

@unsafe
def nx110_pair_call_ok(+found: Maybe<&2,Nx110ImportPair>, +first: String, +second: String, +args: List<&2,NxExpr>, +env: List<&2,NxParam>, +fs: List<&2,NxFunction>) -> Bool:
  match found:
    case None{}: False{}
    case Some{Nx110ImportPair{name,params,a,b}}:
      Bool.not(String.eq(first,second)) && nx_type_equal(nx_lookup(first,env),a) &&
      nx_type_equal(nx_lookup(second,env),b) && nxlib_args_ok(args) &&
      nx_arg_types(args,nx_param_types(params),env,fs)

@unsafe
def nx110_scalar_ok(+stmt: NxStmt, +env: List<&2,NxParam>, +fs: List<&2,NxFunction>, +result: NxType) -> Bool:
  match stmt:
    case NxSet{name,value}: nxlib_expr_ok(value) && nx_stmt_ok(stmt,env,fs,result)
    case NxReturn{value}: nxlib_expr_ok(value) && nx_stmt_ok(stmt,env,fs,result)
    case _: False{}

@unsafe
def nx110_stmt_ok(+stmt: Nx110Stmt, +env: List<&2,NxParam>, +fs: List<&2,NxFunction>, +pairs: List<&2,Nx110ImportPair>, +result: NxType) -> Bool:
  match stmt:
    case Nx110Scalar{base}: nx110_scalar_ok(base,env,fs,result)
    case Nx110If{condition,yes,no}:
      nxlib_expr_ok(condition) && nx_pure(condition) && nx_type_equal(nx_expr_type(condition,env,fs),NxU32{}) &&
      nx110_stmts_ok(yes,env,fs,pairs,result) && nx110_stmts_ok(no,env,fs,pairs,result)
    case Nx110While{condition,body}:
      nxlib_expr_ok(condition) && nx_pure(condition) && nx_type_equal(nx_expr_type(condition,env,fs),NxU32{}) &&
      nx110_stmts_ok(body,env,fs,pairs,result)
    case Nx110CallPair{first,second,name,args}: nx110_pair_call_ok(nx110_find_pair(name,pairs),first,second,args,env,fs)

@unsafe
def nx110_stmt_returns(+stmt: Nx110Stmt) -> Bool:
  match stmt:
    case Nx110Scalar{base}: nx_stmt_returns(base)
    case Nx110If{condition,yes,no}: nx110_returns(yes) && nx110_returns(no)
    case _: False{}

@unsafe
def nx110_returns(+body: List<&2,Nx110Stmt>) -> Bool:
  match body:
    case Nil{}: False{}
    case Con{head,Nil{}}: nx110_stmt_returns(head)
    case Con{head,rest}: nx110_returns(rest)

@unsafe
def nx110_stmts_ok(+body: List<&2,Nx110Stmt>, +env: List<&2,NxParam>, +fs: List<&2,NxFunction>, +pairs: List<&2,Nx110ImportPair>, +result: NxType) -> Bool:
  match body:
    case Nil{}: True{}
    case Con{head,Nil{}}: nx110_stmt_ok(head,env,fs,pairs,result)
    case Con{head,rest}: Bool.not(nx110_stmt_returns(head)) && nx110_stmt_ok(head,env,fs,pairs,result) && nx110_stmts_ok(rest,env,fs,pairs,result)

@unsafe
def nx110_functions_ok(+items: List<&2,Nx110Function>, +fs: List<&2,NxFunction>, +pairs: List<&2,Nx110ImportPair>) -> Bool:
  match items:
    case Nil{}: True{}
    case Con{Nx110Function{name,params,result,locals,body},rest}:
      +env = nx_params_join(params,locals)
      nx_ident(name) && nx_unique_function(name,nx110_signatures(rest)) && nx_type_equal(result,result) && nx_params_ok(env) &&
      nx110_stmts_ok(body,env,fs,pairs,result) && nx110_returns(body) && nx110_functions_ok(rest,fs,pairs)

@unsafe
def nx110_verify(+library: Nx110Library) -> Bool:
  match library:
    case Nx110Library{imports,pairs,functions,exports}:
      +defs = nx110_signatures(functions)
      +fs = nxlib_signatures(imports,defs)
      nxlib_imports_ok(imports,defs) && nx110_pair_imports_ok(pairs,fs) &&
      nxlib_has_export(exports) && nxlib_exports_ok(exports,defs) && nx110_functions_ok(functions,fs,pairs)
