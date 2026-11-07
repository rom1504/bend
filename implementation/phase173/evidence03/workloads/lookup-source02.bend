import Base


# Phase88 native-host-only consuming string helpers.
# Consuming compiler-host helpers. No reconstructed input pair or host closure.
# Deliberately safe: checked ownership must suffice without @unsafe.
def p88_string_eq_go(a: String, b: String, same: Bool) -> Bool:
  match a b same:
    case SNil{} SNil{} result: result
    case SNil{} SCon{h, t} result: False{}
    case SCon{h, t} SNil{} result: False{}
    case SCon{h1, t1} SCon{h2, t2} False{}: False{}
    case SCon{h1, t1} SCon{h2, t2} True{}:
      p88_string_eq_go(t1, t2, Char.is_eq(h1, h2))


def p98_eq_finish(same: Bool, left: String, right: String) -> Bool:
  same


def p88_string_eq(+a: String, +b: String) -> Bool:
  p98_eq_finish(p88_string_eq_go(a, b, True{}), a, b)


# Generated source assembly. Edit the individual src modules.

# Module: src/core/term.bend:25
type KTerm is Data:
  KTerm{+tag: String, +name: String, +id: U32, +quant: U32, +kids: List<&2, KTerm>, +removed: List<&2, String>, +originBegin: U32, +originEnd: U32}
  KLambda{+name: String, +id: U32, +quant: U32, +kids: List<&2,KTerm>, +removed: List<&2,String>, +originBegin: U32, +originEnd: U32, +quantityPresent: Bool}
  KLiteral{+kind: String, +number: U32, +text: String, +originBegin: U32, +originEnd: U32}


# Module: src/core/term.bend:30
type KDef is Data:
  KDef{+name: String, +kind: String, +arity: U32, +templates: U32, +typ: KTerm, +value: KTerm, +ctors: List<&2, KDef>, +native: Bool, +unsafe: Bool}
  KIndexLeaf{+hash: U32, +bucket: List<&2,KDef>}
  KIndexNode{+hash: U32, +mask: U32, +left: KDef, +right: KDef}


# Module: src/core/index.bend:4
law index_child_list:
  for +ds: List<&2, KDef>
  for +right: Bool
  KDef


# Module: src/core/index.bend:9
law index_first:
  for +ds: List<&2, KDef>
  KDef


# Module: src/core/index.bend:13
law index_bucket:
  for +ds: List<&2, KDef>
  for +name: String
  KDef


# Compressed persistent binary trie. Internal nodes carry one discriminating
# hash bit; leaves retain exact-name buckets for complete 32-bit collisions.

# Module: src/core/index.bend:20
law index_lookup:
  for +cache: KDef
  for +name: String
  KDef


# Module: src/core/term.bend:4
@unsafe
def kc(
  -A: Type,
  +b: Bool,
  yes: Unit -> A,
  no: Unit -> A,
) -> A:
  match b:
    case True{}:
      yes(Unit{})
    case False{}:
      no(Unit{})


# First-order trusted core. Binder identifiers are globally unique.
# Quantities: 0 erased, 1 affine, 2 unrestricted. No function-valued fields.

# Module: src/core/term.bend:36
@unsafe
def kt(
  +tag: String,
  +name: String,
  +id: U32,
  +quant: U32,
  +kids: List<&2, KTerm>,
) -> KTerm:
  KTerm{tag, name, id, quant, kids, Nil{}, 0, 0}


# Module: src/core/term.bend:155
@unsafe
def qua(
  +q: U32,
) -> KTerm:
  kt("Qua", "", 0, q, Nil{})


# Module: src/core/term.bend:161
@unsafe
def typ(
  +q: U32,
) -> KTerm:
  kt("Typ", "", 0, 0, Con{qua(q), Nil{}})


# Module: src/core/term.bend:184
@unsafe
def dn(
  +d: KDef,
) -> String:
  match d:
    case KDef{name, kind, arity, templates, typ, value, ctors, native, unsafe}:
      name
    case KIndexLeaf{hash, bucket}: ""
    case KIndexNode{hash, mask, left, right}: ""


# Module: src/core/term.bend:244
@unsafe
def dc(
  +d: KDef,
) -> List<&2, KDef>:
  match d:
    case KDef{name, kind, arity, templates, typ, value, ctors, native, unsafe}:
      ctors
    case KIndexLeaf{hash, bucket}: bucket
    case KIndexNode{hash, mask, left, right}: Con{left, Con{right, Nil{}}}


# Module: src/core/term.bend:274
@unsafe
def missing() -> KDef:
  KDef{"", "Absent", 0, 0,
    KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0},
    KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0},
    Nil{}, False{}, False{}}


