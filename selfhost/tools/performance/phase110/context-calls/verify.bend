@unsafe
def nx110ctx_json_names(+names: List<&2,String>) -> String:
  match names:
    case Nil{}: ""
    case Con{name,Nil{}}: nx_quote(name)
    case Con{name,rest}: nx_quote(name) ++ "," ++ nx110ctx_json_names(rest)

@unsafe
def nx110ctx_json(+library: NxLibrary) -> String:
  match library:
    case NxLibrary{imports,functions,exports}:
      "{\"imports\":[" ++ nx_json_functions(nxlib_signatures(imports,[])) ++
      "],\"functions\":[" ++ nx_json_functions(functions) ++
      "],\"exports\":[" ++ nx110ctx_json_names(exports) ++ "]}"

@unsafe
def nx110ctx_verify(+library: Nx110CtxLibrary) -> Bool:
  match library:
    case Nx110CtxLibrary{source,mode,machine}:
      nx110ctx_mode(mode) && nx110rt_verify(source) && nx110ctx_source_prefixes(source) &&
      nx110ctx_exact(nx110ctx_json(machine),nx110ctx_json(nx110ctx_machine(source,mode))) &&
      nx110rt_machine_ok(machine)

@unsafe
def nx110ctx_qbe(+library: Nx110CtxLibrary) -> String:
  match library:
    case Nx110CtxLibrary{source,mode,machine}:
      nx_choose(String,nx110ctx_verify(library),u => nxlib_qbe_verified(machine),u => "INVALID_NX110_CONTEXT_LIBRARY\n")
def nx110ctx_getter_prefix(body: List<&2,NxStmt>) -> Bool:
  match body:
    case Con{NxSet{heap,NxCall{heap_call,Con{NxVar{heap_ctx},Nil{}}}},Con{NxSet{alc,NxCall{alc_call,Con{NxVar{alc_ctx},Nil{}}}},rest}}:
      String.eq(heap,"ir_heap") && String.eq(heap_call,"rt_ir_heap") && String.eq(heap_ctx,"ctx") &&
      String.eq(alc,"ir_alc") && String.eq(alc_call,"rt_ir_alc") && String.eq(alc_ctx,"ctx")
    case _: False{}

@unsafe
def nx110ctx_prefixes(+workers: List<&2,Nx110RtWorker>) -> Bool:
  match workers:
    case Nil{}: True{}
    case Con{Nx110RtWorker{name,arity,next,ownership,view,NxFunction{symbol,params,result,locals,body}},rest}:
      nx110ctx_getter_prefix(body) && nx110ctx_prefixes(rest)

@unsafe
def nx110ctx_source_prefixes(source: Nx110RtLibrary) -> Bool:
  match source:
    case Nx110RtLibrary{workers,exports}: nx110ctx_prefixes(workers)

@unsafe
def nx110ctx_exact(a: String, b: String) -> Bool:
  nx110ctx_exact_go(True{},a,b)

@unsafe
def nx110ctx_exact_go(same: Bool, a: String, b: String) -> Bool:
  match same a b:
    case False{} _ _: False{}
    case True{} SNil{} SNil{}: True{}
    case True{} SCon{head_a,tail_a} SCon{head_b,tail_b}:
      nx110ctx_exact_go(U32.is_eq(Char.to_u32(head_a),Char.to_u32(head_b)),tail_a,tail_b)
    case _ _ _: False{}

