
# Independent original semantics. Keep this unchanged when wiring the entry.

@unsafe
def p144o_original(book: List<&2,KDef>, +name: String) -> Bool:
  match book:
    case Nil{}: False{}
    case Con{+d,+rest}:
      kc(Bool,p137q_is_adt(d),
        u => kc(Bool,p137q_is_ctr(lookup(dc(d),name)),u => db(d),u => p144o_original(rest,name)),
        u => p144o_original(rest,name))


@unsafe
def p144o_build(book: List<&2,KDef>) -> P144OFacts:
  p144o_rows(book,missing(),[])


@unsafe
def p144o_rows(book: List<&2,KDef>, +claimed: KDef, +positive: List<&2,String>) -> P144OFacts:
  match book:
    case Nil{}: P144OFacts{nt_reverse(String,positive,[]),True{}}
    case Con{+head,+rest}:
      nt_choose(P144OFacts,p137q_is_adt(head),
        u => p144o_children(rest,dc(head),db(head),missing(),claimed,positive),
        u => p144o_rows(rest,claimed,positive))


@unsafe
def p144o_children(+rows: List<&2,KDef>, children: List<&2,KDef>, +owned: Bool,
    +seen: KDef, +claimed: KDef, +positive: List<&2,String>) -> P144OFacts:
  match children:
    case Nil{}: p144o_rows(rows,claimed,positive)
    case Con{+head,+rest}:
      nt_choose(P144OFacts,p88_string_eq(dk(head),"BookCache") || Bool.not(book_final_name_valid(dn(head))),
        u => P144OFacts{[],False{}},
        u => p144o_child(rows,rest,owned,seen,claimed,positive,head,index_hash(dn(head),2166136261)))


@unsafe
def p144o_child(+rows: List<&2,KDef>, +rest: List<&2,KDef>, +owned: Bool,
    +seen: KDef, +claimed: KDef, +positive: List<&2,String>, +head: KDef, +hash: U32) -> P144OFacts:
  +name = dn(head)
  nt_choose(P144OFacts,p142j_member(seen,name,hash),
    u => p144o_children(rows,rest,owned,seen,claimed,positive),
    u => nt_choose(P144OFacts,p137q_is_ctr(head) && Bool.not(p142j_member(claimed,name,hash)),
      v => p144o_children(rows,rest,owned,p142j_mark(seen,name,hash),p142j_mark(claimed,name,hash),
        nt_choose(List<&2,String>,owned,w => Con{name,positive},w => positive)),
      v => p144o_children(rows,rest,owned,p142j_mark(seen,name,hash),claimed,positive)))


@unsafe
def p144o_query(+book: List<&2,KDef>, facts: P144OFacts, +name: String) -> Bool:
  match facts:
    case P144OFacts{+names,valid}:
      nt_choose(Bool,valid,u => nb_contains(names,name),u => p144o_original(book,name))


@unsafe
def p144o_identity(+book: List<&2,KDef>, facts: P144OFacts, +name: String) -> String:
  nt_choose(String,p144o_query(book,facts,name),u => name,u => nc_ctor_encode(name))

# Existing-index comparison: additional construction/destruction is charged by
# calling this after p144o_build; it is not selected by the production adapter.

@unsafe
def p144o_index(names: List<&2,String>, tree: KDef) -> KDef:
  match names:
    case Nil{}: tree
    case Con{+name,rest}: p144o_index(rest,p142j_mark(tree,name,index_hash(name,2166136261)))


@unsafe
def p144o_index_query(+book: List<&2,KDef>, valid: Bool, +tree: KDef, +name: String) -> Bool:
  nt_choose(Bool,valid,u => p142j_member(tree,name,index_hash(name,2166136261)),u => p144o_original(book,name))

# Catalogue normalization still uses the ORIGINAL source book. Only ownership
# identity queries consume the shared summary; order/arity/foreign rules stay.

@unsafe
def p144o_specs(+book: List<&2,KDef>, children: List<&2,KDef>, +params: U32, +facts: P144OFacts) -> List<&2,N_Constructor>:
  match children:
    case Nil{}: []
    case Con{+child,rest}:
      Con{N_Constructor{p144o_identity(book,facts,dn(child)),nc_live_count(book,nc_skip_tel(book,dt(child),params),da(child)),True{}},
        p144o_specs(book,rest,params,facts)}


