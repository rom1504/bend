import Base

type P134Cursor is Data:
  P134ProbeCursor{+count: U32, +piece: String}

type P134Step is Data:
  P134Done{}
  P134Piece{+text: String, +legacy_end: Bool, +next: P134Cursor}

def p134e_next(cursor: P134Cursor) -> P134Step:
  match cursor:
    case P134ProbeCursor{+count,piece}: p134f_next(U32.is_eq(count,0),count,piece)

def p134f_next(stop: Bool, count: U32, +piece: String) -> P134Step:
  match stop:
    case True{}: P134Done{}
    case False{}: P134Piece{piece,True{},P134ProbeCursor{U32.sub(count,1),piece}}

@unsafe
def nt_choose(-A: Type, +b: Bool, yes: Unit -> A, no: Unit -> A) -> A:
  match b:
    case True{}: yes(Unit{})
    case False{}: no(Unit{})

# Chunks arrive in reverse output order. Only each new chunk is traversed by
# append; the growing suffix stays on its right.

# Module: src/back/native/text.bend:10

@unsafe
def nt_text_finish(xs: List<&2,String>, acc: String) -> String:
  match xs:
    case Nil{}: acc
    case Con{head,rest}: nt_text_finish(rest,head ++ acc)

type P134WInput is Data:
  P134WCursor{+cursor: P134Cursor}
  P134WHeld{+step: P134Step}

type P134Packet is Data:
  P134PacketDone{}
  P134Packet{+text: String, +next: P134WInput, +pieces: U32, +capped_chars: U32}

@unsafe
def p134wb_length(text: String, +count: U32) -> U32:
  p134wb_length_go(U32.is_eq(count,65537),text,count)

@unsafe
def p134wb_length_go(stop: Bool, text: String, count: U32) -> U32:
  match stop:
    case True{}: count
    case False{}:
      match text:
        case SNil{}: count
        case SCon{head,rest}:
          +next = U32.add(count,1)
          p134wb_length_go(U32.is_eq(next,65537),rest,next)

@unsafe
def p134wb_size(text: String, +ending: Bool) -> U32:
  +size = p134wb_length(text,0)
  nt_choose(U32,U32.is_eq(size,65537),u => size,
    u => U32.add(size,nt_choose(U32,ending,v => 1,v => 0)))

@unsafe
def p134wb_input(input: P134WInput) -> P134Step:
  match input:
    case P134WCursor{cursor}: p134e_next(cursor)
    case P134WHeld{step}: step

@unsafe
def p134wb_packet(input: P134WInput) -> P134Packet:
  p134wb_fill(input,[],0,0)

@unsafe
def p134wb_fill(input: P134WInput, acc: List<&2,String>, used: U32, count: U32) -> P134Packet:
  p134wb_step(p134wb_input(input),acc,used,count)

@unsafe
def p134wb_step(+step: P134Step, +acc: List<&2,String>, +used: U32, +count: U32) -> P134Packet:
  match step:
    case P134Done{}:
      nt_choose(P134Packet,U32.is_eq(count,0),u => P134PacketDone{},
        u => P134Packet{nt_text_finish(acc,""),P134WHeld{P134Done{}},count,used})
    case P134Piece{+text,+legacy_end,+next}:
      +size = p134wb_size(text,legacy_end)
      nt_choose(P134Packet,Bool.not(U32.is_eq(count,0)) && U32.is_gt(size,U32.sub(65536,used)),
        u => P134Packet{nt_text_finish(acc,""),P134WHeld{step},count,used},
        u => p134wb_append(text,legacy_end,next,size,acc,used,count))

@unsafe
def p134wb_append(text: String, +ending: Bool, +next: P134Cursor, +size: U32,
    acc: List<&2,String>, +used: U32, +count: U32) -> P134Packet:
  +parts : List<&2,String> = Con{text,acc}
  +parts = nt_choose(List<&2,String>,ending,u => Con{"\n",parts},u => parts)
  +total = U32.add(used,size)
  +number = U32.add(count,1)
  nt_choose(P134Packet,U32.is_gt(total,65535) || U32.is_eq(number,64),
    u => P134Packet{nt_text_finish(parts,""),P134WCursor{next},number,total},
    u => p134wb_fill(P134WCursor{next},parts,total,number))

