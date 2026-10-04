# General backend controls: no names or shapes copied from timed benchmarks.
import Base

type Cargo is Data:
  Vacant{}
  Item{value: U32}
  Fork{left: Cargo, right: Cargo}

type Envelope is Data:
  Envelope{cargo: Cargo}

def cargo.make(depth: Nat, +seed: U32) -> Cargo:
  match depth:
    case 0n: Item{seed}
    case 1n+p: Fork{Item{seed}, cargo.make(p, U32.add(seed, 1))}

def cargo.sum(tree: Cargo) -> U32:
  match tree:
    case Vacant{}: 0
    case Item{x}: x
    case Fork{left, right}: U32.add(cargo.sum(left), cargo.sum(right))

def envelope.sum(box: Envelope) -> U32:
  match box:
    case Envelope{cargo}: cargo.sum(cargo)

def cargo.result(size: U32, seed: U32) -> U32:
  envelope.sum(Envelope{cargo.make(U32.to_nat(size), seed)})

def cargo.forward(size: U32, seed: U32) -> U32:
  cargo.result(size, seed)

def cargo.let(size: U32, seed: U32) -> U32:
  value = cargo.make(U32.to_nat(size), seed)
  envelope.sum(Envelope{value})

def cargo.empty() -> U32:
  envelope.sum(Envelope{Vacant{}})

def cargo.nullary() -> U32:
  cargo.result(4, 17)

def arithmetic(x: U32, y: U32) -> U32:
  U32.sub(U32.mul(x, 3), y)

def arithmetic.forward(x: U32, y: U32) -> U32:
  arithmetic(x, y)

def arithmetic.let(x: U32, y: U32) -> U32:
  scaled = U32.mul(x, 3)
  U32.sub(scaled, y)

def shift(x: U32) -> U32:
  U32.add(x, 7)

def invoke(f: U32 -> U32, x: U32) -> U32:
  f(x)

def known(x: U32) -> U32:
  invoke(shift, x)

def captured(seed: U32, x: U32) -> U32:
  invoke(y => U32.sub(seed, y), x)

def partial(x: U32) -> U32:
  subtract = U32.sub(31)
  subtract(x)

def retained(seed: U32) -> U32 -> U32:
  x => U32.sub(seed, x)

# These helpers are public runtime mutation/effect observation boundaries.
def observed.left(x: U32) -> U32:
  U32.add(x, 10)

def observed.right(x: U32) -> U32:
  U32.mul(x, 3)

def ordered(+x: U32) -> U32:
  U32.sub(observed.left(x), observed.right(x))

def deferred(seed: U32) -> U32 -> U32:
  x => U32.sub(observed.left(seed), observed.right(x))

# Mixed recursion + ADTs + callback application + scalar wraparound.
# Kept out of timing/admission until the first implementation is frozen.
def mixed(size: U32, seed: U32, salt: U32) -> U32:
  captured(salt, cargo.let(size, known(seed)))
