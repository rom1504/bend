# Semantic port of the mature immutable-constructor admission, with typed
# image words and shallow final atoms. It never reads generated C expressions.
@unsafe
def p112s_fields(terms: List<&2,KTerm>) -> List<&2,P112SWord>:
  match terms:
    case Nil{}: []
    case Con{head,rest}: Con{p112s_term_word(head),p112s_fields(rest)}

@unsafe
def p112s_word_key(word: P112SWord) -> String:
  match word:
    case P112SRaw{value}: "r" ++ U32.show(value) ++ ";"
    case P112SPacked{name,payload}: "p" ++ nc_ctor_codes(name) ++ ":" ++ U32.show(payload) ++ ";"
    case P112SBox{name,offset}: "b" ++ nc_ctor_codes(name) ++ ":" ++ U32.show(offset) ++ ";"

@unsafe
def p112s_fields_key(fields: List<&2,P112SWord>) -> String:
  match fields:
    case Nil{}: ""
    case Con{head,rest}: p112s_word_key(head) ++ p112s_fields_key(rest)

@unsafe
def p112s_intern(+term: KTerm, +fields: List<&2,P112SWord>, image: P112SImage) -> P112STerm:
  match image:
    case P112SImage{+size,+nodes,+index,+error}:
      +key = nc_ctor_codes(nm(term)) ++ ":" ++ p112s_fields_key(fields)
      +hash = index_hash(key,2166136261)
      +old = index_find(index,key,hash,32)
      +count = nt_count(P112SWord,fields)
      nt_choose(P112STerm,String.eq(dk(old),"P112StaticIntern"),
        u => P112STerm{p112s_marker(P112SBox{nm(term),da(old)}),P112SImage{size,nodes,index,error}},u =>
      nt_choose(P112STerm,U32.is_le(size,65536) && U32.is_le(count,U32.sub(65536,size)),
        u => P112STerm{p112s_marker(P112SBox{nm(term),size}),P112SImage{U32.add(size,count),Con{P112SNode{size,nm(term),fields},nodes},index_set(index,KDef{key,"P112StaticIntern",size,0,atom("Absent"),atom("Absent"),[],False{},False{}},hash,32),error}},
        u => P112STerm{term,P112SImage{size,nodes,index,error}}))

@unsafe
def p112s_packed(+term: KTerm, fields: List<&2,KTerm>, +image: P112SImage) -> P112STerm:
  match fields:
    case Nil{}: P112STerm{p112s_marker(P112SPacked{nm(term),0}),image}
    case Con{head,Nil{}}: P112STerm{p112s_marker(P112SPacked{nm(term),p112s_uint(U32.read(nm(head)))}),image}
    case _: P112STerm{term,image}

@unsafe
def p112s_constructor(+constructors: KDef, +term: KTerm, +image: P112SImage) -> P112STerm:
  nt_choose(P112STerm,String.eq(tg(term),"NWord"),u => P112STerm{term,image},u =>
    nt_choose(P112STerm,ns_ctor(constructors,nm(term),terms_len(ks(term))) && ns_constants(ks(term)),u =>
      nt_choose(P112STerm,ns_packed(term),v => p112s_packed(term,ks(term),image),v => p112s_intern(term,p112s_fields(ks(term)),image)),
      u => P112STerm{term,image}))

law p112s_term:
  for +constructors: KDef
  for +term: KTerm
  for +image: P112SImage
  P112STerm

@unsafe
def p112s_terms(+constructors: KDef, terms: List<&2,KTerm>, +image: P112SImage) -> P112STerms:
  match terms:
    case Nil{}: P112STerms{[],image}
    case Con{head,rest}: p112s_terms_step(constructors,rest,p112s_term(constructors,head,image))

@unsafe
def p112s_terms_step(+constructors: KDef, +rest: List<&2,KTerm>, first: P112STerm) -> P112STerms:
  match first:
    case P112STerm{head,image}: p112s_terms_cons(head,p112s_terms(constructors,rest,image))

def p112s_terms_cons(head: KTerm, tail: P112STerms) -> P112STerms:
  match tail:
    case P112STerms{rest,image}: P112STerms{Con{head,rest},image}

@unsafe
def p112s_rebuild(+constructors: KDef, +original: KTerm, children: P112STerms) -> P112STerm:
  match children:
    case P112STerms{kids,+image}:
      +term = k_rebuild(original,nm(original),ix(original),qt(original),kids,rm(original),kb(original),ke(original))
      nt_choose(P112STerm,String.eq(tg(term),"Ctr"),u => p112s_constructor(constructors,ns_static_scalar(term),image),u => P112STerm{term,image})

