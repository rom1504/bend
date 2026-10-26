# Ordinary erasure keeps its exact queue, names and facts. Only done-membership
# uses the existing collision-safe set, with no incremental-session state.
@unsafe
def p143nr_begin(+book: List<&2,KDef>, +todo: List<&2,String>, +done: List<&2,String>, +facts: List<&2,KDef>) -> NR_Closure:
  p143nr_walk(book,todo,done,facts,p142j_members(done,missing()))

@unsafe
def p143nr_walk(+book: List<&2,KDef>, todo: List<&2,String>, +done: List<&2,String>, +facts: List<&2,KDef>, +seen: KDef) -> NR_Closure:
  match todo:
    case Nil{}: NR_Closure{done,facts}
    case Con{+name,+rest}:
      p143nr_name(book,name,rest,done,facts,seen,index_hash(name,2166136261))

@unsafe
def p143nr_name(+book: List<&2,KDef>, +name: String, +todo: List<&2,String>, +done: List<&2,String>, +facts: List<&2,KDef>, +seen: KDef, +hash: U32) -> NR_Closure:
  nt_choose(NR_Closure,p142j_member(seen,name,hash),
    u => p143nr_walk(book,todo,done,facts,seen),
    u => p143nr_visit(book,name,todo,done,facts,p142j_mark(seen,name,hash),lookup(book,name)))

@unsafe
def p143nr_visit(+book: List<&2,KDef>, +name: String, +todo: List<&2,String>, +done: List<&2,String>, +facts: List<&2,KDef>, +seen: KDef, +d: KDef) -> NR_Closure:
  +body = nc_definition_plain(book,d,0)
  +more = nt_choose(List<&2,KDef>,p88_string_eq(dk(d),"Def") && Bool.not(nc_native_def(d) || nc_foreign(d)),
    u => Con{KDef{name,"NativeErasedBody",nd_arity_plain(book,name),1,{KTerm{"Absent","",0,0,[],[],0,0}:KTerm},body,[],False{},False{}},facts},u => facts)
  p143nr_walk(book,nt_append(String,nc_refs(body),todo),Con{name,done},more,seen)
