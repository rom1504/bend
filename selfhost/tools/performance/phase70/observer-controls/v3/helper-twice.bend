import Base
import ./strand.bend as S

# Each expansion of echo must get fresh match/field binders.
def inspect(a: S.Strand, b: S.Strand) -> (S.Strand & S.Strand) & U32:
  x = S.echo(a)
  y = S.echo(b)
  ((x, y), 5)

def main() -> U32:
  S.finish_two(inspect(S.make(2), S.make(3)))

#|80955
