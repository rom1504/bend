# Independent untimed native String equality and scalar Bool result controls.
import Base

def prism.keep(-T: Type, value: T) -> T:
  value

def prism.right(different: Bool) -> String:
  match different:
    case False{}: String.append("λ", "🧭")
    case True{}: String.append("λ", "🧬")

@unsafe
def prism.scan(n: Nat, +a: String, +b: String) -> Bool:
  match n:
    case 0n: String.eq(a, b)
    case 1n+rest: prism.scan(rest, a, b)

def bench(n: U32, different: Bool) -> Bool:
  prism.scan(U32.to_nat(n), String.append("λ", "🧭"), prism.right(different))

def prism.scalar(value: Char) -> Bool:
  String.eq(SCon{value, SNil{}}, "x")

def scalar(code: U32) -> Bool:
  prism.keep(Bool, prism.scalar(Chr{code}))

# Public String inputs remain outside contextual worker admission.
def public_eq(a: String, b: String) -> Bool:
  String.eq(a, b)
