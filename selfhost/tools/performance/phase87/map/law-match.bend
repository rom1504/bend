# Keep the original law and unsafe permission; change only branch ownership.
import Base

law route:
  for b: Bool
  for +k: U32 -> U32
  U32

@unsafe
def route(b, k):
  match b:
    case True{}: k(1)
    case False{}: k(2)

def run(+seed: U32, b: Bool) -> U32:
  route(b, x => U32.add(seed, x))

def main() -> U32:
  U32.add(run(40, True{}), run(40, False{}))

#|83