@unsafe
def p144o_constructors(+book: List<&2,KDef>, definitions: List<&2,KDef>, +facts: P144OFacts) -> List<&2,N_Constructor>:
  match definitions:
    case Nil{}: []
    case Con{+definition,+rest}:
      nt_choose(List<&2,N_Constructor>,p88_string_eq(dk(definition),"ADT"),
        u => List.append(&2,N_Constructor,p144o_specs(book,dc(definition),da(definition),facts),p144o_constructors(book,rest,facts)),
        u => nt_choose(List<&2,N_Constructor>,p88_string_eq(dk(definition),"Def") && nc_foreign(definition),
          v => Con{N_Constructor{dn(definition),nc_all_args(book,dt(definition)),True{}},p144o_constructors(book,rest,facts)},
          v => p144o_constructors(book,rest,facts)))

@unsafe
def p144o_term(term: KTerm) -> P144OFacts:
  match term:
    case KTerm{tag,name,id,version,kids,names,begin,end}:
      nt_choose(P144OFacts,p88_string_eq(tag,"P144Ownership") && p88_string_eq(name,"") &&
        U32.is_eq(id,0) && U32.is_eq(version,1) && List.is_empty(&2,KTerm,kids) &&
        U32.is_eq(begin,0) && U32.is_eq(end,0),
        u => P144OFacts{names,True{}},u => P144OFacts{[],False{}})
    case _: P144OFacts{[],False{}}


@unsafe
def p144o_payload(context: KDef) -> P144OFacts:
  match context:
    case KDef{name,kind,arity,templates,typ,value,children,native,uns}:
      nt_choose(P144OFacts,p88_string_eq(name,"$native.ctors") && p88_string_eq(kind,"NativeCtorIndex") &&
        U32.is_eq(arity,0) && U32.is_eq(templates,0) && Bool.not(native) && Bool.not(uns),
        u => p144o_term(typ),u => P144OFacts{[],False{}})
    case _: P144OFacts{[],False{}}


@unsafe
def p144o_ctor_carrier(+context: KDef, facts: P144OFacts) -> KDef:
  match context facts:
    case KDef{+name,+kind,+arity,+templates,+typ,+value,+children,+native,+uns} P144OFacts{+names,valid}:
      nt_choose(KDef,valid && p88_string_eq(name,"$native.ctors") && p88_string_eq(kind,"NativeCtorIndex") &&
        U32.is_eq(arity,0) && U32.is_eq(templates,0) && Bool.not(native) && Bool.not(uns) && p98_tag_eq(typ,"Absent"),
        u => KDef{name,kind,arity,templates,KTerm{"P144Ownership","",0,1,[],names,0,0},value,children,native,uns},
        u => context)
    case _ _: context


@unsafe
def p144o_view(+book: List<&2,KDef>, +facts: P144OFacts) -> List<&2,KDef>:
  match book:
    case Con{+cache,+rest}:
      nt_choose(List<&2,KDef>,p88_string_eq(dk(cache),"BookCache"),
        u => Con{KDef{dn(cache),dk(cache),da(cache),dx(cache),dt(cache),dv(cache),
          [index_first(dc(cache)),KDef{"$native.static","NativeStaticContext",0,0,
            KTerm{"NativeImage","",0,0,[],[],0,0},KTerm{"Absent","",0,0,[],[],0,0},
            [missing(),p144o_ctor_carrier(nc_ctor_prepare(book),facts)],False{},False{}}],db(cache),du(cache)},rest},
        u => book)
    case Nil{}: []


@unsafe
def p144o_owned(+book: List<&2,KDef>, name: String) -> Bool:
  p144o_owned_context(book,name,nc_ctor_context(book))

# The hot query returns Bool directly: no intermediate P144OFacts result box.

@unsafe
def p144o_owned_context(+book: List<&2,KDef>, +query: String, context: KDef) -> Bool:
  match context:
    case KDef{name,kind,arity,templates,typ,value,children,native,uns}:
      nt_choose(Bool,p88_string_eq(name,"$native.ctors") && p88_string_eq(kind,"NativeCtorIndex") &&
        U32.is_eq(arity,0) && U32.is_eq(templates,0) && Bool.not(native) && Bool.not(uns),
        u => p144o_owned_term(book,query,typ),u => p144o_original(book,query))
    case _: p144o_original(book,query)


