import Base
import ./strand.bend as S

def outside.echo(value: U32) -> IO(U32):
  import "./foreign-refusal.c"
  import "./foreign-refusal.js"

def main() -> IO(Unit):
  do IO<Unit>:
    seed : U32 <- outside.echo(2)
    IO.print(U32.show(S.finish_one(S.probe(S.make(seed), 1n))))

#|7087
