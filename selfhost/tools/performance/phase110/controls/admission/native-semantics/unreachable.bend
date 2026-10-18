# Canonical requested entry exists in source but is not reachable from main.
import Base

@unsafe
def p110_close_unreachable(xs: List<&2,String>) -> List<&2,String>:
  xs

def main() -> IO(Unit):
  IO.print("unrelated")

#|unrelated
