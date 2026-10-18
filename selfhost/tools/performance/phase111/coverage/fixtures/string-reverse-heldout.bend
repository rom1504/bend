# Held out before candidate execution; invokes unchanged pinned Base code.
import Base

def p108_string_alias(+s: String) -> String:
  String.reverse.go(s, "!") ++ "/" ++ s

def main() -> IO(Unit):
  do IO<Unit>:
    Unit <- IO.print(String.reverse.go("", "tail"))
    Unit <- IO.print(String.reverse.go("a🙂é", "!"))
    Unit <- IO.print(String.reverse.go("é", ""))
    IO.print(p108_string_alias(String.reverse("cba")))

#|tail
#|é🙂a!
#|́e
#|cba!/abc
