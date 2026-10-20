import Base

def combine(f: U32 -> U32, g: U32 -> U32, x: U32) -> U32:
  g(f(x))

def saturated(x: U32) -> U32:
  combine(y => U32.add(y,1), z => U32.mul(z,3), x)

def residual(+k: U32) -> (U32 -> U32):
  combine(y => U32.add(y,k), z => U32.mul(z,k))

def unknown_partial(f: U32 -> U32, g: U32 -> U32) -> (U32 -> U32):
  combine(f,g)

def text_combine(f: String -> String, g: String -> String, x: String) -> String:
  g(f(x))

def captured(+text: String) -> String:
  text_combine(value => text ++ value, value => value ++ text, "!")

def observe(+text: String) -> IO(Unit):
  do IO<Unit>:
    Unit <- IO.print(U32.show(saturated(4)))
    Unit <- IO.print(U32.show(residual(5)(2)))
    Unit <- IO.print(U32.show(unknown_partial(x => U32.add(x,2),x => U32.mul(x,4))(3)))
    Unit <- IO.print(captured(text))
    IO.print(text)

def main() -> IO(Unit):
  observe(String.reverse("🙂k"))

#|15
#|35
#|20
#|k🙂!k🙂
#|k🙂
