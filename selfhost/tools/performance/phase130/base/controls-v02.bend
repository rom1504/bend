@unsafe
def p130b_same(+expected: U32, read: P88Number) -> Bool:
  match read:
    case P88Number{P88Cursor{tail,True{}},actual}:
      U32.is_eq(expected,actual) && String.eq(tail,"tail")
    case other: False{}

@unsafe
def p130b_roundtrip(+value: U32) -> Bool:
  p130b_same(value,p130b_u32(P88Cursor{p130b_word(value) ++ "tail",True{}}))

@unsafe
def p130b_bad(read: P88Number) -> Bool:
  match read:
    case P88Number{P88Cursor{SNil{},False{}},0}: True{}
    case other: False{}

@unsafe
def p130b_control(+ok: Bool, +name: String) -> String:
  match ok:
    case True{}: name ++ ":pass"
    case False{}: name ++ ":fail"

@unsafe
def p130b_controls() -> List<&2,String>:
  [p130b_control(p130b_roundtrip(0),"word-zero"),
   p130b_control(p130b_roundtrip(1),"word-one"),
   p130b_control(p130b_roundtrip(65535),"word-low-max"),
   p130b_control(p130b_roundtrip(65536),"word-high-one"),
   p130b_control(p130b_roundtrip(2147483648),"word-string-head-bit"),
   p130b_control(p130b_roundtrip(4294967295),"word-u32-max"),
   p130b_control(p130b_bad(p130b_u32(P88Cursor{"",True{}})),"word-empty"),
   p130b_control(p130b_bad(p130b_u32(P88Cursor{SCon{Chr{65536},SNil{}},True{}})),"word-truncated"),
   p130b_control(p130b_bad(p130b_u32(P88Cursor{p130b_word(1),False{}})),"word-failed-cursor"),
   p130b_control(p130b_bad(p130b_u32(P88Cursor{SCon{Chr{65535},SCon{Chr{65536},"tail"}},True{}})),"word-low-range"),
   p130b_control(p130b_bad(p130b_u32(P88Cursor{SCon{Chr{131072},SCon{Chr{65536},"tail"}},True{}})),"word-low-high-range"),
   p130b_control(p130b_bad(p130b_u32(P88Cursor{SCon{Chr{65536},SCon{Chr{65535},"tail"}},True{}})),"word-high-low-range"),
   p130b_control(p130b_bad(p130b_u32(P88Cursor{SCon{Chr{65536},SCon{Chr{131072},"tail"}},True{}})),"word-high-range"),
   p130b_control(p130b_word_empty(p130b_u32(P88Cursor{p130b_word(4294967295),True{}})),"word-empty-suffix"),
   p130b_control(p130b_bad(p130b_u32(P88Cursor{"12\n",True{}})),"word-decimal-refused")]

@unsafe
def p130b_word_empty(read: P88Number) -> Bool:
  match read:
    case P88Number{P88Cursor{SNil{},True{}},4294967295}: True{}
    case other: False{}
