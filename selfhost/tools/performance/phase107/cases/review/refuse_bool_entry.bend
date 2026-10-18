import Base

def bench(b: Bool) -> U32:
  match b:
    case True{}: 1
    case False{}: 0

def main() -> U32:
  bench(True{})
