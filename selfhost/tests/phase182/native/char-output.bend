import Base

def main() -> IO(Unit):
  do IO<Unit>:
    IO.print(U32.show(Char.to_u32(Char.from_u32(4294967295))))
    IO.print(SCon{Char.from_u32(55296),
      SCon{Char.from_u32(1114112), SCon{Char.from_u32(4294967295), SNil{}}}})
    IO.print(F32.show(10000000000.0))

#|4294967295
#|���
#|10000000000
