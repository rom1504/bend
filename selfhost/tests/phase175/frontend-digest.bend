# Full structural 32-bit observation, including caches, quantities, spans and flags.
# A digest match is NOT exact equivalence; complete small-value oracles remain required.
# Full traversal occurs after the frontend timing boundary and may be substantial.
law p175fd_terms:
  for terms: List<&2,KTerm>
  for hash: U32
  U32

def p175fd_word(hash: U32, value: U32) -> U32:
  U32.mul(U32.xor(hash,value),16777619)

@unsafe
def p175fd_string(text: String, hash: U32) -> U32:
  match text:
    case SNil{}: p175fd_word(hash,0)
    case SCon{char,rest}:
      p175fd_string(rest,p175fd_word(p175fd_word(hash,1),Char.to_u32(char)))

@unsafe
def p175fd_strings(texts: List<&2,String>, hash: U32) -> U32:
  match texts:
    case Nil{}: p175fd_word(hash,0)
    case Con{text,rest}:
      p175fd_strings(rest,p175fd_string(text,p175fd_word(hash,1)))

def p175fd_bool(value: Bool, hash: U32) -> U32:
  match value:
    case False{}: p175fd_word(hash,0)
    case True{}: p175fd_word(hash,1)

@unsafe
def p175fd_term(term: KTerm, hash: U32) -> U32:
  match term:
    case KTerm{tag,name,id,quant,kids,removed,begin,end}:
      h1 = p175fd_string(tag,p175fd_word(hash,101))
      h2 = p175fd_string(name,h1)
      h3 = p175fd_word(p175fd_word(h2,id),quant)
      h4 = p175fd_terms(kids,h3)
      h5 = p175fd_strings(removed,h4)
      p175fd_word(p175fd_word(h5,begin),end)
    case KLambda{name,id,quant,kids,removed,begin,end,present}:
      h1 = p175fd_string(name,p175fd_word(hash,102))
      h2 = p175fd_word(p175fd_word(h1,id),quant)
      h3 = p175fd_terms(kids,h2)
      h4 = p175fd_strings(removed,h3)
      p175fd_bool(present,p175fd_word(p175fd_word(h4,begin),end))
    case KLiteral{kind,number,text,begin,end}:
      h1 = p175fd_string(kind,p175fd_word(hash,103))
      h2 = p175fd_string(text,p175fd_word(h1,number))
      p175fd_word(p175fd_word(h2,begin),end)

@unsafe
def p175fd_terms(terms, hash):
  match terms:
    case Nil{}: p175fd_word(hash,0)
    case Con{term,rest}:
      p175fd_terms(rest,p175fd_term(term,p175fd_word(hash,1)))


law p175fd_defs:
  for defs: List<&2,KDef>
  for hash: U32
  U32

@unsafe
def p175fd_def(definition: KDef, hash: U32) -> U32:
  match definition:
    case KDef{name,kind,arity,templates,typ,value,ctors,native,unsafe}:
      h1 = p175fd_string(name,p175fd_word(hash,201))
      h2 = p175fd_string(kind,p175fd_word(p175fd_word(h1,arity),templates))
      h3 = p175fd_term(value,p175fd_term(typ,h2))
      p175fd_bool(unsafe,p175fd_bool(native,p175fd_defs(ctors,h3)))
    case KIndexLeaf{key,bucket}:
      p175fd_defs(bucket,p175fd_word(p175fd_word(hash,202),key))
    case KIndexNode{key,mask,left,right}:
      h1 = p175fd_word(p175fd_word(p175fd_word(hash,203),key),mask)
      p175fd_def(right,p175fd_def(left,h1))

@unsafe
def p175fd_defs(defs, hash):
  match defs:
    case Nil{}: p175fd_word(hash,0)
    case Con{definition,rest}:
      p175fd_defs(rest,p175fd_def(definition,p175fd_word(hash,1)))

def p175fd_bound(bound: Maybe<&2,U32>, hash: U32) -> U32:
  match bound:
    case None{}: p175fd_word(hash,0)
    case Some{value}: p175fd_word(p175fd_word(hash,1),value)

@unsafe
def p175fd_request(request: NR_Request, hash: U32) -> U32:
  match request:
    case NR_Request{source,book,names,paths,scope,bound}:
      h1 = p175fd_defs(book,p175fd_defs(source,p175fd_word(hash,301)))
      h2 = p175fd_strings(paths,p175fd_strings(names,h1))
      p175fd_bound(bound,p175fd_defs(scope,h2))

@unsafe
def p175fd_value(value: P175Frontend) -> U32:
  match value:
    case P175FError{error}: p175fd_string(error,p175fd_word(2166136261,401))
    case P175FBook{stage,book,verdict}:
      p175fd_string(verdict,p175fd_defs(book,p175fd_string(stage,p175fd_word(2166136261,402))))
    case P175FRequest{request,verdict}:
      p175fd_string(verdict,p175fd_request(request,p175fd_word(2166136261,403)))
