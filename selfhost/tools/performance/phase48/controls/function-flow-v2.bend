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

law saffron.bump:
  for +n: Nat
  Nat

def saffron.bump(n):
  Succ{n}

law saffron.natmake:
  for +n: Nat
  U32 -> U32

def saffron.natmake(n):
  +p = saffron.bump(n)
  x => U32.add(U32.from_nat(p), x)

law saffron.later:
  for +n: Nat
  U32

def saffron.later(n):
  U32.from_nat(Succ{n})

law failorder:
  for +n: Nat
  U32

def failorder(n):
  saffron.apply(saffron.natmake(n), saffron.later(n))

law saffron.ignore:
  for f: (U32 -> U32)
  for +unused: Nat
  for x: U32
  U32

def saffron.ignore(f, unused, x):
  f(x)

law unused:
  for +n: U32
  for +m: Nat
  U32

def unused(n, m):
  saffron.ignore(saffron.make(n), Succ{m}, 7)
