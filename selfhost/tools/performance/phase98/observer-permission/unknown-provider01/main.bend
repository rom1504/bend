import Base

def outside.echo(value: U32) -> IO(U32):
  import "./foreign-refusal.c"
  import "./foreign-refusal.js"

def main() -> IO(Unit):
  do IO<Unit>:
    seed : U32 <- outside.echo(2)
    IO.print(U32.show(seed))

#|2
