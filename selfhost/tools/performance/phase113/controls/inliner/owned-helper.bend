import Base

def identity(text: String) -> String:
  text

def doubled(+text: String) -> String:
  String.append(identity(text), identity(text))

def observe(+text: String) -> IO(Unit):
  do IO<Unit>:
    Unit <- IO.print(doubled(text))
    Unit <- IO.print(text)
    IO.print(String.reverse(identity(text)))

def main() -> IO(Unit):
  observe(String.reverse("🙂cbaλ"))

#|λabc🙂λabc🙂
#|λabc🙂
#|🙂cbaλ
