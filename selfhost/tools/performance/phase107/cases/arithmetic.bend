import Base

def mix(x: U32, y: U32) -> U32:
  U32.xor(U32.add(U32.mul(x, 1664525), 1013904223), y)

def bench(n: U32, +seed: U32) -> U32:
  +x = mix(n, seed)
  mix(x, U32.add(seed, 7))

def main() -> U32:
  bench(19, 23)
