import Base

def join(a: String, b: String) -> String:
  String.append(a, b)

def main() -> IO(Unit):
  +f = {join("a") : String -> String}
  IO.print(String.append(f("b"), f("c")))

#|abac
