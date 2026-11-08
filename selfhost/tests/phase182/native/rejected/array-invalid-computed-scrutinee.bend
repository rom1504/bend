import Base

# Array.get_unchecked's ordinary body is the portable semantic fallback.
# Only valid indexes are in contract; there is no unchecked native fast path.
@unsafe
def main() -> U32:
  a = Array.new(U32, 2n, 7)
  b = Array.set(U32, a, 3, 91)
  (c, x) = Array.get_unchecked(U32, b, 3)
  (d, y) = Array.get(U32, c, 0)
  U32.add(x, y)

#|98