@unsafe
def p144o_owned_term(+book: List<&2,KDef>, +query: String, term: KTerm) -> Bool:
  match term:
    case KTerm{tag,name,id,version,kids,names,begin,end}:
      nt_choose(Bool,p88_string_eq(tag,"P144Ownership") && p88_string_eq(name,"") &&
        U32.is_eq(id,0) && U32.is_eq(version,1) && List.is_empty(&2,KTerm,kids) &&
        U32.is_eq(begin,0) && U32.is_eq(end,0),
        u => nb_contains(names,query),u => p144o_original(book,query))
    case _: p144o_original(book,query)

@unsafe
def p144o_request(+source: List<&2,KDef>, view: List<&2,KDef>, closure: NR_Closure, bound: Maybe<&2,U32>) -> NR_Request:
  match closure:
    case NR_Closure{+names,facts}:
      NR_Request{source,ns_attach_book(view,facts,0,[]),names,nc_paths_of(source,names),kr_filter(source,names),bound}


@unsafe
def p144o_source_ready(+source: List<&2,KDef>, bound: U32, facts: P144OFacts) -> NR_Request:
  +view = p144o_view(source,facts)
  p144o_request(source,view,nr_walk(view,["main"],[],[]),Some{bound})


@unsafe
def p144o_prepare_annotated(+book: List<&2,KDef>, annotated: List<&2,KDef>) -> NR_Request:
  +merged = nc_context_defs(book,nc_context_index(annotated))
  +bound = norm_max_book(merged)
  +source = book_cached(merged,bound)
  p144o_source_ready(source,bound,p144o_build(source))


@unsafe
def p144o_prepared(+source: List<&2,KDef>, +names: List<&2,String>, constructors: List<&2,N_Constructor>, prepared: P112SPrepared) -> P128RawLowering:
  match prepared:
    case P112SPrepared{+book,+nodes,+error}:
      nt_choose(P128RawLowering,String.is_empty(error),
        u => p144o_lower_bangs(source,book,nodes,names,constructors,nc_bangs_names(book,names)),
        u => P128RawLowering{P113DLowered{P113DProgram{P112StaticProgram{p111_empty(),[]},[]},error},[]})


@unsafe
def p144o_lower_bangs(source: List<&2,KDef>, +book: List<&2,KDef>, +nodes: List<&2,P112SNode>, +names: List<&2,String>, constructors: List<&2,N_Constructor>, +bangs: List<&2,String>) -> P128RawLowering:
  p128raw_plan_finish(p112s_finish(nodes,p140or_finish(source,names,constructors,
    p111_compile_defs(book,names,bangs,0,[]))),
    p113pl_candidates(book,names,bangs,book_cached(nq_signatures(book,names),0)))


@unsafe
def p144o_catalogued(source: List<&2,KDef>, book: List<&2,KDef>, +names: List<&2,String>, +constructors: List<&2,N_Constructor>) -> P128RawLowering:
  p144o_prepared(source,names,constructors,p112s_prepare(book,names,constructors))


@unsafe
def p144o_lower_request(request: NR_Request) -> P128RawLowering:
  match request:
    case NR_Request{+source,+book,+names,paths,scope,+bound}:
      +error = nc_compile_error_known(source,bound)
      nt_choose(P128RawLowering,String.is_empty(error),
        u => p144o_catalogued(source,book,names,nc_add_ctors(nc_default_ctors(),
          p144o_constructors(source,source,p144o_payload(nc_ctor_context(book))))),
        u => P128RawLowering{P113DLowered{P113DProgram{P112StaticProgram{p111_empty(),[]},[]},error},[]})

@unsafe
def p144o_original_ctor_identity(
  +book: List<&2, KDef>,
  +name: String,
) -> String:
  kc(String, p144o_original(book, name), u => name, u => nc_ctor_encode(name))


