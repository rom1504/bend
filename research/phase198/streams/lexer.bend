# Project the linear producer's output directly into its stateful fold.
def stream.word(c: U32, st: Mode & U32) -> Mode & U32:
  (m, acc) = st
  step(m, c, acc)

def stream.char(c: Char, st: Mode & U32) -> Mode & U32:
  match c:
    case Chr{x}: stream.word(x, st)

def stream.ident(n: Nat, t: U32, st: Mode & U32) -> Mode & U32:
  match n:
    case 0n: st
    case 1n+p:
      +u = prng(t)
      stream.ident(p, u, stream.word(U32.add(97, U32.mod(u, 26)), st))

def stream.num(n: Nat, t: U32, st: Mode & U32) -> Mode & U32:
  match n:
    case 0n: st
    case 1n+p:
      +u = prng(t)
      stream.num(p, u, stream.word(U32.add(48, U32.mod(u, 10)), st))

def stream.expand(sl: Slot, c: U32, +t: U32, st: Mode & U32) -> Mode & U32:
  match sl:
    case Id{}: stream.ident(U32.to_nat(U32.inc(U32.and(t, 7))), t, st)
    case Nm{}: stream.num(U32.to_nat(U32.inc(U32.mod(t, 6))), t, st)
    case Op{}: stream.char(op.pick(U32.is_ne(U32.and(t, 2), 0), U32.is_ne(U32.and(t, 1), 0)), st)
    case Lit{}: stream.word(c, st)

def stream.step(+c: U32, t: U32, st: Mode & U32) -> Mode & U32:
  stream.expand(slot(c), c, t, st)

def stream.gen(tpl: String, +s: U32, +k: U32, st: Mode & U32) -> U32:
  match tpl:
    case SNil{}:
      (m, acc) = st
      flush(m, acc)
    case SCon{Chr{c}, tail}:
      stream.gen(tail, s, U32.inc(k), stream.step(c, salt(s, k), st))

def line(i: U32) -> U32:
  stream.gen(tpl(), seed(i), 0, (Gap{}, 0))
