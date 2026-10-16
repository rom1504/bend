import Base

type P99Pair is Data:
  P99Pair{+left: String, +right: String, +stamp: U32}

def p99_alias_walk(a: String, b: String, same: Bool) -> Bool:
  match a b same:
    case SNil{} SNil{} result: result
    case SNil{} SCon{h, t} result: False{}
    case SCon{h, t} SNil{} result: False{}
    case SCon{h1, t1} SCon{h2, t2} False{}: False{}
    case SCon{h1, t1} SCon{h2, t2} True{}:
      p99_alias_walk(t1, t2, Char.is_eq(h1, h2))

# Distinct physical child slots may alias one owned String graph.
def p99_pair_equal(pair: P99Pair) -> Bool:
  match pair:
    case P99Pair{left, right, stamp}: p99_alias_walk(left, right, True{})

# One borrowed child may occupy both callee root slots.
def p99_pair_self(pair: P99Pair) -> Bool:
  match pair:
    case P99Pair{left, right, stamp}: p99_alias_walk(left, left, True{})

# This child escapes as an owned String; no scalar observer may replace it.
def p99_pair_escape(pair: P99Pair) -> String:
  match pair:
    case P99Pair{left, right, stamp}: left

def p99_pair_dump(pair: P99Pair) -> IO(Unit):
  match pair:
    case P99Pair{left, right, stamp}:
      do IO<Unit>:
        IO.print(left)
        IO.print(right)
        IO.print(U32.show(stamp))

def main() -> IO(Unit):
  +text : String = String.append("λ", "🙂alias")
  +pair : P99Pair = P99Pair{text, text, 43}
  +escaped : String = p99_pair_escape(P99Pair{String.append("owned-", "child"), "unused", 17})
  do IO<Unit>:
    IO.print(U32.show(Bool.to_u32(p99_pair_equal(pair))))
    IO.print(U32.show(Bool.to_u32(p99_pair_self(pair))))
    IO.print(escaped)
    p99_pair_dump(pair)
    IO.print(text)