@unsafe
def lookup(+book: List<&2,KDef>, +name: String) -> KDef:
  match book:
    case Nil{}: missing()
    case Con{+d,+rest}:
      kc(KDef, p137q_is_cache(d),
        u => index_lookup(d, name),
        u => kc(KDef, p137q_name_eq(name, d),
          v => d, v => lookup(rest, name)))


# Module: src/core/index.bend:26
@unsafe
def index_hash(
  +name: String,
  +acc: U32,
) -> U32:
  match name:
    case SNil{}:
      acc
    case SCon{h, rest}:
      index_hash(rest, U32.mul(U32.xor(acc, Char.to_u32(h)), 16777619))


# Module: src/core/index.bend:51
@unsafe
def index_child_list(ds, right):
  match ds:
    case Nil{}:
      missing()
    case Con{h, rest}:
      match right:
        case True{}: index_first(rest)
        case False{}: h


# Module: src/core/index.bend:61
@unsafe
def index_first(ds):
  match ds:
    case Nil{}:
      missing()
    case Con{h, rest}:
      h


# The public callers supply complete 32-bit hashes. `bits` remains in this
# internal ABI for the native identifier validator; paths use stored masks.

# Module: src/core/index.bend:71
@unsafe
def index_find(+tree: KDef, +name: String, +hash: U32, +bits: U32) -> KDef:
  match tree:
    case KDef{label, kind, arity, +templates, typ, value, +ctors, native, unsafe}:
      kc(KDef, p88_string_eq(kind, "Absent"), u => missing(),
        u => kc(KDef, U32.is_eq(templates, 0),
          v => kc(KDef, U32.is_eq(arity, hash),
            w => index_bucket(ctors, name), w => missing()),
          v => index_find(index_child_list(ctors,
            Bool.not(U32.is_eq(U32.and(hash, templates), 0))), name, hash, bits)))
    case KIndexLeaf{stored, bucket}:
      kc(KDef, U32.is_eq(stored, hash),
        u => index_bucket(bucket, name), u => missing())
    case KIndexNode{stored, +mask, +left, +right}:
      kc(KDef, U32.is_eq(mask, 0),
        u => kc(KDef, U32.is_eq(stored, hash),
          v => index_bucket([left, right], name), v => missing()),
        u => kc(KDef, U32.is_eq(U32.and(hash, mask), 0),
          v => index_find(left, name, hash, bits),
          v => index_find(right, name, hash, bits)))


# Module: src/core/index.bend:126
@unsafe
def index_bucket(ds, name):
  match ds:
    case Nil{}:
      missing()
    case Con{h, rest}:
      kc(KDef, p88_string_eq(dn(h), name), u => h, u => index_bucket(rest, name))


# Module: src/core/index.bend:259
@unsafe
def index_lookup(cache, name):
  index_find(index_first(dc(cache)), name, index_hash(name, 2166136261), 32)


@unsafe
def p137q_name_eq(key: String, record: KDef) -> Bool:
  match record:
    case KDef{name,kind,arity,templates,typ,value,ctors,native,unsafe}: p88_string_eq(name,key)
    case KIndexLeaf{hash,bucket}: p88_string_eq("",key)
    case KIndexNode{hash,mask,left,right}: p88_string_eq("",key)



@unsafe
def p137q_is_cache(record: KDef) -> Bool:
  match record:
    case KDef{name,kind,arity,templates,typ,value,ctors,native,unsafe}: p88_string_eq(kind,"BookCache")
    case KIndexLeaf{hash,bucket}: False{}
    case KIndexNode{hash,mask,left,right}: False{}


# Phase163 additive real-helper workloads. Assemble with the maintained source.
# Export p163w_reverse or p163w_lookup; main may supply a runtime repeat count.
# Each returns all KDef results, not a checksum. Independent expected functions
# construct the literal expected order/results without calling reverse/lookup.
# These qualify the direct-first representation boundary, not workload coverage.

@unsafe
def p163w_row(+name: String, +id: U32) -> KDef:
  KDef{name,"Def",id,3,
    KTerm{"Var","T",id,1,[],[],11,19},
    KTerm{"U32","",id,0,[],[],23,29},[],False{},True{}}



@unsafe
def p163w_absent() -> KDef:
  KDef{"","Absent",0,0,
    KTerm{"Absent","",0,0,[],[],0,0},
    KTerm{"Absent","",0,0,[],[],0,0},[],False{},False{}}



@unsafe
def p163w_rows(+i: U32) -> List<&2,KDef>:
  [p163w_row("alpha",U32.add(i,1)),
   p163w_row("alpha",U32.add(i,2)),
   p163w_row("λ.树",U32.add(i,3)),
   p163w_row("",U32.add(i,4))]



# costarring and liquid have the same FNV32 hash under the maintained index_hash.
# Computing the bucket hash here leaves no undocumented magic hash constant.
# No index_set/book_cached builder is included in this initial closed cluster.
@unsafe
def p163w_collision(+i: U32) -> List<&2,KDef>:
  [p163w_row("costarring",U32.add(i,5)),p163w_row("liquid",U32.add(i,6))]



