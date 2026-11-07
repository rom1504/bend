# Performance driver paired with the separate complete-value AST oracle.
# All compiler computations below remain the unchanged canonical functions.
# The digest is a bounded-output observation, not a replacement correctness gate.
law p173bwp_terms:
  for terms: List<&2,KTerm>
  for hash: U32
  U32

def p173bwp_word(hash: U32, value: U32) -> U32:
  U32.mul(U32.xor(hash,value),16777619)

@unsafe
def p173bwp_string(text: String, hash: U32) -> U32:
  match text:
    case SNil{}: p173bwp_word(hash,0)
    case SCon{char,rest}:
      p173bwp_string(rest,p173bwp_word(p173bwp_word(hash,1),Char.to_u32(char)))

@unsafe
def p173bwp_strings(texts: List<&2,String>, hash: U32) -> U32:
  match texts:
    case Nil{}: p173bwp_word(hash,0)
    case Con{text,rest}:
      p173bwp_strings(rest,p173bwp_string(text,p173bwp_word(hash,1)))

def p173bwp_bool(value: Bool, hash: U32) -> U32:
  match value:
    case False{}: p173bwp_word(hash,0)
    case True{}: p173bwp_word(hash,1)

@unsafe
def p173bwp_term(term: KTerm, hash: U32) -> U32:
  match term:
    case KTerm{tag,name,id,quant,kids,removed,begin,end}:
      h1 = p173bwp_string(tag,p173bwp_word(hash,101))
      h2 = p173bwp_string(name,h1)
      h3 = p173bwp_word(p173bwp_word(h2,id),quant)
      h4 = p173bwp_terms(kids,h3)
      h5 = p173bwp_strings(removed,h4)
      p173bwp_word(p173bwp_word(h5,begin),end)
    case KLambda{name,id,quant,kids,removed,begin,end,present}:
      h1 = p173bwp_string(name,p173bwp_word(hash,102))
      h2 = p173bwp_word(p173bwp_word(h1,id),quant)
      h3 = p173bwp_terms(kids,h2)
      h4 = p173bwp_strings(removed,h3)
      p173bwp_bool(present,p173bwp_word(p173bwp_word(h4,begin),end))
    case KLiteral{kind,number,text,begin,end}:
      h1 = p173bwp_string(kind,p173bwp_word(hash,103))
      h2 = p173bwp_string(text,p173bwp_word(h1,number))
      p173bwp_word(p173bwp_word(h2,begin),end)

@unsafe
def p173bwp_terms(terms, hash):
  match terms:
    case Nil{}: p173bwp_word(hash,0)
    case Con{term,rest}:
      p173bwp_terms(rest,p173bwp_term(term,p173bwp_word(hash,1)))

@unsafe
def p173bwp_heap(heap: GHeap, hash: U32) -> U32:
  match heap:
    case GEmpty{}: p173bwp_word(hash,0)
    case GNode{value,left,right}:
      h1 = p173bwp_term(value,p173bwp_word(hash,1))
      h2 = p173bwp_heap(left,h1)
      p173bwp_heap(right,h2)

def p173bwp_state(state: GState, hash: U32) -> U32:
  match state:
    case GState{heap,next}: p173bwp_word(p173bwp_heap(heap,p173bwp_word(hash,104)),next)

def p173bwp_shared(result: GResult, hash: U32) -> U32:
  match result:
    case GResult{state,term}: p173bwp_term(term,p173bwp_state(state,p173bwp_word(hash,105)))

@unsafe
def p173bwp_results(results: List<&2,GResult>, hash: U32) -> U32:
  match results:
    case Nil{}: p173bwp_word(hash,0)
    case Con{result,rest}:
      p173bwp_results(rest,p173bwp_shared(result,p173bwp_word(hash,1)))

def p173bwp_report(report: P173BWReport, hash: U32) -> U32:
  match report:
    case P173BWReport{located,shared,replaced}:
      h1 = p173bwp_terms(located,p173bwp_word(hash,106))
      h2 = p173bwp_results(shared,h1)
      p173bwp_term(replaced,h2)

# The same 8,223-node shape as the full-value control, with changing source IDs,
# text and requested origins. The retained alias is folded separately, so both
# versions of its fields are observed. Original p173bwa_result stays unchanged.
def p173bwp_result(+seed: U32) -> P173BWReport:
  +alias = p173bwa_tree(4n,U32.add(seed,31))
  P173BWReport{[alias],
    [g_share_head(GState{GEmpty{},1},
      f_span_created(KTerm{"Ctr","root",seed,2,
        [alias,p173bwa_tree(12n,U32.inc(seed))],["retain-root-note"],0,0},
        U32.add(seed,11),U32.add(seed,49)))],
    KLiteral{"U32",8223,"nodes-before-sharing",0,0}}

@unsafe
def p173bwp_repeat(n: Nat, +seed: U32, hash: U32) -> U32:
  match n:
    case 0n: hash
    case 1n+p:
      p173bwp_repeat(p,U32.add(seed,7919),p173bwp_report(p173bwp_result(seed),hash))

def main() -> U32:
  p173bwp_repeat(8n,1,2166136261)
