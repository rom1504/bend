import Base

# Prospective independent shared-frame witness. Input and output ADTs differ;
# one-child and two-child phases coexist in each actual structural worker.
type OrderInput is Data:
  OLeaf{value: U32}
  OOne{child: OrderInput}
  OTwo{left: OrderInput, right: OrderInput}

type OrderResult is Data:
  RLeaf{value: U32}
  RStamp{value: U32, child: OrderResult}
  RPair{left: OrderResult, right: OrderResult}

def order.bump(n: Nat) -> Nat:
  1n+n

def order.pick_first(+child: OrderResult, before: Nat, after: Nat) -> OrderResult:
  RPair{RStamp{U32.from_nat(before), child}, RStamp{U32.from_nat(after), child}}

def order.pick_middle(before: Nat, +child: OrderResult, after: Nat) -> OrderResult:
  RPair{RStamp{U32.from_nat(before), child}, RStamp{U32.from_nat(after), child}}

def order.pick_last(before: Nat, after: Nat, +child: OrderResult) -> OrderResult:
  RPair{RStamp{U32.from_nat(before), child}, RStamp{U32.from_nat(after), child}}

# Child-first: leaf failure must precede either sibling Nat increment.
def order.first(tree: OrderInput, +before: Nat, +leaf: Nat, +after: Nat) -> OrderResult:
  match tree:
    case OLeaf{x}: RLeaf{U32.add(x, U32.from_nat(order.bump(leaf)))}
    case OOne{child}: order.pick_first(order.first(child, before, leaf, after), order.bump(before), order.bump(after))
    case OTwo{left, right}:
      a b = order.first(left, before, leaf, after) order.first(right, before, leaf, after)
      RPair{a, b}

# Middle child: before -> complete child -> after.
def order.middle(tree: OrderInput, +before: Nat, +leaf: Nat, +after: Nat) -> OrderResult:
  match tree:
    case OLeaf{x}: RLeaf{U32.add(x, U32.from_nat(order.bump(leaf)))}
    case OOne{child}: order.pick_middle(order.bump(before), order.middle(child, before, leaf, after), order.bump(after))
    case OTwo{left, right}:
      a b = order.middle(left, before, leaf, after) order.middle(right, before, leaf, after)
      RPair{a, b}

# Last child: both sibling increments occur before descent.
def order.last(tree: OrderInput, +before: Nat, +leaf: Nat, +after: Nat) -> OrderResult:
  match tree:
    case OLeaf{x}: RLeaf{U32.add(x, U32.from_nat(order.bump(leaf)))}
    case OOne{child}: order.pick_last(order.bump(before), order.bump(after), order.last(child, before, leaf, after))
    case OTwo{left, right}:
      a b = order.last(left, before, leaf, after) order.last(right, before, leaf, after)
      RPair{a, b}

# The saturated combiner may return the child itself; exact object alias matters.
def order.identity(child: OrderResult, ignored: Nat) -> OrderResult:
  child

def order.pass(tree: OrderInput, +extra: Nat) -> OrderResult:
  match tree:
    case OLeaf{x}: RLeaf{x}
    case OOne{child}: order.identity(order.pass(child, extra), order.bump(extra))
    case OTwo{left, right}:
      a b = order.pass(left, extra) order.pass(right, extra)
      RPair{a, b}

# Native parser permits matches only on parameters/fields. Keep the computed
# parity argument explicit in a separate pure saturated selector.
def order.make_choose(child: OrderInput, seed: U32, flag: Bool) -> OrderInput:
  match flag:
    case True{}: OOne{child}
    case False{}: OTwo{child, OLeaf{seed}}

# Alternation exercises unary and two-child frames in the same invocation.
def order.make(n: Nat, +seed: U32) -> OrderInput:
  match n:
    case 0n: OLeaf{seed}
    case 1n+p:
      order.make_choose(order.make(p, U32.inc(seed)), seed, U32.is_zero(U32.mod(seed, 2)))

# Changing accumulator preserves full result consumption outside older folds.
def order.score(tree: OrderResult, acc: U32) -> U32:
  match tree:
    case RLeaf{x}: U32.add(acc, x)
    case RStamp{x, child}: order.score(child, U32.add(acc, x))
    case RPair{left, right}: order.score(right, U32.add(order.score(left, acc), 1))

def first_check(depth: U32, before: Nat, leaf: Nat, after: Nat, seed: U32) -> U32:
  order.score(order.first(order.make(U32.to_nat(depth), seed), before, leaf, after), 0)

def middle_check(depth: U32, before: Nat, leaf: Nat, after: Nat, seed: U32) -> U32:
  order.score(order.middle(order.make(U32.to_nat(depth), seed), before, leaf, after), 0)

def last_check(depth: U32, before: Nat, leaf: Nat, after: Nat, seed: U32) -> U32:
  order.score(order.last(order.make(U32.to_nat(depth), seed), before, leaf, after), 0)

def pass_check(depth: U32, extra: Nat, seed: U32) -> U32:
  order.score(order.pass(order.make(U32.to_nat(depth), seed), extra), 0)

def main() -> U32:
  middle_check(3, 0n, 0n, 0n, 18)
