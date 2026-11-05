# Complete-result runtime consumer for direct-workloads.bend. Every constructor,
# scalar, Unicode character and nested list field is visited, including empty
# list/string terminators. The explicit work list makes traversal tail-recursive.
# These checksums supplement, not replace, the existing complete-value oracles.

type P163RWork is Data:
  P163RWord{+word: U32}
  P163RText{+text: String}
  P163RTexts{+texts: List<&2,String>}
  P163RTerm{+term: KTerm}
  P163RTerms{+terms: List<&2,KTerm>}
  P163RDef{+definition: KDef}
  P163RDefs{+definitions: List<&2,KDef>}

def p163r_mix(h: U32, word: U32) -> U32:
  U32.mul(U32.xor(h,word),16777619)

def p163r_mix2(h: U32, word: U32) -> U32:
  U32.add(U32.mul(h,33),word)

@unsafe
def p163r_scan(todo: List<&2,P163RWork>, +h: U32, +g: U32, +count: U32) -> List<&2,U32>:
  match todo:
    case Nil{}: [count,h,g]
    case Con{P163RWord{+word},rest}:
      p163r_scan(rest,p163r_mix(h,word),p163r_mix2(g,word),count)
    case Con{P163RText{SNil{}},rest}:
      p163r_scan(rest,p163r_mix(h,41),p163r_mix2(g,41),count)
    case Con{P163RText{SCon{char,text}},rest}:
      p163r_scan(Con{P163RWord{Char.to_u32(char)},Con{P163RText{text},rest}},
        p163r_mix(h,42),p163r_mix2(g,42),count)
    case Con{P163RTexts{Nil{}},rest}:
      p163r_scan(rest,p163r_mix(h,51),p163r_mix2(g,51),count)
    case Con{P163RTexts{Con{text,texts}},rest}:
      p163r_scan(Con{P163RText{text},Con{P163RTexts{texts},rest}},
        p163r_mix(h,52),p163r_mix2(g,52),count)
    case Con{P163RTerms{Nil{}},rest}:
      p163r_scan(rest,p163r_mix(h,61),p163r_mix2(g,61),count)
    case Con{P163RTerms{Con{term,terms}},rest}:
      p163r_scan(Con{P163RTerm{term},Con{P163RTerms{terms},rest}},
        p163r_mix(h,62),p163r_mix2(g,62),count)
    case Con{P163RDefs{Nil{}},rest}:
      p163r_scan(rest,p163r_mix(h,11),p163r_mix2(g,11),count)
    case Con{P163RDefs{Con{definition,definitions}},rest}:
      p163r_scan(Con{P163RDef{definition},Con{P163RDefs{definitions},rest}},
        p163r_mix(h,12),p163r_mix2(g,12),count)
    case Con{P163RDef{KDef{name,kind,arity,templates,typ,value,ctors,native,unsafe}},rest}:
      p163r_scan(Con{P163RText{name},Con{P163RText{kind},
        Con{P163RWord{arity},Con{P163RWord{templates},
        Con{P163RTerm{typ},Con{P163RTerm{value},Con{P163RDefs{ctors},
        Con{P163RWord{Bool.to_u32(native)},Con{P163RWord{Bool.to_u32(unsafe)},rest}}}}}}}}},
        p163r_mix(h,21),p163r_mix2(g,21),U32.inc(count))
    case Con{P163RDef{KIndexLeaf{hash,bucket}},rest}:
      p163r_scan(Con{P163RWord{hash},Con{P163RDefs{bucket},rest}},
        p163r_mix(h,22),p163r_mix2(g,22),U32.inc(count))
    case Con{P163RDef{KIndexNode{hash,mask,left,right}},rest}:
      p163r_scan(Con{P163RWord{hash},Con{P163RWord{mask},
        Con{P163RDef{left},Con{P163RDef{right},rest}}}},
        p163r_mix(h,23),p163r_mix2(g,23),U32.inc(count))
    case Con{P163RTerm{KTerm{tag,name,id,quant,kids,removed,begin,end}},rest}:
      p163r_scan(Con{P163RText{tag},Con{P163RText{name},
        Con{P163RWord{id},Con{P163RWord{quant},Con{P163RTerms{kids},
        Con{P163RTexts{removed},Con{P163RWord{begin},Con{P163RWord{end},rest}}}}}}}},
        p163r_mix(h,31),p163r_mix2(g,31),count)
    case Con{P163RTerm{KLambda{name,id,quant,kids,removed,begin,end,present}},rest}:
      p163r_scan(Con{P163RText{name},Con{P163RWord{id},Con{P163RWord{quant},
        Con{P163RTerms{kids},Con{P163RTexts{removed},Con{P163RWord{begin},
        Con{P163RWord{end},Con{P163RWord{Bool.to_u32(present)},rest}}}}}}}},
        p163r_mix(h,32),p163r_mix2(g,32),count)
    case Con{P163RTerm{KLiteral{kind,number,text,begin,end}},rest}:
      p163r_scan(Con{P163RText{kind},Con{P163RWord{number},Con{P163RText{text},
        Con{P163RWord{begin},Con{P163RWord{end},rest}}}}},
        p163r_mix(h,33),p163r_mix2(g,33),count)

@unsafe
def p163r_digest(definitions: List<&2,KDef>) -> List<&2,U32>:
  p163r_scan([P163RDefs{definitions}],2166136261,5381,0)

@unsafe
def p163r_reverse(n: U32) -> List<&2,U32>:
  p163r_digest(p163w_reverse(n))

@unsafe
def p163r_lookup(n: U32) -> List<&2,U32>:
  p163r_digest(p163w_lookup(n))

# Independent expected builders never call book_final_reverse or lookup. They
# construct all expected rows and use the identical complete-result consumer.
@unsafe
def p163r_reverse_expected(n: U32) -> List<&2,U32>:
  p163r_digest(p163w_reverse_expected(n))

@unsafe
def p163r_lookup_expected(n: U32) -> List<&2,U32>:
  p163r_digest(p163w_lookup_expected(n))