@unsafe
def p163w_cache(tree: KDef) -> List<&2,KDef>:
  [KDef{"$kernel.cache","BookCache",0,0,
    KTerm{"Absent","",0,0,[],[],0,0},
    KTerm{"Absent","",0,0,[],[],0,0},[tree],True{},False{}}]



@unsafe
def p163w_leaf(+i: U32) -> List<&2,KDef>:
  p163w_cache(KIndexLeaf{index_hash("costarring",2166136261),p163w_collision(i)})



# Both retained legacy tree and current collision-leaf representations must work.
@unsafe
def p163w_legacy(+i: U32) -> List<&2,KDef>:
  p163w_cache(KDef{"","Index",index_hash("costarring",2166136261),0,
    KTerm{"Absent","",0,0,[],[],0,0},
    KTerm{"Absent","",0,0,[],[],0,0},p163w_collision(i),False{},False{}})



@unsafe
def p163w_lookup_round(+i: U32, acc: List<&2,KDef>) -> List<&2,KDef>:
  +plain = p163w_rows(i)
  +leaf = p163w_leaf(i)
  +legacy = p163w_legacy(i)
  Con{lookup(plain,"alpha"),
  Con{lookup(plain,"λ.树"),
  Con{lookup(plain,""),
  Con{lookup(plain,"missing"),
  Con{lookup(leaf,"costarring"),
  Con{lookup(leaf,"liquid"),
  Con{lookup(leaf,"missing"),
  Con{lookup(legacy,"costarring"),
  Con{lookup(legacy,"liquid"),
  Con{lookup(legacy,"missing"),acc}}}}}}}}}}



@unsafe
def p163w_lookup_expected_round(+i: U32, acc: List<&2,KDef>) -> List<&2,KDef>:
  Con{p163w_row("alpha",U32.add(i,1)),
  Con{p163w_row("λ.树",U32.add(i,3)),
  Con{p163w_row("",U32.add(i,4)),
  Con{p163w_absent(),
  Con{p163w_row("costarring",U32.add(i,5)),
  Con{p163w_row("liquid",U32.add(i,6)),
  Con{p163w_absent(),
  Con{p163w_row("costarring",U32.add(i,5)),
  Con{p163w_row("liquid",U32.add(i,6)),
  Con{p163w_absent(),acc}}}}}}}}}}


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


# Actual compiler lookup computation. Dependencies are the unchanged Phase163
# direct-workloads.bend and direct-runtime.bend plus maintained compiler helpers.
# Full values are exported for hosted controls; native runs digest every field
# and release each round before continuing. No generated answer is precomputed.

@unsafe
def p166l_names(+i: U32) -> List<&2,KDef>:
  [p163w_row("p111q_value",U32.add(i,17)),
   p163w_row("p111q_values",U32.add(i,18)),
   p163w_row("p113d_candidate",U32.add(i,19)),
   p163w_row("解析.λ名字",U32.add(i,20))]



@unsafe
def p166l_values(+i: U32) -> List<&2,KDef>:
  +book = p166l_names(i)
  p163w_lookup_round(i,
    [lookup(book,"p111q_value"),
     lookup(book,"p111q_valuf"),
     lookup(book,"q111q_value"),
     lookup(book,"p111q_values"),
     lookup(book,"p111q_valu"),
     lookup(book,"解析.λ名字"),
     lookup(book,"解析.λ名子"),
     lookup(book,"p113d_candidate")])



@unsafe
def p166l_expected_values(+i: U32) -> List<&2,KDef>:
  p163w_lookup_expected_round(i,
    [p163w_row("p111q_value",U32.add(i,17)),
     p163w_absent(),p163w_absent(),
     p163w_row("p111q_values",U32.add(i,18)),
     p163w_absent(),
     p163w_row("解析.λ名字",U32.add(i,20)),
     p163w_absent(),
     p163w_row("p113d_candidate",U32.add(i,19))])



@unsafe
def p166l_continue(left: U32, i: U32, h: U32, words: List<&2,U32>) -> U32:
  match words:
    case Con{count,Con{first,Con{second,Nil{}}}}:
      p166l_go(left,i,p163r_mix(p163r_mix(p163r_mix(h,count),first),second))
    case _: 0



@unsafe
def p166l_go(left: U32, +i: U32, +h: U32) -> U32:
  match left:
    case 0: h
    case n:
      p166l_continue(U32.sub(n,1),U32.inc(i),h,p163r_digest(p166l_values(i)))



@unsafe
def p166l_run(n: U32) -> U32:
  p166l_go(n,0,2166136261)


def main() -> U32:
  p166l_run(10000)
