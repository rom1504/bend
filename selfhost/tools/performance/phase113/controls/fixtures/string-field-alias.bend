import Base

def pack(text: String, number: U32) -> String & U32:
  (text, U32.add(number, 3))

def reverse_field(pair: String & U32) -> U32 & String:
  (text, number) = pair
  (U32.mul(number, 2), String.reverse(text))

def show(+original: String, pair: U32 & String) -> IO(Unit):
  (number, +text) = pair
  do IO<Unit>:
    Unit <- IO.print(original)
    Unit <- IO.print(text)
    Unit <- IO.print(U32.show(number))
    Unit <- IO.print(text)
    IO.print(original)

def observe(+text: String) -> IO(Unit):
  show(text, reverse_field(pack(text, 7)))

def main() -> IO(Unit):
  observe(String.reverse("λtfel"))

#|leftλ
#|λtfel
#|20
#|λtfel
#|leftλ
