import Base

type P53Box is Type:
  P53Box{value: U32}

def opaque(h: U32 -> U32, f: U32 -> U32, g: U32 -> U32, +n: U32) -> U32:
  h(U32.mul(f(n), U32.add(g(U32.add(n, 1)), 3)))

def boxed(f: U32 -> U32, g: U32 -> U32, +n: U32) -> P53Box:
  P53Box{U32.mul(f(n), U32.add(g(U32.add(n, 1)), 3))}

def let.argument(f: U32 -> U32, g: U32 -> U32, +n: U32) -> U32:
  U32.mul(f(n), (x = g(U32.add(n, 1)); U32.add(x, 3)))

def deferred.context(f: U32 -> U32, g: U32 -> U32, +n: U32) -> (U32 -> U32) -> U32:
  h => h(U32.mul(f(n), U32.add(g(U32.add(n, 1)), 3)))
