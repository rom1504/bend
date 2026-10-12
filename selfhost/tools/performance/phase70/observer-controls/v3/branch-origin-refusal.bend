import Base
import ./strand.bend as S

# Different branches have different root maps; one fixed wrapper cannot serve
# both. Local facts from one echo/match arm must not leak into the other.
def pick(flip: Bool, x: S.Strand, y: S.Strand) -> (S.Strand & S.Strand) & U32:
  match flip:
    case True{}: ((x, y), 3)
    case False{}: ((y, x), 3)

def inspect(a: S.Strand, b: S.Strand, flip: Bool) -> (S.Strand & S.Strand) & U32:
  x = S.echo(a)
  y = S.echo(b)
  pick(flip, x, y)

def main() -> U32:
  S.finish_two(inspect(S.make(2), S.make(3), False{}))

#|108583
