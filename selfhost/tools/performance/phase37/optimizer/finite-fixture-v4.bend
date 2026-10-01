import Base

type FiniteChoice is Data:
  ChoiceOne{value: U32}
  ChoiceTwo{left: U32, right: U32}
  ChoiceEmpty{}

type FiniteBox is Data:
  BoxLeaf{value: U32}
  BoxNode{left: FiniteBox, right: FiniteBox}

def BoxAlias() -> Data:
  FiniteBox

# A leading Bool consumes two following ordinary arguments.
def finite.choose(flag: Bool, x: U32, y: U32) -> FiniteChoice:
  match flag:
    case True{}: ChoiceOne{x}
    case False{}: ChoiceTwo{x, y}

# Three alternatives, unequal field counts and a remaining ordinary argument.
def finite.change(value: FiniteChoice, salt: U32) -> FiniteChoice:
  match value:
    case ChoiceOne{x}: ChoiceTwo{x, salt}
    case ChoiceTwo{x, y}: ChoiceOne{U32.add(x, y)}
    case ChoiceEmpty{}: ChoiceEmpty{}

def finite.score(value: FiniteChoice) -> U32:
  match value:
    case ChoiceOne{x}: x
    case ChoiceTwo{x, y}: U32.xor(x, y)
    case ChoiceEmpty{}: 17

def choice_check(+x: U32, +y: U32) -> U32:
  finite.score(finite.change(finite.choose(U32.is_lt(x, y), x, y), x))

def empty_check(x: U32) -> U32:
  finite.score(finite.change(ChoiceEmpty{}, x))

def finite.zip(a: BoxAlias, b: BoxAlias) -> BoxAlias:
  match a b:
    case BoxNode{a0, a1} BoxNode{b0, b1}: BoxNode{BoxNode{a0, b0}, BoxNode{a1, b1}}
    case BoxNode{a0, a1} BoxLeaf{x}: BoxLeaf{0}
    case BoxLeaf{x} BoxNode{b0, b1}: BoxLeaf{0}
    case BoxLeaf{x} BoxLeaf{y}: BoxLeaf{0}

def finite.sum(value: FiniteBox) -> U32:
  match value:
    case BoxLeaf{x}: x
    case BoxNode{left, right}: U32.add(finite.sum(left), finite.sum(right))

# A final Bool is evaluated only after the two original lambda stages.
def finite.leaf(x: U32, y: U32, flag: Bool) -> FiniteBox:
  match flag:
    case False{}: BoxNode{BoxLeaf{x}, BoxLeaf{y}}
    case True{}: BoxNode{BoxLeaf{y}, BoxLeaf{x}}

def alias_check(+x: U32) -> U32:
  +leaf: FiniteBox = BoxLeaf{x}
  finite.sum(finite.zip(BoxNode{leaf, leaf}, BoxNode{leaf, leaf}))

def leaf_check(+x: U32, +y: U32) -> U32:
  finite.sum(finite.leaf(x, y, Bool.xor(U32.is_lt(x, y), U32.is_zero(x))))

def finite.step(x: U32) -> U32:
  U32.inc(x)

# Helper calls are intentionally outside this selector's leaf-body admission.
def finite.opaque(value: FiniteChoice) -> U32:
  match value:
    case ChoiceOne{x}: finite.step(x)
    case ChoiceTwo{x, y}: finite.step(U32.add(x, y))
    case ChoiceEmpty{}: finite.step(17)

def opaque_check(+x: U32, +y: U32) -> U32:
  finite.opaque(finite.choose(U32.is_lt(x, y), x, y))

# Native constructor creation must not be admitted by the inert-sum rule.
def finite.native(flag: Bool, x: Nat) -> Nat:
  match flag:
    case False{}: x
    case True{}: Succ{x}

def native_check(flag: Bool, x: Nat) -> U32:
  U32.from_nat(finite.native(flag, x))

def finite.closure(flag: Bool, +x: U32) -> U32 -> U32:
  match flag:
    case True{}: y => U32.add(x, y)
    case False{}: y => U32.xor(x, y)

def closure_check(flag: Bool, x: U32, y: U32) -> U32:
  finite.closure(flag, x)(y)

def finite.array.finish(value: FiniteChoice, pair: Array<U32> & U32) -> U32:
  (unused, x) = pair
  U32.add(finite.score(value), x)

def array_check(+x: U32) -> U32:
  finite.array.finish(finite.choose(U32.is_zero(x), x, 7), Array.get(U32, Array.new(U32, 1n, x), 0))

# Original argument evaluation can fail; no private prefix may call a hook
# before the later argument is evaluated. Nat successor supplies real overflow.
def finite.argument(n: Nat) -> U32:
  U32.from_nat(Succ{n})

def argument_check(n: Nat, m: Nat) -> U32:
  finite.score(finite.change(ChoiceOne{finite.argument(n)}, finite.argument(m)))

# Generic tail cycles must stay in the outer force loop while its proof is active.
# Like pinned tests/run/unsafe_mutual.bend, explicit laws plus @unsafe
# admit mutual calls; this runtime control does not claim termination proof.
law finite.cycle.root:
  for n: Nat
  for acc: U32
  U32

law finite.cycle.step:
  for n: Nat
  for +acc: U32
  U32

law finite.mutual.root:
  for n: Nat
  for acc: U32
  U32

law finite.mutual.left:
  for n: Nat
  for +acc: U32
  U32

law finite.mutual.next:
  for n: Nat
  for acc: U32
  U32

law finite.mutual.right:
  for n: Nat
  for +acc: U32
  U32

@unsafe
def finite.cycle.root(n, acc):
  finite.cycle.step(n, acc)

@unsafe
def finite.cycle.step(n, acc):
  match n:
    case 0n: finite.score(finite.choose(U32.is_zero(acc), acc, 7))
    case 1n+p: finite.cycle.root(p, U32.inc(acc))

@unsafe
def finite.mutual.root(n, acc):
  finite.mutual.left(n, acc)

@unsafe
def finite.mutual.left(n, acc):
  match n:
    case 0n: finite.score(finite.choose(U32.is_zero(acc), acc, 7))
    case 1n+p: finite.mutual.next(p, U32.inc(acc))

@unsafe
def finite.mutual.next(n, acc):
  finite.mutual.right(n, acc)

@unsafe
def finite.mutual.right(n, acc):
  match n:
    case 0n: finite.score(finite.choose(U32.is_zero(acc), acc, 7))
    case 1n+p: finite.mutual.root(p, U32.inc(acc))

def main() -> U32:
  choice_check(17, 31)
