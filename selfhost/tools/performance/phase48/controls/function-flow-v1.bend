import Base

law saffron.make:
  for +salt: U32
  U32 -> U32

def saffron.make(salt):
  +bias = U32.add(salt, 1)
  x => U32.add(bias, x)

law saffron.apply:
  for f: (U32 -> U32)
  for x: U32
  U32

def saffron.apply(f, x):
  f(x)

law saffron.sub:
  for +salt: U32
  U32 -> U32

def saffron.sub(salt):
  x => U32.sub(salt, x)

law sample:
  for +n: U32
  U32

def sample(n):
  saffron.apply(saffron.make(n), 7)

law ordered:
  for +n: U32
  U32

def ordered(n):
  saffron.apply(saffron.sub(n), saffron.apply(saffron.make(2), 3))

law fresh:
  for +n: U32
  U32

def fresh(n):
  U32.sub(saffron.apply(saffron.make(n), 4), saffron.apply(saffron.make(2), 1))

law returned:
  for +n: U32
  U32 -> U32

def returned(n):
  saffron.make(n)

law unknown:
  for f: (U32 -> U32)
  for x: U32
  U32

def unknown(f, x):
  saffron.apply(f, x)

law branched.factory:
  for b: Bool
  U32 -> U32

def branched.factory(b):
  match b:
    case True{}: x => U32.add(x, 1)
    case False{}: x => U32.sub(x, 1)

law branched:
  for b: Bool
  U32

def branched(b):
  saffron.apply(branched.factory(b), 9)

law retained:
  for +n: U32
  U32

def retained(n):
  early = saffron.make(n)
  late = saffron.make(2)
  U32.sub(saffron.apply(early, 4), saffron.apply(late, 1))
