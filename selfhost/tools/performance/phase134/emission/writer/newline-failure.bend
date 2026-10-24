import Base

type P134Cursor is Data:
  P134End{}

type P134Step is Data:
  P134Done{}
  P134Piece{+text: String, +legacy_end: Bool, +next: P134Cursor}

@unsafe
def p134e_next(cursor: P134Cursor) -> P134Step:
  match cursor:
    case P134End{}: P134Done{}

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
def p134wn_end(ending: Bool, file: File, next: P134Cursor) -> IO(U32):
  match ending:
    case False{}: p134w_drain(file,next)
    case True{}:
      do IO<U32>:
        pair : File & Result<&1,&1,U32 & String,Unit> <- File.write(file,"\n")
        p134w_written(pair,next)

@unsafe
def p134wn_text(pair: File & Result<&1,&1,U32 & String,Unit>, ending: Bool, next: P134Cursor) -> IO(U32):
  (file,result) = pair
  match result:
    case Done{unit}: p134wn_end(ending,file,next)
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
    case P134Piece{text,legacy_end,next}:
      do IO<U32>:
        pair : File & Result<&1,&1,U32 & String,Unit> <- File.write(file,text)
        p134wn_text(pair,legacy_end,next)

@unsafe
def p134w_drain(file: File, cursor: P134Cursor) -> IO(U32):
  p134w_step(file,p134e_next(cursor))


@unsafe
def main() -> IO(U32):
  do IO<U32>:
    file : File <- IO.try(File,File.open("/dev/stdout","a"))
    p134w_step(file,P134Piece{"",True{},P134End{}})
