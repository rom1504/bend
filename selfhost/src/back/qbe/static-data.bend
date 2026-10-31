
# Same ordered identities as p111_finish / p111q_constructor_ids. Store both
# numeric ID and exact live arity so lowering and validation share one lookup.


@unsafe
def p112s_ctors(constructors: List<&2,N_Constructor>, +next: U32, index: KDef) -> KDef:
  match constructors:
    case Nil{}: index
    case Con{N_Constructor{+name,arity,hot},rest}:
      p112s_ctors(rest,U32.inc(next),index_set(index,KDef{name,"P112StaticCtor",next,arity,{KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},{KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},[],False{},False{}},index_hash(name,2166136261),32))


@unsafe
def p112s_find(+index: KDef, +name: String) -> KDef:
  index_find(index,name,index_hash(name,2166136261),32)


@unsafe
def p112s_block_effects(index: KDef, names: List<&2,String>) -> KDef:
  match names:
    case Nil{}: index
    case Con{+name,rest}:
      p112s_block_effects(index_set(index,KDef{name,"P112StaticForeign",0,0,{KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},{KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},[],False{},False{}},index_hash(name,2166136261),32),rest)


@unsafe
def p112s_word(word: P112SWord, +constructors: KDef) -> N111Value:
  match word:
    case P112SRaw{value}: N111Const{value,0}
    case P112SPacked{name,payload}: N111Const{payload,U32.or(16777216,U32.shln(da(p112s_find(constructors,name)),8n))}
    case P112SBox{name,offset}: N111Const{U32.add(51413504,offset),U32.or(33554432,U32.shln(da(p112s_find(constructors,name)),8n))}


@unsafe
def p112s_size(nodes: List<&2,P112SNode>, total: U32) -> U32:
  match nodes:
    case Nil{}: total
    case Con{P112SNode{offset,name,fields},rest}: p112s_size(rest,U32.add(total,nt_count(P112SWord,fields)))


@unsafe
def p112s_marker(word: P112SWord) -> KTerm:
  match word:
    case P112SRaw{value}: kt("NWord",U32.show(value),0,0,[])
    case P112SPacked{name,payload}: kt("NStatic",name,payload,1,[])
    case P112SBox{name,offset}: kt("NStatic",name,offset,0,[])


@unsafe
def p112s_term_word(+term: KTerm) -> P112SWord:
  nt_choose(P112SWord,String.eq(tg(term),"NWord"),u => P112SRaw{p112s_uint(U32.read(nm(term)))},u =>
    nt_choose(P112SWord,U32.is_eq(qt(term),1),v => P112SPacked{nm(term),ix(term)},v => P112SBox{nm(term),ix(term)}))


def p112s_uint(value: Maybe<&2,U32>) -> U32:
  match value:
    case None{}: 0
    case Some{word}: word


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
        u => P112STerm{p112s_marker(P112SBox{nm(term),size}),P112SImage{U32.add(size,count),Con{P112SNode{size,nm(term),fields},nodes},index_set(index,KDef{key,"P112StaticIntern",size,0,{KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},{KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},[],False{},False{}},hash,32),error}},
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
    case P112SImage{size,nodes,index,error}: P112STerm{{KTerm{"NativeStaticInput", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},P112SImage{size,nodes,index,p111_first(error,"static atom present before fresh preparation")}}


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
      p112s_defs(book,constructors,rest,Con{KDef{name,"NativeStaticBody",da(prior),dx(prior),{KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},body,[prior],False{},False{}},facts},image)


@unsafe
def p112s_node_index(nodes: List<&2,P112SNode>, index: KDef) -> KDef:
  match nodes:
    case Nil{}: index
    case Con{P112SNode{+offset,name,fields},rest}:
      +key = U32.show(offset)
      p112s_node_index(rest,index_set(index,KDef{key,"P112StaticNode",offset,nt_count(P112SWord,fields),atom(name),{KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},[],False{},False{}},index_hash(key,2166136261),32))


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
        [index_first(dc(cache)),KDef{"$native.static","NativeStaticContext",0,0,kt("P112StaticImage","",size,0,[]),{KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},[index_build(facts),nc_ctor_prepare(Con{cache,rest}),constructors,p112s_node_index(nodes,missing())],False{},False{}}],db(cache),du(cache)},rest},nodes,error}
    case _: P112SPrepared{book,[],"static preparation requires a fresh cached request"}


