# Matched C control for the exact NxLibrary graph and external runtime ABI.
# Reuse the original Nx expression/statement emitter; only declarations differ.
# NxPtr here is the opaque runtime context, not scalar Nx's uintptr_t heap.
def nxlib_c_type(typ: NxType) -> String:
  match typ:
    case NxPtr{}: "struct NxRt *"
    case _: nx_c_type(typ)

@unsafe
def nxlib_c_params(+params: List<&2, NxParam>) -> String:
  match params:
    case Nil{}: "void"
    case Con{NxParam{name, typ}, Nil{}}: nxlib_c_type(typ) ++ " v_" ++ name
    case Con{NxParam{name, typ}, rest}: nxlib_c_type(typ) ++ " v_" ++ name ++ "," ++ nxlib_c_params(rest)

@unsafe
def nxlib_c_locals(+locals: List<&2, NxParam>) -> String:
  match locals:
    case Nil{}: ""
    case Con{NxParam{name, typ}, rest}: nxlib_c_type(typ) ++ " v_" ++ name ++ "=0;\n" ++ nxlib_c_locals(rest)

@unsafe
def nxlib_c_imports(+imports: List<&2, NxImport>) -> String:
  match imports:
    case Nil{}: ""
    case Con{NxImport{name, params, result}, rest}:
      "extern " ++ nxlib_c_type(result) ++ " nx_" ++ name ++ "(" ++ nxlib_c_params(params) ++ ");\n" ++ nxlib_c_imports(rest)

@unsafe
def nxlib_c_decl(+function: NxFunction, +exports: List<&2, String>) -> String:
  match function:
    case NxFunction{name, params, result, locals, body}:
      nx_choose(String, nxlib_has_name(name, exports), u => "", u => "static ") ++
      nxlib_c_type(result) ++ " nx_" ++ name ++ "(" ++ nxlib_c_params(params) ++ ")"

@unsafe
def nxlib_c_decls(+functions: List<&2, NxFunction>, +exports: List<&2, String>) -> String:
  match functions:
    case Nil{}: ""
    case Con{function, rest}: nxlib_c_decl(function, exports) ++ ";\n" ++ nxlib_c_decls(rest, exports)

@unsafe
def nxlib_c_functions(+functions: List<&2, NxFunction>, +context: List<&2, NxFunction>, +exports: List<&2, String>) -> String:
  match functions:
    case Nil{}: ""
    case Con{function, rest}:
      match function:
        case NxFunction{name, params, result, locals, body}:
          nxlib_c_decl(function, exports) ++ "{\n" ++ nxlib_c_locals(locals) ++
          nx_c_stmts(body, nx_params_join(params, locals), context) ++ "}\n" ++ nxlib_c_functions(rest, context, exports)

@unsafe
def nxlib_c_verified(+library: NxLibrary) -> String:
  match library:
    case NxLibrary{imports, functions, exports}:
      "#include <stdint.h>\nstruct NxRt;\n" ++ nxlib_c_imports(imports) ++ nxlib_c_decls(functions, exports) ++
      nxlib_c_functions(functions, nxlib_signatures(imports, functions), exports)

@unsafe
def nxlib_c(+library: NxLibrary) -> String:
  nx_choose(String, nxlib_verify(library), u => nxlib_c_verified(library), u => "#error INVALID_NX_LIBRARY\n")
