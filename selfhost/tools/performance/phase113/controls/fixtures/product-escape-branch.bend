import Base

# A product escaping into a closure must retain owning String fields.
def use_pair(pair: String & U32, extra: U32) -> String:
  (text, value) = pair
  text ++ U32.show(U32.add(value, extra))

def escape(pair: String & U32) -> (U32 -> String):
  extra => use_pair(pair, extra)

def choose(flag: Bool, left: String, right: String) -> String & U32:
  match flag:
    case True{}: (left, 3)
    case False{}: (right, 8)

def apply(f: U32 -> String) -> String:
  f(4)

def main() -> IO(Unit):
  do IO<Unit>:
    Unit <- IO.print(apply(escape(choose(True{}, String.reverse("α=L"), String.reverse("β=R")))))
    IO.print(apply(escape(choose(False{}, String.reverse("α=L"), String.reverse("β=R")))))

#|L=α7
#|R=β12
