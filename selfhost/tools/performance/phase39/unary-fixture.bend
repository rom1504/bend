import Base

type Trail is Data:
  Start{value: U32}
  Step{before: Nat, left: Trail, right: Trail, after: Nat, stamp: U32}

# Consume only the left chain; right deliberately aliases it. Full diagnostic
# structural checks visit each distinct node once and check every right alias.
def trail.head(tree: Trail) -> U32:
  match tree:
    case Start{value}: value
    case Step{before, left, right, after, stamp}: trail.head(left)

def unary.pick_first(+tree: Trail, seed: U32) -> Trail:
  Step{0n, tree, tree, 0n, seed}

def unary.first(n: Nat, +seed: U32) -> Trail:
  match n:
    case 0n: Start{seed}
    case 1n+p: unary.pick_first(unary.first(p, U32.add(seed, 1)), seed)

def first_check(size: U32, seed: U32) -> U32:
  trail.head(unary.first(U32.to_nat(size), seed))

def unary.pick_last(seed: U32, +tree: Trail) -> Trail:
  Step{0n, tree, tree, 0n, seed}

def unary.last(n: Nat, +seed: U32) -> Trail:
  match n:
    case 0n: Start{seed}
    case 1n+p: unary.pick_last(seed, unary.last(p, U32.add(seed, 1)))

def last_check(size: U32, seed: U32) -> U32:
  trail.head(unary.last(U32.to_nat(size), seed))

# A finite native-Nat prefix with more arguments. The private selector route
# must be live, rather than leaving a generic call at every reconstruction.
def unary.pick_middle(before: Nat, +tree: Trail, after: Nat, seed: U32) -> Trail:
  match before:
    case 0n: Step{0n, tree, tree, after, seed}
    case 1n+p: Step{p, tree, tree, after, seed}

# The three independent Nat increments can fail at three different phases:
# argument before child, child's zero branch, argument after child.
# The bump is a separately checked pure residual helper. This exercises actual
# error suspension without requiring new native-constructor region admission.
def unary.bump(n: Nat) -> Nat:
  1n+n

def unary.middle(n: Nat, +before: Nat, +leaf: Nat, +after: Nat, +seed: U32) -> Trail:
  match n:
    case 0n: Start{U32.add(seed, U32.from_nat(unary.bump(leaf)))}
    case 1n+p:
      unary.pick_middle(unary.bump(before), unary.middle(p, before, leaf, after, U32.add(seed, 1)), unary.bump(after), seed)

def middle_check(size: U32, before: Nat, leaf: Nat, after: Nat, seed: U32) -> U32:
  trail.head(unary.middle(U32.to_nat(size), before, leaf, after, seed))

# Refusal: two self references nested in one combiner argument list. The older
# two-child producer requires explicit independent lets, so this stays generic.
def unary.two(+n: Nat, +seed: U32) -> Trail:
  match n:
    case 0n: Start{seed}
    case 1n+p: Step{0n, unary.two(p, seed), unary.two(p, U32.add(seed, 1)), 0n, seed}

def two_check(size: U32, seed: U32) -> U32:
  trail.head(unary.two(U32.to_nat(size), seed))