@unsafe
def p144o_original_ctor_specs(+book: List<&2, KDef>, cs: List<&2, KDef>, +params: U32) -> List<&2, N_Constructor>:
  match cs:
    case Nil{}: Nil{}
    case Con{+c, rest}: Con{N_Constructor{p144o_original_ctor_identity(book, dn(c)), nc_live_count(book, nc_skip_tel(book, dt(c), params), da(c)), True{}}, p144o_original_ctor_specs(book, rest, params)}


@unsafe
def p144o_original_constructors(+book: List<&2,KDef>, ds: List<&2,KDef>) -> List<&2,N_Constructor>:
  match ds:
    case Nil{}: Nil{}
    case Con{+d, +rest}:
      nt_choose(List<&2, N_Constructor>, p88_string_eq(dk(d), "ADT"),
        u => List.append(&2, N_Constructor, p144o_original_ctor_specs(book, dc(d), da(d)), p144o_original_constructors(book, rest)),
        u => nt_choose(List<&2, N_Constructor>, p88_string_eq(dk(d), "Def") && nc_foreign(d),
          u => Con{N_Constructor{dn(d), nc_all_args(book, dt(d)), True{}}, p144o_original_constructors(book, rest)},
          u => p144o_original_constructors(book, rest)))


@unsafe
def p144o_controls() -> List<&2,String>:
  +c = p144ot_ctor("C")
  +owned = p144ot_def("Owned","ADT",True{},[c])
  +plain = p144ot_def("Plain","ADT",False{},[c])
  +shadow = p144ot_def("Shadow","ADT",False{},[p144ot_def("C","Def",False{},[]),c])
  +nested = p144ot_def("Nested","ADT",True{},[p144ot_def("wrapper","Def",False{},[c])])
  +cached = p144ot_def("Cached","ADT",True{},book_cached([c],0))
  +collision: List<&2,KDef> = [p144ot_def("First","ADT",False{},[p144ot_ctor("costarring")]),p144ot_def("Second","ADT",True{},[p144ot_ctor("liquid")])]
  +unicode: List<&2,KDef> = [p144ot_def("BMP","ADT",True{},[p144ot_ctor("商"),p144ot_ctor("")]),p144ot_def("Astral","ADT",False{},[p144ot_ctor("𐀀")])]
  +leaf: KDef = KIndexLeaf{0,[c]}
  +node: KDef = KIndexNode{0,1,leaf,leaf}
  +empty = p144ot_ctor("")
  [p114st_row("ownership-empty",p144ot_expected([],"C",False{},True{})),
   p114st_row("ownership-missing",p144ot_expected([owned],"missing",False{},True{})),
   p114st_row("ownership-true",p144ot_expected([owned],"C",True{},True{})),
   p114st_row("ownership-false",p144ot_expected([plain],"C",False{},True{})),
   p114st_row("ownership-false-first",p144ot_expected([plain,owned],"C",False{},True{})),
   p114st_row("ownership-true-first",p144ot_expected([owned,plain],"C",True{},True{})),
   p114st_row("ownership-non-ADT",p144ot_expected([p144ot_def("ignored","Def",True{},[c])],"C",False{},True{})),
   p114st_row("ownership-child-shadow",p144ot_expected([shadow],"C",False{},True{})),
   p114st_row("ownership-later-ADT-after-shadow",p144ot_expected([shadow,owned],"C",True{},True{})),
   p114st_row("ownership-first-child-wins",p144ot_expected([p144ot_def("First","ADT",True{},[c,p144ot_def("C","Def",False{},[])])],"C",True{},True{})),
   p114st_row("ownership-empty-name",p144ot_expected([p144ot_def("Empty","ADT",True{},[empty])],"",True{},True{})),
   p114st_row("ownership-nested-ignored",p144ot_expected([nested],"C",False{},True{})),
   p114st_row("ownership-child-cache-fallback",p144ot_expected([cached],"C",True{},False{})),
   p114st_row("ownership-child-cache-after-visible-fallback",p144ot_expected([p144ot_def("Cached","ADT",True{},[c,index_first(book_cached([],0))])],"C",True{},False{})),
   p114st_row("ownership-full-hash-collision",U32.is_eq(index_hash("costarring",2166136261),index_hash("liquid",2166136261))),
   p114st_row("ownership-collision-false",p144ot_expected(collision,"costarring",False{},True{})),
   p114st_row("ownership-collision-true",p144ot_expected(collision,"liquid",True{},True{})),
   p114st_row("ownership-unicode-BMP",p144ot_expected(unicode,"商",True{},True{})),
   p114st_row("ownership-unicode-boundary",p144ot_expected(unicode,"",True{},True{}) && p144ot_expected(unicode,"𐀀",False{},True{})),
   p114st_row("ownership-index-record-top-ignored",p144ot_expected([leaf,node,owned],"C",True{},True{})),
   p114st_row("ownership-index-leaf-shadows-empty-child",p144ot_expected([p144ot_def("Malformed","ADT",True{},[leaf,empty])],"",False{},True{})),
   p114st_row("ownership-index-node-shadows-empty-child",p144ot_expected([p144ot_def("Malformed","ADT",True{},[node,empty])],"",False{},True{})),
   p114st_row("ownership-local-shadow-set-resets",p144ot_expected([p144ot_def("Malformed","ADT",True{},[leaf,empty]),p144ot_def("Later","ADT",True{},[empty])],"",True{},True{})),
   p114st_row("ownership-carrier-positive-survives",p144ot_carry([owned],"C")),
   p114st_row("ownership-carrier-false-survives",p144ot_carry([plain,owned],"C")),
   p114st_row("ownership-carrier-miss-survives",p144ot_carry([owned],"missing")),
   p114st_row("ownership-raw-view-fallback",p134v_bool(p144o_owned([owned],"C"),True{})),
   p114st_row("ownership-metadata-wrong-version",p144ot_bad_metadata([owned],"C",KTerm{"P144Ownership","",0,2,[],[],0,0})),
   p114st_row("ownership-metadata-wrong-tag",p144ot_bad_metadata([owned],"C",KTerm{"Absent","",0,1,[],[],0,0})),
   p114st_row("ownership-metadata-wrong-origin",p144ot_bad_metadata([owned],"C",KTerm{"P144Ownership","",0,1,[],[],1,0})),
   p114st_row("ownership-metadata-wrong-kind",p144ot_bad_metadata([owned],"C",KLiteral{"U32",0,"",0,0})),
   p114st_row("ownership-catalogue-empty",p144ot_catalogue([])),
   p114st_row("ownership-catalogue-first-false",p144ot_catalogue([plain,owned])),
   p114st_row("ownership-catalogue-shadow",p144ot_catalogue([shadow,owned])),
   p114st_row("ownership-catalogue-collision",p144ot_catalogue(collision))]


