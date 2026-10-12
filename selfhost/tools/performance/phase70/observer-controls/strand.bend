import Base

# Deliberately unrelated names: admission must follow structure and provenance.
type Strand is Data:
  Void{}
  Bead{word: U32, rest: Strand}

def make(+seed: U32) -> Strand:
  Bead{seed, Bead{U32.add(seed, 5), Bead{U32.add(seed, 9), Void{}}}}

def make_tail(+seed: U32) -> Strand:
  Bead{U32.add(seed, 5), Bead{U32.add(seed, 9), Void{}}}

def hash(xs: Strand, acc: U32) -> U32:
  match xs:
    case Void{}:
      acc
    case Bead{h, t}:
      hash(t, U32.add(U32.mul(acc, 17), h))

def probe(xs: Strand, at: Nat) -> Strand & U32:
  match xs:
    case Void{}:
      (Void{}, 0)
    case Bead{+h, t}:
      match at:
        case 0n:
          (Bead{h, t}, h)
        case 1n+p:
          (rest, value) = probe(t, p)
          (Bead{h, rest}, value)

def order(+x: U32, +y: U32) -> U32:
  less = U32.is_lt(x, y)
  match less:
    case True{}:
      1
    case False{}:
      equal = U32.is_eq(x, y)
      match equal:
        case True{}: 0
        case False{}: 2

def compare(a: Strand, b: Strand) -> (Strand & Strand) & U32:
  match a b:
    case Void{} Void{}:
      ((Void{}, Void{}), 0)
    case Void{} Bead{y, bt}:
      ((Void{}, Bead{y, bt}), 1)
    case Bead{x, at} Void{}:
      ((Bead{x, at}, Void{}), 2)
    case Bead{+x, at} Bead{+y, bt}:
      +sign = order(x, y)
      equal = U32.is_eq(sign, 0)
      match equal:
        case True{}:
          (roots, answer) = compare(at, bt)
          (ar, br) = roots
          ((Bead{x, ar}, Bead{y, br}), answer)
        case False{}:
          ((Bead{x, at}, Bead{y, bt}), sign)

def finish_one(p: Strand & U32) -> U32:
  (root, value) = p
  U32.add(U32.mul(hash(root, 0), 10), value)

def finish_two(p: (Strand & Strand) & U32) -> U32:
  (roots, value) = p
  (a, b) = roots
  U32.add(U32.mul(hash(a, 0), 100), U32.add(U32.mul(hash(b, 0), 10), value))

def echo(xs: Strand) -> Strand:
  match xs:
    case Void{}: Void{}
    case Bead{h, t}: Bead{h, t}

def overflow(+n: U32) -> Nat:
  Nat.mul(U32.to_nat(n), U32.to_nat(n))
