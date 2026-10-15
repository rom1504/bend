# Safe predicate used by the actual scoped observer-permission classifier.
# Host authentication and unannotation supply the two explicit flags.
def no_effect_provider_member(names: List<&2, String>, +name: String) -> Bool:
  match names:
    case Nil{}: False{}
    case Con{head, rest}: p88_string_eq(head, name) || no_effect_provider_member(rest, name)

def no_effect_foreign_allowed(trusted: Bool, filled: Bool, name: String) -> Bool:
  trusted && filled && no_effect_provider_member(["IO.args", "IO.print", "IO.now", "IO.print_err", "File.open", "File.read", "File.size", "File.write", "File.close"], name)
