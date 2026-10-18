import Base

def main() -> IO(Unit):
  do IO<Unit>:
    Unit <- IO.print(List.last.go(&2, String, List.tail(&2, String, ["discard", "first", "λ🙂"]), "default"))
    Unit <- IO.print(List.last.go(&2, String, [], "default🙂"))
    IO.print(List.last.go(&2, String, List.tail(&2, String, ["only"]), "empty-tail"))

#|λ🙂
#|default🙂
#|empty-tail
