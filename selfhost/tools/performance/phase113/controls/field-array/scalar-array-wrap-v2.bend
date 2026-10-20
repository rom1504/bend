import Base

# Unique scalar arrays: power-of-two index wrap, swap/get/set/size and field order.

def u_size(old: U32, middle: U32, last: U32, pair: Array<U32> & U32) -> IO(Unit):
  (a, size) = pair
  do IO<Unit>:
    Unit <- IO.print(U32.show(old))
    Unit <- IO.print(U32.show(middle))
    Unit <- IO.print(U32.show(last))
    IO.print(U32.show(size))

def u_last(old: U32, middle: U32, pair: Array<U32> & U32) -> IO(Unit):
  (a, last) = pair
  u_size(old, middle, last, Array.size(U32, a))

def u_middle(old: U32, pair: Array<U32> & U32) -> IO(Unit):
  (a, middle) = pair
  u_last(old, middle, Array.get(U32, Array.set(U32, a, 11, 23), 3))

def u_start(pair: Array<U32> & U32) -> IO(Unit):
  (a, old) = pair
  u_middle(old, Array.get(U32, a, 7))

def b_size(old: Bool, middle: Bool, last: Bool, pair: Array<Bool> & U32) -> IO(Unit):
  (a, size) = pair
  do IO<Unit>:
    Unit <- IO.print(U32.show(Bool.to_u32(old)))
    Unit <- IO.print(U32.show(Bool.to_u32(middle)))
    Unit <- IO.print(U32.show(Bool.to_u32(last)))
    IO.print(U32.show(size))

def b_last(old: Bool, middle: Bool, pair: Array<Bool> & Bool) -> IO(Unit):
  (a, last) = pair
  b_size(old, middle, last, Array.size(Bool, a))

def b_middle(old: Bool, pair: Array<Bool> & Bool) -> IO(Unit):
  (a, middle) = pair
  b_last(old, middle, Array.get(Bool, Array.set(Bool, a, 11, False{}), 3))

def b_start(pair: Array<Bool> & Bool) -> IO(Unit):
  (a, old) = pair
  b_middle(old, Array.get(Bool, a, 7))

def c_size(old: Char, middle: Char, last: Char, pair: Array<Char> & U32) -> IO(Unit):
  (a, size) = pair
  do IO<Unit>:
    Unit <- IO.print(U32.show(Char.to_u32(old)))
    Unit <- IO.print(U32.show(Char.to_u32(middle)))
    Unit <- IO.print(U32.show(Char.to_u32(last)))
    IO.print(U32.show(size))

def c_last(old: Char, middle: Char, pair: Array<Char> & Char) -> IO(Unit):
  (a, last) = pair
  c_size(old, middle, last, Array.size(Char, a))

def c_middle(old: Char, pair: Array<Char> & Char) -> IO(Unit):
  (a, middle) = pair
  c_last(old, middle, Array.get(Char, Array.set(Char, a, 11, 'Z'), 3))

def c_start(pair: Array<Char> & Char) -> IO(Unit):
  (a, old) = pair
  c_middle(old, Array.get(Char, a, 7))

def f_size(old: F32, middle: F32, last: F32, pair: Array<F32> & U32) -> IO(Unit):
  (a, size) = pair
  do IO<Unit>:
    Unit <- IO.print(F32.show(old))
    Unit <- IO.print(F32.show(middle))
    Unit <- IO.print(F32.show(last))
    IO.print(U32.show(size))

def f_last(old: F32, middle: F32, pair: Array<F32> & F32) -> IO(Unit):
  (a, last) = pair
  f_size(old, middle, last, Array.size(F32, a))

def f_middle(old: F32, pair: Array<F32> & F32) -> IO(Unit):
  (a, middle) = pair
  f_last(old, middle, Array.get(F32, Array.set(F32, a, 11, 0.0), 3))

def f_start(pair: Array<F32> & F32) -> IO(Unit):
  (a, old) = pair
  f_middle(old, Array.get(F32, a, 7))

def main() -> IO(Unit):
  do IO<Unit>:
    Unit <- u_start(Array.swap(U32, Array.new(U32, 2n, 4294967295), 7, 9))
    Unit <- b_start(Array.swap(Bool, Array.new(Bool, 2n, False{}), 7, True{}))
    Unit <- c_start(Array.swap(Char, Array.new(Char, 2n, 'λ'), 7, '🙂'))
    f_start(Array.swap(F32, Array.new(F32, 2n, 1.5), 7, F32.neg(2.5)))

#|4294967295
#|9
#|23
#|4
#|0
#|1
#|0
#|4
#|955
#|128578
#|90
#|4
#|1.5
#|-2.5
#|0
#|4
