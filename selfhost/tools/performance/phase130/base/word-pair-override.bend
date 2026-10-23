# Only for the isolated compact decoder image. Do not install on the compiler.
# Its externally authenticated format and expected stamp are distinct from P88.
@unsafe
def p88_u32(cursor: P88Cursor) -> P88Number:
  p130b_u32(cursor)