@unsafe
def p112s_prepare(+book: List<&2,KDef>, +names: List<&2,String>, +constructors: List<&2,N_Constructor>) -> P112SPrepared:
  nt_choose(P112SPrepared,nc_pack_foreign(book),u => P112SPrepared{book,[],""},u =>
    nt_choose(P112SPrepared,String.eq(dk(index_first(book)),"BookCache"),
      u => p112s_attach(book,constructors,p112s_defs(book,p112s_block_effects(ns_ctor_index(constructors,missing()),p111_effects(book,names)),names,[],P112SImage{0,[],missing(),""})),
      u => P112SPrepared{book,[],"static preparation requires a fresh cached request"}))


@unsafe
def p112s_immutable_name(+name: String) -> Bool:
  Bool.not(nb_contains(["Zero","Succ","True","False","Chr","U32","F32","ALeaf","ANode","Emit","Halt","Done","Fail"],name))


@unsafe
def p112s_constructor_ok(+constructors: KDef, +name: String, +arity: U32) -> Bool:
  +found = p112s_find(constructors,name)
  String.eq(dk(found),"P112StaticCtor") && U32.is_lt(da(found),65536) && U32.is_eq(dx(found),arity) && p112s_immutable_name(name)


@unsafe
def p112s_word_valid(word: P112SWord, +constructors: KDef, +nodes: KDef) -> Bool:
  match word:
    case P112SRaw{value}: True{}
    case P112SPacked{+name,+payload}:
      +found = p112s_find(constructors,name)
      p112s_constructor_ok(constructors,name,dx(found)) &&
        ((U32.is_eq(dx(found),0) && U32.is_eq(payload,0)) || (U32.is_eq(dx(found),1) && String.starts_with(name,"$ctor.")))
    case P112SBox{+name,+offset}:
      +found = p112s_find(nodes,U32.show(offset))
      String.eq(dk(found),"P112StaticNode") && String.eq(tg(dt(found)),name) &&
        U32.is_gt(dx(found),0) && p112s_constructor_ok(constructors,name,dx(found))


@unsafe
def p112s_fields_valid(fields: List<&2,P112SWord>, +constructors: KDef, +nodes: KDef) -> Bool:
  match fields:
    case Nil{}: True{}
    case Con{head,rest}: p112s_word_valid(head,constructors,nodes) && p112s_fields_valid(rest,constructors,nodes)


@unsafe
def p112s_nodes_error(nodes: List<&2,P112SNode>, +constructors: KDef, +prior: KDef, +next: U32) -> String:
  match nodes:
    case Nil{}: ""
    case Con{+node,+rest}:
      p112s_node_error(node,rest,constructors,prior,next)


@unsafe
def p112s_node_error(node: P112SNode, +rest: List<&2,P112SNode>, +constructors: KDef, +prior: KDef, +next: U32) -> String:
  match node:
    case P112SNode{+offset,+name,+fields}:
      +count = nt_count(P112SWord,fields)
      nt_choose(String,Bool.not(U32.is_eq(offset,next)) || U32.is_eq(count,0) || U32.is_gt(next,65536) || U32.is_gt(count,U32.sub(65536,next)),
        u => "static image offset or word budget invalid",u =>
      nt_choose(String,p112s_constructor_ok(constructors,name,count),u =>
      nt_choose(String,p112s_fields_valid(fields,constructors,prior),u =>
        p112s_nodes_error(rest,constructors,p112s_node_index([P112SNode{offset,name,fields}],prior),U32.add(next,count)),u => "static image child is not a prior immutable word"),u => "static image constructor or arity invalid"))


