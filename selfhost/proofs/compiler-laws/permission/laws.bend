import Base
import ./candidate.bend as H
import ./reference.bend as R
import ./baseline.bend as B

# Support over the real recursive helper, using the already proved exact D04
# character/string comparator. The reference uses structural equality only.
law provider_membership_exact:
  for names: List<&2, String>
  for +name: String
  {H.no_effect_provider_member(names, name) == R.provider_member(names, name) : Bool}

def provider_membership_exact(names, name):
  match names:
    case Nil{}: {==}
    case Con{+head, +rest}:
      %B.consuming_equal_specification(head, name) : {H.no_effect_provider_member(Con{head, rest}, name) == Bool.or(_, R.provider_member(rest, name)) : Bool}
      %provider_membership_exact(rest, name) : {Bool.or(H.p88_string_eq(head, name), H.no_effect_provider_member(rest, name)) == Bool.or(H.p88_string_eq(head, name), _) : Bool}
      {==}

# Public: exact closed whitelist and both explicit guards, for every String.
law foreign_permission_exact:
  for trusted: Bool
  for filled: Bool
  for name: String
  {H.no_effect_foreign_allowed(trusted, filled, name) == Bool.and(trusted, Bool.and(filled, R.provider_allowed(name))) : Bool}

def foreign_permission_exact(trusted, filled, name):
  match trusted filled:
    case False{} False{}: {==}
    case False{} True{}: {==}
    case True{} False{}: {==}
    case True{} True{}:
      provider_membership_exact(["IO.args", "IO.print", "IO.now", "IO.print_err", "File.open", "File.read", "File.size", "File.write", "File.close"], name)

# Public: spelling a known provider cannot bypass the trust flag.
law foreign_permission_requires_trust:
  for filled: Bool
  for name: String
  {H.no_effect_foreign_allowed(False{}, filled, name) == False{} : Bool}

def foreign_permission_requires_trust(filled, name): {==}

# Public: no trusted name can license an unfilled foreign declaration.
law foreign_permission_requires_body:
  for trusted: Bool
  for name: String
  {H.no_effect_foreign_allowed(trusted, False{}, name) == False{} : Bool}

def foreign_permission_requires_body(trusted, name):
  match trusted:
    case False{}: {==}
    case True{}: {==}

# Public: every name outside the structural-equality whitelist is rejected.
# The premise is about the independent reference, not the implementation.
law foreign_permission_rejects_unlisted:
  for name: String
  for absent: {R.provider_allowed(name) == False{} : Bool}
  {H.no_effect_foreign_allowed(True{}, True{}, name) == False{} : Bool}

def foreign_permission_rejects_unlisted(name, absent):
  %absent : {H.no_effect_foreign_allowed(True{}, True{}, name) == _ : Bool}
  provider_membership_exact(["IO.args", "IO.print", "IO.now", "IO.print_err", "File.open", "File.read", "File.size", "File.write", "File.close"], name)

#|ALL PROOFS CHECK
#|Use --verdict for mathematical validity.
