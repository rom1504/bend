import Base

def worker(n: U32) -> U32:
  U32.add(n, 1)

# This definition is not reachable from main. Its marked call must not exclude
# worker from ordinary workers or select parallel runtime mode.
def unused() -> U32:
  worker!(100)

def main() -> U32:
  worker(41)

#|42
