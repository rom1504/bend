# Native compiler-owned framing. The supervisor copies authenticated old payload
# bytes for REUSE records; only Bend decides whether a semantic unit can reuse.
# Protocol2 counts bytes exactly as the pinned native io_utf8/File.write edge,
# without escaping or copying payload text. The host enforces a per-piece bound.
type P140RWritten is Data:
  P140RWritten{+cache: P140RCache, +hits: U32, +misses: U32, +pieces: U32}

@unsafe
def p140rw_width(+code: U32) -> U32:
  nt_choose(U32,U32.is_lt(code,128),u => 1,u =>
    nt_choose(U32,U32.is_lt(code,2048),v => 2,v =>
      nt_choose(U32,U32.is_lt(code,65536),w => 3,w => 4)))

@unsafe
def p140rw_bytes(text: String, count: U32) -> U32:
  match text:
    case SNil{}: count
    case SCon{Chr{code},rest}: p140rw_bytes(rest,U32.add(count,p140rw_width(code)))

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
        file : File <- p140rw_put(file,"# P140/2 DONE " ++ U32.show(ordinal) ++ "\n")
        Unit <- File.close(file)
        IO.pure(P140RWritten,P140RWritten{cache,hits,misses,ordinal})
    case P140RReuse{old,next}:
      do IO<P140RWritten>:
        file : File <- p140rw_put(file,"# P140/2 REUSE " ++ U32.show(ordinal) ++ " " ++ U32.show(old) ++ "\n")
        p140rw_drain(file,U32.inc(ordinal),next)
    case P140RText{+text,+ending,next}:
      do IO<P140RWritten>:
        file : File <- p140rw_put(file,"# P140/2 BEGIN " ++ U32.show(ordinal) ++ " " ++ U32.show(Bool.to_u32(ending)) ++ " " ++
          U32.show(p140rw_bytes(text,Bool.to_u32(ending))) ++ "\n")
        file : File <- p140rw_put(file,text)
        file : File <- p140rw_line(ending,file)
        # Delimiter newline is removed by transport; payload may end mid-line.
        file : File <- p140rw_put(file,"\n# P140/2 END " ++ U32.show(ordinal) ++ "\n")
        p140rw_drain(file,U32.inc(ordinal),next)

@unsafe
def p140rw_drain(file: File, ordinal: U32, state: P140RState) -> IO(P140RWritten):
  p140rw_step(file,ordinal,p140r_next(state))

@unsafe
def p140rw_plan(path: String, plan: P134EmissionPlan, cache: P140RCache) -> IO(P140RWritten):
  do IO<P140RWritten>:
    file : File <- IO.try(File,File.open(path,"w"))
    p140rw_drain(file,0,p140r_begin(plan,cache))

@unsafe
def p140rw_controls() -> List<&2,String>:
  [p128bs_control_row("frame-byte-empty",U32.is_eq(p140rw_bytes("",0),0)),
   p128bs_control_row("frame-byte-legacy-newline",U32.is_eq(p140rw_bytes("abc",1),4)),
   p128bs_control_row("frame-byte-unicode",U32.is_eq(p140rw_bytes("é😀\n",0),7)),
   p128bs_control_row("frame-byte-marker-payload",U32.is_eq(p140rw_bytes("\n# P140/2 END 0\n",0),16)),
   p128bs_control_row("frame-byte-width-boundaries",
     U32.is_eq(p140rw_width(127),1) && U32.is_eq(p140rw_width(128),2) &&
     U32.is_eq(p140rw_width(2047),2) && U32.is_eq(p140rw_width(2048),3) &&
     U32.is_eq(p140rw_width(65535),3) && U32.is_eq(p140rw_width(65536),4)),
   p128bs_control_row("frame-byte-nul",U32.is_eq(p140rw_width(0),1))]
