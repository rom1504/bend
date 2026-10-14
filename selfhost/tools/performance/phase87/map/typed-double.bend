# Both paths really execute, as when the observer evaluates symbolic branches.
import Base

@unsafe
def route(+k: U32 -> U32) -> U32:
  U32.add(k(1), k(2))

def run(+seed: U32) -> U32:
  route(x => U32.add(seed, x))

def main() -> U32:
  run(40)

#|83
