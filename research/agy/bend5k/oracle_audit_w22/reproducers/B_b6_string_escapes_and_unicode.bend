import Base
def show_s(+s: String) -> String:
  String.quote(s) ++ "|" ++ Nat.show(String.length(s))
def main() -> IO(Unit):
  IO.print(show_s("a\tb\"c\\d\u{00e9}"))
