import Base

# A live constructor under Rwt exercises the motive/body annotation boundary.
# The rewrite shape follows the existing tests/reg/rwt_carb_binders.bend.
type P175Witness<-expected: U32> is Data:
  P175Witness{value: U32, -same: {value == expected : U32}, spare: U32}

def p175sw_wrap(e: {1 == 1 : U32}, +value: U32) -> P175Witness<value>:
  %e : P175Witness<value>;
  P175Witness{value,{==},U32.inc(value)}

def p175sw_read(-expected: U32, packet: P175Witness<expected>) -> U32 & U32:
  match packet:
    case P175Witness{value,same,spare}: (value,spare)

def main() -> (U32 & U32) & (U32 & U32):
  (p175sw_read(41,p175sw_wrap({==},41)),p175sw_read(7,p175sw_wrap({==},7)))

#|((41, 42), (7, 8))
