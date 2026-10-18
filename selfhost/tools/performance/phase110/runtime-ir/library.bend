# Memory-bearing worker certificates are separate from public opaque NxLibrary.
# Verification recomputes the complete machine graph from the unchanged owned
# graph, then compares its canonical structural serialization. Arbitrary Nx
# memory is never accepted by the public verifier or by this private boundary.
type Nx110RtWorker is Data:
  Nx110RtWorker{+name: String, +arity: U32, +next: U32, +ownership: List<&2,NxoOp>, +view: String, +function: NxFunction}

type Nx110RtResult is Data:
  Nx110RtResult{+worker: Nx110RtWorker, +error: String}

type Nx110RtLibrary is Data:
  Nx110RtLibrary{+workers: List<&2,Nx110RtWorker>, +exports: List<&2,String>}

def nx110rt_imports() -> List<&2,NxImport>:
  nxo_join(NxImport,
    [NxImport{"rt_ir_heap",[NxParam{"ctx",NxPtr{}}],NxPtr{}},
     NxImport{"rt_ir_alc",[NxParam{"ctx",NxPtr{}}],NxPtr{}},
     NxImport{"rt_ir_alloc0",[NxParam{"ctx",NxPtr{}}],NxU64{}},
     NxImport{"rt_ir_hand0",[NxParam{"ctx",NxPtr{}}],NxU32{}},
     NxImport{"rt_ir_view",[NxParam{"ctx",NxPtr{}},NxParam{"loc",NxU64{}}],NxU64{}}],
    nxlib_runtime110_imports_policy("specialized"))

@unsafe
def nx110rt_functions(+workers: List<&2,Nx110RtWorker>) -> List<&2,NxFunction>:
  match workers:
    case Nil{}: []
    case Con{Nx110RtWorker{name,arity,next,ownership,view,function},rest}: Con{function,nx110rt_functions(rest)}

@unsafe
def nx110rt_workers_ok(+workers: List<&2,Nx110RtWorker>) -> Bool:
  match workers:
    case Nil{}: True{}
    case Con{Nx110RtWorker{name,arity,next,ownership,view,function},rest}:
      nx110rt_view_valid(view) && U32.is_gt(arity,0) && U32.is_lt(arity,9) &&
      nxo_verify(ownership,arity) &&
      String.eq(nx_json_function(function),nx_json_function(nx110rt_function(name,arity,next,ownership,view))) &&
      nx110rt_workers_ok(rest)

@unsafe
def nx110rt_machine(+library: Nx110RtLibrary) -> NxLibrary:
  match library:
    case Nx110RtLibrary{workers,exports}: NxLibrary{nx110rt_imports(),nx110rt_functions(workers),exports}

@unsafe
def nx110rt_machine_ok(+library: NxLibrary) -> Bool:
  match library:
    case NxLibrary{imports,functions,exports}:
      nxlib_imports_ok(imports,functions) && nxlib_has_export(exports) &&
      nxlib_exports_ok(exports,functions) && nx_functions_ok(functions,nxlib_signatures(imports,functions))

@unsafe
def nx110rt_verify(+library: Nx110RtLibrary) -> Bool:
  match library:
    case Nx110RtLibrary{workers,exports}: nx110rt_workers_ok(workers) && nx110rt_machine_ok(nx110rt_machine(library))

@unsafe
def nx110rt_qbe(+library: Nx110RtLibrary) -> String:
  nx_choose(String,nx110rt_verify(library),u => nxlib_qbe_verified(nx110rt_machine(library)),u => "INVALID_NX110_RUNTIME_LIBRARY\n")

# Pointer-producing private imports return uintptr_t at the C type boundary.
# Every pointer parameter is still the opaque context. Memory locals are
# uintptr_t, matching the shared Nx memory emitter's byte address arithmetic.
@unsafe
def nx110rt_c_imports(+imports: List<&2,NxImport>) -> String:
  match imports:
    case Nil{}: ""
    case Con{NxImport{name,params,result},rest}:
      "extern " ++ nx_c_type(result) ++ " nx_" ++ name ++ "(" ++ nxlib_c_params(params) ++ ");\n" ++ nx110rt_c_imports(rest)

@unsafe
def nx110rt_c_functions(+functions: List<&2,NxFunction>, +context: List<&2,NxFunction>, +exports: List<&2,String>) -> String:
  match functions:
    case Nil{}: ""
    case Con{function,rest}:
      match function:
        case NxFunction{name,params,result,locals,body}:
          nxlib_c_decl(function,exports) ++ "{\n" ++ nx_c_locals(locals) ++
          nx_c_stmts(body,nx_params_join(params,locals),context) ++ "}\n" ++ nx110rt_c_functions(rest,context,exports)

@unsafe
def nx110rt_c_machine(+library: NxLibrary) -> String:
  match library:
    case NxLibrary{imports,functions,exports}:
      "#include <stdint.h>\nstruct NxRt;\n" ++ nx110rt_c_imports(imports) ++ nxlib_c_decls(functions,exports) ++
      nx110rt_c_functions(functions,nxlib_signatures(imports,functions),exports)

@unsafe
def nx110rt_c(+library: Nx110RtLibrary) -> String:
  nx_choose(String,nx110rt_verify(library),u => nx110rt_c_machine(nx110rt_machine(library)),u => "#error INVALID_NX110_RUNTIME_LIBRARY\n")

def nx110rt_refused(+name: String, +error: String) -> Nx110RtResult:
  Nx110RtResult{Nx110RtWorker{name,0,0,[],"",NxFunction{name,[],NxU64{},[],[]}},error}

@unsafe
def nx110rt_checked(+name: String, +arity: U32, +next: U32, +ownership: List<&2,NxoOp>, +view: String) -> Nx110RtResult:
  nx110rt_checked_worker(Nx110RtWorker{name,arity,next,ownership,view,nx110rt_function(name,arity,next,ownership,view)},name)

@unsafe
def nx110rt_checked_worker(+worker: Nx110RtWorker, +name: String) -> Nx110RtResult:
  Nx110RtResult{worker,nx_choose(String,nx110rt_verify(Nx110RtLibrary{[worker],[name]}),u => "",u => "private runtime template verifier refused")}

@unsafe
def nx110rt_finish(+name: String, +arity: U32, +code: NxoCode, +view: String) -> Nx110RtResult:
  match code:
    case NxoCode{body,next,error}:
      nx_choose(Nx110RtResult,Bool.not(String.eq(error,"")),u => nx110rt_refused(name,error),u =>
      nx_choose(Nx110RtResult,Bool.not(nx110rt_view_valid(view)),u => nx110rt_refused(name,"unknown private runtime view policy"),u =>
      nx_choose(Nx110RtResult,nxo_verify(body,arity),u => nx110rt_checked(name,arity,next,body,view),u => nx110rt_refused(name,"owned-Term verifier refused"))))

@unsafe
def nxo_lower110rt(+fact: KDef, +ctors: List<&2,NxoCtor>, +symbol: String, +view: String) -> Nx110RtResult:
  nx_choose(Nx110RtResult,nxo_admit(fact,ctors),u =>
    nx110rt_finish(symbol,da(fact),nxo_apply(dv(fact),nxo_param_words(0,da(fact)),[],nxo_param_words(0,da(fact)),ctors,dn(fact),da(fact),0),view),u =>
    nx110rt_refused(symbol,"requires checked fixed-catalogue NativeErasedBody"))
