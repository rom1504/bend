@unsafe
def nx110ctx_args(+args: List<&2,NxExpr>, +mode: String) -> List<&2,NxExpr>:
  match args:
    case Nil{}: []
    case Con{context,rest}:
      nx_choose(List<&2,NxExpr>,String.eq(mode,"threaded"),u =>
        Con{context,Con{NxVar{"ir_heap"},Con{NxVar{"ir_alc"},rest}}},u => args)

# Canonical owning calls are statement-root NxCalls. Runtime calls keep their
# original ABI; only the authenticated closed worker catalogue is renamed.
@unsafe
def nx110ctx_stmt(+stmt: NxStmt, +names: List<&2,String>, +mode: String) -> NxStmt:
  match stmt:
    case NxSet{dest,NxCall{name,args}}:
      nx_choose(NxStmt,nxlib_has_name(name,names),u =>
        NxSet{dest,NxCall{nx110ctx_name(name),nx110ctx_args(args,mode)}},u => stmt)
    case NxIf{condition,yes,no}: NxIf{condition,nx110ctx_stmts(yes,names,mode),nx110ctx_stmts(no,names,mode)}
    case NxWhile{condition,body}: NxWhile{condition,nx110ctx_stmts(body,names,mode)}
    case _: stmt

@unsafe
def nx110ctx_stmts(+body: List<&2,NxStmt>, +names: List<&2,String>, +mode: String) -> List<&2,NxStmt>:
  match body:
    case Nil{}: []
    case Con{head,rest}: Con{nx110ctx_stmt(head,names,mode),nx110ctx_stmts(rest,names,mode)}

@unsafe
def nx110ctx_locals(+locals: List<&2,NxParam>, +mode: String) -> List<&2,NxParam>:
  match locals:
    case Nil{}: []
    case Con{NxParam{name,typ},rest}:
      nx_choose(List<&2,NxParam>,String.eq(mode,"threaded") && (String.eq(name,"ir_heap") || String.eq(name,"ir_alc")),
        u => nx110ctx_locals(rest,mode),u => Con{NxParam{name,typ},nx110ctx_locals(rest,mode)})

def nx110ctx_params(+params: List<&2,NxParam>, +mode: String) -> List<&2,NxParam>:
  match params:
    case Nil{}: []
    case Con{+context,+rest}:
      nx_choose(List<&2,NxParam>,String.eq(mode,"threaded"),u =>
        Con{context,Con{NxParam{"ir_heap",NxPtr{}},Con{NxParam{"ir_alc",NxPtr{}},rest}}},u => Con{context,rest})

# Original canonical entry has precisely the two checked accessor statements.
# Context mode replaces them with private loads after the exported wrapper has
# validated the context. Byte offsets are independently runtime-authenticated.
def nx110ctx_entry(mode: String) -> List<&2,NxStmt>:
  nx_choose(List<&2,NxStmt>,String.eq(mode,"context"),u =>
    [NxSet{"ir_heap",NxLoad{NxPtr{},NxOffset{NxVar{"ctx"},nx110rt_u(0)},0}},
     NxSet{"ir_alc",NxLoad{NxPtr{},NxOffset{NxVar{"ctx"},nx110rt_u(0)},8}}],u => [])

def nx110ctx_without_getters(body: List<&2,NxStmt>) -> List<&2,NxStmt>:
  match body:
    case Con{first,Con{second,rest}}: rest
    case _: []

@unsafe
def nx110ctx_private(+function: NxFunction, +names: List<&2,String>, +mode: String) -> NxFunction:
  match function:
    case NxFunction{name,params,result,locals,body}:
      NxFunction{nx110ctx_name(name),nx110ctx_params(params,mode),result,nx110ctx_locals(locals,mode),
        nxo_join(NxStmt,nx110ctx_entry(mode),nx110ctx_stmts(nx110ctx_without_getters(body),names,mode))}

@unsafe
def nx110ctx_wrapper(+worker: Nx110RtWorker, +mode: String) -> NxFunction:
  match worker:
    case Nx110RtWorker{name,arity,next,ownership,view,function}:
      NxFunction{name,Con{NxParam{"ctx",NxPtr{}},nxo_params("p",0,arity)},NxU64{},
        [NxParam{"ir_heap",NxPtr{}},NxParam{"ir_alc",NxPtr{}},NxParam{"result",NxU64{}}],
        [NxSet{"ir_heap",NxCall{"rt_ir_heap",[NxVar{"ctx"}]}},
         NxSet{"ir_alc",NxCall{"rt_ir_alc",[NxVar{"ctx"}]}},
         NxSet{"result",NxCall{nx110ctx_name(name),nx110ctx_args(Con{NxVar{"ctx"},nxo_exprs(nxo_param_words(0,arity))},mode)}},
         NxReturn{NxVar{"result"}}]}

@unsafe
def nx110ctx_functions(+workers: List<&2,Nx110RtWorker>, +names: List<&2,String>, +exports: List<&2,String>, +mode: String) -> List<&2,NxFunction>:
  match workers:
    case Nil{}: []
    case Con{worker,rest}:
      match worker:
        case Nx110RtWorker{name,arity,next,ownership,view,function}:
          Con{nx110ctx_private(function,names,mode),
            nxo_join(NxFunction,nx_choose(List<&2,NxFunction>,nxlib_has_name(name,exports),u => [nx110ctx_wrapper(worker,mode)],u => []),
              nx110ctx_functions(rest,names,exports,mode))}

@unsafe
def nx110ctx_machine(+source: Nx110RtLibrary, +mode: String) -> NxLibrary:
  match source:
    case Nx110RtLibrary{workers,exports}:
      NxLibrary{nx110rt_imports(),nx110ctx_functions(workers,nx110ctx_names(workers),exports,mode),exports}

@unsafe
def nx110ctx_prepare(+source: Nx110RtLibrary, +mode: String) -> Nx110CtxLibrary:
  Nx110CtxLibrary{source,mode,nx110ctx_machine(source,mode)}
