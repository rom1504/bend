import Base

def finish(x: String, pair: Array<String> & String) -> String:
  (a, y) = pair
  String.append(x, y)

@unsafe
def first(pair: Array<String> & String) -> String:
  (a, x) = pair
  finish(x, Array.get_unchecked(String, a, 0))

@unsafe
def main() -> String:
  a = Array.new(String, 1n, "left")
  b = Array.set(String, a, 1, "right")
  first(Array.get_unchecked(String, b, 1))

#|"rightleft"
