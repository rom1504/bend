import Base

def finish(+original: String, old: String, current: String, pair: Array<String> & String) -> IO(Unit):
  (a, first) = pair
  do IO<Unit>:
    Unit <- IO.print(old)
    Unit <- IO.print(current)
    Unit <- IO.print(first)
    IO.print(original)

def current(original: String, old: String, pair: Array<String> & String) -> IO(Unit):
  (a, now) = pair
  finish(original, old, now, Array.get(String, a, 0))

def swapped(original: String, pair: Array<String> & String) -> IO(Unit):
  (a, old) = pair
  current(original, old, Array.get(String, a, 3))

def observe(+original: String) -> IO(Unit):
  swapped(original, Array.swap(String, Array.new(String, 1n, original), 3, "new🙂"))

def main() -> IO(Unit):
  observe(String.reverse("λdees"))

#|seedλ
#|new🙂
#|seedλ
#|seedλ
