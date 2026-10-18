# Opaque-runtime library boundary over the shared Nx graph. Imported calls are
# effect barriers, not definitions. Their signatures enter lookup only; they
# must never be fed to closed-program inlining or reachability as empty bodies.
# The scalar NxProgram verifier and entry ABI are unchanged.
type NxImport is Data:
  NxImport{+name: String, +params: List<&2, NxParam>, +result: NxType}

type NxLibrary is Data:
  NxLibrary{+imports: List<&2, NxImport>, +functions: List<&2, NxFunction>, +exports: List<&2, String>}

@unsafe
def nxlib_signatures(+imports: List<&2, NxImport>, +functions: List<&2, NxFunction>) -> List<&2, NxFunction>:
  match imports:
    case Nil{}: functions
    case Con{NxImport{name, params, result}, rest}:
      Con{NxFunction{name, params, result, [], []}, nxlib_signatures(rest, functions)}

@unsafe
def nxlib_imports_ok(+imports: List<&2, NxImport>, +functions: List<&2, NxFunction>) -> Bool:
  match imports:
    case Nil{}: True{}
    case Con{NxImport{name, params, result}, rest}:
      nx_ident(name) && nx_params_ok(params) && nx_type_equal(result, result) &&
      nx_unique_function(name, nxlib_signatures(rest, functions)) && nxlib_imports_ok(rest, functions)

# No raw heap or pointer manipulation enters the opaque-context slice. The
# mature runtime owns allocation, tagged-Term interpretation and lifetime.
@unsafe
def nxlib_expr_ok(+expr: NxExpr) -> Bool:
  match expr:
    case NxConst{typ, value}: nx_scalar(typ)
    case NxVar{name}: True{}
    case NxBin{op, left, right}: nxlib_expr_ok(left) && nxlib_expr_ok(right)
    case NxCall{name, args}: nxlib_args_ok(args)
    case _: False{}

@unsafe
def nxlib_args_ok(+args: List<&2, NxExpr>) -> Bool:
  match args:
    case Nil{}: True{}
    case Con{head, rest}: nxlib_expr_ok(head) && nxlib_args_ok(rest)

@unsafe
def nxlib_stmt_ok(+stmt: NxStmt) -> Bool:
  match stmt:
    case NxSet{name, value}: nxlib_expr_ok(value)
    case NxReturn{value}: nxlib_expr_ok(value)
    case NxIf{condition, yes, no}: nxlib_expr_ok(condition) && nxlib_body_ok(yes) && nxlib_body_ok(no)
    case NxWhile{condition, body}: nxlib_expr_ok(condition) && nxlib_body_ok(body)
    case _: False{}

@unsafe
def nxlib_body_ok(+body: List<&2, NxStmt>) -> Bool:
  match body:
    case Nil{}: True{}
    case Con{head, rest}: nxlib_stmt_ok(head) && nxlib_body_ok(rest)

@unsafe
def nxlib_bodies_ok(+functions: List<&2, NxFunction>) -> Bool:
  match functions:
    case Nil{}: True{}
    case Con{NxFunction{name, params, result, locals, body}, rest}:
      nxlib_body_ok(body) && nxlib_bodies_ok(rest)

@unsafe
def nxlib_term_params(+params: List<&2, NxParam>) -> Bool:
  match params:
    case Nil{}: True{}
    case Con{NxParam{name, typ}, rest}: nx_type_equal(typ, NxU64{}) && nxlib_term_params(rest)

@unsafe
def nxlib_export_abi(+found: Maybe<&2, NxFunction>) -> Bool:
  match found:
    case None{}: False{}
    case Some{NxFunction{name, params, result, locals, body}}:
      match params:
        case Nil{}: False{}
        case Con{NxParam{context, typ}, rest}:
          nx_type_equal(typ, NxPtr{}) && nx_type_equal(result, NxU64{}) && nxlib_term_params(rest)

@unsafe
def nxlib_has_name(+name: String, +names: List<&2, String>) -> Bool:
  match names:
    case Nil{}: False{}
    case Con{head, rest}: String.eq(name, head) || nxlib_has_name(name, rest)

@unsafe
def nxlib_exports_ok(+names: List<&2, String>, +functions: List<&2, NxFunction>) -> Bool:
  match names:
    case Nil{}: True{}
    case Con{name, rest}:
      Bool.not(nxlib_has_name(name, rest)) && nxlib_export_abi(nx_find(name, functions)) && nxlib_exports_ok(rest, functions)

def nxlib_has_export(names: List<&2, String>) -> Bool:
  match names:
    case Nil{}: False{}
    case Con{head, rest}: True{}

@unsafe
def nxlib_verify(+library: NxLibrary) -> Bool:
  match library:
    case NxLibrary{imports, functions, exports}:
      nxlib_imports_ok(imports, functions) && nxlib_has_export(exports) &&
      nxlib_exports_ok(exports, functions) && nxlib_bodies_ok(functions) &&
      nx_functions_ok(functions, nxlib_signatures(imports, functions))

@unsafe
def nxlib_qbe_functions(+functions: List<&2, NxFunction>, +context: List<&2, NxFunction>, +exports: List<&2, String>) -> String:
  match functions:
    case Nil{}: ""
    case Con{function, rest}:
      match function:
        case NxFunction{name, params, result, locals, body}:
          nx_choose(String, nxlib_has_name(name, exports), u => "export ", u => "") ++
          nxq_function(function, context) ++ nxlib_qbe_functions(rest, context, exports)

@unsafe
def nxlib_qbe_verified(+library: NxLibrary) -> String:
  match library:
    case NxLibrary{imports, functions, exports}:
      nxlib_qbe_functions(functions, nxlib_signatures(imports, functions), exports)

@unsafe
def nxlib_qbe(+library: NxLibrary) -> String:
  nx_choose(String, nxlib_verify(library), u => nxlib_qbe_verified(library), u => "INVALID_NX_LIBRARY\n")

# Optional local folding only. The closed-world NxProgram pipelines do not
# accept NxLibrary and cannot interpret runtime signatures as function bodies.
@unsafe
def nxlib_fold(+library: NxLibrary) -> NxLibrary:
  match library:
    case NxLibrary{imports, functions, exports}:
      NxLibrary{imports, nx_simplify_functions(functions), exports}

@unsafe
def nxlib_optimized(+candidate: NxLibrary, +original: NxLibrary) -> NxLibrary:
  nx_choose(NxLibrary, nxlib_verify(candidate), u => candidate, u => original)

@unsafe
def nxlib_optimize(+library: NxLibrary) -> NxLibrary:
  nx_choose(NxLibrary, nxlib_verify(library), u => nxlib_optimized(nxlib_fold(library), library), u => library)
