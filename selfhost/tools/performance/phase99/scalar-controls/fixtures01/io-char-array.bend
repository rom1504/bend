import Base

def finish(r: Array<Char> & Char) -> U32:
  (a, x) = r
  Char.to_u32(x)

def swapped(r: Array<Char> & Char) -> U32:
  (a, old) = r
  U32.add(Char.to_u32(old), finish(Array.get(Char, a, 1)))

def main() -> IO(Unit):
  do IO<Unit>:
    IO.print_err("scalar-control")
    IO.print(U32.show(swapped(Array.swap(Char, Array.new(Char, 2n, 'λ'), 1, '🦀'))))

#|130363