@unsafe
def p112s_image_error(bundle: P112StaticProgram) -> String:
  match bundle:
    case P112StaticProgram{P111Program{segments,constructors,show,show_names,effects,pure},nodes}:
      p112s_nodes_error(nodes,p112s_block_effects(p112s_ctors(constructors,0,missing()),effects),missing(),0)


@unsafe
def p112s_verify(+bundle: P112StaticProgram) -> String:
  match bundle:
    case P112StaticProgram{+program,nodes}: p111_first(p111_verify_program(program),p112s_image_error(bundle))


@unsafe
def p112s_context_ctors(book: List<&2,KDef>) -> KDef:
  p112s_context_ctors_list(dc(ns_context(book)))


def p112s_context_ctors_list(children: List<&2,KDef>) -> KDef:
  match children:
    case Con{facts,Con{original,Con{constructors,Con{nodes,Nil{}}}}}: constructors
    case _: missing()


@unsafe
def p112s_context_nodes(book: List<&2,KDef>) -> KDef:
  p112s_context_nodes_list(dc(ns_context(book)))


def p112s_context_nodes_list(children: List<&2,KDef>) -> KDef:
  match children:
    case Con{facts,Con{original,Con{constructors,Con{nodes,Nil{}}}}}: nodes
    case _: missing()


@unsafe
def p112s_value(+book: List<&2,KDef>, +term: KTerm) -> P111ValueCode:
  +word = p112s_term_word(term)
  +constructors = p112s_context_ctors(book)
  +valid = String.eq(tg(dt(ns_context(book))),"P112StaticImage") && String.eq(tg(term),"NStatic") &&
    List.is_empty(&2,KTerm,ks(term)) && U32.is_le(qt(term),1) && p112s_word_valid(word,constructors,p112s_context_nodes(book))
  nt_choose(P111ValueCode,valid,u => P111ValueCode{[],p112s_word(word,constructors),""},
    u => P111ValueCode{[],N111Const{0,0},"static word outside its fresh validated image"})


law p112s_live_fallback:
  for +book: List<&2, KDef>
  for +t: KTerm
  for +env: List<&2, NC_Binding>
  for +n: U32
  P111Code


@unsafe
def p112s_live_fallback(book, t, env, n):
  +tag = tg(t)
  nt_choose(P111Code, String.eq(tag, "NWord") || String.eq(tag, "Var"), u => p111_value_return(p111_value(t, env), n), u =>
  nt_choose(P111Code, String.eq(tag, "Ref"), u => p111_jump(nc_ref_name(book, nm(t)), Nil{}, n), u =>
  nt_choose(P111Code, String.eq(tag, "Ann") || String.eq(tag, "Loc") || String.eq(tag, "Src") || String.eq(tag, "Cut") || String.eq(tag, "Slf") || String.eq(tag, "Ins"), u => p111_lower(book, kid(t, 0), env, n), u =>
  nt_choose(P111Code, String.eq(tag, "Lam"), u => p111_lambda(book, t, env, n), u =>
  nt_choose(P111Code, String.eq(tag, "App"), u => p111_app(book, t, env, n), u =>
  nt_choose(P111Code, String.eq(tag, "Let") || String.eq(tag, "NSeqLet"), u => p111_lets(book, ks(t), env, n), u =>
  nt_choose(P111Code, String.eq(tag, "NNatAdd"), u => p111_lower(book, nc_sequence("NNatSum", nm(t), ks(t), Nil{}, n), env, U32.inc(n)), u =>
  nt_choose(P111Code, String.eq(tag, "NNatSum"), u => p111_nat_sum_finish(p111_values(ks(t), env), n, U32.read(nm(t))), u =>
  nt_choose(P111Code, String.eq(tag, "Ctr"), u => p111_lower_ctor(book, t, env, n, nc_literal(t)), u =>
  nt_choose(P111Code, String.eq(tag, "NCtr") || String.eq(tag, "NOp"), u => p111_value_return(p111_value(t, env), n), u =>
  nt_choose(P111Code, String.eq(tag, "NApply"), u => p111_apply(p111_values(ks(t), env), n), u =>
  nt_choose(P111Code, String.eq(tag, "NCall"), u => p111_jump(nm(t), p111_values(ks(t), env), n), u =>
  nt_choose(P111Code, String.eq(tag, "Rfl") || String.eq(tag, "Typ") || String.eq(tag, "All") || String.eq(tag, "Qua") || String.eq(tag, "ADT") || String.eq(tag, "Eql"), u => p111_return(N111Const{0, 0}, n), u =>
  nt_choose(P111Code, String.eq(tag, "Mat"), u => p111_match_value(book, t, env, n), u =>
  nt_choose(P111Code, String.eq(tag, "NMatch"), u => p111_match_apply(book, t, env, n), u =>
  nt_choose(P111Code, String.eq(tag, "Efq"), u => P111Code{[N111Call{"reply", N111U64{}, "p111_rt_fail", [p111_state(), p111_u32(4)]}, N111Return{N111Local{"reply"}}], Nil{}, n, ""}, u =>
  nt_choose(P111Code, String.eq(tag, "Rwt"), u => p111_lower(book, kid(t, 2), env, n), u =>
    p111_fail("structured native lowering does not support core node " ++ tag, n))))))))))))))))))


