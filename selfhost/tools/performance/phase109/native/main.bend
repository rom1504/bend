# Native selected-library experiment. The full checked Bend frontend and mature
# erasure produce NativeErasedBody; no scalar frontend or host AST conversion.
# Only two frozen source texts are accepted. This is a controlled research entry,
# not arbitrary source-to-runtime-ABI admission. Base/cache are externally pinned.
def p109_native_ctors() -> List<&2,NxoCtor>:
  [NxoCtor{"Nil",0,0},NxoCtor{"Con",1,2},NxoCtor{"SNil",2,0},NxoCtor{"SCon",3,2}]

def p109_native_print(+text: String) -> IO(U32):
  do IO<U32>:
    Unit <- IO.print(text)
    IO.pure(U32, 0)

@unsafe
def p109_native_emit(+contract: String, +policy: String, +format: String, +left: NxFunction, +right: NxFunction) -> IO(U32):
  +library : NxLibrary = NxLibrary{nxlib_runtime_imports_policy(policy),[left,right],["list_reverse","string_reverse"]}
  nx_choose(IO(U32),nxlib_verify(library),
    u => p109_native_print(nx_choose(String,String.eq(format,"qbe"),
      v => nxlib_qbe(library),
      v => "{\"kind\":\"phase109-selected-owned-library\",\"contract\":" ++ sk_quote(contract) ++
        ",\"policy\":" ++ sk_quote(policy) ++ ",\"functions\":[" ++ nx_json_function(left) ++ "," ++ nx_json_function(right) ++ "]}")),
    u => IO.die(U32,1,"owned library verifier refused"))

@unsafe
def p109_native_lowered(+contract: String, +policy: String, +format: String, +left: NxoResult, +right: NxoResult) -> IO(U32):
  match left right:
    case NxoResult{lf,lo,+le} NxoResult{rf,ro,+re}:
      nx_choose(IO(U32),String.is_empty(le) && String.is_empty(re),
        u => p109_native_emit(contract,policy,format,lf,rf),
        u => IO.die(U32,1,"owned lowering refused: " ++ le ++ "; " ++ re))

@unsafe
def p109_native_request_ready(+contract: String, +policy: String, +format: String, request: NR_Request) -> IO(U32):
  match request:
    case NR_Request{source,+book,names,paths,scope,bound}:
      +list_name = nx_choose(String,String.eq(contract,"reverse"),u => "nt_reverse",u => "p109_list_" ++ contract)
      +string_name = nx_choose(String,String.eq(contract,"reverse"),u => "String.reverse.go",u => "p109_string_" ++ contract)
      p109_native_lowered(contract,policy,format,
        nxo_lower_policy(ns_body(book,list_name),p109_native_ctors(),"list_reverse",policy),
        nxo_lower_policy(ns_body(book,string_name),p109_native_ctors(),"string_reverse",policy))

@unsafe
def p109_native_planned(+contract: String, +policy: String, +format: String, plan: P86Plan) -> IO(U32):
  match plan:
    case P86PlanError{error}: IO.die(U32,1,error)
    case P86PlanReady{request,verdict}: p109_native_request_ready(contract,policy,format,request)

@unsafe
def p109_native_prepared(+input: String, +text: String, +contract: String, +policy: String, +format: String, prepared: P86Preparation) -> IO(U32):
  match prepared:
    case P86PreparationError{error}: IO.die(U32,1,error)
    case P86PreparationReady{seed}:
      p109_native_planned(contract,policy,format,p86_plan(seed,input,text))

@unsafe
def p109_native_admitted(+input: String, +text: String, +contract: String, +policy: String, +format: String, +cached: Bool) -> IO(U32):
  do IO<U32>:
    +base : String <- p86_read_file(p109_native_base_path())
    nx_choose(IO(U32),cached,
      u => do IO<U32>:
        carrier : String <- p86_read_file(p109_native_cache_path())
        p109_native_prepared(input,text,contract,policy,format,
          p88_cache_prepare(p109_native_base_path(),base,carrier,p109_native_cache_stamp())),
      u => p109_native_prepared(input,text,contract,policy,format,
        p86_prepare(p109_native_base_path(),base)))

@unsafe
def p109_native_request(+input: String, +contract: String, +policy: String, +format: String, +cached: Bool) -> IO(U32):
  do IO<U32>:
    +text : String <- p86_read_file(input)
    nx_choose(IO(U32),String.eq(text,p109_native_contract_text(contract)),
      u => p109_native_admitted(input,text,contract,policy,format,cached),
      u => IO.die(U32,2,"source does not match frozen selected-library contract"))

@unsafe
def p109_native_args(args: List<&1,String>) -> IO(U32):
  match args:
    case Con{program,Con{+input,Con{+contract,Con{+format,Con{+policy,Con{+base_mode,Nil{}}}}}}}:
      nx_choose(IO(U32),String.starts_with(input,"/") &&
        (String.eq(contract,"reverse") || String.eq(contract,"discard") || String.eq(contract,"duplicate")) &&
        (String.eq(format,"qbe") || String.eq(format,"ir")) &&
        nxlib_runtime_policy_valid(policy) && (String.eq(base_mode,"cache") || String.eq(base_mode,"live")),
        u => p109_native_request(input,contract,policy,format,String.eq(base_mode,"cache")),
        u => IO.die(U32,2,"invalid selected-library arguments"))
    case _: IO.die(U32,2,"usage: native-owned ABS_INPUT reverse|discard|duplicate qbe|ir raw|trusted|fused cache|live")

@unsafe
def main() -> IO(U32):
  do IO<U32>:
    args : List<&1,String> <- IO.args()
    p109_native_args(args)
