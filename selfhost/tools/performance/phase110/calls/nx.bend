# A closed source catalogue supplies every ordinary call definition. Runtime
# imports remain a disjoint ABI namespace; final shared Nx verification checks
# the complete library after all definition bodies have been constructed.
def nxc_policy_valid(+policy: String) -> Bool:
  nxlib_runtime_policy_valid(policy) || nxlib_runtime110_policy_valid(policy)

def nxc_runtime(+policy: String) -> List<&2,NxImport>:
  nx_choose(List<&2,NxImport>,nxlib_runtime_policy_valid(policy),u => nxlib_runtime_imports_policy(policy),u => nxlib_runtime110_imports_policy(policy))

@unsafe
def nxc_function(+name: String, +arity: U32, +next: U32, +body: List<&2,NxoOp>, +policy: String) -> NxFunction:
  nx_choose(NxFunction,nxlib_runtime_policy_valid(policy),u => nxo_policy_function(name,arity,next,body,policy),u => nxo110_function(name,arity,next,body,policy))

@unsafe
def nxc_finish(+symbol: String, +arity: U32, +callees: List<&2,NxcCallee>, +code: NxoCode, +policy: String) -> NxoResult:
  match code:
    case NxoCode{body,next,error}:
      nx_choose(NxoResult,Bool.not(String.eq(error,"")),u => nxo_refused(symbol,body,error),u =>
      nx_choose(NxoResult,nxc_verify(body,arity,callees),u => NxoResult{nxc_function(symbol,arity,next,body,policy),body,""},u =>
        nxo_refused(symbol,body,"owned call credit or closed-callee verifier refused")))

@unsafe
def nxc_lower_one(+fact: KDef, +symbol: String, +ctors: List<&2,NxoCtor>, +callees: List<&2,NxcCallee>, +policy: String) -> NxoResult:
  nxc_finish(symbol,da(fact),callees,nxc_apply(dv(fact),nxo_param_words(0,da(fact)),[],nxo_param_words(0,da(fact)),ctors,callees,dn(fact),da(fact),0),policy)

def nxc_refused(error: String) -> NxcLibraryResult:
  NxcLibraryResult{NxLibrary{[],[],[]},[],error}

@unsafe
def nxc_collect(+sources: List<&2,NxcSource>, +ctors: List<&2,NxoCtor>, +callees: List<&2,NxcCallee>, +policy: String) -> NxcLibraryResult:
  match sources:
    case Nil{}: NxcLibraryResult{NxLibrary{[],[],[]},[],""}
    case Con{NxcSource{fact,symbol},rest}:
      nxc_collect_head(dn(fact),symbol,rest,ctors,callees,policy,nxc_lower_one(fact,symbol,ctors,callees,policy))

@unsafe
def nxc_collect_head(+source: String, +symbol: String, +rest: List<&2,NxcSource>, +ctors: List<&2,NxoCtor>, +callees: List<&2,NxcCallee>, +policy: String, +head: NxoResult) -> NxcLibraryResult:
  match head:
    case NxoResult{function,ownership,error}:
      nx_choose(NxcLibraryResult,String.eq(error,""),u => nxc_collect_tail(source,symbol,function,ownership,nxc_collect(rest,ctors,callees,policy)),u => nxc_refused(source ++ ": " ++ error))

@unsafe
def nxc_collect_tail(+source: String, +symbol: String, +function: NxFunction, +ops: List<&2,NxoOp>, +tail: NxcLibraryResult) -> NxcLibraryResult:
  match tail:
    case NxcLibraryResult{NxLibrary{imports,functions,exports},ownership,error}:
      NxcLibraryResult{NxLibrary{imports,Con{function,functions},exports},Con{NxcBody{source,symbol,ops},ownership},error}

@unsafe
def nxc_finish_library(+result: NxcLibraryResult, +exports: List<&2,String>, +policy: String) -> NxcLibraryResult:
  match result:
    case NxcLibraryResult{NxLibrary{imports,functions,old_exports},ownership,error}:
      +library : NxLibrary = NxLibrary{nxc_runtime(policy),functions,exports}
      nx_choose(NxcLibraryResult,Bool.not(String.eq(error,"")),u => result,u =>
        nx_choose(NxcLibraryResult,nxlib_verify(library),u => NxcLibraryResult{library,ownership,""},u => nxc_refused("closed owned-call Nx library refused")))

@unsafe
def nxc_lower_library(+sources: List<&2,NxcSource>, +ctors: List<&2,NxoCtor>, +exports: List<&2,String>, +policy: String) -> NxcLibraryResult:
  nx_choose(NxcLibraryResult,nxc_policy_valid(policy),u =>
    nx_choose(NxcLibraryResult,nxc_sources_ok(sources,ctors),u =>
      nxc_finish_library(nxc_collect(sources,ctors,nxc_catalogue(sources),policy),exports,policy),u =>
      nxc_refused("invalid checked source shape or duplicate source/symbol catalogue")),u => nxc_refused("unknown owned-call lowering policy"))