# Phase111 module: selfhost/tools/performance/phase111/segment/lower-book.bend
# Request source remains authoritative for validation and metadata. Cached
# NativeErasedBody facts are reused without adding optional optimizer forms.


@unsafe
def p112s_let_fallback(+book: List<&2, KDef>, +value: KTerm, +body: KTerm, +env: List<&2, NC_Binding>, +id: U32, +n: U32) -> P111Code:
  +tag = tg(value)
  +prim = nd_native_call(book, value)
  nt_choose(P111Code, String.eq(tag, "Var") || String.eq(tag, "NWord") || String.eq(tag, "NCtr") || String.eq(tag, "NOp"),
    u => p111_bind_value(book, value, body, env, id, n, p111_value(value, env)), u =>
  nt_choose(P111Code, String.eq(tag, "Ctr"), u => p111_let_ctor(book, value, body, env, id, n, nc_literal(value)), u =>
  nt_choose(P111Code, String.eq(prim, ""),
    u => p111_let_cut(book, value, body, env, id, n),
    u => p111_lower(book, nd_bind_value("NOp", prim, nd_args(value, Nil{}), Nil{}, n, id, body), env, U32.add(n, terms_len(nd_args(value, Nil{})))))))


def p112s_datum(value: N111Value) -> P111QDatum:
  match value:
    case N111Const{lo,hi}: P111QLong{lo,hi}
    case _: P111QReloc{"INVALID_P112_STATIC_WORD",0}


@unsafe
def p112s_image_fields(fields: List<&2,P112SWord>, +constructors: KDef, acc: List<&2,P111QDatum>) -> List<&2,P111QDatum>:
  match fields:
    case Nil{}: acc
    case Con{head,rest}: p112s_image_fields(rest,constructors,Con{p112s_datum(p112s_word(head,constructors)),acc})


@unsafe
def p112s_image_items(nodes: List<&2,P112SNode>, +constructors: KDef, acc: List<&2,P111QDatum>) -> List<&2,P111QDatum>:
  match nodes:
    case Nil{}: nt_reverse(P111QDatum,acc,[])
    case Con{P112SNode{offset,name,fields},rest}:
      p112s_image_items(rest,constructors,p112s_image_fields(fields,constructors,acc))

# ABI11101 has 24 eight-byte descriptor slots. Only static_words (slot8,
# byte64) and static_image (slot19,byte152) differ from the selected descriptor.


