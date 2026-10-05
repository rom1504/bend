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

def carry(f: U32 -> U32) -> U32 -> U32:
  f

def capture.expression(f: U32 -> U32, h: U32 -> U32, n: U32) -> U32 -> U32:
  carry((x = f(n); k => U32.mul(x, h(k))))

def capture.inner(f: U32 -> U32, h: U32 -> U32, n: U32) -> U32 -> U32:
  carry((x = f(n); k => (y = h(k); U32.mul(x, y))))

def capture.siblings(f: U32 -> U32, g: U32 -> U32, +n: U32) -> U32:
  Tuple{left, right} = ((x = f(n); k => U32.add(x, k)), (x = g(U32.add(n, 1)); k => U32.add(x, k)))
  U32.mul(left(1), right(2))

def consume(value: U32, h: U32 -> U32) -> U32:
  h(value)

def partial.named(f: U32 -> U32, g: U32 -> U32, +n: U32) -> (U32 -> U32) -> U32:
  consume(U32.mul(f(n), U32.add(g(U32.add(n, 1)), 3)))

def maker(value: U32) -> (U32 -> U32) -> U32:
  h => h(value)

def oversaturated(f: U32 -> U32, g: U32 -> U32, h: U32 -> U32, +n: U32) -> U32:
  maker(U32.mul(f(n), U32.add(g(U32.add(n, 1)), 3)))(h)
