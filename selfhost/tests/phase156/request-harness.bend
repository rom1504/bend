# Isolated actual-request transport. The supervisor pins Base/source/image and
# requires a fresh output. Original ancestor clones are supplied as p156o_*.
# No warm cache, prepared carrier, literal fixture, timer or partial observation.

def p156h_valid(+mode: String) -> Bool:
  String.eq(mode,"old") || String.eq(mode,"publication") || String.eq(mode,"uses") || String.eq(mode,"both")

def p156h_publication(+mode: String) -> Bool:
  String.eq(mode,"publication") || String.eq(mode,"both")

def p156h_uses(+mode: String) -> Bool:
  String.eq(mode,"uses") || String.eq(mode,"both")

@unsafe
def p156h_plan(+mode: String, +seed: P86Seed, +path: String, +text: String) -> P86Plan:
  nt_choose(P86Plan,p156h_valid(mode),
    u => nt_choose(P86Plan,p156h_publication(mode),
      v => p86_plan(seed,path,text),v => p156o_p86_plan(seed,path,text)),
    u => P86PlanError{"phase156: invalid mode"})

@unsafe
def p156h_emission(+mode: String, +plan: P86Plan) -> P111Emission:
  nt_choose(P111Emission,p156h_valid(mode),
    u => nt_choose(P111Emission,p156h_uses(mode),
      v => p134e_plan(plan),v => p156o_p134e_plan(plan)),
    u => P111Emission{[],"phase156: invalid mode"})

# Compatibility emissions retain one newline per original chunk. Planned
# emissions use the maintained cursor writer, including legacy_end handling.
@unsafe
def p156h_chunk_line(pair: File & Result<&1,&1,U32 & String,Unit>, rest: List<&2,String>) -> IO(U32):
  (file,result) = pair
  match result:
    case Done{unit}: p156h_chunks(file,rest)
    case Fail{error}:
      do IO<U32>:
        Unit <- File.close(file)
        IO.pass(U32,Fail{error})

@unsafe
def p156h_chunk_text(pair: File & Result<&1,&1,U32 & String,Unit>, rest: List<&2,String>) -> IO(U32):
  (file,result) = pair
  match result:
    case Done{unit}:
      do IO<U32>:
        next : File & Result<&1,&1,U32 & String,Unit> <- File.write(file,"\n")
        p156h_chunk_line(next,rest)
    case Fail{error}:
      do IO<U32>:
        Unit <- File.close(file)
        IO.pass(U32,Fail{error})

@unsafe
def p156h_chunks(file: File, chunks: List<&2,String>) -> IO(U32):
  match chunks:
    case Nil{}:
      do IO<U32>:
        Unit <- File.close(file)
        IO.pure(U32,0)
    case Con{text,rest}:
      do IO<U32>:
        pair : File & Result<&1,&1,U32 & String,Unit> <- File.write(file,text)
        p156h_chunk_text(pair,rest)

@unsafe
def p156h_legacy(path: String, chunks: List<&2,String>) -> IO(U32):
  match chunks:
    case Nil{}: IO.die(U32,1,"phase156: empty compiler emission")
    case Con{head,rest}:
      do IO<U32>:
        file : File <- IO.try(File,File.open(path,"w"))
        p156h_chunks(file,Con{head,rest})

@unsafe
def p156h_write(+path: String, emitted: P111Emission) -> IO(U32):
  match emitted:
    case P134Planned{plan}:
      do IO<U32>:
        file : File <- IO.try(File,File.open(path,"w"))
        p134w_drain(file,p134e_begin(plan))
    case P111Emission{+chunks,+error}:
      nt_choose(IO(U32),String.is_empty(error),
        u => p156h_legacy(path,chunks),u => IO.die(U32,1,error))

@unsafe
def p156h_prepared(+mode: String, path: String, text: String, output: String, prepared: P86Preparation) -> IO(U32):
  match prepared:
    case P86PreparationError{error}: IO.die(U32,1,error)
    case P86PreparationReady{seed}: p156h_write(output,p156h_emission(mode,p156h_plan(mode,seed,path,text)))

@unsafe
def p156h_request(+base_path: String, +source_path: String, mode: String, output: String) -> IO(U32):
  do IO<U32>:
    base : String <- p86_read_file(base_path)
    source : String <- p86_read_file(source_path)
    p156h_prepared(mode,source_path,source,output,p86_prepare(base_path,base))

def p156h_paths(+base: String, +source: String, +output: String) -> Bool:
  String.starts_with(base,"/") && String.starts_with(source,"/") && String.starts_with(output,"/") &&
    Bool.not(String.eq(output,base)) && Bool.not(String.eq(output,source))

@unsafe
def p156h_args(args: List<&1,String>) -> IO(U32):
  match args:
    case Con{+command,Con{+base,Con{+source,Con{+mode,Con{+output,Nil{}}}}}}:
      nt_choose(IO(U32),String.eq(command,"transfer") && p156h_valid(mode) && p156h_paths(base,source,output),
        u => p156h_request(base,source,mode,output),
        u => IO.die(U32,2,"usage: transfer ABS_BASE ABS_SOURCE old|publication|uses|both DISTINCT_ABS_OUTPUT"))
    case _: IO.die(U32,2,"usage: transfer ABS_BASE ABS_SOURCE old|publication|uses|both DISTINCT_ABS_OUTPUT")

@unsafe
def p156h_main() -> IO(U32):
  do IO<U32>:
    args : List<&1,String> <- IO.args()
    p156h_args(args)

@unsafe
def main() -> IO(U32):
  p156h_main()
