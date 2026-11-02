# One executable, common captured context and full fresh pipelines per request.
# Final decoding, independent verification, QBE emission and destruction are paid.
type P154HCase is Data:
  P154HCase{+name: String, +ready: KDef}

type P154HResult is Data:
  P154HResult{+function: P113DFunction, +error: String}
type P154HText is Data:
  P154HText{+text: String, +error: String}

@unsafe
def p154h_old(candidate: P113DCandidate) -> P154HResult:
  match candidate:
    case P113DCandidate{function,error,calls}: P154HResult{p113k_function(function),error}

@unsafe
def p154h_new(candidate: P154DCandidate) -> P154HResult:
  match candidate:
    case P154DCandidate{function,error,calls}: P154HResult{p154c_decode_function(p154k_function(function)),error}

@unsafe
def p154h_result(+mode: String, +book: List<&2,KDef>, +name: String) -> P154HResult:
  nt_choose(P154HResult,String.eq(mode,"new"),u => p154h_new(p154d_candidate(book,name)),u => p154h_old(p113d_candidate(book,name)))

@unsafe
def p154h_rendered(function: P113DFunction, render: N111Ids, +error: String) -> P154HText:
  nt_choose(P154HText,String.is_empty(error),u => P154HText{p113e_private(function,render),""},u => P154HText{"",error})

@unsafe
def p154h_final(result: P154HResult, +ids: N111Ids, +render: N111Ids, +ready: KDef) -> P154HText:
  match result:
    case P154HResult{+function,+error}:
      nt_choose(P154HText,String.is_empty(error),u => p154h_rendered(function,render,p113e_function(function,ids,ready)),u => P154HText{"",error})

@unsafe
def p154h_text(+mode: String, +book: List<&2,KDef>, +name: String, ids: N111Ids, render: N111Ids, ready: KDef) -> P154HText:
  p154h_final(p154h_result(mode,book,name),ids,render,ready)

@unsafe
def p154h_written(pair: File & Result<&1,&1,U32 & String,Unit>) -> IO(File):
  (file,result) = pair
  match result:
    case Done{unit}: IO.pure(File,file)
    case Fail{error}:
      do IO<File>:
        Unit <- File.close(file)
        IO.pass(File,Fail{error})

@unsafe
def p154h_write_ready(text: String, file: File, error: String, ready: Bool) -> IO(File):
  match ready:
    case True{}:
      do IO<File>:
        pair : File & Result<&1,&1,U32 & String,Unit> <- File.write(file,text)
        p154h_written(pair)
    case False{}:
      do IO<File>:
        Unit <- File.close(file)
        IO.die(File,2,error)

@unsafe
def p154h_write(text: P154HText, file: File) -> IO(File):
  match text:
    case P154HText{text,+error}: p154h_write_ready(text,file,error,String.is_empty(error))

@unsafe
def p154h_prefix(headers: List<&2,P113DFunction>, +owner: String, +ready: KDef) -> KDef:
  match headers:
    case Nil{}: ready
    case Con{+head,rest}:
      match head:
        case P113DFunction{+name,params,result,public,body}:
          nt_choose(KDef,String.eq(name,owner),u => ready,u => p154h_prefix(rest,owner,p113e_insert(ready,p113e_signature(head))))

@unsafe
def p154h_prepare(names: List<&2,String>, +book: List<&2,KDef>, +headers: List<&2,P113DFunction>) -> List<&2,P154HCase>:
  match names:
    case Nil{}: []
    case Con{+name,rest}: Con{P154HCase{name,p154h_prefix(headers,p113d_public(book,name),missing())},p154h_prepare(rest,book,headers)}

@unsafe
def p154h_cases(names: List<&2,P154HCase>, +book: List<&2,KDef>, +mode: String, +ids: N111Ids, +render: N111Ids, file: File) -> IO(File):
  match names:
    case Nil{}: IO.pure(File,file)
    case Con{P154HCase{name,ready},rest}:
      do IO<File>:
        file : File <- p154h_write(p154h_text(mode,book,name,ids,render,ready),file)
        p154h_cases(rest,book,mode,ids,render,file)

@unsafe
def p154h_loop(+names: List<&2,P154HCase>, +book: List<&2,KDef>, +mode: String, +ids: N111Ids, +render: N111Ids, left: U32, file: File) -> IO(U32):
  match left:
    case 0:
      do IO<U32>:
        Unit <- File.close(file)
        IO.pure(U32,0)
    case _:
      do IO<U32>:
        file : File <- p154h_cases(names,book,mode,ids,render,file)
        p154h_loop(names,book,mode,ids,render,U32.sub(left,1),file)

@unsafe
def p154h_loaded(+mode: String, +output: String, count: U32, ids: N111Ids, render: N111Ids, headers: List<&2,P113DFunction>, names: List<&2,String>, result: P154RResult) -> IO(U32):
  match result:
    case P154RError{error}: IO.die(U32,2,error)
    case P154RReady{+book}:
      do IO<U32>:
        file : File <- IO.try(File,File.open(nt_choose(String,String.eq(output,"oracle"),u => "/dev/stdout",u => "/dev/null"),"a"))
        p154h_loop(p154h_prepare(names,book,headers),book,mode,ids,render,count,file)

@unsafe
def p154h_open(+family: U32, +mode: String, +output: String, count: U32) -> IO(U32):
  +headers : List<&2,N111Segment> = p154h_headers(family)
  +constructors : List<&2,N_Constructor> = p154h_constructors(family)
  ids : N111Ids = N111Ids{p113e_originals(headers,missing()),ns_ctor_index(constructors,missing())}
  render : N111Ids = N111Ids{p111q_function_ids(headers,0,missing()),p111q_constructor_ids(constructors,0,missing())}
  do IO<U32>:
    text : String <- p86_read_file(p154h_book_path(family))
    p154h_loaded(mode,output,count,ids,render,p154h_direct_headers(family),p154h_names(family),p154r_read(text))

@unsafe
def p154h_parsed(+family: U32, +mode: String, +output: String, parsed: Maybe<&2,U32>) -> IO(U32):
  match parsed:
    case None{}: IO.die(U32,2,"invalid repetition count")
    case Some{+count}:
      nt_choose(IO(U32),(String.eq(mode,"old") || String.eq(mode,"new")) && U32.is_le(count,65536) &&
        (String.eq(output,"bench") || (String.eq(output,"oracle") && U32.is_eq(count,1))),
        u => p154h_open(family,mode,output,count),u => IO.die(U32,2,"expected old/new oracle 1 or bench COUNT<=65536"))

@unsafe
def p154h_args(args: List<&1,String>) -> IO(U32):
  match args:
    case Con{sentinel,Con{+family,Con{mode,Con{output,Con{count,Nil{}}}}}}:
      nt_choose(IO(U32),(String.eq(sentinel,"numeric-unit") && (String.eq(family,"compiler") || String.eq(family,"map"))),u => p154h_parsed(Bool.to_u32(String.eq(family,"map")),mode,output,U32.read(count)),u => IO.die(U32,2,"expected numeric-unit"))
    case _: IO.die(U32,2,"usage: numeric-unit compiler/map old/new oracle/bench COUNT")

@unsafe
def main() -> IO(U32):
  do IO<U32>:
    args : List<&1,String> <- IO.args()
    p154h_args(args)
