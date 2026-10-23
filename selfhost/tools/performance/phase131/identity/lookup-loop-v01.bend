# Close the catalogue's cache/name dispatch in its original tail loop. A cache
# sentinel is authoritative even when its index misses; later list entries are
# never consulted. Plain entries retain first-match, exact-name/full-payload
# behavior, including the empty names of internal index values.

@unsafe
def lookup(+book: List<&2,KDef>, +name: String) -> KDef:
  match book:
    case Nil{}: missing()
    case Con{+d,+rest}:
      kc(KDef, p88_string_eq(dk(d), "BookCache"),
        u => index_lookup(d, name),
        u => kc(KDef, p88_string_eq(dn(d), name),
          v => d, v => lookup(rest, name)))
