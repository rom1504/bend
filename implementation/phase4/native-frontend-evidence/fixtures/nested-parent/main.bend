import Base
import ./sub/a.bend as A
def main() -> IO(Unit):
  IO.print(U32.show(A.answer()))
