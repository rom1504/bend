# Native compiler-owned framing. The supervisor copies authenticated old payload
# bytes for REUSE records; only Bend decides whether a semantic unit can reuse.
type P140RWritten is Data:
  P140RWritten{+cache: P140RCache, +hits: U32, +misses: U32, +pieces: U32}

@unsafe
def p140rw_written(pair: File & Result<&1,&1,U32 & String,Unit>) -> IO(File):
  (file,result) = pair
  match result:
    case Done{unit}: IO.pure(File,file)
    case Fail{error}:
      do IO<File>:
        Unit <- File.close(file)
        IO.pass(File,Fail{error})

@unsafe
def p140rw_put(file: File, text: String) -> IO(File):
  do IO<File>:
    pair : File & Result<&1,&1,U32 & String,Unit> <- File.write(file,text)
    p140rw_written(pair)

@unsafe
def p140rw_line(ending: Bool, file: File) -> IO(File):
  match ending:
    case False{}: IO.pure(File,file)
    case True{}: p140rw_put(file,"\n")

@unsafe
def p140rw_step(file: File, +ordinal: U32, step: P140RStep) -> IO(P140RWritten):
  match step:
    case P140REnd{cache,hits,misses}:
      do IO<P140RWritten>:
        file : File <- p140rw_put(file,"# P140/1 DONE " ++ U32.show(ordinal) ++ "\n")
        Unit <- File.close(file)
        IO.pure(P140RWritten,P140RWritten{cache,hits,misses,ordinal})
    case P140RReuse{old,next}:
      do IO<P140RWritten>:
        file : File <- p140rw_put(file,"# P140/1 REUSE " ++ U32.show(ordinal) ++ " " ++ U32.show(old) ++ "\n")
        p140rw_drain(file,U32.inc(ordinal),next)
    case P140RText{text,ending,next}:
      do IO<P140RWritten>:
        file : File <- p140rw_put(file,"# P140/1 BEGIN " ++ U32.show(ordinal) ++ " " ++ U32.show(Bool.to_u32(ending)) ++ "\n")
        file : File <- p140rw_put(file,text)
        file : File <- p140rw_line(ending,file)
        # Delimiter newline is removed by transport; payload may end mid-line.
        file : File <- p140rw_put(file,"\n# P140/1 END " ++ U32.show(ordinal) ++ "\n")
        p140rw_drain(file,U32.inc(ordinal),next)

@unsafe
def p140rw_drain(file: File, ordinal: U32, state: P140RState) -> IO(P140RWritten):
  p140rw_step(file,ordinal,p140r_next(state))

@unsafe
def p140rw_plan(path: String, plan: P134EmissionPlan, cache: P140RCache) -> IO(P140RWritten):
  do IO<P140RWritten>:
    file : File <- IO.try(File,File.open(path,"w"))
    p140rw_drain(file,0,p140r_begin(plan,cache))
