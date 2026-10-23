# Optional source-level ownership ablation. The list head remains needed by the
# result branch and the key by the recursive branch. Ordinary checked Bend
# sharing therefore retains those values around the consuming comparison.
# This removes the extra root-preserving p88_string_eq wrapper, not ownership
# checks or the selected comparison worker's safe fallback.

@unsafe
def index_bucket(ds, name):
  match ds:
    case Nil{}: missing()
    case Con{h, rest}:
      kc(KDef, p88_string_eq_go(dn(h), name, True{}),
        u => h, u => index_bucket(rest, name))
