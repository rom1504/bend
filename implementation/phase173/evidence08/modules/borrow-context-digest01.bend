# Pair with borrow-compiler-digest-support.bend and borrow-context-workload01.bend.
# Complete loader outputs have a separate independent full-value gate.
law p173cmd_book:
  for book: List<&2,KDef>
  for hash: U32
  U32

@unsafe
def p173cmd_definition(definition: KDef, hash: U32) -> U32:
  match definition:
    case KDef{name,kind,arity,templates,typ,value,ctors,native,unsafe}:
      h1 = p173bwp_string(name,p173bwp_word(hash,201))
      h2 = p173bwp_string(kind,h1)
      h3 = p173bwp_word(p173bwp_word(h2,arity),templates)
      h4 = p173bwp_term(value,p173bwp_term(typ,h3))
      h5 = p173cmd_book(ctors,h4)
      p173bwp_bool(unsafe,p173bwp_bool(native,h5))
    case KIndexLeaf{key,bucket}:
      p173cmd_book(bucket,p173bwp_word(p173bwp_word(hash,202),key))
    case KIndexNode{key,mask,left,right}:
      h1 = p173bwp_word(p173bwp_word(p173bwp_word(hash,203),key),mask)
      p173cmd_definition(right,p173cmd_definition(left,h1))

@unsafe
def p173cmd_book(book, hash):
  match book:
    case Nil{}: p173bwp_word(hash,0)
    case Con{definition,rest}:
      p173cmd_book(rest,p173cmd_definition(definition,p173bwp_word(hash,1)))

def p173cmd_result(result: FResult, hash: U32) -> U32:
  match result:
    case FResult{book,error,imports}:
      h1 = p173cmd_book(book,p173bwp_word(hash,204))
      p173bwp_terms(imports,p173bwp_string(error,h1))

@unsafe
def p173cmd_expression(n: Nat, body: String) -> String:
  match n:
    case 0n: body
    case 1n+p: p173cmd_expression(p,"id(" ++ body ++ ")")

def p173cmd_source(+seed: U32) -> String:
  "# varied loader input " ++ U32.show(seed) ++ "\n" ++ p173cmw_prelude() ++
    "def id(+value: Flag) -> Flag:\n  value\ndef main() -> Flag:\n  " ++
    p173cmd_expression(24n,"On{}") ++ "\n"

@unsafe
def p173cmd_repeat(n: Nat, +seed: U32, hash: U32) -> U32:
  match n:
    case 0n: hash
    case 1n+p:
      result = p173cmw_load("/context/performance.bend",p173cmd_source(seed))
      p173cmd_repeat(p,U32.inc(seed),p173cmd_result(result,hash))

def main() -> U32:
  p173cmd_repeat(32n,7,2166136261)
