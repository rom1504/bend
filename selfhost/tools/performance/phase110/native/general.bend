# Live-only general entry. This factory reads and checks compiled-in exact Base
# bytes, constructs the mature seed internally and consumes its checked request.
# Public raw seed, book, certificate, or provenance-flag inputs are absent.
@unsafe
def p110_general_facts(names: List<&2,String>, +book: List<&2,KDef>) -> List<&2,KDef>:
  match names:
    case Nil{}: []
    case Con{name,rest}: p110_general_fact(ns_body(book,name),p110_general_facts(rest,book))

@unsafe
def p110_general_fact(+fact: KDef, +rest: List<&2,KDef>) -> List<&2,KDef>:
  nx_choose(List<&2,KDef>,String.eq(dk(fact),"NativeErasedBody"),u => Con{fact,rest},u => rest)

@unsafe
def p110_general_closed(+entry: String, +policy: String, +format: String, closure: NxeClosure) -> IO(U32):
  match closure:
    case NxeClosure{+sources,certificates,+exports,+error}:
      nx_choose(IO(U32),String.is_empty(error),u =>
        nx_choose(IO(U32),p110_native_rt_policy(policy),v =>
          p110_native_rt_ready(entry,policy,format,nx110rt_lower_library(sources,nxe_constructors(),exports,
            nx_choose(String,String.eq(policy,"runtime-ir-atomic"),w => "atomic",w => "single"))),v =>
          p110_native_lowered(entry,policy,format,nxc_lower_library(sources,nxe_constructors(),exports,p110_native_base_policy(policy)))),u =>
        IO.die(U32,1,"checked entry closure refused: " ++ error))

@unsafe
def p110_general_planned(+entry: String, +policy: String, +format: String, plan: P86Plan) -> IO(U32):
  match plan:
    case P86PlanError{error}: IO.die(U32,1,error)
    case P86PlanReady{NR_Request{source,book,names,paths,scope,bound},verdict}:
      p110_general_closed(entry,policy,format,nxe_close(source,p110_general_facts(names,book),[NxeRoot{entry,"entry"}]))

@unsafe
def p110_general_prepared(+input: String, +text: String, +entry: String, +policy: String, +format: String, preparation: P86Preparation) -> IO(U32):
  match preparation:
    case P86PreparationError{error}: IO.die(U32,1,error)
    case P86PreparationReady{seed}: p110_general_planned(entry,policy,format,p86_plan(seed,input,text))

@unsafe
def p110_general_request(+input: String, +entry: String, +policy: String, +format: String) -> IO(U32):
  do IO<U32>:
    +text : String <- p86_read_file(input)
    +base : String <- p86_read_file(p110_native_base_path())
    nx_choose(IO(U32),String.eq(base,p110_general_base_source()),u =>
      p110_general_prepared(input,text,entry,policy,format,p86_prepare(p110_native_base_path(),base)),u =>
      IO.die(U32,2,"general entry requires exact compiled Base path and bytes"))

@unsafe
def p110_general_args(args: List<&1,String>) -> IO(U32):
  match args:
    case Con{program,Con{+input,Con{mode,Con{+entry,Con{+format,Con{+policy,Con{base_mode,Nil{}}}}}}}}:
      nx_choose(IO(U32),String.starts_with(input,"/") && String.eq(mode,"general") && Bool.not(String.is_empty(entry)) &&
        p110_native_policy_valid(policy) && (String.eq(format,"qbe") || String.eq(format,"c") || String.eq(format,"ir")) && String.eq(base_mode,"live"),u =>
        p110_general_request(input,entry,policy,format),u => IO.die(U32,2,"usage: native-owned ABS_INPUT general SOURCE_ENTRY qbe|c|ir POLICY live"))
    case Con{program,Con{+input,Con{+contract,Con{+format,Con{+policy,Con{+base_mode,Nil{}}}}}}}:
      nx_choose(IO(U32),String.starts_with(input,"/") && p110_native_contract_valid(contract) && p110_native_policy_valid(policy) &&
        (String.eq(format,"qbe") || String.eq(format,"c") || String.eq(format,"ir")) && (String.eq(base_mode,"cache") || String.eq(base_mode,"live")),u =>
        p110_native_request(input,contract,policy,format,String.eq(base_mode,"cache")),u => IO.die(U32,2,"invalid selected-library arguments"))
    case _: IO.die(U32,2,"usage: native-owned ABS_INPUT CONTRACT qbe|c|ir POLICY cache|live; or ABS_INPUT general SOURCE_ENTRY qbe|c|ir POLICY live")
