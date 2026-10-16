import Base

def p101_array_rows(values: List<&1, String>) -> String:
  match values:
    case Nil{}: ""
    case Con{head, rest}: head ++ "\n" ++ p101_array_rows(rest)

# Drop the entire repeated array while its extracted element survives.
def p101_array_escape(pair: Array<String> & String) -> String:
  (array, value) = pair
  value

def p101_array_checked(pair: Array<String> & String, +source: String, +tail: String) -> IO(Unit):
  (array, +escaped) = pair
  array = Array.set(String, array, 0, "first:" ++ tail)
  array = Array.set(String, array, 31, "middle:" ++ source)
  array = Array.set(String, array, 63, "last:" ++ tail)
  rows = p101_array_rows(Array.to_list(String, array))
  survivor = p101_array_escape(Array.get(String, Array.new(String, 7n, tail), 73))
  do IO<Unit>:
    IO.print("array\n" ++ rows)
    IO.print("escaped:" ++ escaped)
    IO.print("source:" ++ source)
    IO.print("tail:" ++ tail)
    IO.print("survivor:" ++ survivor)
    IO.print(U32.show(Bool.to_u32(String.eq(escaped, source))))

def main() -> IO(Unit):
  +source : String = String.append("λ\0", "🙂X")
  +tail : String = String.drop(source, 1n)
  p101_array_checked(Array.get(String, Array.new(String, 6n, source), 37), source, tail)
