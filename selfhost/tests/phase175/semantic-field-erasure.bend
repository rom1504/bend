# PRIVATE experimental consumer of this request's annotate_selected output.
# Ann marker shape alone is not an authority. Only p175sf_prepare's annotated
# winners acquire this path; ordinary raw erasure entry points stay unchanged.

law p175sf_erase:
  for +book: List<&2,KDef>
  for +term: KTerm
  KTerm

law p175sf_list:
  for +book: List<&2,KDef>
  for terms: List<&2,KTerm>
  List<&2,KTerm>

@unsafe
def p175sf_marked(+term: KTerm) -> Bool:
  p98_tag_eq(term,"Ann") && String.is_empty(nm(term)) && U32.is_eq(ix(term),1) &&
    U32.is_le(qt(term),2) && U32.is_eq(terms_len(ks(term)),2) &&
    List.is_empty(&2,String,rm(term)) && U32.is_eq(kb(term),0) && U32.is_eq(ke(term),0)

@unsafe
def p175sf_markers(terms: List<&2,KTerm>) -> Bool:
  match terms:
    case Nil{}: True{}
    case Con{head,rest}: p175sf_marked(head) && p175sf_markers(rest)

@unsafe
def p175sf_fields(+book: List<&2,KDef>, terms: List<&2,KTerm>) -> List<&2,KTerm>:
  match terms:
    case Nil{}: []
    case Con{+head,+rest}:
      nt_choose(List<&2,KTerm>,U32.is_eq(qt(head),0),
        u => p175sf_fields(book,rest),
        u => Con{p175sf_erase(book,head),p175sf_fields(book,rest)})

law p175sf_arg_head:
  for +book: List<&2,KDef>
  for +tel: KTerm
  for +head: KTerm
  for +rest: List<&2,KTerm>
  List<&2,KTerm>

@unsafe
def p175sf_args(+book: List<&2,KDef>, +tel: KTerm, terms: List<&2,KTerm>) -> List<&2,KTerm>:
  match terms:
    case Nil{}: []
    case Con{+head,+rest}:
      p175sf_arg_head(book,wnf(book,tel),head,rest)

@unsafe
def p175sf_arg_head(book,tel,head,rest):
  nt_choose(List<&2,KTerm>,U32.is_eq(qt(tel),0),
    u => p175sf_args(book,subst(kid(tel,1),ix(tel),head),rest),
    u => Con{p175sf_erase(book,head),p175sf_args(book,subst(kid(tel,1),ix(tel),head),rest)})

@unsafe
def p175sf_ctor(+book: List<&2,KDef>, +term: KTerm, +typ: KTerm) -> KTerm:
  kt("Ctr",nt_choose(String,db(lookup(book,nm(typ))),u => nm(term),u => nc_ctor_identity(book,nm(term))),
    ix(term),qt(term),nt_choose(List<&2,KTerm>,p175sf_markers(ks(term)),
      u => p175sf_fields(book,ks(term)),
      u => p175sf_args(book,nc_tele_fill(book,dt(lookup(dc(lookup(book,nm(typ))),nm(term))),ks(typ)),ks(term))))

@unsafe
def p175sf_mat(+book: List<&2,KDef>, +term: KTerm, +adt: KTerm) -> KTerm:
  +ctr = lookup(dc(lookup(book,nm(adt))),nm(term))
  +count = nc_live_count(book,nc_tele_fill(book,dt(ctr),ks(adt)),da(ctr))
  kt("Mat",nt_choose(String,db(lookup(book,nm(adt))),u => nm(term),u => nc_ctor_identity(book,nm(term))),
    U32.inc(count),nh_field_mask(book,nc_tele_fill(book,dt(ctr),ks(adt)),da(ctr),0),p175sf_list(book,ks(term)))

@unsafe
def p175sf_annotated(+book: List<&2,KDef>, +term: KTerm, +typ: KTerm) -> KTerm:
  nt_choose(KTerm,p98_tag_eq(typ,"Eql"),u => KTerm{"Rfl","",0,0,[],[],0,0},u =>
    nt_choose(KTerm,p98_tag_eq(term,"Ctr"),u => p175sf_ctor(book,term,typ),u =>
      nt_choose(KTerm,p98_tag_eq(term,"Mat"),u => p175sf_mat(book,term,wnf(book,kid(typ,0))),
        u => p175sf_erase(book,term))))

@unsafe
def p175sf_list(book,terms):
  match terms:
    case Nil{}: []
    case Con{head,rest}: Con{p175sf_erase(book,head),p175sf_list(book,rest)}

