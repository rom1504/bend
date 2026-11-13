# Exact public wrappers from Phase189's maintained typed x86 modules.
# The x86 CLI entry closure drops these API-only collection/consumer wrappers.
# Snapshot definitions take precedence; preparation adds only absent wrappers.

# Accumulation is reversed once. A refusal never exposes partial assembly.
@unsafe
def x181_program_piece(piece: X181Output, next: P134Cursor, available: KDef, acc: List<&2,X188Seq>) -> X181Output:
  match piece:
    case X181Output{chunks,+error}:
      nt_choose(X181Output,String.is_empty(error),
        u => x181_program_cursor(next,available,nt_reverse(X188Seq,chunks,acc)),
        u => X181Output{[],error})

@unsafe
def x181_program_cursor(cursor: P134Cursor, +available: KDef, acc: List<&2,X188Seq>) -> X181Output:
  match cursor:
    case P134Private{Nil{},context,next}: x181_program_cursor(next,available,acc)
    case P134Private{Con{head,rest},+context,next}:
      x181_program_piece(x181_program_private(head,context,available),P134Private{rest,context,next},available,acc)
    case P134Legacy{entries,context,next}: x181_program_cursor(next,available,acc)
    case P134Public{Nil{},context,next}: x181_program_cursor(next,available,acc)
    case P134Public{Con{head,rest},+context,next}:
      x181_program_piece(x181_program_public(head,context,available),P134Public{rest,context,next},available,acc)
    case P134Tables{Nil{}}: x181_program_cursor(P134Main{},available,acc)
    case P134Tables{Con{head,rest}}:
      x181_program_piece(x181_program_data(head,available),P134Tables{rest},available,acc)
    case P134Main{}: X181Output{nt_reverse(X188Seq,acc,[x181_program_main(),x181_program_note()]),""}
    case P134Data{items,first,rest}: X181Output{[],"x86 requires a complete data cursor"}
    case P134End{}: X181Output{[],"x86 cursor ended before program tables and entry"}

@unsafe
def x181_cursor(+cursor: P134Cursor) -> X181Output:
  x181_program_cursor(cursor,x181_cursor_index(cursor,missing()),[])

# P169Prepared is not a certificate. The owning frontend must construct it
# through the unchanged final admission path before invoking this renderer.
@unsafe
def x181_prepared(prepared: P169Prepared) -> X181Output:
  match prepared:
    case P169Prepared{forwarders,cursor,+error}:
      nt_choose(X181Output,String.is_empty(error),u => x181_cursor(cursor),u => X181Output{[],error})

@unsafe
def x188_assemble(code: X188Seq) -> X187ObjectResult:
  x187_build_finish(x187_build_seq(code,x187_build_empty()))
