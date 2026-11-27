import Base
def main() -> IO(Unit):
  c0 = Char.quote(39, Chr{0})
  c1 = Char.quote(39, Chr{10})
  c2 = Char.quote(39, Chr{39})
  c3 = Char.quote(39, Chr{92})
  c4 = Char.quote(39, Chr{233})
  IO.print(c0 ++ "|" ++ c1 ++ "|" ++ c2 ++ "|" ++ c3 ++ "|" ++ c4)
