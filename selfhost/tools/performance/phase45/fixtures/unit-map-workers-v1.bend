import Base

@unsafe
def grove(n: Nat, s: Set()) -> Set():
  match n:
    case 0n:
      s
    case 1n+rest:
      grove(rest, Set.add(Set.add(s, "λ"), "elm"))

@unsafe
def willow(flag: Bool) -> U32:
  match flag:
    case False{}:
      0
    case True{}:
      1

@unsafe
def finish(r: Set() & Bool, seed: U32) -> U32:
  (s, found) = r
  U32.add(seed, U32.add(U32.from_nat(Set.size(s)), willow(found)))

def bench(size: U32, seed: U32) -> U32:
  s: Set() = grove(U32.to_nat(size), {MTip{} : Set()})
  finish(Set.has(Set.del(s, "elm"), "λ"), seed)

@unsafe
def touch(u: Unit, seed: U32) -> U32:
  match u:
    case Unit{}:
      U32.add(seed, 1)

@unsafe
def knots(xs: List<&2, Unit>, seed: U32) -> U32:
  match xs:
    case Nil{}:
      seed
    case u <> rest:
      knots(rest, touch(u, seed))

@unsafe
def fern(x: Maybe<&2, Unit>, seed: U32) -> U32:
  match x:
    case None{}:
      seed
    case Some{u}:
      touch(u, seed)

def boxed(seed: U32) -> U32:
  +u: Unit = Unit{}
  fern(Some{u}, knots([u, u], seed))

def public_size(s: Set()) -> U32:
  U32.from_nat(Set.size(s))

def echo_unit(u: Unit) -> Unit:
  u

def new_unit(seed: U32) -> Unit:
  Unit{}

type Bead is Data:
  Bead{}

def foreign_payload(seed: U32) -> U32:
  m: Map<&2, Bead> = MLeaf{"bead", Bead{}}
  U32.add(seed, U32.from_nat(Map.size(&2, Bead, m)))
