# Shared decoder integration. Cursor mode is 0=failed, 1=canonical decimal,
# 2=two-scalar word. Format is chosen once; mixed numeric encodings refuse.
# Only compiler-local cursor Data changes; production native ABI is unchanged.
type P88Cursor is Data:
  P88Cursor{+text: String, +mode: U32}

@unsafe
def p130m_valid(+mode: U32) -> Bool:
  U32.is_eq(mode,1) || U32.is_eq(mode,2)

@unsafe
def p130m_status(valid: Bool, mode: U32) -> U32:
  match valid:
    case True{}: mode
    case False{}: 0

@unsafe
def p130m_initial(text: String, expected: String) -> U32:
  match text:
    case SCon{Chr{+first},rest}:
      match U32.is_ge(first,65536) && U32.is_le(first,131071) && String.starts_with(expected,"p130-word-pair-v1:"):
        case True{}: 2
        case False{}: 1
    case SNil{}: 1

@unsafe
def p88_u32(cursor: P88Cursor) -> P88Number:
  match cursor:
    case P88Cursor{text,1}: p88_digits(text,0,0)
    case P88Cursor{text,2}: p130m_word(text)
    case other: P88Number{P88Cursor{"",0},0}

@unsafe
def p130m_word(text: String) -> P88Number:
  match text:
    case SCon{Chr{+lo},SCon{Chr{+hi},tail}}:
      p130m_word_gate(tail,lo,hi,U32.is_ge(lo,65536) && U32.is_le(lo,131071) && U32.is_ge(hi,65536) && U32.is_le(hi,131071))
    case other: P88Number{P88Cursor{"",0},0}

@unsafe
def p130m_word_gate(tail: String, lo: U32, hi: U32, valid: Bool) -> P88Number:
  match valid:
    case True{}: P88Number{P88Cursor{tail,2},U32.add(U32.sub(lo,65536),U32.mul(U32.sub(hi,65536),65536))}
    case False{}: P88Number{P88Cursor{"",0},0}

@unsafe
def p88_digits(text: String, +acc: U32, +digits: U32) -> P88Number:
  match text:
    case SCon{'\n',tail}: P88Number{P88Cursor{tail,p130m_status(U32.is_ne(digits,0),1)},acc}
    case SCon{Chr{c},tail}:
      +d = U32.sub(c,48)
      p88_digit(tail,acc,digits,d,U32.is_lt(d,10) && U32.is_lt(digits,10) && (U32.is_eq(digits,0) || U32.is_ne(acc,0)) && (U32.is_lt(acc,429496729) || (U32.is_eq(acc,429496729) && U32.is_le(d,5))))
    case other: P88Number{P88Cursor{"",0},0}

@unsafe
def p88_digit(text: String, acc: U32, digits: U32, digit: U32, ok: Bool) -> P88Number:
  match ok:
    case True{}: p88_digits(text,U32.add(U32.mul(acc,10),digit),U32.inc(digits))
    case False{}: P88Number{P88Cursor{"",0},0}

@unsafe
def p88_text_size(read: P88Number) -> P88TextRead:
  match read:
    case P88Number{P88Cursor{text,+mode},+size}:
      p88_text_gate(text,size,mode,p130m_valid(mode) && U32.is_le(size,1048576))

@unsafe
def p88_text_gate(text: String, size: U32, mode: U32, ok: Bool) -> P88TextRead:
  match ok:
    case True{}: p88_text_chars(size,text,"",mode)
    case False{}: P88TextRead{P88Cursor{"",0},""}

@unsafe
def p88_text_chars(size: U32, text: String, acc: String, mode: U32) -> P88TextRead:
  match size text:
    case 0 SCon{'\n',tail}: P88TextRead{P88Cursor{tail,mode},String.reverse(acc)}
    case 0 other: P88TextRead{P88Cursor{"",0},""}
    case n SCon{Chr{+c},tail}:
      p88_text_char(tail,U32.sub(n,1),SCon{Chr{c},acc},mode,U32.is_le(c,1114111) && (U32.is_lt(c,55296) || U32.is_gt(c,57343)))
    case n other: P88TextRead{P88Cursor{"",0},""}

@unsafe
def p88_text_char(text: String, size: U32, acc: String, mode: U32, ok: Bool) -> P88TextRead:
  match ok:
    case True{}: p88_text_chars(size,text,acc,mode)
    case False{}: P88TextRead{P88Cursor{"",0},""}

@unsafe
def p88_state_bad(state: P88State) -> P88State:
  match state:
    case P88State{cursor,nodes,strings,made,sn,begin,end}:
      P88State{P88Cursor{"",0},nodes,strings,made,sn,begin,end}