@unsafe
def p112s_descriptor_items(items: List<&2,P111QDatum>, +index: U32, +size: U32, acc: List<&2,P111QDatum>) -> List<&2,P111QDatum>:
  match items:
    case Nil{}: nt_reverse(P111QDatum,acc,[])
    case Con{head,rest}:
      p112s_descriptor_items(rest,U32.inc(index),size,Con{p112s_descriptor_item(head,index,size),acc})


def p112s_descriptor_item(item: P111QDatum, index: U32, size: U32) -> P111QDatum:
  match index:
    case 8: P111QLong{size,0}
    case 19: P111QReloc{"p111_static_image",0}
    case _: item


@unsafe
def p112s_patch_data(+data: P111QData, +size: U32) -> P111QData:
  match data:
    case P111QData{+name,alignment,exported,items}:
      nt_choose(P111QData,String.eq(name,"p111_program"),
        u => P111QData{name,alignment,exported,p112s_descriptor_items(items,0,size,[])},u => data)


@unsafe
def p112s_patch_tables(tables: List<&2,P111QData>, +size: U32, acc: List<&2,P111QData>) -> List<&2,P111QData>:
  match tables:
    case Nil{}: nt_reverse(P111QData,acc,[])
    case Con{head,rest}: p112s_patch_tables(rest,size,Con{p112s_patch_data(head,size),acc})


@unsafe
def p112s_tables(+program: P111Program, +nodes: List<&2,P112SNode>, +ids: N111Ids) -> List<&2,P111QData>:
  match program:
    case P111Program{segments,constructors,show,show_names,effects,pure}:
      nt_append(P111QData,p112s_patch_tables(p111q_tables(program,ids),p112s_size(nodes,0),[]),
        [P111QData{"p111_static_image",8,False{},p112s_image_items(nodes,p112s_ctors(constructors,0,missing()),[])}])


@unsafe
def p112s_chunks_static(+program: P111Program, nodes: List<&2,P112SNode>, +ids: N111Ids) -> List<&2,String>:
  match program:
    case P111Program{segments,constructors,show,show_names,effects,pure}:
      nt_append(String,p111q_segment_chunks(segments,ids,[]),
        nt_append(String,p111q_data_chunks(p112s_tables(program,nodes,ids)),[p111q_main()]))


@unsafe
def p112s_chunks(bundle: P112StaticProgram) -> List<&2,String>:
  match bundle:
    case P112StaticProgram{+program,+nodes}:
      nt_choose(List<&2,String>,List.is_empty(&2,P112SNode,nodes),u => p111q_chunks(program),
        u => p112s_chunks_static(program,nodes,p111q_ids(program)))


@unsafe
def p112s_text(bundle: P112StaticProgram) -> String:
  nt_text_finish(nt_reverse(String,p112s_chunks(bundle),[]),"")


@unsafe
def p112s_finish(+nodes: List<&2,P112SNode>, result: P111Result) -> P112SResult:
  match result:
    case P111Result{program,error}: P112SResult{P112StaticProgram{program,nodes},error}


@unsafe
def p112s_lower_prepared(+source: List<&2,KDef>, +names: List<&2,String>, prepared: P112SPrepared) -> P112SResult:
  match prepared:
    case P112SPrepared{+book,+nodes,+error}:
      nt_choose(P112SResult,String.is_empty(error),
        u => p112s_finish(nodes,p111_finish(source,names,p111_compile_defs(book,names,nc_bangs_names(book,names),0,[]))),
        u => P112SResult{P112StaticProgram{p111_empty(),[]},error})


@unsafe
def p112s_lower_request(request: NR_Request) -> P112SResult:
  match request:
    case NR_Request{+source,+book,+names,paths,scope,+bound}:
      +error = nc_compile_error_known(source,bound)
      nt_choose(P112SResult,String.is_empty(error),
        u => p112s_lower_prepared(source,names,p112s_prepare(book,names,nc_add_ctors(nc_default_ctors(),nc_constructors(source,source)))),
        u => P112SResult{P112StaticProgram{p111_empty(),[]},error})


