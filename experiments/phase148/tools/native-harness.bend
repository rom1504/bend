# Both modes share fixed actual input/context lifetimes. Only complete unit work
# is repeated: encode (new), scalar pass, admission, decode (new), final check,
# complete rendering, write and temporary destruction. No cached candidate units.
type P148HSelected is Data:
  P148HSelected{+index: U32, +function: P113DFunction}
type P148HCase is Data:
  P148HCase{+function: P113DFunction, +ready: KDef}
type P148HText is Data:
  P148HText{+text: String, +error: String}

@unsafe
def p148h_cases(headers: List<&2,P113DFunction>, selected: List<&2,P148HSelected>, +ready: KDef, +index: U32) -> List<&2,P148HCase>:
  match headers selected:
    case _ Nil{}: []
    case Nil{} _: []
    case Con{+head,+rest} Con{P148HSelected{+wanted,+function},+next}:
      nt_choose(List<&2,P148HCase>,U32.is_eq(index,wanted),
        u => Con{P148HCase{function,ready},p148h_cases(rest,next,p113e_insert(ready,p113e_signature(head)),U32.inc(index))},
        u => p148h_cases(rest,Con{P148HSelected{wanted,function},next},p113e_insert(ready,p113e_signature(head)),U32.inc(index)))

@unsafe
def p148h_render_body(function: P113DFunction, ids: N111Ids, emit: Bool) -> String:
  match emit:
    case True{}: p113e_private(function,ids)
    case False{}: ""

@unsafe
def p148h_rendered(function: P113DFunction, ids: N111Ids, +error: String, emit: Bool) -> P148HText:
  nt_choose(P148HText,String.is_empty(error),u => P148HText{p148h_render_body(function,ids,emit),""},u => P148HText{"",error})

@unsafe
def p148h_final(+function: P113DFunction, ids: N111Ids, render: N111Ids, ready: KDef, emit: Bool) -> P148HText:
  p148h_rendered(function,render,p113e_function(function,ids,ready),emit)

@unsafe
def p148h_old_checked(function: P113DFunction, ids: N111Ids, render: N111Ids, ready: KDef, +error: String, emit: Bool) -> P148HText:
  nt_choose(P148HText,String.is_empty(error),u => p148h_final(function,ids,render,ready,emit),u => P148HText{"",error})

@unsafe
def p148h_old_optimized(+function: P113DFunction, +ids: N111Ids, render: N111Ids, +ready: KDef, emit: Bool) -> P148HText:
  p148h_old_checked(function,ids,render,ready,p147d_function(function,ids,ready),emit)

@unsafe
def p148h_new_result(unit: P148Unit, ids: N111Ids, render: N111Ids, ready: KDef, error: String, valid: Bool, emit: Bool) -> P148HText:
  match valid:
    case True{}: p148h_final(p148_unpack(unit),ids,render,ready,emit)
    case False{}: P148HText{"",error}

@unsafe
def p148h_new_checked(checked: P148Checked, ids: N111Ids, render: N111Ids, ready: KDef, emit: Bool) -> P148HText:
  match checked:
    case P148Checked{unit,+error}: p148h_new_result(unit,ids,render,ready,error,String.is_empty(error),emit)

@unsafe
def p148h_new_unit(unit: P148Unit, +ids: N111Ids, render: N111Ids, +ready: KDef, emit: Bool) -> P148HText:
  p148h_new_checked(p148v_check(unit,ids,ready),ids,render,ready,emit)

@unsafe
def p148h_transport(unit: P148Unit, ids: N111Ids, render: N111Ids, ready: KDef, emit: Bool) -> P148HText:
  match unit:
    case P148Bad{error}: P148HText{"",error}
    case P148Good{name,params,result,public,tape}:
      p148h_old_optimized(p113k_function(p148_unpack(P148Good{name,params,result,public,tape})),ids,render,ready,emit)

@unsafe
def p148h_work(+mode: String, +function: P113DFunction, +ids: N111Ids, +render: N111Ids, +ready: KDef, +emit: Bool) -> P148HText:
  nt_choose(P148HText,String.eq(mode,"new") || String.eq(mode,"new-analysis"),
    u => p148h_new_unit(p148o_function(p148_pack(function)),ids,render,ready,emit),
    u => nt_choose(P148HText,String.eq(mode,"transport"),
      v => p148h_transport(p148_pack(function),ids,render,ready,emit),
      v => p148h_old_optimized(p113k_function(function),ids,render,ready,emit)))