@unsafe
def p144ce_build(book: List<&2,KDef>) -> P144CEFacts:
  p144ce_rows(book,missing())


@unsafe
def p144ce_rows(book: List<&2,KDef>, +members: KDef) -> P144CEFacts:
  match book:
    case Nil{}: P144CEFacts{members,True{}}
    case Con{+parent,+rest}:
      nt_choose(P144CEFacts,book_final_name_valid(dk(parent)),
        u => nt_choose(P144CEFacts,p88_string_eq(dk(parent),"BookCache"),
          v => p144ce_rows(rest,members),
          v => p144ce_children(rest,dc(parent),missing(),members)),
        u => P144CEFacts{missing(),False{}})


@unsafe
def p144ce_children(+rows: List<&2,KDef>, children: List<&2,KDef>,
    +seen: KDef, +members: KDef) -> P144CEFacts:
  match children:
    case Nil{}: p144ce_rows(rows,members)
    case Con{+head,+rest}:
      nt_choose(P144CEFacts,book_final_name_valid(dn(head)) && book_final_name_valid(dk(head)),
        u => nt_choose(P144CEFacts,p88_string_eq(dk(head),"BookCache"),
          v => P144CEFacts{missing(),False{}},
          v => p144ce_child(rows,rest,seen,members,head,index_hash(dn(head),2166136261))),
        u => P144CEFacts{missing(),False{}})


