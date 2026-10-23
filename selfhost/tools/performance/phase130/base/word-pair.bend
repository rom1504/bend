# Experimental transport only. Two Unicode scalars U+10000..U+1FFFF encode a
# U32 little-endian in 16-bit lanes. This is NOT decimal-format autodetection.
# Existing decoder roles, bounds, readiness and reconstruction stay unchanged.
@unsafe
def p130b_word(+value: U32) -> String:
  SCon{Chr{U32.add(65536,U32.and(value,65535))},
    SCon{Chr{U32.add(65536,U32.div(value,65536))},SNil{}}}

@unsafe
def p130b_u32(cursor: P88Cursor) -> P88Number:
  match cursor:
    case P88Cursor{SCon{Chr{+lo},SCon{Chr{+hi},tail}},True{}}:
      p130b_word_read(tail,lo,hi,
        U32.is_ge(lo,65536) && U32.is_le(lo,131071) &&
        U32.is_ge(hi,65536) && U32.is_le(hi,131071))
    case other: P88Number{P88Cursor{"",False{}},0}

@unsafe
def p130b_word_read(tail: String, lo: U32, hi: U32, valid: Bool) -> P88Number:
  match valid:
    case True{}:
      P88Number{P88Cursor{tail,True{}},
        U32.add(U32.sub(lo,65536),U32.mul(U32.sub(hi,65536),65536))}
    case False{}: P88Number{P88Cursor{"",False{}},0}
