# Experimental closed-image machine-unit framing. Payload rendering stays Bend.
# The reserved markers occur only between complete declarations/bundles.
@unsafe
def p135m_marker(+verb: String, +kind: U32, +unit: U32) -> String:
  "# P135/1 " ++ verb ++ " " ++ U32.show(kind) ++ " " ++ U32.show(unit) ++ "\n"

@unsafe
def p135m_written(pair: File & Result<&1,&1,U32 & String,Unit>) -> IO(File):
  (file,result) = pair
  match result:
    case Done{unit}: IO.pure(File,file)
    case Fail{error}:
      do IO<File>:
        Unit <- File.close(file)
        IO.pass(File,Fail{error})

@unsafe
def p135m_put(file: File, text: String) -> IO(File):
  do IO<File>:
    pair : File & Result<&1,&1,U32 & String,Unit> <- File.write(file,text)
    p135m_written(pair)

@unsafe
def p135m_lf(ending: Bool, file: File) -> IO(File):
  match ending:
    case False{}: IO.pure(File,file)
    case True{}: p135m_put(file,"\n")

@unsafe
def p135m_close(opened: Bool, file: File, kind: U32, unit: U32) -> IO(File):
  match opened:
    case False{}: IO.pure(File,file)
    case True{}: p135m_put(file,p135m_marker("END",kind,unit))

@unsafe
def p135m_rotate(+kind: U32, +old_kind: U32, count: U32) -> Bool:
  Bool.not(U32.is_eq(kind,old_kind)) || (U32.is_eq(kind,0) && U32.is_ge(count,1000))

@unsafe
def p135m_payload(file: File, kind: U32, complete: Bool, text: String, ending: Bool, next: P134Cursor, unit: U32, count: U32) -> IO(U32):
  do IO<U32>:
    file : File <- p135m_put(file,text)
    file : File <- p135m_lf(ending,file)
    p135m_drain(file,next,kind,unit,U32.add(count,Bool.to_u32(complete)))

@unsafe
def p135m_emit(rotate: Bool, file: File, +kind: U32, complete: Bool, text: String, ending: Bool, next: P134Cursor, +old_kind: U32, +unit: U32, count: U32) -> IO(U32):
  match rotate:
    case False{}: p135m_payload(file,kind,complete,text,ending,next,unit,count)
    case True{}:
      +new_unit = nt_choose(U32,U32.is_eq(old_kind,3),u => unit,u => U32.inc(unit))
      do IO<U32>:
        file : File <- p135m_close(Bool.not(U32.is_eq(old_kind,3)),file,old_kind,unit)
        file : File <- p135m_put(file,p135m_marker("BEGIN",kind,new_unit))
        p135m_payload(file,kind,complete,text,ending,next,new_unit,0)

@unsafe
def p135m_step(file: File, +old_kind: U32, +unit: U32, +count: U32, frame: P135MFrame) -> IO(U32):
  match frame:
    case P135MDone{}:
      do IO<U32>:
        file : File <- p135m_close(Bool.not(U32.is_eq(old_kind,3)),file,old_kind,unit)
        file : File <- p135m_put(file,"# P135/1 DONE " ++ U32.show(nt_choose(U32,U32.is_eq(old_kind,3),u => 0,u => U32.inc(unit))) ++ "\n")
        Unit <- File.close(file)
        IO.pure(U32,0)
    case P135MFrame{+kind,complete,text,ending,next}:
      p135m_emit(p135m_rotate(kind,old_kind,count),file,kind,complete,text,ending,next,old_kind,unit,count)

@unsafe
def p135m_drain(file: File, cursor: P134Cursor, kind: U32, unit: U32, count: U32) -> IO(U32):
  p135m_step(file,kind,unit,count,p135m_next(cursor))

@unsafe
def p135ms_write(path: String, emission: P111Emission) -> IO(U32):
  match emission:
    case P134Planned{plan}:
      do IO<U32>:
        file : File <- IO.try(File,File.open(path,"w"))
        p135m_drain(file,p134e_begin(plan),3,0,0)
    case P111Emission{chunks,+error}:
      IO.die(U32,1,nt_choose(String,String.is_empty(error),u => "units require a sealed emission plan",u => error))
