import Base

def ordinary(text: String, number: U32) -> String:
  text ++ U32.show(number)

def capture(text: String) -> (U32 -> String):
  number => ordinary(text, number)

def apply(f: U32 -> String, number: U32) -> String:
  f(number)

def observe(+text: String) -> IO(Unit):
  f = capture(text)
  answer = ordinary(text, 41)
  do IO<Unit>:
    Unit <- IO.print(answer)
    Unit <- IO.print(text)
    Unit <- IO.print(apply(f, 7))
    IO.print(text)

def main() -> IO(Unit):
  observe(String.reverse("🙂=yek"))

#|key=🙂41
#|key=🙂
#|key=🙂7
#|key=🙂
