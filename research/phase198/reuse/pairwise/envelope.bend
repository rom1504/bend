import Base

type Signal is Data:
  Reading{volts: U32}
  Fork{former: Signal, latter: Signal}

def envelope.order(a: U32, b: U32, flipped: Bool) -> Signal:
  match flipped:
    case False{}: Fork{Reading{a}, Reading{b}}
    case True{}: Fork{Reading{b}, Reading{a}}

def envelope.leaf(+a: U32, +b: U32, upper: Bool) -> Signal:
  envelope.order(a, b, Bool.xor(upper, U32.is_gt(a, b)))

def envelope.children(a: Signal, b: Signal) -> Signal:
  match a b:
    case Fork{a0, a1} Fork{b0, b1}: Fork{Fork{a0, b0}, Fork{a1, b1}}
    case Fork{a0, a1} Reading{b0}: Reading{0}
    case Reading{a0} Fork{b0, b1}: Reading{0}
    case Reading{a0} Reading{b0}: Reading{0}

def envelope(a: Signal, b: Signal, +upper: Bool) -> Signal:
  match a b:
    case Reading{x} Reading{y}: envelope.leaf(x, y, upper)
    case Reading{x} Fork{b0, b1}: Reading{0}
    case Fork{a0, a1} Reading{y}: Reading{0}
    case Fork{a0, a1} Fork{b0, b1}:
      x y = envelope(a0, b0, upper) envelope(a1, b1, upper)
      envelope.children(x, y)

def envelope.input(+depth: Nat, +s: U32) -> Signal:
  match depth:
    case 0n: Reading{s}
    case 1n+p: Fork{envelope.input(p, U32.add(U32.mul(s, 29), 3)), envelope.input(p, U32.add(U32.mul(s, 13), 5))}

def envelope.signature(t: Signal) -> U32:
  match t:
    case Reading{v}: v
    case Fork{x,y}: U32.add(U32.mul(envelope.signature(x), 71), envelope.signature(y))

def bench(size: U32, +seed: U32) -> U32:
  +d = U32.to_nat(size)
  envelope.signature(envelope(envelope.input(d, seed), envelope.input(d, U32.add(seed, 11)), False{}))

def main() -> IO(Unit):
  IO.print(U32.show(bench(4, 23)))
