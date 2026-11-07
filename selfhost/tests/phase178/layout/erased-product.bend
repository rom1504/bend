# One erasure implementation publishes both its value and reverse-preorder refs.
# The incoming accumulator belongs to earlier siblings; it is never inspected.
type NativeErasedTerm is Data:
  NativeErasedTerm{+body: KTerm, +reversedRefs: List<&2,String>}

type NativeErasedTerms is Data:
  NativeErasedTerms{+bodies: List<&2,KTerm>, +reversedRefs: List<&2,String>}

law nc_erase_product:
  for +book: List<&2,KDef>
  for +t: KTerm
  for +collect: Bool
  for +reversedRefs: List<&2,String>
  NativeErasedTerm

law nc_erase_list_product:
  for +book: List<&2,KDef>
  for +ts: List<&2,KTerm>
  for +collect: Bool
  for +reversedRefs: List<&2,String>
  NativeErasedTerms

law nc_erase_args_product:
  for +book: List<&2,KDef>
  for +tel: KTerm
  for +xs: List<&2,KTerm>
  for +collect: Bool
  for +reversedRefs: List<&2,String>
  NativeErasedTerms

@unsafe
def nc_erased_body(product: NativeErasedTerm) -> KTerm:
  match product:
    case NativeErasedTerm{body,reversedRefs}: body

@unsafe
def nc_erased_terms(product: NativeErasedTerms) -> List<&2,KTerm>:
  match product:
    case NativeErasedTerms{bodies,reversedRefs}: bodies

@unsafe
def nc_erased_cons(head: KTerm, product: NativeErasedTerms) -> NativeErasedTerms:
  match product:
    case NativeErasedTerms{bodies,reversedRefs}:
      NativeErasedTerms{Con{head,bodies},reversedRefs}

@unsafe
def nc_erase_list_after_head(book: List<&2,KDef>, rest: List<&2,KTerm>, collect: Bool, product: NativeErasedTerm) -> NativeErasedTerms:
  match product:
    case NativeErasedTerm{body,reversedRefs}:
      nc_erased_cons(body,nc_erase_list_product(book,rest,collect,reversedRefs))

@unsafe
def nc_erase_list_product(book,ts,collect,reversedRefs):
  match ts:
    case Nil{}: NativeErasedTerms{[],reversedRefs}
    case Con{head,rest}:
      nc_erase_list_after_head(book,rest,collect,nc_erase_product(book,head,collect,reversedRefs))

@unsafe
def nc_erase_args_after_head(+book: List<&2,KDef>, +tel: KTerm, h: KTerm,
  rest: List<&2,KTerm>, collect: Bool, product: NativeErasedTerm) -> NativeErasedTerms:
  match product:
    case NativeErasedTerm{body,reversedRefs}:
      nc_erased_cons(body,nc_erase_args_product(book,subst(kid(tel,1),ix(tel),h),rest,collect,reversedRefs))

@unsafe
def nc_erase_args_product(book,tel,xs,collect,reversedRefs):
  match xs:
    case Nil{}: NativeErasedTerms{[],reversedRefs}
    case Con{+h,rest}:
      +head = wnf(book,tel)
      nt_choose(NativeErasedTerms,U32.is_eq(qt(head),0),
        u => nc_erase_args_product(book,subst(kid(head,1),ix(head),h),rest,collect,reversedRefs),
        u => nc_erase_args_after_head(book,head,h,rest,collect,nc_erase_product(book,h,collect,reversedRefs)))

@unsafe
def nc_erased_rebuild(t: KTerm, name: String, id: U32, quant: U32,
  product: NativeErasedTerms) -> NativeErasedTerm:
  match product:
    case NativeErasedTerms{bodies,reversedRefs}:
      NativeErasedTerm{k_rebuild(t,name,id,quant,bodies,[],0,0),reversedRefs}

