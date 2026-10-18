# Native checked selected-library entry. Frozen source bytes preserve the
# admitted List<String>/String representation contract while the actual mature
# Bend frontend performs checking, erasure and source-bound worker lowering.
def p110_native_ctors() -> List<&2,NxoCtor>:
  [NxoCtor{"Nil",0,0},NxoCtor{"Con",1,2},NxoCtor{"SNil",2,0},NxoCtor{"SCon",3,2}]

def p110_native_contract_valid(+contract: String) -> Bool:
  String.eq(contract,"reverse") || String.eq(contract,"discard") || String.eq(contract,"duplicate") ||
  String.eq(contract,"tail") || String.eq(contract,"last") || String.eq(contract,"append")

def p110_native_rt_policy(+policy: String) -> Bool:
  String.eq(policy,"runtime-ir-single") || String.eq(policy,"runtime-ir-atomic")

def p110_native_policy_valid(+policy: String) -> Bool:
  nxc_policy_valid(policy) || String.eq(policy,"pair") || String.eq(policy,"pair-take") || p110_native_rt_policy(policy)

def p110_native_base_policy(+policy: String) -> String:
  nx_choose(String,String.eq(policy,"pair") || String.eq(policy,"pair-take"),u => "specialized",u => policy)

@unsafe
def p110_native_sources(+contract: String, +book: List<&2,KDef>) -> List<&2,NxcSource>:
  nx_choose(List<&2,NxcSource>,String.eq(contract,"tail"),u => [NxcSource{ns_body(book,"List.tail"),"list_tail"}],u =>
  nx_choose(List<&2,NxcSource>,String.eq(contract,"last"),u => [NxcSource{ns_body(book,"List.last.go"),"list_last"}],u =>
  nx_choose(List<&2,NxcSource>,String.eq(contract,"append"),u => [NxcSource{ns_body(book,"nt_reverse"),"list_reverse"},NxcSource{ns_body(book,"nt_append"),"list_append"}],u =>
  nx_choose(List<&2,NxcSource>,String.eq(contract,"reverse"),u => [NxcSource{ns_body(book,"nt_reverse"),"list_reverse"},NxcSource{ns_body(book,"String.reverse.go"),"string_reverse"}],u =>
    [NxcSource{ns_body(book,"p109_list_" ++ contract),"list_reverse"},NxcSource{ns_body(book,"p109_string_" ++ contract),"string_reverse"}]))))

def p110_native_exports(+contract: String) -> List<&2,String>:
  nx_choose(List<&2,String>,String.eq(contract,"tail"),u => ["list_tail"],u =>
  nx_choose(List<&2,String>,String.eq(contract,"last"),u => ["list_last"],u =>
  nx_choose(List<&2,String>,String.eq(contract,"append"),u => ["list_append"],u => ["list_reverse","string_reverse"])))

def p110_native_print(text: String) -> IO(U32):
  do IO<U32>:
    Unit <- IO.print(text)
    IO.pure(U32,0)

def p110_native_json(contract: String, policy: String, library: String) -> String:
  "{\"kind\":\"phase110-selected-owned-library\",\"contract\":" ++ nx_quote(contract) ++ ",\"policy\":" ++ nx_quote(policy) ++ ",\"library\":" ++ library ++ "}"

@unsafe
def p110_native_pair_emit(+contract: String, +policy: String, +format: String, +library: Nx110Library) -> IO(U32):
  nx_choose(IO(U32),nx110_verify(library),u => p110_native_print(
    nx_choose(String,String.eq(format,"qbe"),v => nx110_qbe_verified(library),v =>
    nx_choose(String,String.eq(format,"c"),w => nx110_c_verified(library),w => p110_native_json(contract,policy,nx110_json_library(library))))),u =>
    IO.die(U32,1,"typed pair library refused"))

@unsafe
def p110_native_emit(+contract: String, +policy: String, +format: String, +library: NxLibrary) -> IO(U32):
  nx_choose(IO(U32),String.eq(policy,"pair") || String.eq(policy,"pair-take"),u =>
    p110_native_pair_emit(contract,policy,format,nx_choose(Nx110Library,String.eq(policy,"pair-take"),v => nx110_take_pair_library(library),v => nx110_pair_library(library))),u =>
    nx_choose(IO(U32),nxlib_verify(library),v => p110_native_print(
      nx_choose(String,String.eq(format,"qbe"),w => nxlib_qbe_verified(library),w =>
      nx_choose(String,String.eq(format,"c"),x => nxlib_c_verified(library),x => p110_native_json(contract,policy,nx110_json_scalar_library(library))))),v =>
      IO.die(U32,1,"owned scalar library refused")))

