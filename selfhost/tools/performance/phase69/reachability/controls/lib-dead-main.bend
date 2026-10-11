import Base

def worker(n: U32) -> U32:
  U32.add(n, 1)

# A library's main is not a root of its importer.
def main() -> U32:
  worker!(100)