@unsafe
def p144ce_child(+rows: List<&2,KDef>, +rest: List<&2,KDef>, +seen: KDef,
    +members: KDef, +head: KDef, +hash: U32) -> P144CEFacts:
  +name = dn(head)
  nt_choose(P144CEFacts,p142j_member(seen,name,hash),
    u => p144ce_children(rows,rest,seen,members),
    u => p144ce_children(rows,rest,p142j_mark(seen,name,hash),
      nt_choose(KDef,p88_string_eq(dk(head),"Absent"),
        v => members,v => p142j_mark(members,name,hash))))


@unsafe
def p144ce_query(+book: List<&2,KDef>, facts: P144CEFacts, +name: String) -> Bool:
  match facts:
    case P144CEFacts{members,valid}:
      nt_choose(Bool,valid && book_final_name_valid(name),
        u => p142j_member(members,name,index_hash(name,2166136261)),
        u => constructor_exists(book,name))

# Full consumer interfaces build and release their own facts. Original functions
# remain unchanged independent oracles and all invalid fact cases use them.

@unsafe
def p144ce_names(+done: List<&2,KDef>, +ctors: List<&2,KDef>, +names: List<&2,String>) -> String:
  match ctors:
    case Nil{}: ""
    case Con{head,Nil{}}: constructor_names(done,ctors,names)
    case _: p144ce_names_go(done,ctors,names,p144ce_build(done))


@unsafe
def p144ce_names_go(+done: List<&2,KDef>, ctors: List<&2,KDef>, +names: List<&2,String>, +facts: P144CEFacts) -> String:
  match ctors:
    case Nil{}: ""
    case Con{+head,rest}:
      nt_choose(String,has_name(names,dn(head)) || p144ce_query(done,facts,dn(head)),
        u => "duplicate constructor name",
        u => p144ce_names_go(done,rest,Con{dn(head),names},facts))


@unsafe
def p144ce_disjoint(+defs: List<&2,KDef>, +context: List<&2,KDef>) -> Bool:
  match defs:
    case Nil{}: True{}
    case _: p144ce_disjoint_go(defs,context,p144ce_build(context))


@unsafe
def p144ce_disjoint_go(defs: List<&2,KDef>, +context: List<&2,KDef>, +facts: P144CEFacts) -> Bool:
  match defs:
    case Nil{}: True{}
    case Con{+definition,rest}:
      nt_choose(Bool,Bool.not(p144ce_query(context,facts,dn(definition))) &&
        p144ce_disjoint_go(dc(definition),context,facts),
        u => p144ce_disjoint_go(rest,context,facts),u => False{})

@unsafe
def p144ce_original_disjoint(+defs: List<&2,KDef>, +context: List<&2,KDef>) -> Bool:
  match defs:
    case Nil{}: True{}
    case Con{d, rest}: kc(Bool, Bool.not(constructor_exists(context, dn(d))) && p144ce_original_disjoint(dc(d), context), u => p144ce_original_disjoint(rest, context), u => False{})


