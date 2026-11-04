# Complete unchanged parser/loader; private streaming observation only.
# The output is exactly the Phase155 full FResult serialization, without a hash.
@unsafe
def p160p_result(trace: FLoadTrace) -> FResult:
  match trace:
    case FLoadTrace{result,done,sources}: result

@unsafe
def p160p_parse(+source: String, +base: String) -> FResult:
  +end = U32.add(dg_width(base),2)
  p160p_result(f_load_graph_trace("/phase160/Main.bend",[
    FLocatedSource{FSource{"Base","/phase160/Base.bend",base},1,end},
    FLocatedSource{FSource{"Main","/phase160/Main.bend",source},end,U32.add(U32.add(end,dg_width(source)),1)}]))

@unsafe
def p160p_text(result: FResult) -> String:
  match result:
    case FResult{book,error,imports}:
      "R" ++ p155p_defs(book) ++ "E" ++ p155p_string(error) ++ "I" ++ p155p_terms(imports)

@unsafe
def p160p_written(pair: File & Result<&1,&1,U32 & String,Unit>) -> IO(File):
  (file,result) = pair
  match result:
    case Done{unit}: IO.pure(File,file)
    case Fail{error}:
      do IO<File>:
        Unit <- File.close(file)
        IO.pass(File,Fail{error})

@unsafe
def p160p_write(file: File, text: String) -> IO(File):
  do IO<File>:
    pair : File & Result<&1,&1,U32 & String,Unit> <- File.write(file,text)
    p160p_written(pair)

@unsafe
def p160p_defs(file: File, book: List<&2,KDef>) -> IO(File):
  match book:
    case Nil{}: p160p_write(file,"]")
    case Con{head,rest}:
      do IO<File>:
        next : File <- p160p_write(file,p155p_def(head))
        p160p_defs(next,rest)

@unsafe
def p160p_report(read_ms: Nat, parse_ms: Nat, observed: Nat) -> IO(U32):
  do IO<U32>:
    finished : Nat <- IO.now()
    Unit <- IO.print_err("phase160-parser read_ms=" ++ Nat.show(read_ms) ++ " parse_ms=" ++ Nat.show(parse_ms) ++ " observe_write_ms=" ++ Nat.show(Nat.sub(finished,observed)))
    IO.pure(U32,0)

@unsafe
def p160p_observe(+output: String, read_ms: Nat, parse_ms: Nat, observed: Nat, result: FResult) -> IO(U32):
  match result:
    case FResult{+book,+error,imports}:
      nt_choose(IO(U32),String.is_empty(error) && String.eq(dn(f_find("main",book)),"main"),
        u => p160p_success(output,read_ms,parse_ms,observed,book,error,imports),
        u => IO.die(U32,1,"phase160 parser refused: " ++ error))

@unsafe
def p160p_success(output: String, read_ms: Nat, parse_ms: Nat, observed: Nat,
    book: List<&2,KDef>, error: String, imports: List<&2,KTerm>) -> IO(U32):
  do IO<U32>:
    opened : File <- IO.try(File,File.open(output,"w"))
    header : File <- p160p_write(opened,"R")
    body : File <- p160p_defs(header,book)
    tail : File <- p160p_write(body,"E" ++ p155p_string(error) ++ "I" ++ p155p_terms(imports))
    Unit <- File.close(tail)
    p160p_report(read_ms,parse_ms,observed)

@unsafe
def p160p_parsed(started: Nat, prepared: Nat, output: String, result: FResult) -> IO(U32):
  do IO<U32>:
    parsed : Nat <- IO.now()
    p160p_observe(output,Nat.sub(prepared,started),Nat.sub(parsed,prepared),parsed,result)

@unsafe
def p160p_files(input: String, base: String, output: String) -> IO(U32):
  do IO<U32>:
    started : Nat <- IO.now()
    source : String <- p86_read_file(input)
    prelude : String <- p86_read_file(base)
    prepared : Nat <- IO.now()
    p160p_parsed(started,prepared,output,p160p_parse(source,prelude))

@unsafe
def p160p_args(args: List<&1,String>) -> IO(U32):
  match args:
    case Con{+command,Con{+input,Con{+base,Con{+output,Nil{}}}}}:
      nt_choose(IO(U32),String.eq(command,"phase160-parser") && String.starts_with(input,"/") &&
        String.starts_with(base,"/") && String.starts_with(output,"/") &&
        Bool.not(String.eq(output,input)) && Bool.not(String.eq(output,base)),
        u => p160p_files(input,base,output),u => IO.die(U32,2,"expected phase160-parser ABS_INPUT ABS_BASE DISTINCT_ABS_OUTPUT"))
    case _: IO.die(U32,2,"expected phase160-parser ABS_INPUT ABS_BASE DISTINCT_ABS_OUTPUT")

@unsafe
def main() -> IO(U32):
  do IO<U32>:
    args : List<&1,String> <- IO.args()
    p160p_args(args)
