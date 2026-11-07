# Exact ordered first non-native names. Reuse the existing collision-safe set.
# Native rows must not mark their names: a later ordinary row may still be own.
@unsafe
def p175rn_name(+rest: List<&2,KDef>, +members: KDef, +name: String, +hash: U32) -> List<&2,String>:
  nt_choose(List<&2,String>,p142j_member(members,name,hash),
    u => p175rn_walk(rest,members),
    u => Con{name,p175rn_walk(rest,p142j_mark(members,name,hash))})

@unsafe
def p175rn_walk(book,members):
  match book:
    case Nil{}: []
    case Con{+head,+rest}:
      nt_choose(List<&2,String>,db(head),
        u => p175rn_walk(rest,members),
        u => p175rn_name(rest,members,dn(head),index_hash(dn(head),2166136261)))

@unsafe
def dr_own_names(+book: List<&2,KDef>, +seen: List<&2,String>) -> List<&2,String>:
  p175rn_walk(book,p142j_members(seen,missing()))
