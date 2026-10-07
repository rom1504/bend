import Base

# Private realization of the beta-stable environment admitted by env_tele_safe.
# The cursor stores newest first. Reversing once lets a Var find its earliest
# replacement; only later bindings may act on that inserted raw value.
# No new guard scan occurs here. Callers retain the existing admission proof.
law env_subst_term:
  for +t: KTerm
  for +bindings: List<&2,KTelescopeBinding>
  KTerm

law env_subst_terms:
  for +ts: List<&2,KTerm>
  for +bindings: List<&2,KTelescopeBinding>
  List<&2,KTerm>

law env_subst_find:
  for +t: KTerm
  for +bindings: List<&2,KTelescopeBinding>
  KTerm

@unsafe
def env_subst_reverse(+bindings: List<&2,KTelescopeBinding>, +out: List<&2,KTelescopeBinding>) -> List<&2,KTelescopeBinding>:
  match bindings:
    case Nil{}: out
    case Con{binding, rest}: env_subst_reverse(rest, Con{binding, out})

@unsafe
def env_subst_start(+t: KTerm, +bindings: List<&2,KTelescopeBinding>, +first: KTelescopeBinding, +rest: List<&2,KTelescopeBinding>) -> KTerm:
  match rest:
    case Nil{}: env_tele_apply_binding(t, first)
    case Con{h, tail}: env_subst_term(t, env_subst_reverse(bindings, Nil{}))

@unsafe
def env_subst_apply(+t: KTerm, +bindings: List<&2,KTelescopeBinding>) -> KTerm:
  match bindings:
    case Nil{}: t
    case Con{first, rest}: env_subst_start(t, bindings, first, rest)

@unsafe
def env_subst_binding(+t: KTerm, +binding: KTelescopeBinding, +rest: List<&2,KTelescopeBinding>) -> KTerm:
  match binding:
    case KTelescopeBinding{id, value}:
      kc(KTerm, U32.is_eq(ix(t), id), u => env_subst_term(value, rest), u => env_subst_find(t, rest))

@unsafe
def env_subst_find(t, bindings):
  match bindings:
    case Nil{}: t
    case Con{binding, rest}: env_subst_binding(t, binding, rest)

@unsafe
def env_subst_term(t, bindings):
  match bindings:
    case Nil{}: t
    case Con{binding, rest}:
      kc(KTerm, String.eq(tg(t), "Var"), u => env_subst_find(t, bindings),
        u => kc(KTerm, core_literal(t), u => t,
          u => k_with_children(t, env_subst_terms(ks(t), bindings))))

@unsafe
def env_subst_terms(ts, bindings):
  match ts:
    case Nil{}: Nil{}
    case Con{h, rest}: Con{env_subst_term(h, bindings), env_subst_terms(rest, bindings)}
