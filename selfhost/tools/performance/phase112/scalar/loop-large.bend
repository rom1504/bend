# Scalar work is a real dynamic self-tail loop; readback observes its final word.
import Base

@unsafe
def p112_scalar_loop(+remaining: U32, word: U32, done: Bool) -> U32:
  match done:
    case True{}: word
    case False{}:
      +next = U32.sub(remaining, 1)
      p112_scalar_loop(next, U32.add(U32.mul(word, 1664525), 1013904223), U32.is_zero(next))

def main() -> IO(Unit):
  IO.print(U32.show(p112_scalar_loop(1048576, 305419896, False{})))

#|1518622328
