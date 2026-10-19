import Base

# The 31-bit Word is returned as an owning value. The bounded no-tail rewrite
# must refuse this shape and preserve the original runtime materialization.
def escaping_tail(value: U32) -> Word(31n):
  match value:
    case U32{WCon{bit, tail}}: tail

def restore_low_zero(tail: Word(31n)) -> U32:
  U32{WCon{False{}, tail}}

def main() -> IO(Unit):
  do IO<Unit>:
    Unit <- IO.print(U32.show(restore_low_zero(escaping_tail(4294967295))))
    Unit <- IO.print(U32.show(restore_low_zero(escaping_tail(2147483649))))
    Unit <- IO.print(U32.show(restore_low_zero(escaping_tail(1))))
    IO.print(U32.show(restore_low_zero(escaping_tail(42))))

#|4294967294
#|2147483648
#|0
#|42
