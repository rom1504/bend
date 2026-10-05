import Base

type Packet<-T: Type> is Type:
  Packet{payload: T, count: U32}

law add:
  for a: U32
  for b: U32
  U32

def add(a, b):
  U32.add(a, b)

law capture:
  for seed: U32
  U32 -> U32

def capture(seed):
  x => U32.add(seed, x)

law factory:
  for n: Nat
  for seed: U32
  U32 -> U32

def factory(n, seed):
  match n:
    case 0n:
      x => U32.add(seed, x)
    case 1n+p:
      factory(p, U32.add(seed, 1))

law keep:
  for -T: Type
  for x: T
  T

def keep(T, x):
  x

law pack:
  for x: U32
  Packet<U32>

def pack(x):
  Packet{x, 7}

law unpack:
  for p: Packet<U32>
  U32

def unpack(p):
  match p:
    case Packet{payload, count}:
      U32.add(payload, count)

law tail:
  for n: Nat
  for acc: U32
  U32

def tail(n, acc):
  match n:
    case 0n:
      acc
    case 1n+p:
      tail(p, U32.add(acc, 1))

law nat.add:
  for a: Nat
  for b: Nat
  Nat

def nat.add(a, b):
  Nat.add(a, b)

law fl.add:
  for a: F32
  for b: F32
  F32

def fl.add(a, b):
  F32.add(a, b)

law fl.floor:
  for a: F32
  F32

def fl.floor(a):
  F32.floor(a)

law char.make:
  for n: U32
  Char

def char.make(n):
  Char.from_u32(n)

law text.join:
  for a: String
  for b: String
  String

def text.join(a, b):
  String.append(a, b)

law main.out:
  U32

def main.out():
  unpack(pack(35))

law main:
  IO(Unit)

def main():
  IO.print(U32.show(main.out()))

#|42

law order.stage:
  for n: U32
  Char -> String

def order.stage(n):
  bad = Char.from_u32(U32.add(55296, n))
  x => SCon{bad, SCon{x, SNil{}}}

law order.check:
  String

def order.check():
  order.stage(0, Char.from_u32(55297))


law invoke:
  for f: U32 -> U32
  for x: U32
  U32

def invoke(f, x):
  f(x)