@unsafe
def nc_erased_ctor(tag: String, name: String, id: U32, quant: U32,
  product: NativeErasedTerms) -> NativeErasedTerm:
  match product:
    case NativeErasedTerms{bodies,reversedRefs}:
      NativeErasedTerm{kt(tag,name,id,quant,bodies),reversedRefs}

@unsafe
def nc_erase_rebuild_product(book: List<&2,KDef>, +t: KTerm, name: String,
  id: U32, quant: U32, +collect: Bool, +reversedRefs: List<&2,String>) -> NativeErasedTerm:
  nc_erased_rebuild(t,name,id,quant,nc_erase_list_product(book,ks(t),collect,
    nt_choose(List<&2,String>,collect,
      u => nt_choose(List<&2,String>,p98_tag_eq(t,"Ref"),v => Con{nm(t),reversedRefs},v => reversedRefs),
      u => reversedRefs)))

@unsafe
def nc_erase_mat_product(+book: List<&2,KDef>, +t: KTerm, +adt: KTerm,
  collect: Bool, reversedRefs: List<&2,String>) -> NativeErasedTerm:
  +ctr = lookup(dc(lookup(book,nm(adt))),nm(t))
  +count = nc_live_count(book,nc_tele_fill(book,dt(ctr),ks(adt)),da(ctr))
  nc_erased_ctor("Mat",nt_choose(String,db(lookup(book,nm(adt))),u => nm(t),u => nc_ctor_identity(book,nm(t))),
    U32.inc(count),nh_field_mask(book,nc_tele_fill(book,dt(ctr),ks(adt)),da(ctr),0),
    nc_erase_list_product(book,ks(t),collect,reversedRefs))

@unsafe
def nc_erase_annotated_product(+book: List<&2,KDef>, +t: KTerm, +ty: KTerm,
  +collect: Bool, +reversedRefs: List<&2,String>) -> NativeErasedTerm:
  nt_choose(NativeErasedTerm,p98_tag_eq(ty,"Eql"),
    u => NativeErasedTerm{KTerm{"Rfl","",0,0,[],[],0,0},reversedRefs},u =>
  nt_choose(NativeErasedTerm,p98_tag_eq(t,"Ctr"),
    u => nc_erased_ctor("Ctr",nt_choose(String,db(lookup(book,nm(ty))),v => nm(t),v => nc_ctor_identity(book,nm(t))),ix(t),qt(t),
      nc_erase_args_product(book,nc_tele_fill(book,dt(lookup(dc(lookup(book,nm(ty))),nm(t))),ks(ty)),ks(t),collect,reversedRefs)),u =>
  nt_choose(NativeErasedTerm,p98_tag_eq(t,"Mat"),
    u => nc_erase_mat_product(book,t,wnf(book,kid(ty,0)),collect,reversedRefs),
    u => nc_erase_product(book,t,collect,reversedRefs))))

@unsafe
def nc_erase_app_product(+book: List<&2,KDef>, +t: KTerm,
  +collect: Bool, +reversedRefs: List<&2,String>) -> NativeErasedTerm:
  nt_choose(NativeErasedTerm,p98_tag_eq(kid(t,0),"Ann"),
    u => nt_choose(NativeErasedTerm,U32.is_eq(qt(wnf(book,kid(kid(t,0),1))),0),
      v => nc_erase_product(book,kid(t,0),collect,reversedRefs),
      v => nc_erase_rebuild_product(book,t,nm(t),ix(t),qt(t),collect,reversedRefs)),
    u => nc_erase_rebuild_product(book,t,nm(t),ix(t),qt(t),collect,reversedRefs))