@unsafe
def p112s_stale(image: P112SImage) -> P112STerm:
  match image:
    case P112SImage{size,nodes,index,error}: P112STerm{atom("NativeStaticInput"),P112SImage{size,nodes,index,p111_first(error,"static atom present before fresh preparation")}}

@unsafe
def p112s_term(constructors,term,image):
  nt_choose(P112STerm,String.eq(tg(term),"NStatic") || String.eq(tg(term),"NWPattern"),u => p112s_stale(image),u =>
    nt_choose(P112STerm,String.eq(tg(term),"NWord") || String.eq(tg(term),"Var") || String.eq(tg(term),"Ref"),
      u => P112STerm{term,image},u => p112s_rebuild(constructors,term,p112s_terms(constructors,ks(term),image))))

@unsafe
def p112s_defs(+book: List<&2,KDef>, +constructors: KDef, names: List<&2,String>, +facts: List<&2,KDef>, +image: P112SImage) -> P112SDefs:
  match names:
    case Nil{}: P112SDefs{facts,image}
    case Con{+name,+rest}:
      +definition = lookup(book,name)
      nt_choose(P112SDefs,String.eq(dk(definition),"Def") && Bool.not(nc_native_def(definition) || nc_foreign(definition)),
        u => p112s_def_step(book,constructors,rest,name,facts,p112s_term(constructors,nc_compact(nc_definition(book,definition,0)),image)),
        u => p112s_defs(book,constructors,rest,facts,image))

@unsafe
def p112s_def_step(+book: List<&2,KDef>, +constructors: KDef, +rest: List<&2,String>, +name: String, +facts: List<&2,KDef>, transformed: P112STerm) -> P112SDefs:
  match transformed:
    case P112STerm{body,image}:
      +prior = ns_body(book,name)
      p112s_defs(book,constructors,rest,Con{KDef{name,"NativeStaticBody",da(prior),dx(prior),atom("Absent"),body,[prior],False{},False{}},facts},image)

@unsafe
def p112s_node_index(nodes: List<&2,P112SNode>, index: KDef) -> KDef:
  match nodes:
    case Nil{}: index
    case Con{P112SNode{+offset,name,fields},rest}:
      +key = U32.show(offset)
      p112s_node_index(rest,index_set(index,KDef{key,"P112StaticNode",offset,nt_count(P112SWord,fields),atom(name),atom("Absent"),[],False{},False{}},index_hash(key,2166136261),32))

@unsafe
def p112s_attach(+book: List<&2,KDef>, +constructors: List<&2,N_Constructor>, built: P112SDefs) -> P112SPrepared:
  match built:
    case P112SDefs{+facts,P112SImage{+size,+nodes,index,+error}}:
      p112s_attach_book(book,facts,size,nt_reverse(P112SNode,nodes,[]),p112s_ctors(constructors,0,missing()),error)

@unsafe
def p112s_attach_book(book: List<&2,KDef>, +facts: List<&2,KDef>, +size: U32, +nodes: List<&2,P112SNode>, +constructors: KDef, +error: String) -> P112SPrepared:
  match book:
    case Con{+cache,+rest}:
      P112SPrepared{Con{KDef{dn(cache),dk(cache),da(cache),dx(cache),dt(cache),dv(cache),
        [index_first(dc(cache)),KDef{"$native.static","NativeStaticContext",0,0,kt("P112StaticImage","",size,0,[]),atom("Absent"),[index_build(facts),nc_ctor_prepare(Con{cache,rest}),constructors,p112s_node_index(nodes,missing())],False{},False{}}],db(cache),du(cache)},rest},nodes,error}
    case _: P112SPrepared{book,[],"static preparation requires a fresh cached request"}

@unsafe
def p112s_prepare(+book: List<&2,KDef>, +names: List<&2,String>, +constructors: List<&2,N_Constructor>) -> P112SPrepared:
  nt_choose(P112SPrepared,nc_pack_foreign(book),u => P112SPrepared{book,[],""},u =>
    nt_choose(P112SPrepared,String.eq(dk(index_first(book)),"BookCache"),
      u => p112s_attach(book,constructors,p112s_defs(book,p112s_block_effects(ns_ctor_index(constructors,missing()),p111_effects(book,names)),names,[],P112SImage{0,[],missing(),""})),
      u => P112SPrepared{book,[],"static preparation requires a fresh cached request"}))
