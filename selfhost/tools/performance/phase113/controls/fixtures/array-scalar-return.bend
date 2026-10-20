import Base

# Both the array handle and scalar result cross two ordinary function returns.
def read(a: Array<U32>, index: U32) -> Array<U32> & U32:
  Array.get(U32, a, index)

def advance(pair: Array<U32> & U32) -> Array<U32> & U32:
  (a, +value) = pair
  (Array.set(U32, a, 1, U32.add(value, 10)), U32.add(value, 100))

def final_read(tag: U32, changed: U32, pair: Array<U32> & U32) -> IO(Unit):
  (a, original) = pair
  do IO<Unit>:
    Unit <- IO.print(U32.show(tag))
    Unit <- IO.print(U32.show(changed))
    IO.print(U32.show(original))

def changed_read(tag: U32, pair: Array<U32> & U32) -> IO(Unit):
  (a, changed) = pair
  final_read(tag, changed, read(a, 0))

def observe(pair: Array<U32> & U32) -> IO(Unit):
  (a, tag) = pair
  changed_read(tag, read(a, 1))

def main() -> IO(Unit):
  observe(advance(read(Array.new(U32, 4n, 7), 0)))

#|107
#|17
#|7
