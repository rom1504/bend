@unsafe
def p134wbc_repeat(+n: U32, +acc: String) -> String:
  nt_choose(String,U32.is_eq(n,0),u => acc,
    u => p134wbc_repeat(U32.sub(n,1),SCon{Char.from_u32(88),acc}))

@unsafe
def p134wbc_chunks(input: P134WInput, acc: List<&2,String>) -> List<&2,String>:
  p134wbc_result(p134wb_packet(input),acc)

@unsafe
def p134wbc_result(packet: P134Packet, acc: List<&2,String>) -> List<&2,String>:
  match packet:
    case P134PacketDone{}: nt_reverse(String,acc,[])
    case P134Packet{text,next,pieces,capped_chars}: p134wbc_chunks(next,Con{text,acc})

@unsafe
def p134wbc_bounds(input: P134WInput) -> Bool:
  p134wbc_bounds_step(p134wb_packet(input))

@unsafe
def p134wbc_bounds_step(packet: P134Packet) -> Bool:
  match packet:
    case P134PacketDone{}: True{}
    case P134Packet{text,next,pieces,capped_chars}:
      Bool.not(U32.is_eq(pieces,0)) && Bool.not(U32.is_gt(pieces,64)) &&
      (Bool.not(U32.is_gt(capped_chars,65536)) || U32.is_eq(pieces,1)) && p134wbc_bounds(next)

@unsafe
def p134wbc_single(+text: String, +ending: Bool, +expected: String) -> Bool:
  +input : P134WInput = P134WHeld{P134Piece{text,ending,P134End{}}}
  p134wbc_bounds(input) && String.eq(nt_join(p134wbc_chunks(input,[]),""),expected)

@unsafe
def p134wbc_empty(packet: P134Packet) -> Bool:
  match packet:
    case P134PacketDone{}: True{}
    case _: False{}

@unsafe
def p134wbc_split() -> Bool:
  +prefix = p134wbc_repeat(65500,"")
  p134wbc_split_first(p134wb_packet(P134WHeld{P134Piece{prefix,False{},P134Main{}}}),prefix)

@unsafe
def p134wbc_split_first(packet: P134Packet, prefix: String) -> Bool:
  match packet:
    case P134Packet{text,+next,pieces,capped_chars}:
      String.eq(text,prefix) && U32.is_eq(pieces,1) && U32.is_eq(capped_chars,65500) &&
      String.eq(nt_join(p134wbc_chunks(next,[]),""),p111q_main() ++ "\n")
    case _: False{}

@unsafe
def p134wbc_tables(+count: U32, +acc: List<&2,P111QData>) -> List<&2,P111QData>:
  nt_choose(List<&2,P111QData>,U32.is_eq(count,0),u => acc,
    u => p134wbc_tables(U32.sub(count,1),Con{P111QData{"part",8,False{},[P111QWord{count}]},acc}))

@unsafe
def p134wbc_data(+tables: List<&2,P111QData>) -> Bool:
  +input : P134WInput = P134WCursor{P134Tables{tables}}
  p134wbc_bounds(input) && String.eq(nt_join(p134wbc_chunks(input,[]),""),
    nt_join(p111q_data_chunks_go(tables,[]),"\n") ++ "\n" ++ p111q_main() ++ "\n")

@unsafe
def p134wbc_controls() -> List<&2,String>:
  +small = p134wbc_repeat(65535,"")
  +big = p134wbc_repeat(66536,"")
  [p113ft_row("batch-empty-stream",p134wbc_empty(p134wb_packet(P134WHeld{P134Done{}}))),
   p113ft_row("batch-empty-fragment",p134wbc_single("",False{},"")),
   p113ft_row("batch-empty-chunk-newline",p134wbc_single("",True{},"\n")),
   p113ft_row("batch-existing-final-newline",p134wbc_single("abc\n",True{},"abc\n\n")),
   p113ft_row("batch-no-newline-boundary",p134wbc_single("abc",False{},"abc")),
   p113ft_row("batch-exact-character-limit",p134wbc_single(small,True{},small ++ "\n")),
   p113ft_row("batch-oversized-alone",p134wbc_single(big,True{},big ++ "\n")),
   p113ft_row("batch-pending-lookahead",p134wbc_split()),
   p113ft_row("batch-piece-count-and-data",p134wbc_data(p134wbc_tables(70,[]))),
   p113ft_row("batch-large-data-fragments",p134wbc_data([P111QData{"many",4,False{},p134ec_datum_rows(10000,[])}]))]
