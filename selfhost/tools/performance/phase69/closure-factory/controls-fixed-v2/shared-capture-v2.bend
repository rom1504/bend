import Base

def join(a: String, b: String) -> String:
  String.append(a, b)

def main() -> IO(Unit):
  +prefix = {"a" : String}
  f = {join(prefix) : String -> String}
  g = {join(prefix) : String -> String}
  IO.print(String.append(f("b"), g("c")))

#|abac
