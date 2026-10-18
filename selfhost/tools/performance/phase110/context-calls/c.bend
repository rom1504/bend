# Only ctx is an opaque public runtime pointer. Private base addresses are
# uintptr_t, matching the shared memory expression emitter's byte arithmetic.
def nx110ctx_c_type(+name: String, +typ: NxType) -> String:
  nx_choose(String,String.eq(name,"ctx") && nx_type_equal(typ,NxPtr{}),u => "struct NxRt *",u => nx_c_type(typ))

@unsafe
def nx110ctx_c_params(+params: List<&2,NxParam>) -> String:
  match params:
    case Nil{}: "void"
    case Con{NxParam{name,typ},Nil{}}: nx110ctx_c_type(name,typ) ++ " v_" ++ name
    case Con{NxParam{name,typ},rest}: nx110ctx_c_type(name,typ) ++ " v_" ++ name ++ "," ++ nx110ctx_c_params(rest)

@unsafe
def nx110ctx_c_decl(+function: NxFunction, +exports: List<&2,String>) -> String:
  match function:
    case NxFunction{name,params,result,locals,body}:
      nx_choose(String,nxlib_has_name(name,exports),u => "",u => "static ") ++
      nx_c_type(result) ++ " nx_" ++ name ++ "(" ++ nx110ctx_c_params(params) ++ ")"

@unsafe
def nx110ctx_c_decls(+functions: List<&2,NxFunction>, +exports: List<&2,String>) -> String:
  match functions:
    case Nil{}: ""
    case Con{function,rest}: nx110ctx_c_decl(function,exports) ++ ";\n" ++ nx110ctx_c_decls(rest,exports)

@unsafe
def nx110ctx_c_stmt(+stmt: NxStmt, +env: List<&2,NxParam>, +context: List<&2,NxFunction>) -> String:
  match stmt:
    case NxSet{name,NxLoad{NxPtr{},ptr,offset}}:
      "v_" ++ name ++ "=nx110ctx_load_pointer(" ++ nx_c_expr(ptr,env,context) ++ "," ++ U32.show(offset) ++ "u);\n"
    case NxIf{condition,yes,no}:
      "if(" ++ nx_c_expr(condition,env,context) ++ "){\n" ++ nx110ctx_c_stmts(yes,env,context) ++
      "}else{\n" ++ nx110ctx_c_stmts(no,env,context) ++ "}\n"
    case NxWhile{condition,body}:
      "while(" ++ nx_c_expr(condition,env,context) ++ "){\n" ++ nx110ctx_c_stmts(body,env,context) ++ "}\n"
    case _: nx_c_stmt(stmt,env,context)

@unsafe
def nx110ctx_c_stmts(+body: List<&2,NxStmt>, +env: List<&2,NxParam>, +context: List<&2,NxFunction>) -> String:
  match body:
    case Nil{}: ""
    case Con{head,rest}: nx110ctx_c_stmt(head,env,context) ++ nx110ctx_c_stmts(rest,env,context)

@unsafe
def nx110ctx_c_functions(+functions: List<&2,NxFunction>, +context: List<&2,NxFunction>, +exports: List<&2,String>) -> String:
  match functions:
    case Nil{}: ""
    case Con{function,rest}:
      match function:
        case NxFunction{name,params,result,locals,body}:
          nx110ctx_c_decl(function,exports) ++ "{\n" ++ nx_c_locals(locals) ++
          nx110ctx_c_stmts(body,nx_params_join(params,locals),context) ++ "}\n" ++ nx110ctx_c_functions(rest,context,exports)

@unsafe
def nx110ctx_c_machine(+machine: NxLibrary) -> String:
  match machine:
    case NxLibrary{imports,functions,exports}:
      "#include <stdint.h>\n#include <string.h>\nstruct NxRt;\n" ++
      "static uintptr_t nx110ctx_load_pointer(uintptr_t base,uint32_t offset){uintptr_t value;memcpy(&value,(const void *)(base+offset),sizeof value);return value;}\n" ++
      nx110rt_c_imports(imports) ++ nx110ctx_c_decls(functions,exports) ++
      nx110ctx_c_functions(functions,nxlib_signatures(imports,functions),exports)

@unsafe
def nx110ctx_c(+library: Nx110CtxLibrary) -> String:
  match library:
    case Nx110CtxLibrary{source,mode,machine}:
      nx_choose(String,nx110ctx_verify(library),u => nx110ctx_c_machine(machine),u => "#error INVALID_NX110_CONTEXT_LIBRARY\n")