@unsafe
def p112s_emit_verified(+bundle: P112StaticProgram, +error: String) -> P111Emission:
  nt_choose(P111Emission,String.is_empty(error),u => P134Planned{P134Static{bundle}},
    u => P111Emission{[],"static structured IR: " ++ error})

@unsafe
def p112s_emit_lowered(result: P112SResult) -> P111Emission:
  match result:
    case P112SResult{+bundle,+error}:
      nt_choose(P111Emission,String.is_empty(error),u => p112s_emit_verified(bundle,p112s_verify(bundle)),
        u => P111Emission{[],"static native lowering: " ++ error})


@unsafe
def p112s_control_name(+name: String, good: Bool) -> String:
  nt_choose(String,good,u => "PASS " ++ name,u => "FAIL " ++ name)


def p112s_control_ctors() -> List<&2,N_Constructor>:
  [N_Constructor{"SNil",0,True{}},N_Constructor{"SCon",2,True{}},N_Constructor{"$ctor.Leaf",1,True{}},N_Constructor{"Pair",2,True{}},N_Constructor{"ALeaf",1,True{}}]


@unsafe
def p112s_control_image(nodes: List<&2,P112SNode>) -> Bool:
  String.is_empty(p112s_nodes_error(nodes,p112s_ctors(p112s_control_ctors(),0,missing()),missing(),0))


@unsafe
def p112s_control_shallow(result: P112STerm, +size: U32, +tag: String) -> Bool:
  match result:
    case P112STerm{+term,P112SImage{actual,nodes,index,error}}:
      String.is_empty(error) && U32.is_eq(size,actual) && String.eq(tg(term),tag) &&
        nt_choose(Bool,String.eq(tag,"NStatic"),u => List.is_empty(&2,KTerm,ks(term)),u => True{})


@unsafe
def p112s_control_stale(result: P112STerm) -> Bool:
  match result:
    case P112STerm{term,P112SImage{size,nodes,index,error}}: Bool.not(String.is_empty(error))


@unsafe
def p112s_control_dedup(first: P112STerm, +term: KTerm) -> Bool:
  match first:
    case P112STerm{head,image}: p112s_control_shallow(p112s_term(ns_ctor_index(p112s_control_ctors(),missing()),term,image),2,"NStatic")


@unsafe
def p112s_control_value(value: N111Value, +lo: U32, +hi: U32) -> Bool:
  match value:
    case N111Const{a,b}: U32.is_eq(a,lo) && U32.is_eq(b,hi)
    case _: False{}


@unsafe
def p112s_control_effect() -> Bool:
  +program : P111Program = P111Program{[],p112s_control_ctors(),[],[],["Pair"],False{}}
  Bool.not(String.is_empty(p112s_image_error(P112StaticProgram{program,[P112SNode{0,"Pair",[P112SRaw{0},P112SRaw{0}]}]})))


