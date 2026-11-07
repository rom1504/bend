# Keep the existing exact-name membership through the final ordered filter.
# The public kr_visit and its duplicate/order contract remain unchanged.
# Resolved parents still expand on every original visit, including repeated
# parent names and arbitrary duplicate-name/raw-cache definition payloads.
@unsafe
def p177rr_walk(book,todo,members,stops):
  match todo:
    case Nil{}: members
    case Con{+name,rest}:
      p177rr_name(book,rest,members,stops,name,index_hash(name,2166136261))

@unsafe
def p177rr_name(book,todo,members,stops,name,hash):
  kc(KDef,p142j_member(members,name,hash),
    u => p177rr_walk(book,todo,members,stops),
    u => p177rr_def(book,todo,p142j_mark(members,name,hash),stops,kr_resolve(book,name)))

@unsafe
def p177rr_def(book,todo,members,stops,definition):
  kc(KDef,p88_string_eq(dk(definition),"Absent"),
    u => p177rr_walk(book,todo,members,stops),
    u => p177rr_walk(book,kr_dependencies(definition,stops,todo),
      p142j_mark(members,dn(definition),index_hash(dn(definition),2166136261)),stops))

@unsafe
def p177rr_filter(book,members):
  match book:
    case Nil{}: []
    case Con{+definition,+rest}:
      kc(List<&2,KDef>,p142j_member(members,dn(definition),index_hash(dn(definition),2166136261)),
        u => Con{definition,p177rr_filter(rest,members)},
        u => p177rr_filter(rest,members))

@unsafe
def p177rr_reach(book,roots,stops):
  p177rr_filter(book,p177rr_walk(book,roots,missing(),stops))

@unsafe
def reach_book(+book: List<&2,KDef>, +roots: List<&2,String>, +stops: List<&2,String>) -> List<&2,KDef>:
  p177rr_reach(book,roots,stops)
