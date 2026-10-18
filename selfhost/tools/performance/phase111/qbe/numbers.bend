# QBE 1.3 accepts decimal integer tokens; preserve all 64 bits without host
# floating-point conversion, hexadecimal assumptions or an auxiliary C parser.
type P111QDecimal is Data:
  P111QDecimal{+lo: U32, +hi: U32, +digit: U32}

@unsafe
def p111q_div10(+lo: U32, +hi: U32) -> P111QDecimal:
  +a = U32.shrn(hi,16n)
  +b = U32.add(U32.mul(U32.mod(a,10),65536),U32.and(hi,65535))
  +c = U32.add(U32.mul(U32.mod(b,10),65536),U32.shrn(lo,16n))
  +d = U32.add(U32.mul(U32.mod(c,10),65536),U32.and(lo,65535))
  P111QDecimal{U32.add(U32.mul(U32.div(c,10),65536),U32.div(d,10)),
    U32.add(U32.mul(U32.div(a,10),65536),U32.div(b,10)),U32.mod(d,10)}

@unsafe
def p111q_decimal_step(+value: P111QDecimal, acc: String) -> String:
  match value:
    case P111QDecimal{lo,hi,digit}:
      p111q_decimal_go(lo,hi,SCon{Char.from_u32(U32.add(48,digit)),acc})

@unsafe
def p111q_decimal_go(+lo: U32, +hi: U32, +acc: String) -> String:
  nt_choose(String,U32.is_eq(lo,0) && U32.is_eq(hi,0),u => acc,
    u => p111q_decimal_step(p111q_div10(lo,hi),acc))

@unsafe
def p111q_u64(+lo: U32, +hi: U32) -> String:
  nt_choose(String,U32.is_eq(hi,0),u => U32.show(lo),u => p111q_decimal_go(lo,hi,""))
