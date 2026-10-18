# Closed ordinary-call ownership for private runtime-template workers. Callee
# signatures come from actual workers, never the runtime import namespace.
type Nx110RtLibraryResult is Data:
  Nx110RtLibraryResult{+library: Nx110RtLibrary, +error: String}

@unsafe
def nx110rt_callees(+workers: List<&2,Nx110RtWorker>) -> List<&2,NxcCallee>:
  match workers:
    case Nil{}: []
    case Con{Nx110RtWorker{name,arity,next,ownership,view,function},rest}:
      Con{NxcCallee{name,name,arity},nx110rt_callees(rest)}

@unsafe
def nx110rt_calls_ok(+workers: List<&2,Nx110RtWorker>, +callees: List<&2,NxcCallee>) -> Bool:
  match workers:
    case Nil{}: True{}
    case Con{Nx110RtWorker{name,arity,next,ownership,view,function},rest}:
      nxc_ops_ok(ownership,callees) && nx110rt_calls_ok(rest,callees)

def nx110rt_library_refused(error: String) -> Nx110RtLibraryResult:
  Nx110RtLibraryResult{Nx110RtLibrary{[],[]},error}

@unsafe
def nx110rt_call_finish(+symbol: String, +arity: U32, +callees: List<&2,NxcCallee>, +code: NxoCode, +view: String) -> Nx110RtResult:
  match code:
    case NxoCode{body,next,error}:
      nx_choose(Nx110RtResult,Bool.not(String.eq(error,"")),u => nx110rt_refused(symbol,error),u =>
      nx_choose(Nx110RtResult,nxc_verify(body,arity,callees),u =>
        Nx110RtResult{Nx110RtWorker{symbol,arity,next,body,view,nx110rt_function(symbol,arity,next,body,view)},""},u =>
        nx110rt_refused(symbol,"owned call credit or closed-callee verifier refused")))

@unsafe
def nx110rt_call_one(+fact: KDef, +symbol: String, +ctors: List<&2,NxoCtor>, +callees: List<&2,NxcCallee>, +view: String) -> Nx110RtResult:
  nx110rt_call_finish(symbol,da(fact),callees,nxc_apply(dv(fact),nxo_param_words(0,da(fact)),[],nxo_param_words(0,da(fact)),ctors,callees,dn(fact),da(fact),0),view)

@unsafe
def nx110rt_call_collect(+sources: List<&2,NxcSource>, +ctors: List<&2,NxoCtor>, +callees: List<&2,NxcCallee>, +view: String) -> Nx110RtLibraryResult:
  match sources:
    case Nil{}: Nx110RtLibraryResult{Nx110RtLibrary{[],[]},""}
    case Con{NxcSource{fact,symbol},rest}:
      nx110rt_call_head(dn(fact),rest,ctors,callees,view,nx110rt_call_one(fact,symbol,ctors,callees,view))

@unsafe
def nx110rt_call_head(+source: String, +rest: List<&2,NxcSource>, +ctors: List<&2,NxoCtor>, +callees: List<&2,NxcCallee>, +view: String, +head: Nx110RtResult) -> Nx110RtLibraryResult:
  match head:
    case Nx110RtResult{worker,error}:
      nx_choose(Nx110RtLibraryResult,String.eq(error,""),u => nx110rt_call_tail(worker,nx110rt_call_collect(rest,ctors,callees,view)),u => nx110rt_library_refused(source ++ ": " ++ error))

def nx110rt_call_tail(worker: Nx110RtWorker, tail: Nx110RtLibraryResult) -> Nx110RtLibraryResult:
  match tail:
    case Nx110RtLibraryResult{Nx110RtLibrary{workers,exports},error}:
      Nx110RtLibraryResult{Nx110RtLibrary{Con{worker,workers},exports},error}

@unsafe
def nx110rt_call_library(+result: Nx110RtLibraryResult, +exports: List<&2,String>) -> Nx110RtLibraryResult:
  match result:
    case Nx110RtLibraryResult{Nx110RtLibrary{workers,old_exports},error}:
      +library : Nx110RtLibrary = Nx110RtLibrary{workers,exports}
      nx_choose(Nx110RtLibraryResult,Bool.not(String.eq(error,"")),u => result,u =>
      nx_choose(Nx110RtLibraryResult,nx110rt_verify(library),u => Nx110RtLibraryResult{library,""},u => nx110rt_library_refused("closed runtime-template library refused")))

@unsafe
def nx110rt_lower_library(+sources: List<&2,NxcSource>, +ctors: List<&2,NxoCtor>, +exports: List<&2,String>, +view: String) -> Nx110RtLibraryResult:
  nx_choose(Nx110RtLibraryResult,nx110rt_view_valid(view),u =>
    nx_choose(Nx110RtLibraryResult,nxc_sources_ok(sources,ctors),u =>
      nx110rt_call_library(nx110rt_call_collect(sources,ctors,nxc_catalogue(sources),view),exports),u =>
      nx110rt_library_refused("invalid checked source shape or duplicate source/symbol catalogue")),u => nx110rt_library_refused("unknown private runtime view policy"))