@unsafe
def nc_erase_product(book,t,collect,reversedRefs):
  kc(NativeErasedTerm,core_literal(t),u => NativeErasedTerm{t,reversedRefs},u =>
  nt_choose(NativeErasedTerm,p98_tag_eq(t,"Var"),u => NativeErasedTerm{var(nm(t),ix(t)),reversedRefs},u =>
  nt_choose(NativeErasedTerm,p98_tag_eq(t,"Ann"),u => nc_erase_annotated_product(book,kid(t,0),wnf(book,kid(t,1)),collect,reversedRefs),u =>
  nt_choose(NativeErasedTerm,p98_tag_eq(t,"Lam") && U32.is_eq(qt(t),0),u => nc_erase_product(book,kid(t,0),collect,reversedRefs),u =>
  nt_choose(NativeErasedTerm,p98_tag_eq(t,"App"),u => nc_erase_app_product(book,t,collect,reversedRefs),u =>
    nc_erase_rebuild_product(book,t,nt_choose(String,p98_tag_eq(t,"Ctr") || p98_tag_eq(t,"Mat"),u => nc_ctor_identity(book,nm(t)),u => nm(t)),ix(t),qt(t),collect,reversedRefs))))))

# Native and foreign bodies keep their original constructors. Only this fallback
# scans a completed body; ordinary definitions publish refs during erasure.
@unsafe
def nc_erased_observe(+body: KTerm, collect: Bool) -> NativeErasedTerm:
  NativeErasedTerm{body,nt_choose(List<&2,String>,collect,u => nt_reverse(String,nc_refs(body),[]),u => [])}

@unsafe
def nc_definition_product(+book: List<&2,KDef>, +d: KDef, +n: U32, +collect: Bool) -> NativeErasedTerm:
  +prim = nc_primitive_name(dn(d))
  nt_choose(NativeErasedTerm,nc_native_def(d),
    u => nc_erased_observe(nc_primitive_body(prim),collect),u =>
    nt_choose(NativeErasedTerm,nc_foreign(d),
      u => nc_erased_observe(nc_foreign_tel(book,dt(d),dn(d),[],n),collect),
      u => nc_erase_product(book,dv(d),collect,[])))

# Compatibility projections keep all original public results and signatures.
@unsafe
def nc_erase_value(book,t):
  nc_erased_body(nc_erase_product(book,t,False{},[]))

@unsafe
def nc_erase_list_value(book,ts):
  nc_erased_terms(nc_erase_list_product(book,ts,False{},[]))

@unsafe
def nc_erase_args_value(book,tel,xs):
  nc_erased_terms(nc_erase_args_product(book,tel,xs,False{},[]))

@unsafe
def nc_erase_mat_value(book,t,adt):
  nc_erased_body(nc_erase_mat_product(book,t,adt,False{},[]))

@unsafe
def nc_erase_annotated_value(book,t,ty):
  nc_erased_body(nc_erase_annotated_product(book,t,ty,False{},[]))

@unsafe
def nc_erase_app_value(book,t):
  nc_erased_body(nc_erase_app_product(book,t,False{},[]))

@unsafe
def nc_definition_value(book,d,n):
  nc_erased_body(nc_definition_product(book,d,n,False{}))

@unsafe
def nr_visit_product_finish(+book: List<&2,KDef>, +name: String, todo: List<&2,String>,
  done: List<&2,String>, +facts: List<&2,KDef>, seen: KDef, +d: KDef,
  product: NativeErasedTerm) -> NR_Closure:
  match product:
    case NativeErasedTerm{body,reversedRefs}:
      +more = nt_choose(List<&2,KDef>,p88_string_eq(dk(d),"Def") && Bool.not(nc_native_def(d) || nc_foreign(d)),
        u => Con{KDef{name,"NativeErasedBody",nd_arity_plain(book,name),1,KTerm{"Absent","",0,0,[],[],0,0},body,[],False{},False{}},facts},u => facts)
      p143nr_walk(book,nt_reverse(String,reversedRefs,todo),Con{name,done},more,seen)

@unsafe
def nr_visit_product(book,name,todo,done,facts,seen,d):
  nr_visit_product_finish(book,name,todo,done,facts,seen,d,nc_definition_product(book,d,0,True{}))

