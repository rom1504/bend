# Replace repeated immutable live-name scans at the kr_filter boundary only.
# The existing exact-name Patricia index retains full collision buckets.
# No definition is reconstructed: its original payload and book order survive.

@unsafe
def p128rf_members(names: List<&2,String>, tree: KDef) -> KDef:
  match names:
    case Nil{}: tree
    case Con{+name,rest}:
      p128rf_members(rest,index_set(tree,
        KDef{name,"P128ReachMember",0,0,atom("Absent"),atom("Absent"),[],False{},False{}},
        index_hash(name,2166136261),32))

@unsafe
def p128rf_member(+members: KDef, +name: String) -> Bool:
  String.eq(dk(index_find(members,name,index_hash(name,2166136261),32)),"P128ReachMember")

@unsafe
def p128rf_filter(book: List<&2,KDef>, +members: KDef) -> List<&2,KDef>:
  match book:
    case Nil{}: []
    case Con{+d,+rest}:
      kc(List<&2,KDef>,p128rf_member(members,dn(d)),
        u => Con{d,p128rf_filter(rest,members)},u => p128rf_filter(rest,members))

@unsafe
def kr_filter(book, live):
  p128rf_filter(book,p128rf_members(live,missing()))
