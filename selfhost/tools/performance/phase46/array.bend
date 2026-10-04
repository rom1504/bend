import Base
import ../phase37/fixtures-historical/local-fold.bend as W

def main() -> U32:
  W.bench(4096, 17)