@unsafe
def p148h_text(+mode: String, +function: P113DFunction, +ids: N111Ids, +render: N111Ids, +ready: KDef) -> P148HText:
  p148h_work(mode,function,ids,render,ready,Bool.not(String.eq(mode,"old-analysis") || String.eq(mode,"new-analysis")))

@unsafe
def p148h_written(pair: File & Result<&1,&1,U32 & String,Unit>) -> IO(File):
  (file,result) = pair
  match result:
    case Done{unit}: IO.pure(File,file)
    case Fail{error}:
      do IO<File>:
        Unit <- File.close(file)
        IO.pass(File,Fail{error})

@unsafe
def p148h_write_ready(text: String, file: File, error: String, ready: Bool) -> IO(File):
  match ready:
    case True{}:
      do IO<File>:
        pair : File & Result<&1,&1,U32 & String,Unit> <- File.write(file,text)
        p148h_written(pair)
    case False{}:
      do IO<File>:
        Unit <- File.close(file)
        IO.die(File,2,error)

@unsafe
def p148h_write(text: P148HText, file: File) -> IO(File):
  match text:
    case P148HText{text,+error}: p148h_write_ready(text,file,error,String.is_empty(error))

@unsafe
def p148h_write_cases(cases: List<&2,P148HCase>, +mode: String, +ids: N111Ids, +render: N111Ids, file: File) -> IO(File):
  match cases:
    case Nil{}: IO.pure(File,file)
    case Con{P148HCase{function,ready},rest}:
      do IO<File>:
        file : File <- p148h_write(p148h_text(mode,function,ids,render,ready),file)
        p148h_write_cases(rest,mode,ids,render,file)

@unsafe
def p148h_loop(+cases: List<&2,P148HCase>, +mode: String, +ids: N111Ids, +render: N111Ids, left: U32, file: File) -> IO(U32):
  match left:
    case 0:
      do IO<U32>:
        Unit <- File.close(file)
        IO.pure(U32,0)
    case _:
      do IO<U32>:
        file : File <- p148h_write_cases(cases,mode,ids,render,file)
        p148h_loop(cases,mode,ids,render,U32.sub(left,1),file)

@unsafe
def p148h_open(+mode: String, +output: String, count: U32) -> IO(U32):
  +headers : List<&2,N111Segment> = p148h_headers()
  +constructors : List<&2,N_Constructor> = p148h_constructors()
  ids : N111Ids = N111Ids{p113e_originals(headers,missing()),ns_ctor_index(constructors,missing())}
  render : N111Ids = N111Ids{p111q_function_ids(headers,0,missing()),p111q_constructor_ids(constructors,0,missing())}
  cases : List<&2,P148HCase> = p148h_cases(p148h_direct_headers(),p148h_selected(),missing(),0)
  do IO<U32>:
    file : File <- IO.try(File,File.open(nt_choose(String,String.eq(output,"oracle"),u => "/dev/stdout",u => "/dev/null"),"a"))
    p148h_loop(cases,mode,ids,render,count,file)

@unsafe
def p148h_parsed(+mode: String, +output: String, parsed: Maybe<&2,U32>) -> IO(U32):
  match parsed:
    case None{}: IO.die(U32,2,"invalid unsigned repetition count")
    case Some{+count}:
      nt_choose(IO(U32),(String.eq(mode,"old") || String.eq(mode,"new") || String.eq(mode,"transport") || String.eq(mode,"old-analysis") || String.eq(mode,"new-analysis")) && U32.is_le(count,65536) &&
        (String.eq(output,"bench") || (String.eq(output,"oracle") && U32.is_eq(count,1) &&
          (String.eq(mode,"old") || String.eq(mode,"new") || String.eq(mode,"transport")))),
        u => p148h_open(mode,output,count),u => IO.die(U32,2,"expected full old/new/transport oracle 1 or supported bench COUNT<=65536"))

@unsafe
def p148h_args(args: List<&1,String>) -> IO(U32):
  match args:
    case Con{sentinel,Con{mode,Con{output,Con{count,Nil{}}}}}:
      nt_choose(IO(U32),String.eq(sentinel,"compact-unit"),
        u => p148h_parsed(mode,output,U32.read(count)),u => IO.die(U32,2,"expected compact-unit command"))
    case _: IO.die(U32,2,"usage: compact-unit old/new oracle/bench COUNT")

@unsafe
def main() -> IO(U32):
  do IO<U32>:
    args : List<&1,String> <- IO.args()
    p148h_args(args)
