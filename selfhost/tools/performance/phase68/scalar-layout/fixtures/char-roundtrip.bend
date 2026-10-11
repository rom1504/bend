import Base

def main() -> U32:
  (a, old) = Array.swap(Char, Array.new(Char, 2n, 'λ'), 1, '🦀')
  (a, got) = Array.get(Char, a, 1)
  U32.add(Char.to_u32(old), Char.to_u32(got))

#|130363
