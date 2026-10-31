
# Module: src/check/env-substitution.bend:7
law env_subst_term:
  for +t: KTerm
  for +bindings: List<&2,KTelescopeBinding>
  KTerm

# Module: src/check/env-substitution.bend:12
law env_subst_terms:
  for +ts: List<&2,KTerm>
  for +bindings: List<&2,KTelescopeBinding>
  List<&2,KTerm>

# Module: src/check/env-substitution.bend:17
law env_subst_find:
  for +t: KTerm
  for +bindings: List<&2,KTelescopeBinding>
  KTerm

# Module: src/check/env-substitution.bend:23
@unsafe
def env_subst_reverse(+bindings: List<&2,KTelescopeBinding>, +out: List<&2,KTelescopeBinding>) -> List<&2,KTelescopeBinding>:
  match bindings:
    case Nil{}: out
    case Con{binding, rest}: env_subst_reverse(rest, Con{binding, out})

# Module: src/check/env-substitution.bend:29
@unsafe
def env_subst_start(+t: KTerm, +bindings: List<&2,KTelescopeBinding>, +first: KTelescopeBinding, +rest: List<&2,KTelescopeBinding>) -> KTerm:
  match rest:
    case Nil{}: env_tele_apply_binding(t, first)
    case Con{h, tail}: env_subst_term(t, env_subst_reverse(bindings, Nil{}))

# Module: src/check/env-substitution.bend:35
@unsafe
def env_subst_apply(+t: KTerm, +bindings: List<&2,KTelescopeBinding>) -> KTerm:
  match bindings:
    case Nil{}: t
    case Con{first, rest}: env_subst_start(t, bindings, first, rest)

# Module: src/check/env-substitution.bend:41
@unsafe
def env_subst_binding(+t: KTerm, +binding: KTelescopeBinding, +rest: List<&2,KTelescopeBinding>) -> KTerm:
  match binding:
    case KTelescopeBinding{id, value}:
      kc(KTerm, U32.is_eq(ix(t), id), u => env_subst_term(value, rest), u => env_subst_find(t, rest))

# Module: src/check/env-substitution.bend:47
@unsafe
def env_subst_find(t, bindings):
  match bindings:
    case Nil{}: t
    case Con{binding, rest}: env_subst_binding(t, binding, rest)

# Module: src/check/env-substitution.bend:53
@unsafe
def env_subst_term(t, bindings):
  match bindings:
    case Nil{}: t
    case Con{binding, rest}:
      kc(KTerm, p98_tag_eq(t, "Var"), u => env_subst_find(t, bindings),
        u => kc(KTerm, core_literal(t), u => t,
          u => k_with_children(t, env_subst_terms(ks(t), bindings))))

# Module: src/check/env-substitution.bend:62
@unsafe
def env_subst_terms(ts, bindings):
  match ts:
    case Nil{}: Nil{}
    case Con{h, rest}: Con{env_subst_term(h, bindings), env_subst_terms(rest, bindings)}
