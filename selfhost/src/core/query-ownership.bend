
@unsafe
def p143o_in_range(+id: U32, +n: U32, +left: U32) -> Bool:
  U32.is_lt(U32.sub(nc_id(id),n),left)


@unsafe
def p143o_range_term(+t: KTerm, +n: U32, +left: U32) -> Bool:
  nt_choose(Bool,p98_tag_eq(t,"Var"),u => p143o_in_range(ix(t),n,left),
    u => p143o_range_terms(ks(t),n,left))


@unsafe
def p143o_range_terms(terms: List<&2,KTerm>, +n: U32, +left: U32) -> Bool:
  match terms:
    case Nil{}: False{}
    case Con{head,rest}: p143o_range_term(head,n,left) || p143o_range_terms(rest,n,left)

# Preserve first-match nc_word and its literal sentinel semantics. This loop
# has the same U32 sequence and termination budget as nd_comb_fresh.

@unsafe
def p143o_range_env(+env: List<&2,NC_Binding>, +n: U32, +left: U32) -> Bool:
  nt_choose(Bool,U32.is_eq(left,0),u => True{},u =>
    nt_choose(Bool,p88_string_eq(nc_word(nc_id(n),env),"NATIVE_UNBOUND_VARIABLE"),
      u => p143o_range_env(env,U32.inc(n),U32.sub(left,1)),u => False{}))


@unsafe
def p143o_range(+body: KTerm, +args: List<&2,KTerm>, +env: List<&2,NC_Binding>, +n: U32, +left: U32) -> Bool:
  nt_choose(Bool,U32.is_eq(left,0),u => True{},u =>
    Bool.not(p143o_range_term(body,n,left)) && Bool.not(p143o_range_terms(args,n,left)) &&
      p143o_range_env(env,n,left))

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
