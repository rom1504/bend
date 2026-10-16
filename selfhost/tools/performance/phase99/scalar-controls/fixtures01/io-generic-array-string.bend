import Base

def p98_array_string_walk(a: String, b: String, same: Bool) -> Bool:
  match a b same:
    case SNil{} SNil{} result: result
    case SNil{} SCon{h, t} result: False{}
    case SCon{h, t} SNil{} result: False{}
    case SCon{h1, t1} SCon{h2, t2} False{}: False{}
    case SCon{h1, t1} SCon{h2, t2} True{}:
      p98_array_string_walk(t1, t2, Char.is_eq(h1, h2))


def p98_array_string_observe(+value: String) -> String & Bool:
  (value, p98_array_string_walk(value, "Łx", True{}))

def p98_array_string_read(pair: Array<String> & String) -> String:
  (array, value) = pair
  value

def p98_array_string_show(pair: String & Bool) -> String:
  (value, same) = pair
  match same:
    case False{}: value ++ ":false"
    case True{}: value ++ ":true"

def main() -> IO(Unit):
  +source : String = "Łx"
  +copy : String = p98_array_string_read(Array.get(String, Array.new(String, 1n, source), 1))
  do IO<Unit>:
    IO.print_err("scalar-control")
    IO.print(p98_array_string_show(p98_array_string_observe(copy)))
    IO.print(copy)
    IO.print(source)

#|Łx:true
#|Łx
#|Łx