@unsafe
def nr_visit_unindexed_product_finish(+book: List<&2,KDef>, +name: String,
  todo: List<&2,String>, done: List<&2,String>, +facts: List<&2,KDef>, +d: KDef,
  product: NativeErasedTerm) -> NR_Closure:
  match product:
    case NativeErasedTerm{body,reversedRefs}:
      +more = nt_choose(List<&2,KDef>,p88_string_eq(dk(d),"Def") && Bool.not(nc_native_def(d) || nc_foreign(d)),
        u => Con{KDef{name,"NativeErasedBody",nd_arity_plain(book,name),1,KTerm{"Absent","",0,0,[],[],0,0},body,[],False{},False{}},facts},u => facts)
      nr_walk(book,nt_reverse(String,reversedRefs,todo),Con{name,done},more)

@unsafe
def nr_visit_unindexed_product(book,name,todo,done,facts,d):
  nr_visit_unindexed_product_finish(book,name,todo,done,facts,d,nc_definition_product(book,d,0,True{}))

@unsafe
def nr_incremental_product_finish(+book: List<&2,KDef>, +name: String, todo: List<&2,String>,
  done: List<&2,String>, facts: List<&2,KDef>, analysis: P140OAnalysis, seen: KDef,
  previous: List<&2,P140OEEntry>, entries: List<&2,P140OEEntry>, hits: U32, misses: U32,
  +d: KDef, product: NativeErasedTerm) -> P140OEResult:
  match product:
    case NativeErasedTerm{body,reversedRefs}:
      p140oe_record(book,name,todo,done,facts,analysis,seen,previous,entries,hits,U32.inc(misses),d,
        body,nt_choose(U32,p140oe_regular(d),u => nd_arity_plain(book,name),u => 0),nt_reverse(String,reversedRefs,[]))

@unsafe
def nr_incremental_product(book,name,todo,done,facts,analysis,seen,previous,entries,hits,misses,d):
  nr_incremental_product_finish(book,name,todo,done,facts,analysis,seen,previous,entries,hits,misses,d,
    nc_definition_product(book,d,0,True{}))

@unsafe
def nc_erase(book,t):
  nc_erase_value(book,t)

@unsafe
def nc_erase_list(book,ts):
  nc_erase_list_value(book,ts)

@unsafe
def nc_erase_args(+book: List<&2,KDef>, +tel: KTerm, +xs: List<&2,KTerm>) -> List<&2,KTerm>:
  nc_erase_args_value(book,tel,xs)

@unsafe
def nc_erase_mat(+book: List<&2,KDef>, +t: KTerm, +adt: KTerm) -> KTerm:
  nc_erase_mat_value(book,t,adt)

@unsafe
def nc_erase_annotated(+book: List<&2,KDef>, +t: KTerm, +ty: KTerm) -> KTerm:
  nc_erase_annotated_value(book,t,ty)

@unsafe
def nc_erase_app(+book: List<&2,KDef>, +t: KTerm) -> KTerm:
  nc_erase_app_value(book,t)

@unsafe
def nc_definition_plain(+book: List<&2,KDef>, +d: KDef, +n: U32) -> KTerm:
  nc_definition_value(book,d,n)

@unsafe
def p143nr_visit(+book: List<&2,KDef>, +name: String, +todo: List<&2,String>, +done: List<&2,String>, +facts: List<&2,KDef>, +seen: KDef, +d: KDef) -> NR_Closure:
  nr_visit_product(book,name,todo,done,facts,seen,d)

@unsafe
def nr_visit(+book: List<&2, KDef>, +name: String, +todo: List<&2, String>, +done: List<&2, String>, +facts: List<&2, KDef>, +d: KDef) -> NR_Closure:
  nr_visit_unindexed_product(book,name,todo,done,facts,d)

@unsafe
def p140oe_fresh(+book: List<&2,KDef>, +name: String, todo: List<&2,String>, done: List<&2,String>, facts: List<&2,KDef>,
    analysis: P140OAnalysis, seen: KDef, previous: List<&2,P140OEEntry>, entries: List<&2,P140OEEntry>, hits: U32, misses: U32, +d: KDef) -> P140OEResult:
  nr_incremental_product(book,name,todo,done,facts,analysis,seen,previous,entries,hits,misses,d)