@unsafe
def p112s_control_report() -> List<&2,String>:
  +constructors = ns_ctor_index(p112s_control_ctors(),missing())
  +ids = p112s_ctors(p112s_control_ctors(),0,missing())
  +empty : P112SImage = P112SImage{0,[],missing(),""}
  +pair = kt("Ctr","Pair",0,0,[kt("NWord","7",0,0,[]),kt("NWord","11",0,0,[])])
  +valid : List<&2,P112SNode> = [P112SNode{0,"SCon",[P112SRaw{127822},P112SPacked{"SNil",0}]},P112SNode{2,"SCon",[P112SRaw{945},P112SBox{"SCon",0}]}]
  [p112s_control_name("empty-image",p112s_control_image([])),
   p112s_control_name("unicode-backward-image",p112s_control_image(valid)),
   p112s_control_name("packed-user-payload",p112s_control_image([P112SNode{0,"Pair",[P112SPacked{"$ctor.Leaf",4294967295},P112SRaw{0}]}])),
   p112s_control_name("offset-gap-refused",Bool.not(p112s_control_image([P112SNode{1,"Pair",[P112SRaw{0},P112SRaw{0}]}]))),
   p112s_control_name("forward-reference-refused",Bool.not(p112s_control_image([P112SNode{0,"SCon",[P112SRaw{0},P112SBox{"SCon",2}]},P112SNode{2,"SCon",[P112SRaw{1},P112SPacked{"SNil",0}]}]))),
   p112s_control_name("cycle-refused",Bool.not(p112s_control_image([P112SNode{0,"SCon",[P112SRaw{0},P112SBox{"SCon",0}]}]))),
   p112s_control_name("unknown-constructor-refused",Bool.not(p112s_control_image([P112SNode{0,"Missing",[P112SRaw{0}]}]))),
   p112s_control_name("wrong-arity-refused",Bool.not(p112s_control_image([P112SNode{0,"Pair",[P112SRaw{0}]}]))),
   p112s_control_name("array-image-refused",Bool.not(p112s_control_image([P112SNode{0,"ALeaf",[P112SRaw{0}]}]))),
   p112s_control_name("registered-effect-image-refused",p112s_control_effect()),
   p112s_control_name("packed-nullary-payload-refused",Bool.not(p112s_control_image([P112SNode{0,"Pair",[P112SPacked{"SNil",1},P112SRaw{0}]}]))),
   p112s_control_name("packed-multifield-refused",Bool.not(p112s_control_image([P112SNode{0,"Pair",[P112SPacked{"Pair",0},P112SRaw{0}]}]))),
   p112s_control_name("boxed-word-exact",p112s_control_value(p112s_word(P112SBox{"SCon",2},ids),51413506,33554688)),
   p112s_control_name("packed-word-exact",p112s_control_value(p112s_word(P112SPacked{"$ctor.Leaf",4294967295},ids),4294967295,16777728)),
   p112s_control_name("shallow-static-atom",p112s_control_shallow(p112s_term(constructors,pair,empty),2,"NStatic")),
   p112s_control_name("exact-intern-dedup",p112s_control_dedup(p112s_term(constructors,pair,empty),pair)),
   p112s_control_name("stale-marker-refused",p112s_control_stale(p112s_term(constructors,kt("NStatic","Pair",0,0,[]),empty))),
   p112s_control_name("budget-exact-fill",p112s_control_shallow(p112s_term(constructors,pair,P112SImage{65534,[],missing(),""}),65536,"NStatic")),
   p112s_control_name("budget-parent-fallback",p112s_control_shallow(p112s_term(constructors,pair,P112SImage{65535,[],missing(),""}),65535,"Ctr")),
   p112s_control_name("array-producer-fallback",p112s_control_shallow(p112s_term(constructors,kt("Ctr","ALeaf",0,0,[kt("NWord","7",0,0,[])]),empty),0,"Ctr"))]


@unsafe
def p112s_liveness_fallback(+book: List<&2, KDef>, +value: KTerm, +rest: P112Liveness, +env: List<&2, NC_Binding>, +id: U32, +n: U32) -> P111Code:
  +tag = tg(value)
  +prim = nd_native_call(book, value)
  nt_choose(P111Code, String.eq(tag, "Var") || String.eq(tag, "NWord") || String.eq(tag, "NCtr") || String.eq(tag, "NOp"),
    u => p112_liveness_value(book, value, rest, env, id, n, p111_value(value, env)), u =>
  nt_choose(P111Code, String.eq(tag, "Ctr"), u => p112_liveness_ctor(book, value, rest, env, id, n, nc_literal(value)), u =>
  nt_choose(P111Code, String.eq(prim, ""),
    u => p112_liveness_cut(book, value, rest, env, id, n),
    u => p112_liveness_lower(book, p112_liveness_args("NOp", prim, nd_args(value, Nil{}), Nil{}, n, id, rest), env, U32.add(n, terms_len(nd_args(value, Nil{})))))))
