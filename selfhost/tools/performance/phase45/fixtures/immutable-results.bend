# Independent scalar-input/String-output compositions for contextual workers.
# No timed-program source names or tree shapes are recognized by the compiler.
import Base

def text.values(size: Nat, +seed: U32) -> List<&2, String>:
  match size:
    case 0n: Nil{}
    case 1n+rest:
      String.append("λ", U32.show(seed)) <> text.values(rest, U32.add(seed, 1))

def text.render(values: List<&2, String>) -> String:
  match values:
    case Nil{}: SNil{}
    case value <> rest:
      String.append(value, String.append(";", text.render(rest)))

def bench(size: U32, seed: U32) -> String:
  text.render(List.reverse(&2, String, text.values(U32.to_nat(size), seed)))

def text.maybe(flag: Bool, seed: U32) -> Maybe<&2, String>:
  match flag:
    case False{}: None{}
    case True{}: Some{String.append("🧭", U32.show(seed))}

def selected(flag: Bool, seed: U32) -> String:
  Maybe.default(&2, String, text.maybe(flag, seed), "empty")

# These exports must retain generic public admission despite immutable results.
def non_scalar_input(value: String) -> String:
  Maybe.default(&2, String, Some{value}, "empty")

def returned_closure(seed: U32) -> U32 -> String:
  value => Maybe.default(&2, String, Some{U32.show(U32.add(seed, value))}, "empty")
