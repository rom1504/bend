# This validates the closed immutable image. The unchanged Phase111 verifier
# separately validates every original segment before selected rendering.
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
      nt_choose(String,Bool.not(p112s_constructor_ok(constructors,name,count)),u => "static image constructor or arity invalid",u =>
      nt_choose(String,Bool.not(p112s_fields_valid(fields,constructors,prior)),u => "static image child is not a prior immutable word",u =>
        p112s_nodes_error(rest,constructors,p112s_node_index([P112SNode{offset,name,fields}],prior),U32.add(next,count)))))

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
