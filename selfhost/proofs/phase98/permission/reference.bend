import Base

# Frozen mathematical reference for the existing consuming compiler comparator.
# Characters are compared using actual Base Char.is_eq; there is no ASCII or
# normalization premise, and both strings must end at the same position.
def structural_equal(a: String, b: String) -> Bool:
  match a b:
    case SNil{} SNil{}: True{}
    case SNil{} SCon{head, tail}: False{}
    case SCon{head, tail} SNil{}: False{}
    case SCon{ah, at} SCon{bh, bt}:
      Bool.and(Char.is_eq(ah, bh), structural_equal(at, bt))

# Independent exact-name membership for the admitted provider catalog.
def provider_member(names: List<&2, String>, +name: String) -> Bool:
  match names:
    case Nil{}: False{}
    case Con{head, rest}:
      Bool.or(structural_equal(head, name), provider_member(rest, name))

def provider_allowed(name: String) -> Bool:
  provider_member(["IO.args", "IO.print", "IO.now", "IO.print_err", "File.open", "File.read", "File.size", "File.write", "File.close"], name)
