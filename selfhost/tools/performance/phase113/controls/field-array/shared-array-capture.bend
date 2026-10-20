import Base

# The captured owner observes the mutation through the other shared handle.
def capture(a: Array<U32>) -> (U32 -> (Array<U32> & U32)):
  i => Array.get(U32, a, i)

def finish(old: U32, pair: Array<U32> & U32) -> IO(Unit):
  (a, current) = pair
  do IO<Unit>:
    Unit <- IO.print(U32.show(old))
    IO.print(U32.show(current))

def changed(f: U32 -> (Array<U32> & U32), pair: Array<U32> & U32) -> IO(Unit):
  (a, old) = pair
  finish(old, f(1))

def observe(+a: Array<U32>) -> IO(Unit):
  f = capture(a)
  changed(f, Array.swap(U32, a, 1, 42))

def main() -> IO(Unit):
  observe(Array.new(U32, 1n, 5))

#|5
#|42
