# Finite transport predicates, not authentication or a whole-decoder proof.
@unsafe
def p130mc_word(+value: U32) -> String:
  SCon{Chr{U32.add(65536,U32.and(value,65535))},SCon{Chr{U32.add(65536,U32.div(value,65536))},SNil{}}}

@unsafe
def p130mc_number(read: P88Number, mode: U32, value: U32, tail: String) -> Bool:
  match read:
    case P88Number{P88Cursor{actual_text,actual_mode},actual_value}:
      U32.is_eq(mode,actual_mode) && U32.is_eq(value,actual_value) && String.eq(tail,actual_text)

@unsafe
def p130mc_text(read: P88TextRead, mode: U32, text: String, tail: String) -> Bool:
  match read:
    case P88TextRead{P88Cursor{actual_tail,actual_mode},actual_text}:
      U32.is_eq(mode,actual_mode) && String.eq(text,actual_text) && String.eq(tail,actual_tail)

@unsafe
def p130mc_next(read: P88Number) -> Bool:
  match read:
    case P88Number{cursor,value}: p130mc_number(p88_u32(cursor),0,0,"")

@unsafe
def p130mc_after_text(read: P88TextRead) -> Bool:
  match read:
    case P88TextRead{cursor,value}: p130mc_number(p88_u32(cursor),0,0,"")

@unsafe
def p130mc_error(result: P88Decoded, expected: String) -> Bool:
  match result:
    case P88DecodeError{error}: String.eq(error,expected)
    case other: False{}

@unsafe
def p130mc_row(valid: Bool, name: String) -> String:
  match valid:
    case True{}: name ++ ":pass"
    case False{}: name ++ ":fail"

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
