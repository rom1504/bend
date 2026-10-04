# Both pinned parsers must reject this compact Nat literal, never truncate it.
import Base

def main() -> Nat:
  4294967296n
