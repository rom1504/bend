# Raw streaming uses already-qualified File effects. Opening /dev/stdout in
# append mode preserves redirection contents and owns a separate descriptor.
# Linux native research path; the old pure API remains a collecting adapter.

@unsafe
def p134w_written(pair: File & Result<&1,&1,U32 & String,Unit>, next: P134Cursor) -> IO(U32):
  (file, result) = pair
  match result:
    case Done{unit}: p134w_drain(file,next)
    case Fail{error}:
      do IO<U32>:
        Unit <- File.close(file)
        IO.pass(U32,Fail{error})

@unsafe
def p134w_step(file: File, step: P134Step) -> IO(U32):
  match step:
    case P134Done{}:
      do IO<U32>:
        Unit <- File.close(file)
        IO.pure(U32,0)
    case P134Piece{+text,+legacy_end,next}:
      do IO<U32>:
        pair : File & Result<&1,&1,U32 & String,Unit> <- File.write(file,
          nt_choose(String,legacy_end,u => text ++ "\n",u => text))
        p134w_written(pair,next)

@unsafe
def p134w_drain(file: File, cursor: P134Cursor) -> IO(U32):
  p134w_step(file,p134e_next(cursor))

@unsafe
def p134w_plan(plan: P134EmissionPlan) -> IO(U32):
  do IO<U32>:
    file : File <- IO.try(File,File.open("/dev/stdout","a"))
    p134w_drain(file,p134e_begin(plan))

@unsafe
def p111_print_emission(result: P111Emission) -> IO(U32):
  match result:
    case P111Emission{chunks,+error}:
      nt_choose(IO(U32),String.is_empty(error),u => p111_print_chunks(chunks),
        u => IO.die(U32,1,error))
    case P134Planned{plan}: p134w_plan(plan)

@unsafe
def p111_native_request(+path: String, +base_path: String, +cache_path: String,
  +stamp: String, +cached: Bool) -> IO(U32):
  do IO<U32>:
    +source : String <- p86_read_file(path)
    +base : String <- p86_read_file(base_path)
    nt_choose(IO(U32),cached,
      u => do IO<U32>:
        carrier : String <- p86_read_file(cache_path)
        p111_print_emission(p134e_compile_source(path,source,base_path,base,carrier,stamp,True{})),
      u => p111_print_emission(p134e_compile_source(path,source,base_path,base,"","",False{})))
