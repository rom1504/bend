import Base

law Ghost.request:
  IO(U32)

def Ghost.request():
  import "./live-foreign-v1.js"

def main() -> IO(Unit):
  do IO<Unit>:
    value : U32 <- Ghost.request()
    IO.print(U32.show(value))

#|phase52-live-initializer
#|123
