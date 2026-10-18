# Complete finite top-byte equivalence. A U64 word shifted right56 always has
# one of these256 values; RFC is bit7 and constructor tag is low7 bits.
def nx110rt_predicate_byte(+byte: U32) -> Bool:
  U32.is_eq(nx_bool32(U32.is_eq(U32.and(byte,127),2) && U32.is_eq(U32.shrn(byte,7n),0)),nx_bool32(U32.is_eq(byte,2)))

@unsafe
def nx110rt_predicate_bytes(+byte: U32) -> Bool:
  nx_choose(Bool,U32.is_eq(byte,256),u => True{},u => nx110rt_predicate_byte(byte) && nx110rt_predicate_bytes(U32.inc(byte)))

@unsafe
def nx110rt_predicate_report() -> String:
  nxlib_control_result("runtime-ir-complete256-topbyte-equivalence",nx110rt_predicate_bytes(0))
