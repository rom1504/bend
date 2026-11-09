# One File owns stdout throughout emission. Only one function and at most 128
# data directives are rendered at a time; no whole-program text is collected.
# A later emission/write failure may leave partial bytes in the fresh output.
# The host must accept that artifact only after successful process completion.

type X181StreamSlice is Data:
  X181StreamSlice{+text: X188Seq, +rest: List<&2,P111QDatum>, +error: String}

@unsafe
def x181_stream_datum_error(item: P111QDatum, +available: KDef) -> String:
  match item:
    case P111QReloc{symbol,offset}: x181_program_symbol(symbol,available)
    case _: ""

@unsafe
def x181_stream_slice_checked(item: P111QDatum, rest: List<&2,P111QDatum>, available: KDef,
    remaining: U32, acc: List<&2,X188Seq>, error: String) -> X181StreamSlice:
  match error:
    case SNil{}:
      x181_stream_data_slice(rest,available,U32.sub(remaining,1),Con{x181_program_datum(item),acc})
    case SCon{head,tail}: X181StreamSlice{X188Empty{},[],SCon{head,tail}}

@unsafe
def x181_stream_slice_items(items: List<&2,P111QDatum>, +available: KDef,
    remaining: U32, acc: List<&2,X188Seq>) -> X181StreamSlice:
  match items:
    case Nil{}: X181StreamSlice{x188_finish(acc),[],""}
    case Con{+head,rest}:
      x181_stream_slice_checked(head,rest,available,remaining,acc,x181_stream_datum_error(head,available))

@unsafe
def x181_stream_data_slice(items: List<&2,P111QDatum>, available: KDef,
    remaining: U32, acc: List<&2,X188Seq>) -> X181StreamSlice:
  match remaining:
    case 0: X181StreamSlice{x188_finish(acc),items,""}
    case _: x181_stream_slice_items(items,available,remaining,acc)

@unsafe
def x181_stream_fail(file: File, error: String) -> IO(U32):
  do IO<U32>:
    Unit <- File.close(file)
    IO.die(U32,1,error)

@unsafe
def x181_stream_written(pair: File & Result<&1,&1,U32 & String,Unit>,
    rest: List<&2,X188Seq>, next: P134Cursor, available: KDef, ending: X188Seq) -> IO(U32):
  (file,result) = pair
  match result:
    case Done{unit}: x181_stream_chunks(file,rest,next,available,ending)
    case Fail{error}:
      do IO<U32>:
        Unit <- File.close(file)
        IO.pass(U32,Fail{error})

@unsafe
def x181_stream_chunks(file: File, chunks: List<&2,X188Seq>, next: P134Cursor,
    available: KDef, ending: X188Seq) -> IO(U32):
  match chunks:
    case Nil{}: x181_stream_drain(file,next,available,ending)
    case Con{head,rest}:
      do IO<U32>:
        pair : File & Result<&1,&1,U32 & String,Unit> <- File.write(file,x188_render(head))
        x181_stream_written(pair,rest,next,available,ending)

@unsafe
def x181_stream_piece_checked(file: File, chunks: List<&2,X188Seq>, next: P134Cursor,
    available: KDef, ending: X188Seq, error: String) -> IO(U32):
  match error:
    case SNil{}: x181_stream_chunks(file,chunks,next,available,ending)
    case SCon{head,tail}: x181_stream_fail(file,SCon{head,tail})

@unsafe
def x181_stream_piece(file: File, piece: X181Output, next: P134Cursor,
    available: KDef, ending: X188Seq) -> IO(U32):
  match piece:
    case X181Output{chunks,error}: x181_stream_piece_checked(file,chunks,next,available,ending,error)

@unsafe
def x181_stream_data_written(file: File, slice: X181StreamSlice,
    tables: List<&2,P111QData>, available: KDef, ending: X188Seq) -> IO(U32):
  match slice:
    case X181StreamSlice{text,rest,error}:
      x181_stream_piece(file,X181Output{[text],error},P134Data{rest,False{},tables},available,ending)

@unsafe
def x181_stream_table(file: File, data: P111QData,
    rest: List<&2,P111QData>, available: KDef) -> IO(U32):
  match data:
    case P111QData{+name,alignment,exported,items}:
      x181_stream_piece(file,X181Output{[x188_table_head(name,alignment,exported)],""},
        P134Data{items,True{},rest},available,X188One{PSize{name}})

@unsafe
def x181_stream_drain(file: File, cursor: P134Cursor, +available: KDef, ending: X188Seq) -> IO(U32):
  match cursor:
    case P134Private{Nil{},context,next}: x181_stream_drain(file,next,available,X188Empty{})
    case P134Private{Con{head,rest},+context,next}:
      x181_stream_piece(file,x181_program_private(head,context,available),
        P134Private{rest,context,next},available,X188Empty{})
    case P134Legacy{entries,context,next}: x181_stream_drain(file,next,available,X188Empty{})
    case P134Public{Nil{},context,next}: x181_stream_drain(file,next,available,X188Empty{})
    case P134Public{Con{head,rest},+context,next}:
      x181_stream_piece(file,x181_program_public(head,context,available),
        P134Public{rest,context,next},available,X188Empty{})
    case P134Tables{Nil{}}: x181_stream_drain(file,P134Main{},available,X188Empty{})
    case P134Tables{Con{head,rest}}: x181_stream_table(file,head,rest,available)
    case P134Data{Nil{},first,rest}:
      x181_stream_piece(file,X181Output{[ending],""},P134Tables{rest},available,X188Empty{})
    case P134Data{Con{head,rest},first,tables}:
      x181_stream_data_written(file,x181_stream_data_slice(Con{head,rest},available,128,[]),tables,available,ending)
    case P134Main{}:
      x181_stream_piece(file,X181Output{[x181_program_main(),x181_program_note()],""},P134End{},available,X188Empty{})
    case P134End{}:
      do IO<U32>:
        Unit <- File.close(file)
        IO.pure(U32,0)

@unsafe
def x181_stream_start(+cursor: P134Cursor, available: KDef) -> IO(U32):
  match cursor:
    case P134Data{items,first,rest}: IO.die(U32,1,"x86 requires a complete data cursor")
    case P134End{}: IO.die(U32,1,"x86 cursor ended before program tables and entry")
    case _:
      do IO<U32>:
        file : File <- IO.try(File,File.open("/dev/stdout","a"))
        x181_stream_drain(file,cursor,available,X188Empty{})

# Forwarder text is ignored; program.bend reconstructs the checked import ABI.
# The complete import index is computed once, before any body is released.
@unsafe
def x181_print(prepared: P169Prepared) -> IO(U32):
  match prepared:
    case P169Prepared{forwarders,+cursor,+error}:
      nt_choose(IO(U32),String.is_empty(error),
        u => x181_stream_start(cursor,x181_cursor_index(cursor,missing())),
        u => IO.die(U32,1,error))