@unsafe
def p88_number_read(nodes: Array<P88Node>, strings: Array<String>, made: U32, sn: U32, begin: U32, end: U32, read: P88Number) -> P88Step:
  match read:
    case P88Number{P88Cursor{text,+mode},n}:
      p130m_number_read(nodes,strings,made,sn,begin,end,text,mode,n,p130m_valid(mode))

@unsafe
def p130m_number_read(nodes: Array<P88Node>, strings: Array<String>, made: U32, sn: U32, begin: U32, end: U32, text: String, mode: U32, n: U32, valid: Bool) -> P88Step:
  match valid:
    case True{}: P88Step{P88State{P88Cursor{text,mode},nodes,strings,made,sn,begin,end},P88Word{n}}
    case False{}: P88Step{P88State{P88Cursor{"",0},nodes,strings,made,sn,begin,end},P88Bad{}}

@unsafe
def p88_node_gate(cursor: P88Cursor, nodes: Array<P88Node>, strings: Array<String>, made: U32, sn: U32, begin: U32, end: U32, id: U32, role: U32, ok: Bool) -> P88Step:
  match ok:
    case False{}: P88Step{P88State{P88Cursor{"",0},nodes,strings,made,sn,begin,end},P88Bad{}}
    case True{}: p88_node_got(cursor,strings,made,sn,begin,end,role,Array.get(P88Node,nodes,id))

@unsafe
def p88_string_gate(cursor: P88Cursor, nodes: Array<P88Node>, strings: Array<String>, made: U32, sn: U32, begin: U32, end: U32, id: U32, ok: Bool) -> P88Step:
  match ok:
    case False{}: P88Step{P88State{P88Cursor{"",0},nodes,strings,made,sn,begin,end},P88Bad{}}
    case True{}: p88_string_got(cursor,nodes,made,sn,begin,end,Array.get(String,strings,id))

@unsafe
def p88_roots_done(state: P88State, values: List<&2,P88Node>) -> P88Decoded:
  match state values:
    case P88State{P88Cursor{SNil{},mode},nodes,strings,made,sn,begin,end} Con{P88Defs{book},Con{P88Checked{checked},Con{P88Fresh{+fresh},Con{P88World{+world},Con{P88Frontend{+ready},Nil{}}}}}}:
      p130m_roots_ready(P88Products{book,fresh,ready,world},fresh,ready,world,p130m_valid(mode))
    case s other: P88DecodeError{"cache roots or trailing data"}

@unsafe
def p130m_roots_ready(products: P88Products, fresh: FFreshPrefixState, ready: FReadyPrefixState, world: KBasePreparedWorld, valid: Bool) -> P88Decoded:
  match valid:
    case True{}: p88_roots_ready(products,fresh,ready,world)
    case False{}: P88DecodeError{"cache roots or trailing data"}

@unsafe
def p88_strings_read(nodes: Array<P88Node>, strings: Array<String>, made: U32, sn: U32, begin: U32, end: U32, index: U32, total: U32, read: P88TextRead) -> P88Decoded:
  match read:
    case P88TextRead{P88Cursor{text,+mode},value}:
      p130m_strings_read(nodes,strings,made,sn,begin,end,index,total,text,mode,value,p130m_valid(mode))

@unsafe
def p130m_strings_read(nodes: Array<P88Node>, strings: Array<String>, made: U32, sn: U32, begin: U32, end: U32, +index: U32, total: U32, text: String, mode: U32, value: String, valid: Bool) -> P88Decoded:
  match valid:
    case True{}: p88_strings(P88State{P88Cursor{text,mode},nodes,Array.set(String,strings,index,value),made,sn,begin,end},U32.inc(index),total)
    case False{}: P88DecodeError{"cache string"}

@unsafe
def p88_decode_admitted(+text: String, +expected_stamp: String, +begin: U32, +end: U32) -> P88Decoded:
  p88_header_stamp(p88_text(P88Cursor{text,p130m_initial(text,expected_stamp)}),expected_stamp,begin,end)

@unsafe
def p88_header_stamp(read: P88TextRead, expected: String, begin: U32, end: U32) -> P88Decoded:
  match read:
    case P88TextRead{P88Cursor{text,+mode},stamp}:
      p88_header_gate(P88Cursor{text,mode},begin,end,p130m_valid(mode) && String.eq(stamp,expected))

@unsafe
def p88_header_counts(read: P88Number, +n: U32, +begin: U32, +end: U32) -> P88Decoded:
  match read:
    case P88Number{P88Cursor{text,+mode},+sn}:
      p88_header_allocate(P88Cursor{text,mode},n,sn,begin,end,p130m_valid(mode) && U32.is_ge(n,1) && U32.is_le(n,65536) && U32.is_le(sn,4096) && U32.is_ge(begin,1) && U32.is_gt(end,begin))