@unsafe
def p134wb_written(pair: File & Result<&1,&1,U32 & String,Unit>, next: P134WInput) -> IO(U32):
  (file, result) = pair
  match result:
    case Done{unit}: p134wb_drain(file,next)
    case Fail{error}:
      do IO<U32>:
        Unit <- File.close(file)
        IO.pass(U32,Fail{error})

@unsafe
def p134wb_write(file: File, packet: P134Packet) -> IO(U32):
  match packet:
    case P134PacketDone{}:
      do IO<U32>:
        Unit <- File.close(file)
        IO.pure(U32,0)
    case P134Packet{text,next,pieces,capped_chars}:
      do IO<U32>:
        pair : File & Result<&1,&1,U32 & String,Unit> <- File.write(file,text)
        p134wb_written(pair,next)

@unsafe
def p134wb_drain(file: File, input: P134WInput) -> IO(U32):
  p134wb_write(file,p134wb_packet(input))

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


def p134f_bare_written(pair: File & Result<&1,&1,U32 & String,Unit>, next: P134Cursor) -> IO(U32):
  (file,result) = pair
  match result:
    case Done{unit}: p134f_bare(file,next)
    case Fail{error}:
      do IO<U32>:
        Unit <- File.close(file)
        IO.pass(U32,Fail{error})

def p134f_bare_end(ending: Bool, file: File, next: P134Cursor) -> IO(U32):
  match ending:
    case False{}: p134f_bare(file,next)
    case True{}:
      do IO<U32>:
        pair : File & Result<&1,&1,U32 & String,Unit> <- File.write(file,"\n")
        p134f_bare_written(pair,next)

def p134f_bare_text(pair: File & Result<&1,&1,U32 & String,Unit>, ending: Bool, next: P134Cursor) -> IO(U32):
  (file,result) = pair
  match result:
    case Done{unit}: p134f_bare_end(ending,file,next)
    case Fail{error}:
      do IO<U32>:
        Unit <- File.close(file)
        IO.pass(U32,Fail{error})

def p134f_bare_step(file: File, step: P134Step) -> IO(U32):
  match step:
    case P134Done{}:
      do IO<U32>:
        Unit <- File.close(file)
        IO.pure(U32,0)
    case P134Piece{text,ending,next}:
      do IO<U32>:
        pair : File & Result<&1,&1,U32 & String,Unit> <- File.write(file,text)
        p134f_bare_text(pair,ending,next)

def p134f_bare(file: File, cursor: P134Cursor) -> IO(U32):
  p134f_bare_step(file,p134e_next(cursor))

def p134f_repeat(stop: Bool, n: U32, acc: String) -> String:
  match stop:
    case True{}: acc
    case False{}:
      +next = U32.sub(n,1)
      p134f_repeat(U32.is_eq(next,0),next,SCon{Char.from_u32(88),acc})

def p134f_cursor(large: Bool) -> P134Cursor:
  match large:
    case False{}: P134ProbeCursor{4096,p134f_repeat(False{},1023,"")}
    case True{}: P134ProbeCursor{512,p134f_repeat(False{},8191,"")}

def p134f_run(raw: Bool, batch: Bool, file: File, cursor: P134Cursor) -> IO(U32):
  match raw:
    case True{}: p134w_drain(file,cursor)
    case False{}:
      match batch:
        case True{}: p134wb_drain(file,P134WCursor{cursor})
        case False{}: p134f_bare(file,cursor)

def p134f_value(value: Maybe<&2,Nat>, fallback: Nat) -> Nat:
  match value:
    case None{}: fallback
    case Some{n}: n

def p134f_args(args: List<String>, fallback: Nat) -> Nat:
  match args:
    case Nil{}: fallback
    case head <> rest: p134f_args(rest,p134f_value(Nat.read(head),fallback))

def p134f_start(+mode: U32) -> IO(U32):
  do IO<U32>:
    file : File <- IO.try(File,File.open("/dev/stdout","a"))
    p134f_run(U32.is_eq(U32.mod(mode,3),0),U32.is_eq(U32.mod(mode,3),1),file,p134f_cursor(U32.is_gt(mode,2)))

def main() -> IO(U32):
  do IO<U32>:
    args : List<String> <- IO.args()
    p134f_start(U32.from_nat(p134f_args(args,0n)))
