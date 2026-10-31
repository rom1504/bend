
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
      p130m_initial_choice(U32.is_ge(first,65536) && U32.is_le(first,131071) && String.starts_with(expected,"p130-word-pair-v1:"))
    case SNil{}: 1


@unsafe
def p130m_initial_choice(word: Bool) -> U32:
  match word:
    case True{}: 2
    case False{}: 1


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
def p130m_number_read(nodes: Array<P88Node>, strings: Array<String>, made: U32, sn: U32, begin: U32, end: U32, text: String, mode: U32, n: U32, valid: Bool) -> P88Step:
  match valid:
    case True{}: P88Step{P88State{P88Cursor{text,mode},nodes,strings,made,sn,begin,end},P88Word{n}}
    case False{}: P88Step{P88State{P88Cursor{"",0},nodes,strings,made,sn,begin,end},P88Bad{}}


@unsafe
def p130m_roots_ready(products: P88Products, fresh: FFreshPrefixState, ready: FReadyPrefixState, world: KBasePreparedWorld, valid: Bool) -> P88Decoded:
  match valid:
    case True{}: p88_roots_ready(products,fresh,ready,world)
    case False{}: P88DecodeError{"cache roots or trailing data"}


@unsafe
def p130m_strings_read(nodes: Array<P88Node>, strings: Array<String>, made: U32, sn: U32, begin: U32, end: U32, +index: U32, total: U32, text: String, mode: U32, value: String, valid: Bool) -> P88Decoded:
  match valid:
    case True{}: p88_strings(P88State{P88Cursor{text,mode},nodes,Array.set(String,strings,index,value),made,sn,begin,end},U32.inc(index),total)
    case False{}: P88DecodeError{"cache string"}


@unsafe
def p130m_controls() -> List<&2,String>:
  [p130mc_row(p130mc_number(p88_u32(P88Cursor{"0\ntail",1}),1,0,"tail"),"decimal-zero"),
   p130mc_row(p130mc_number(p88_u32(P88Cursor{"4294967295\ntail",1}),1,4294967295,"tail"),"decimal-max"),
   p130mc_row(p130mc_number(p88_u32(P88Cursor{"01\ntail",1}),0,0,""),"decimal-leading-zero"),
   p130mc_row(p130mc_number(p88_u32(P88Cursor{"4294967296\n",1}),0,0,""),"decimal-overflow"),
   p130mc_row(p130mc_number(p88_u32(P88Cursor{"1",1}),0,0,""),"decimal-truncated"),
   p130mc_row(p130mc_number(p88_u32(P88Cursor{"\ntail",1}),0,0,"tail"),"decimal-empty-preserves-tail"),
   p130mc_row(p130mc_number(p88_u32(P88Cursor{p130mc_word(0) ++ "tail",2}),2,0,"tail"),"word-zero"),
   p130mc_row(p130mc_number(p88_u32(P88Cursor{p130mc_word(65536) ++ "tail",2}),2,65536,"tail"),"word-lane-boundary"),
   p130mc_row(p130mc_number(p88_u32(P88Cursor{p130mc_word(4294967295),2}),2,4294967295,""),"word-max-empty-tail"),
   p130mc_row(p130mc_number(p88_u32(P88Cursor{"0\n",0}),0,0,""),"failed-mode"),
   p130mc_row(p130mc_number(p88_u32(P88Cursor{"0\n",3}),0,0,""),"unknown-mode"),
   p130mc_row(p130mc_number(p88_u32(P88Cursor{p130mc_word(1),4294967295}),0,0,""),"unknown-large-mode"),
   p130mc_row(p130mc_number(p88_u32(P88Cursor{p130mc_word(1),1}),0,0,""),"word-in-decimal-refused"),
   p130mc_row(p130mc_number(p88_u32(P88Cursor{"1\n",2}),0,0,""),"decimal-in-word-refused"),
   p130mc_row(p130mc_next(p88_u32(P88Cursor{"1\n" ++ p130mc_word(2),1})),"mixed-decimal-then-word"),
   p130mc_row(p130mc_next(p88_u32(P88Cursor{p130mc_word(1) ++ "2\n",2})),"mixed-word-then-decimal"),
   p130mc_row(p130mc_text(p88_text(P88Cursor{"2\nλ🙂\ntail",1}),1,"λ🙂","tail"),"decimal-unicode-text"),
   p130mc_row(p130mc_text(p88_text(P88Cursor{p130mc_word(2) ++ "λ🙂\ntail",2}),2,"λ🙂","tail"),"word-unicode-text"),
   p130mc_row(p130mc_after_text(p88_text(P88Cursor{p130mc_word(0) ++ "\n1\n",2})),"text-preserves-word-mode"),
   p130mc_row(p130mc_after_text(p88_text(P88Cursor{"0\n\n" ++ p130mc_word(1),1})),"text-preserves-decimal-mode"),
   p130mc_row(U32.is_eq(p130m_initial("0\n","p130-word-pair-v1:old-text-stamp"),1),"decimal-not-routed-by-stamp"),
   p130mc_row(U32.is_eq(p130m_initial(p130mc_word(0),"p130-word-pair-v1:x"),2),"word-route"),
   p130mc_row(U32.is_eq(p130m_initial(p130mc_word(0),"old-stamp"),1),"word-with-old-namespace-refused"),
   p130mc_row(p130mc_error(p88_decode_admitted("0\n\n0\n0\n","",1,8),"cache header bounds"),"old-header-diagnostic"),
   p130mc_row(p130mc_error(p88_decode_admitted("0\n\n","wrong",1,8),"cache stamp"),"old-stamp-diagnostic"),
   p130mc_row(p130mc_error(p88_decode_admitted(p130mc_word(0) ++ "\n","old",1,8),"cache stamp"),"word-old-stamp-diagnostic")]
