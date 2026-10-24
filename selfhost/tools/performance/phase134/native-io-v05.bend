# Bounded packet writer. No runtime changes; no whole-output text retained.
# At most64 original pieces and65536 characters per packet, except one
# oversized original piece emitted alone. One rendered lookahead may be held.
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
def p134w_plan(plan: P134EmissionPlan) -> IO(U32):
  do IO<U32>:
    file : File <- IO.try(File,File.open("/dev/stdout","a"))
    p134wb_drain(file,P134WCursor{p134e_begin(plan)})

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
