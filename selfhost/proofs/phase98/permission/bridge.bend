import Base
import ./candidate.bend as H
import ./laws.bend as L

# Support: exact existing compiler membership, including arbitrary list order,
# duplicates, strings and keys. Both functions use the actual candidate comparator.
law provider_membership_existing:
  for names: List<&2, String>
  for +name: String
  {H.no_effect_provider_member(names, name) == H.nb_contains(names, name) : Bool}

def provider_membership_existing(names, name):
  match names:
    case Nil{}: {==}
    case Con{+head, +rest}:
      %provider_membership_existing(rest, name) : {H.no_effect_provider_member(Con{head, rest}, name) == Bool.or(H.p88_string_eq(head, name), _) : Bool}
      {==}

# Public: replacing the original inline membership expression with the real
# safe helper preserves its complete Bool result, including both guards.
law foreign_permission_preserves_existing_membership:
  for trusted: Bool
  for filled: Bool
  for name: String
  {H.no_effect_foreign_allowed(trusted, filled, name) == Bool.and(trusted, Bool.and(filled, H.nb_contains(["IO.args", "IO.print", "IO.now", "IO.print_err", "File.open", "File.read", "File.size", "File.write", "File.close"], name))) : Bool}

def foreign_permission_preserves_existing_membership(trusted, filled, name):
  match trusted filled:
    case False{} False{}: {==}
    case False{} True{}: {==}
    case True{} False{}: {==}
    case True{} True{}:
      provider_membership_existing(["IO.args", "IO.print", "IO.now", "IO.print_err", "File.open", "File.read", "File.size", "File.write", "File.close"], name)

#|ALL PROOFS CHECK
#|Use --verdict for mathematical validity.
