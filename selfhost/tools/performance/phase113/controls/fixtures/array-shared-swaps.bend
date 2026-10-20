import Base

def touch(pair: Array<U32> & Array<U32>) -> Array<U32> & Array<U32>:
  (original, copy) = pair
  (Array.set(U32, copy, 0, 9), original)

def swap(pair: Array<U32> & Array<U32>) -> Array<U32> & Array<U32>:
  (left, right) = pair
  (right, left)

def last_read(first: U32, pair: Array<U32> & U32) -> IO(Unit):
  (a, second) = pair
  do IO<Unit>:
    Unit <- IO.print(U32.show(first))
    IO.print(U32.show(second))

def first_read(other: Array<U32>, pair: Array<U32> & U32) -> IO(Unit):
  (released, first) = pair
  last_read(first, Array.get(U32, other, 0))

def observe(pair: Array<U32> & Array<U32>) -> IO(Unit):
  (left, right) = pair
  first_read(right, Array.get(U32, left, 0))

def main() -> IO(Unit):
  do IO<Unit>:
    Unit <- observe(swap(touch(Array.clone(U32, Array.new(U32, 3n, 5)))))
    observe(touch(Array.clone(U32, Array.new(U32, 3n, 5))))

#|5
#|9
#|9
#|5
