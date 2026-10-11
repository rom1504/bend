import Base

def main() -> F32:
  (a, old) = Array.swap(F32, Array.new(F32, 2n, -1.25), 1, 0.75)
  (a, got) = Array.get(F32, a, 1)
  F32.add(old, got)

#|-0.5