@unsafe
def p144ce_controls() -> List<&2,String>:
  +c = p144ot_ctor("C")
  +u = p144ot_ctor("U")
  +absent = p144ot_def("C","Absent",False{},[])
  +nonctor = p144ot_def("C","Def",False{},[])
  +plain = p144ot_def("Plain","ADT",False{},[c])
  +other = p144ot_def("Other","Def",False{},[c])
  +masked = p144ot_def("Masked","ADT",False{},[absent,c])
  +visible = p144ot_def("Visible","ADT",False{},[c,absent])
  +cached = p144ot_def("Cached","ADT",False{},book_cached([c],0))
  +empty = p144ot_def("Empty","Def",False{},[p144ot_ctor("")])
  +nested = p144ot_def("Nested","ADT",False{},[p144ot_def("Wrapper","Def",False{},[c])])
  +cache = p144ot_def("$kernel.cache","BookCache",True{},[c])
  +leaf: KDef = KIndexLeaf{0,[c]}
  +node: KDef = KIndexNode{0,1,leaf,leaf}
  +collision = p144ot_def("Collision","ADT",False{},[p144ot_ctor("costarring"),p144ot_ctor("liquid")])
  +unicode = p144ot_def("Unicode","ADT",False{},[p144ot_ctor("商"),p144ot_ctor("𐀀")])
  [
    nt_choose(String,p144cet_query([],"C",False{},True{}),u=>"empty:pass",u=>"empty:FAIL"),
    nt_choose(String,p144cet_query([plain],"C",True{},True{}),u=>"unowned:pass",u=>"unowned:FAIL"),
    nt_choose(String,p144cet_query([other],"C",True{},True{}),u=>"nonadt:pass",u=>"nonadt:FAIL"),
    nt_choose(String,p144cet_query([p144ot_def("P","ADT",False{},[nonctor])],"C",True{},True{}),u=>"nonctor:pass",u=>"nonctor:FAIL"),
    nt_choose(String,p144cet_query([masked],"C",False{},True{}),u=>"first-absent:pass",u=>"first-absent:FAIL"),
    nt_choose(String,p144cet_query([visible],"C",True{},True{}),u=>"first-visible:pass",u=>"first-visible:FAIL"),
    nt_choose(String,p144cet_query([masked,plain],"C",True{},True{}),u=>"parent-or:pass",u=>"parent-or:FAIL"),
    nt_choose(String,p144cet_query([cache],"C",False{},True{}),u=>"outer-cache-skip:pass",u=>"outer-cache-skip:FAIL"),
    nt_choose(String,p144cet_query([cached],"C",True{},False{}),u=>"child-cache-fallback:pass",u=>"child-cache-fallback:FAIL"),
    nt_choose(String,p144cet_query([empty],"",True{},True{}),u=>"empty-key:pass",u=>"empty-key:FAIL"),
    nt_choose(String,p144cet_query([nested],"C",False{},True{}),u=>"shallow-only:pass",u=>"shallow-only:FAIL"),
    nt_choose(String,p144cet_query([collision],"costarring",True{},True{}),u=>"collision-left:pass",u=>"collision-left:FAIL"),
    nt_choose(String,p144cet_query([collision],"liquid",True{},True{}),u=>"collision-right:pass",u=>"collision-right:FAIL"),
    nt_choose(String,p144cet_query([collision],"missing",False{},True{}),u=>"collision-miss:pass",u=>"collision-miss:FAIL"),
    nt_choose(String,p144cet_query([unicode],"商",True{},True{}),u=>"unicode-bmp:pass",u=>"unicode-bmp:FAIL"),
    nt_choose(String,p144cet_query([unicode],"𐀀",True{},True{}),u=>"unicode-astral:pass",u=>"unicode-astral:FAIL"),
    nt_choose(String,p144cet_names([plain],[u],[],""),u=>"names-clear:pass",u=>"names-clear:FAIL"),
    nt_choose(String,p144cet_names([plain],[c],[],"duplicate constructor name"),u=>"names-existing:pass",u=>"names-existing:FAIL"),
    nt_choose(String,p144cet_names([],[u,u],[],"duplicate constructor name"),u=>"names-local:pass",u=>"names-local:FAIL"),
    nt_choose(String,p144cet_names([],[u],["U"],"duplicate constructor name"),u=>"names-seen:pass",u=>"names-seen:FAIL"),
    nt_choose(String,p144cet_disjoint([plain],[u],True{}),u=>"disjoint-clear:pass",u=>"disjoint-clear:FAIL"),
    nt_choose(String,p144cet_disjoint([plain],[p144ot_def("X","Def",False{},[c])],False{}),u=>"disjoint-nested:pass",u=>"disjoint-nested:FAIL"),
    nt_choose(String,p144cet_query([leaf],"C",True{},True{}),u=>"index-leaf-parent:pass",u=>"index-leaf-parent:FAIL"),
    nt_choose(String,p144cet_query([node],"",True{},True{}),u=>"index-node-parent:pass",u=>"index-node-parent:FAIL"),
    nt_choose(String,p144cet_query([p144ot_def("P","Absent",False{},[c])],"C",True{},True{}),u=>"absent-parent:pass",u=>"absent-parent:FAIL"),
    nt_choose(String,p144cet_query([p144ot_def("P","Def",False{},[leaf])],"",True{},True{}),u=>"index-child:pass",u=>"index-child:FAIL"),
    nt_choose(String,p144cet_query([p144ot_def("P","ADT",False{},[index_first(book_cached([u],0)),c])],"C",False{},False{}),u=>"child-cache-mask:pass",u=>"child-cache-mask:FAIL")
  ]
