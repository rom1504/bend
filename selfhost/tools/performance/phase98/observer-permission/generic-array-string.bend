import Base

def p98_array_string_observe(+value: String) -> String & Bool:
  (value, String.eq(value, "Łx"))

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
    IO.print(p98_array_string_show(p98_array_string_observe(copy)))
    IO.print(copy)
    IO.print(source)

#|Łx:true
#|Łx
#|Łx