@unsafe
def p175sf_app(+book: List<&2,KDef>, +term: KTerm) -> KTerm:
  nt_choose(KTerm,p98_tag_eq(kid(term,0),"Ann"),
    u => nt_choose(KTerm,U32.is_eq(qt(wnf(book,kid(kid(term,0),1))),0),
      u => p175sf_erase(book,kid(term,0)),
      u => k_rebuild(term,nm(term),ix(term),qt(term),p175sf_list(book,ks(term)),[],0,0)),
    u => k_rebuild(term,nm(term),ix(term),qt(term),p175sf_list(book,ks(term)),[],0,0))

@unsafe
def p175sf_erase(book,term):
  nt_choose(KTerm,core_literal(term),u => term,u =>
    nt_choose(KTerm,p98_tag_eq(term,"Var"),u => var(nm(term),ix(term)),u =>
      nt_choose(KTerm,p98_tag_eq(term,"Ann"),u => p175sf_annotated(book,kid(term,0),wnf(book,kid(term,1))),u =>
        nt_choose(KTerm,p98_tag_eq(term,"Lam") && U32.is_eq(qt(term),0),u => p175sf_erase(book,kid(term,0)),u =>
          nt_choose(KTerm,p98_tag_eq(term,"App"),u => p175sf_app(book,term),u =>
            k_rebuild(term,nt_choose(String,p98_tag_eq(term,"Ctr") || p98_tag_eq(term,"Mat"),
              u => nc_ctor_identity(book,nm(term)),u => nm(term)),ix(term),qt(term),p175sf_list(book,ks(term)),[],0,0))))))

# The authority index is built from the exact annotated list used by
# nc_context_defs. First-match behavior therefore agrees with the merged book.
# Unannotated, native, and foreign definitions keep nc_definition_plain.
@unsafe
def p175sf_definition(+book: List<&2,KDef>, +annotated: List<&2,KDef>, +definition: KDef) -> KTerm:
  nt_choose(KTerm,nc_native_def(definition) || nc_foreign(definition) || U32.is_gt(dx(definition),0) ||
      p88_string_eq(dk(lookup(annotated,dn(definition))),"Absent"),
    u => nc_definition_plain(book,definition,0),u => p175sf_erase(book,dv(definition)))

law p175sf_walk:
  for +book: List<&2,KDef>
  for +annotated: List<&2,KDef>
  for todo: List<&2,String>
  for +done: List<&2,String>
  for +facts: List<&2,KDef>
  for +seen: KDef
  NR_Closure

@unsafe
def p175sf_visit(+book: List<&2,KDef>, +annotated: List<&2,KDef>, +name: String,
    +todo: List<&2,String>, +done: List<&2,String>, +facts: List<&2,KDef>, +seen: KDef, +definition: KDef) -> NR_Closure:
  +body = p175sf_definition(book,annotated,definition)
  +more = nt_choose(List<&2,KDef>,p88_string_eq(dk(definition),"Def") && Bool.not(nc_native_def(definition) || nc_foreign(definition)),
    u => Con{KDef{name,"NativeErasedBody",nd_arity_plain(book,name),1,KTerm{"Absent","",0,0,[],[],0,0},body,[],False{},False{}},facts},
    u => facts)
  p175sf_walk(book,annotated,nt_append(String,nc_refs(body),todo),Con{name,done},more,seen)

@unsafe
def p175sf_walk(book,annotated,todo,done,facts,seen):
  match todo:
    case Nil{}: NR_Closure{done,facts}
    case Con{+name,+rest}:
      +hash = index_hash(name,2166136261)
      nt_choose(NR_Closure,p142j_member(seen,name,hash),
        u => p175sf_walk(book,annotated,rest,done,facts,seen),
        u => p175sf_visit(book,annotated,name,rest,done,facts,
          p142j_mark(seen,name,hash),lookup(book,name)))

@unsafe
def p175sf_ready(+source: List<&2,KDef>, annotated: List<&2,KDef>, bound: U32, facts: P144OFacts) -> NR_Request:
  +view = p144o_view(source,facts)
  p144o_request(source,view,p175sf_walk(view,annotated,["main"],[],[],missing()),Some{bound})

@unsafe
def p175sf_indexed(+book: List<&2,KDef>, +annotated: List<&2,KDef>) -> NR_Request:
  +merged = nc_context_defs(book,annotated)
  +bound = norm_max_book(merged)
  +source = book_cached(merged,bound)
  p175sf_ready(source,annotated,bound,p144o_build(source))

@unsafe
def p175sf_prepare(book,annotated):
  p175sf_indexed(book,nc_context_index(annotated))
