# Matched C consumer of the same typed pair statement graph.
@unsafe
def nx110_c_pairs(+pairs: List<&2,Nx110ImportPair>) -> String:
  match pairs:
    case Nil{}: ""
    case Con{Nx110ImportPair{name,params,first,second},rest}:
      "extern struct NxRtPair nx_" ++ name ++ "(" ++ nxlib_c_params(params) ++ ");\n" ++ nx110_c_pairs(rest)

@unsafe
def nx110_c_stmt(+stmt: Nx110Stmt, +env: List<&2,NxParam>, +fs: List<&2,NxFunction>) -> String:
  match stmt:
    case Nx110Scalar{base}: nx_c_stmt(base,env,fs)
    case Nx110If{condition,yes,no}:
      "if(" ++ nx_c_expr(condition,env,fs) ++ "){\n" ++ nx110_c_stmts(yes,env,fs) ++ "}else{\n" ++ nx110_c_stmts(no,env,fs) ++ "}\n"
    case Nx110While{condition,body}:
      "while(" ++ nx_c_expr(condition,env,fs) ++ "){\n" ++ nx110_c_stmts(body,env,fs) ++ "}\n"
    case Nx110CallPair{first,second,name,args}:
      "{ struct NxRtPair nx_pair=nx_" ++ name ++ "(" ++ nx_c_args(args,env,fs) ++ ");\n" ++
      "v_" ++ first ++ "=nx_pair.first;\nv_" ++ second ++ "=nx_pair.second; }\n"

@unsafe
def nx110_c_stmts(+body: List<&2,Nx110Stmt>, +env: List<&2,NxParam>, +fs: List<&2,NxFunction>) -> String:
  match body:
    case Nil{}: ""
    case Con{head,rest}: nx110_c_stmt(head,env,fs) ++ nx110_c_stmts(rest,env,fs)

@unsafe
def nx110_c_functions(+items: List<&2,Nx110Function>, +fs: List<&2,NxFunction>, +exports: List<&2,String>) -> String:
  match items:
    case Nil{}: ""
    case Con{Nx110Function{name,params,result,locals,body},rest}:
      nxlib_c_decl(NxFunction{name,params,result,[],[]},exports) ++ "{\n" ++ nxlib_c_locals(locals) ++
      nx110_c_stmts(body,nx_params_join(params,locals),fs) ++ "}\n" ++ nx110_c_functions(rest,fs,exports)

@unsafe
def nx110_c_verified(+library: Nx110Library) -> String:
  match library:
    case Nx110Library{imports,pairs,functions,exports}:
      +defs = nx110_signatures(functions)
      "#include <stdint.h>\nstruct NxRt;\nstruct NxRtPair { uint64_t first,second; };\n" ++
      nxlib_c_imports(imports) ++ nx110_c_pairs(pairs) ++ nxlib_c_decls(defs,exports) ++
      nx110_c_functions(functions,nxlib_signatures(imports,defs),exports)

@unsafe
def nx110_c(+library: Nx110Library) -> String:
  nx_choose(String,nx110_verify(library),u => nx110_c_verified(library),u => "#error INVALID_NX110_LIBRARY\n")
