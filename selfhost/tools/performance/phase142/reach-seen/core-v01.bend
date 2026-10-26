# Preserve original reached-name list, including duplicate resolved names.
# Only membership of the evolving visited set changes representation.
@unsafe
def p142r_kr_visit(+book: List<&2,KDef>, +todo: List<&2,String>, +seen: List<&2,String>, +stops: List<&2,String>) -> List<&2,String>:
  p142r_visit(book,todo,seen,p142j_members(seen,missing()),stops)

@unsafe
def p142r_reach(+book: List<&2,KDef>, roots: List<&2,String>, stops: List<&2,String>) -> List<&2,KDef>:
  kr_filter(book,p142r_kr_visit(book,roots,[],stops))

@unsafe
def p142r_visit(+book: List<&2,KDef>, todo: List<&2,String>, +seen: List<&2,String>, +members: KDef, +stops: List<&2,String>) -> List<&2,String>:
  match todo:
    case Nil{}: seen
    case Con{+name,rest}:
      p142r_name(book,rest,seen,members,stops,name,index_hash(name,2166136261))

@unsafe
def p142r_name(+book: List<&2,KDef>, +todo: List<&2,String>, +seen: List<&2,String>, +members: KDef, +stops: List<&2,String>, +name: String, +hash: U32) -> List<&2,String>:
  kc(List<&2,String>,p142j_member(members,name,hash),
    u => p142r_visit(book,todo,seen,members,stops),
    u => p142r_def(book,todo,Con{name,seen},p142j_mark(members,name,hash),stops,kr_resolve(book,name)))

@unsafe
def p142r_def(+book: List<&2,KDef>, +todo: List<&2,String>, +seen: List<&2,String>, +members: KDef, +stops: List<&2,String>, +d: KDef) -> List<&2,String>:
  kc(List<&2,String>,p88_string_eq(dk(d),"Absent"),
    u => p142r_visit(book,todo,seen,members,stops),
    u => p142r_resolved(book,todo,seen,members,stops,d,dn(d)))

@unsafe
def p142r_resolved(book: List<&2,KDef>, todo: List<&2,String>, seen: List<&2,String>, members: KDef, +stops: List<&2,String>, d: KDef, +name: String) -> List<&2,String>:
  p142r_visit(book,kr_dependencies(d,stops,todo),Con{name,seen},p142j_mark(members,name,index_hash(name,2166136261)),stops)
