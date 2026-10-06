import Base

# Deliberately renamed: structure, checked Bool/Unit owners and quantities prove it.
def switchboard(-A: Type, +b: Bool, yes: Unit -> A, no: Unit -> A) -> A:
  match b:
    case True{}:
      yes(Unit{})
    case False{}:
      no(Unit{})

# Deliberately familiar spelling with the wrong semantics: must remain a call.
def kc(-A: Type, +b: Bool, yes: Unit -> A, no: Unit -> A) -> A:
  match b:
    case True{}:
      no(Unit{})
    case False{}:
      yes(Unit{})

def selected(+b: Bool, +x: U32) -> U32:
  switchboard(U32, b, u => x, u => U32.add(x, 7))

def counterfeit(+b: Bool, +x: U32) -> U32:
  kc(U32, b, u => x, u => U32.add(x, 1000))

def unit_value(+b: Bool) -> Unit:
  switchboard(Unit, b, u => u, u => u)

def nonliteral(+b: Bool, yes: Unit -> U32, no: Unit -> U32) -> U32:
  switchboard(U32, b, yes, no)

def observed(probe: U32 -> U32, yes: U32 -> U32, no: U32 -> U32, +x: U32) -> U32:
  switchboard(U32, U32.is_eq(probe(x), 10),
    u => yes(U32.add(x, 100)), u => no(U32.add(x, 200)))

# Condition's ordered native prefix must precede the later tuple-field prefix.
def composed(probe: U32 -> U32, later: U32 -> U32) -> U32 & U32:
  (switchboard(U32, U32.is_eq(probe(1), 8), u => 21, u => 22), U32.add(later(2), 0))

def raises(+b: Bool, +n: Nat) -> Nat:
  switchboard(Nat, b, u => n, u => Nat.add(n, 1n))

type ChoiceTail is Type:
  ChoiceTail{run: (Unit -> U32) -> U32}

def partial_make(+b: Bool, +x: U32) -> ChoiceTail:
  ChoiceTail{switchboard(U32, b, u => x)}

def partial_apply(box: ChoiceTail, +x: U32) -> U32:
  ChoiceTail{run} = box
  run(u => x)

def partial_value(+b: Bool, +x: U32) -> U32:
  partial_apply(partial_make(b, x), U32.add(x, 7))

# Full call returns a closure, and the surplus argument must retain old staging.
def overapplied(+b: Bool, +x: U32, y: U32) -> U32:
  switchboard(U32 -> U32, b, u => z => U32.add(x, z), u => z => U32.sub(x, z), y)

def captured(+b: Bool, +x: U32) -> U32 -> U32:
  switchboard(U32 -> U32, b, u => y => U32.add(x, y), u => y => U32.sub(x, y))

@unsafe
def countdown(n: Nat, +acc: U32) -> U32:
  match n:
    case 0n:
      acc
    case 1n+p:
      +rest: Nat = p
      switchboard(U32, U32.is_eq(U32.and(acc, 1), 0),
        u => countdown(rest, U32.add(acc, 1)), u => countdown(rest, U32.add(acc, 1)))

@unsafe
def orbit.a(n: Nat, +acc: U32) -> U32:
  match n:
    case 0n:
      acc
    case 1n+p:
      +rest: Nat = p
      switchboard(U32, U32.is_eq(U32.and(acc, 1), 0),
        u => orbit.b(rest, U32.add(acc, 1), 2), u => orbit.b(rest, U32.add(acc, 1), 2))

@unsafe
def orbit.b(n: Nat, +acc: U32, +bias: U32) -> U32:
  match n:
    case 0n:
      acc
    case 1n+p:
      +rest: Nat = p
      switchboard(U32, U32.is_eq(U32.and(acc, 1), 0),
        u => orbit.a(rest, U32.add(acc, bias)), u => orbit.a(rest, U32.add(acc, bias)))

@unsafe
def nested(n: Nat, +acc: U32) -> U32:
  match n:
    case 0n:
      acc
    case 1n+p:
      +rest: Nat = p
      U32.add(switchboard(U32, U32.is_eq(U32.and(acc, 1), 0),
        u => nested(rest, U32.add(acc, 1)), u => nested(rest, U32.add(acc, 1))), 1)
