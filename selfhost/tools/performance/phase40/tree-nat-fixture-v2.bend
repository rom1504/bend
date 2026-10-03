import Base

# Mixed scalar/Nat/tree prefix independent of bitonic sorting. Every tagged
# intermediate remains visible to the source consumer or diagnostic full oracle.
type NatFlow is Data:
  NEnd{value: U32}
  NFork{left: NatFlow, right: NatFlow}

def natflow.turn(tree: NatFlow, +flag: Bool) -> NatFlow:
  match tree flag:
    case NEnd{x} _: NEnd{U32.add(x, 7)}
    case NFork{left, right} False{}: NFork{left, right}
    case NFork{left, right} True{}: NFork{right, left}

def natflow.join(+left: NatFlow, right: NatFlow, flag: Bool) -> NatFlow:
  match flag:
    case False{}: NFork{left, right}
    case True{}: NFork{left, left}

def natflow.flow(n: Nat, +flag: Bool, tree: NatFlow) -> NatFlow:
  match n:
    case 0n:
      match tree:
        case NEnd{x}: NEnd{x}
        case NFork{left, right}: NFork{left, right}
    case 1n+p:
      match tree:
        case NEnd{x}: NEnd{x}
        case NFork{left, right}:
          a b = natflow.flow(p, flag, natflow.turn(left, flag)) natflow.flow(p, flag, natflow.turn(right, flag))
          natflow.join(a, b, flag)

def natflow.make(n: Nat, +seed: U32) -> NatFlow:
  match n:
    case 0n: NEnd{seed}
    case 1n+p: NFork{natflow.make(p, U32.inc(seed)), NEnd{U32.xor(seed, 91)}}

def natflow.score(tree: NatFlow, acc: U32) -> U32:
  match tree:
    case NEnd{x}: U32.add(acc, x)
    case NFork{left, right}: natflow.score(right, U32.add(natflow.score(left, acc), 1))

def bench(+depth: U32, +seed: U32) -> U32:
  natflow.score(natflow.flow(U32.to_nat(depth), U32.is_zero(U32.mod(seed, 2)), natflow.make(U32.to_nat(depth), seed)), 0)

# A computed equal predecessor is deliberately outside origin-based admission.
law natflow.computed:
  for n: Nat
  for +flag: Bool
  for tree: NatFlow
  NatFlow

@unsafe
def natflow.computed(n, flag, tree):
  match n:
    case 0n: tree
    case 1n+p:
      match tree:
        case NEnd{x}: NEnd{x}
        case NFork{left, right}:
          a b = natflow.computed(Nat.add(p, 0n), flag, left) natflow.computed(Nat.add(p, 0n), flag, right)
          natflow.join(a, b, flag)

def computed_check(+depth: U32, +seed: U32) -> U32:
  natflow.score(natflow.computed(U32.to_nat(depth), False{}, natflow.make(U32.to_nat(depth), seed)), 0)

# A reconstructed parent coordinate also refuses. Termination here instead
# follows the separate tree shape, which is outside this Nat-coordinate proof.
law natflow.parent:
  for n: Nat
  for +flag: Bool
  for tree: NatFlow
  NatFlow

@unsafe
def natflow.parent(n, flag, tree):
  match n:
    case 0n: tree
    case 1n+p:
      match tree:
        case NEnd{x}: NEnd{x}
        case NFork{left, right}:
          a b = natflow.parent(Nat.add(p, 1n), flag, left) natflow.parent(Nat.add(p, 1n), flag, right)
          natflow.join(a, b, flag)

def parent_check(+depth: U32, +seed: U32) -> U32:
  natflow.score(natflow.parent(U32.to_nat(depth), False{}, natflow.make(U32.to_nat(depth), seed)), 0)

# Right recursion observes the completed left result, so the independent-child
# rule must refuse even though both Nat coordinates are proper predecessors.
def natflow.dependent(n: Nat, +flag: Bool, tree: NatFlow) -> NatFlow:
  match n:
    case 0n: tree
    case 1n+p:
      match tree:
        case NEnd{x}: NEnd{x}
        case NFork{left, right}:
          +a = natflow.dependent(p, flag, left)
          b = natflow.dependent(p, U32.is_zero(natflow.score(a, 0)), right)
          natflow.join(a, b, flag)

def dependent_check(+depth: U32, +seed: U32) -> U32:
  natflow.score(natflow.dependent(U32.to_nat(depth), False{}, natflow.make(U32.to_nat(depth), seed)), 0)

law natflow.back:
  for n: Nat
  for +flag: Bool
  for tree: NatFlow
  NatFlow

law natflow.redirect:
  for x: U32
  for +flag: Bool
  NatFlow

@unsafe
def natflow.back(n, flag, tree):
  match n:
    case 0n:
      match tree:
        case NEnd{x}: natflow.redirect(x, flag)
        case NFork{left, right}: NFork{left, right}
    case 1n+p:
      match tree:
        case NEnd{x}: natflow.redirect(x, flag)
        case NFork{left, right}:
          a b = natflow.back(p, flag, left) natflow.back(p, flag, right)
          natflow.join(a, b, flag)

@unsafe
def natflow.redirect(x, flag):
  match flag:
    case False{}: NEnd{x}
    case True{}: natflow.back(0n, False{}, NEnd{x})

def back_check(+depth: U32, +seed: U32) -> U32:
  natflow.score(natflow.back(U32.to_nat(depth), False{}, natflow.make(U32.to_nat(depth), seed)), 0)

def main() -> U32:
  bench(3, 17)
