import Base
import ./strand.bend as S

# One owned input is copied into two outputs. The first observer scope permits
# exactly one transfer per root and must retain the ordinary ownership path.
def inspect(+xs: S.Strand) -> (S.Strand & S.Strand) & U32:
  ((xs, xs), 9)

def main() -> U32:
  S.finish_two(inspect(S.make(2)))

#|77889