@unsafe
def p110_native_lowered(+contract: String, +policy: String, +format: String, result: NxcLibraryResult) -> IO(U32):
  match result:
    case NxcLibraryResult{library,ownership,+error}:
      nx_choose(IO(U32),String.is_empty(error),u => p110_native_emit(contract,policy,format,library),u => IO.die(U32,1,"owned lowering refused: " ++ error))

@unsafe
def p110_native_rt_emit(+contract: String, +policy: String, +format: String, +library: Nx110RtLibrary) -> IO(U32):
  nx_choose(IO(U32),nx110rt_verify(library),u => p110_native_print(
    nx_choose(String,String.eq(format,"qbe"),v => nxlib_qbe_verified(nx110rt_machine(library)),v =>
    nx_choose(String,String.eq(format,"c"),w => nx110rt_c_machine(nx110rt_machine(library)),w => p110_native_json(contract,policy,nx110_json_scalar_library(nx110rt_machine(library)))))),u =>
    IO.die(U32,1,"private runtime template library refused"))

@unsafe
def p110_native_rt_ready(+contract: String, +policy: String, +format: String, result: Nx110RtLibraryResult) -> IO(U32):
  match result:
    case Nx110RtLibraryResult{library,+error}:
      nx_choose(IO(U32),String.is_empty(error),u => p110_native_rt_emit(contract,policy,format,library),u => IO.die(U32,1,"private runtime lowering refused: " ++ error))

@unsafe
def p110_native_request_ready(+contract: String, +policy: String, +format: String, request: NR_Request) -> IO(U32):
  match request:
    case NR_Request{source,+book,names,paths,scope,bound}:
      +sources = p110_native_sources(contract,book)
      nx_choose(IO(U32),p110_native_rt_policy(policy),u =>
        p110_native_rt_ready(contract,policy,format,nx110rt_lower_library(sources,p110_native_ctors(),p110_native_exports(contract),nx_choose(String,String.eq(policy,"runtime-ir-atomic"),v => "atomic",v => "single"))),u =>
        p110_native_lowered(contract,policy,format,nxc_lower_library(sources,p110_native_ctors(),p110_native_exports(contract),p110_native_base_policy(policy))))

@unsafe
def p110_native_planned(+contract: String, +policy: String, +format: String, plan: P86Plan) -> IO(U32):
  match plan:
    case P86PlanError{error}: IO.die(U32,1,error)
    case P86PlanReady{request,verdict}: p110_native_request_ready(contract,policy,format,request)

@unsafe
def p110_native_prepared(+input: String, +text: String, +contract: String, +policy: String, +format: String, prepared: P86Preparation) -> IO(U32):
  match prepared:
    case P86PreparationError{error}: IO.die(U32,1,error)
    case P86PreparationReady{seed}: p110_native_planned(contract,policy,format,p86_plan(seed,input,text))

@unsafe
def p110_native_admitted(+input: String, +text: String, +contract: String, +policy: String, +format: String, +cached: Bool) -> IO(U32):
  do IO<U32>:
    +base : String <- p86_read_file(p110_native_base_path())
    nx_choose(IO(U32),cached,
      u => do IO<U32>:
        carrier : String <- p86_read_file(p110_native_cache_path())
        p110_native_prepared(input,text,contract,policy,format,p88_cache_prepare(p110_native_base_path(),base,carrier,p110_native_cache_stamp())),
      u => p110_native_prepared(input,text,contract,policy,format,p86_prepare(p110_native_base_path(),base)))

@unsafe
def p110_native_request(+input: String, +contract: String, +policy: String, +format: String, +cached: Bool) -> IO(U32):
  do IO<U32>:
    +text : String <- p86_read_file(input)
    nx_choose(IO(U32),String.eq(text,p110_native_contract_text(contract)),u => p110_native_admitted(input,text,contract,policy,format,cached),u => IO.die(U32,2,"source does not match frozen selected-library contract"))

@unsafe
def p110_native_args(args: List<&1,String>) -> IO(U32):
  match args:
    case Con{program,Con{+input,Con{+contract,Con{+format,Con{+policy,Con{+base_mode,Nil{}}}}}}}:
      nx_choose(IO(U32),String.starts_with(input,"/") && p110_native_contract_valid(contract) && p110_native_policy_valid(policy) &&
        (String.eq(format,"qbe") || String.eq(format,"c") || String.eq(format,"ir")) && (String.eq(base_mode,"cache") || String.eq(base_mode,"live")),u =>
        p110_native_request(input,contract,policy,format,String.eq(base_mode,"cache")),u => IO.die(U32,2,"invalid selected-library arguments"))
    case _: IO.die(U32,2,"usage: native-owned ABS_INPUT reverse|discard|duplicate|tail|last|append qbe|c|ir POLICY cache|live")

@unsafe
def main() -> IO(U32):
  do IO<U32>:
    args : List<&1,String> <- IO.args()
    p110_native_args(args)
