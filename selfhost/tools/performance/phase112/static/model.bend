# Typed immutable words. Box offsets are measured in Term words from STAT_OFF.
type P112SWord is Data:
  P112SRaw{+value: U32}
  P112SPacked{+name: String, +payload: U32}
  P112SBox{+name: String, +offset: U32}

type P112SNode is Data:
  P112SNode{+offset: U32, +name: String, +fields: List<&2,P112SWord>}

type P112StaticProgram is Data:
  P112StaticProgram{+program: P111Program, +nodes: List<&2,P112SNode>}

type P112SResult is Data:
  P112SResult{+bundle: P112StaticProgram, +error: String}

type P112SImage is Data:
  P112SImage{+size: U32, +nodes: List<&2,P112SNode>, +index: KDef, +error: String}

type P112STerm is Data:
  P112STerm{+term: KTerm, +image: P112SImage}

type P112STerms is Data:
  P112STerms{+terms: List<&2,KTerm>, +image: P112SImage}

type P112SDefs is Data:
  P112SDefs{+facts: List<&2,KDef>, +image: P112SImage}

type P112SPrepared is Data:
  P112SPrepared{+book: List<&2,KDef>, +nodes: List<&2,P112SNode>, +error: String}

# Same ordered identities as p111_finish / p111q_constructor_ids. Store both
# numeric ID and exact live arity so lowering and validation share one lookup.
@unsafe
def p112s_ctors(constructors: List<&2,N_Constructor>, +next: U32, index: KDef) -> KDef:
  match constructors:
    case Nil{}: index
    case Con{N_Constructor{+name,arity,hot},rest}:
      p112s_ctors(rest,U32.inc(next),index_set(index,KDef{name,"P112StaticCtor",next,arity,atom("Absent"),atom("Absent"),[],False{},False{}},index_hash(name,2166136261),32))

@unsafe
def p112s_find(+index: KDef, +name: String) -> KDef:
  index_find(index,name,index_hash(name,2166136261),32)

@unsafe
def p112s_block_effects(index: KDef, names: List<&2,String>) -> KDef:
  match names:
    case Nil{}: index
    case Con{+name,rest}:
      p112s_block_effects(index_set(index,KDef{name,"P112StaticForeign",0,0,atom("Absent"),atom("Absent"),[],False{},False{}},index_hash(name,2166136261),32),rest)

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
