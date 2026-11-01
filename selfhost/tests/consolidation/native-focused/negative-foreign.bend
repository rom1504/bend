# Admission must reject this provider before attempting a native build.
import Base

def p108_missing() -> IO(U32):
  import "./absent-phase108-provider.c"

def main() -> IO(Unit):
  do IO<Unit>:
    value : U32 <- p108_missing()
    IO.print(U32.show(value))
