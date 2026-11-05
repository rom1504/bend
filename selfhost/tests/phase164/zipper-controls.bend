# Additive data controls. Exported KDef values support host-side full structural
# comparison, including retained old roots; the Bool rows are only a fast gate.
# Reference is the CURRENT single-path insertion, not the older two-pass helper.
type P164XCase is Data:
  P164XCase{+tree: KDef, +record: KDef, +hash: U32}

@unsafe
def p164xc_original(+tree: KDef, +d: KDef, +hash: U32) -> KDef:
  match tree:
    case KDef{name,kind,arity,templates,typ,value,ctors,native,unsafe}:
      p131i_original_set(tree,d,hash,32)
    case KIndexLeaf{stored,bucket}:
      +mask = index_split_bit(U32.xor(hash,stored))
      kc(KDef,U32.is_eq(mask,0),u => index_leaf(d,hash,bucket),u => index_join(tree,d,hash,mask))
    case KIndexNode{stored,split,left,right}:
      +diff = U32.xor(hash,stored)
      kc(KDef,U32.is_eq(split,0),u => p131i_original_set(tree,d,hash,32),
        u => kc(KDef,U32.is_eq(U32.and(diff,U32.sub(split,1)),0),
          v => kc(KDef,U32.is_eq(U32.and(hash,split),0),
            w => index_node(stored,split,p164xc_original(left,d,hash),right),
            w => index_node(stored,split,left,p164xc_original(right,d,hash))),
          v => index_join(tree,d,hash,index_split_bit(diff))))

@unsafe
def p164xc_apply(+tree: KDef, +record: KDef, +hash: U32, new: Bool) -> KDef:
  nt_choose(KDef,new,u => p164x_insert(tree,record,hash),u => p164xc_original(tree,record,hash))

@unsafe
def p164xc_record(+name: String, +version: U32) -> KDef:
  KDef{name,"P164Rich",version,U32.inc(version),
    KLambda{"x",version,2,[KTerm{"Var","x",version,1,[],["drop"],7,13}],[],5,17,True{}},
    KLiteral{"String",version,"payload:,;[]",19,31},
    [KDef{"child","Ctr",3,4,KTerm{"Typ","",2,0,[],[],33,35},atom("Absent"),[],True{},False{}}],
    U32.is_eq(U32.mod(version,2),0),U32.is_eq(U32.mod(version,3),0)}

@unsafe
def p164xc_hash(+key: U32, mode: U32) -> U32:
  match mode:
    case 0: index_hash("identity." ++ U32.show(key),2166136261)
    case 1: 0
    case 2: 4294967295
    case 3: U32.mul(key,2147483648)
    case 4: U32.mul(key,65536)
    case 5: key
    case _: U32.add(U32.mul(key,2654435761),2246822519)

@unsafe
def p164xc_sequence(+tree: KDef, +seed: U32, +count: U32, +mode: U32, +new: Bool) -> KDef:
  nt_choose(KDef,U32.is_eq(count,0),u => tree,u =>
    p164xc_sequence_step(tree,seed,count,mode,new,U32.mod(seed,31)))

@unsafe
def p164xc_sequence_step(tree: KDef, +seed: U32, +count: U32, +mode: U32, +new: Bool, +key: U32) -> KDef:
  p164xc_sequence(p164xc_apply(tree,p164xc_record("identity." ++ U32.show(key),count),p164xc_hash(key,mode),new),
    U32.add(U32.mul(seed,1664525),1013904223),U32.sub(count,1),mode,new)

@unsafe
def p164xc_legacy(tree: KDef) -> KDef:
  match tree:
    case KDef{name,kind,arity,templates,typ,value,ctors,native,unsafe}: tree
    case KIndexLeaf{hash,bucket}:
      KDef{"","IndexLeaf",hash,0,atom("Absent"),atom("Absent"),bucket,False{},False{}}
    case KIndexNode{hash,mask,left,right}:
      KDef{"","IndexNode",hash,mask,atom("Absent"),atom("Absent"),
        [p164xc_legacy(left),p164xc_legacy(right)],False{},False{}}

# Full-tree export: same 4 seeds, 6 lengths and 7 hash modes as Phase131 can
# be supplied externally. Legacy prefixes are made only by the fixed reference.
@unsafe
def p164xc_case(+seed: U32, +count: U32, +mode: U32, legacy: Bool, +new: Bool) -> KDef:
  nt_choose(KDef,legacy,
    u => p164xc_sequence(p164xc_legacy(p164xc_sequence(missing(),seed,17,mode,False{})),
      U32.add(seed,91),count,mode,new),
    u => p164xc_sequence(missing(),seed,count,mode,new))

# Finite noncanonical chain, intentionally beyond canonical U32 trie depth.
@unsafe
def p164xc_chain(+left: U32, +tree: KDef, +sibling: KDef) -> KDef:
  nt_choose(KDef,U32.is_eq(left,0),u => tree,
    u => p164xc_chain(U32.sub(left,1),KIndexNode{0,1,tree,sibling},sibling))

@unsafe
def p164xc_fixture(n: U32) -> P164XCase:
  +a = p164xc_record("a",1)
  +b = p164xc_record("b",2)
  +fresh = p164xc_record("a",99)
  +leaf : KDef = KIndexLeaf{0,[a,b,a]}
  +legacy : KDef = KDef{"legacy","IndexLeaf",0,0,atom("Absent"),atom("Absent"),[a,b,a],True{},True{}}
  p164xc_fixture_select(n,a,b,fresh,leaf,legacy)

@unsafe
def p164xc_fixture_select(n: U32, +a: KDef, +b: KDef, +fresh: KDef, +leaf: KDef, +legacy: KDef) -> P164XCase:
  match n:
    case 0: P164XCase{missing(),fresh,0}
    case 1: P164XCase{leaf,fresh,0}
    case 2: P164XCase{leaf,fresh,2147483648}
    case 3: P164XCase{KIndexLeaf{4294967295,[b]},fresh,0}
    case 4: P164XCase{legacy,fresh,0}
    case 5: P164XCase{KIndexNode{0,0,a,b},fresh,0}
    case 6: P164XCase{KIndexNode{0,1,KIndexNode{0,2,legacy,leaf},leaf},fresh,0}
    case 7: P164XCase{KIndexNode{0,1,KIndexNode{0,2,KIndexNode{0,0,a,b},leaf},leaf},fresh,0}
    case 8: P164XCase{KIndexNode{0,4,KIndexLeaf{1,[a]},KIndexLeaf{4,[b]}},fresh,1}
    case 9: P164XCase{KIndexNode{0,3,leaf,KIndexNode{7,1,leaf,legacy}},fresh,0}
    case 10: P164XCase{p164xc_chain(65,leaf,leaf),fresh,0}
    case 11: P164XCase{KIndexNode{0,1,leaf,leaf},fresh,0}
    case 12: P164XCase{KDef{"absent","Absent",7,9,atom("Odd"),atom("Value"),[a,b],True{},True{}},fresh,0}
    case 13: P164XCase{KDef{"odd","Odd",0,3,atom("Type"),atom("Value"),[leaf,legacy,b],True{},True{}},fresh,0}
    case 14: P164XCase{KIndexLeaf{7,[p164xc_record("",1),b,p164xc_record("",2)]},p164xc_record("",99),7}
    case _: P164XCase{KIndexNode{0,1,leaf,KIndexNode{1,2,leaf,legacy}},fresh,3}

# Observing both retained old and updated roots exercises aliased ownership;
# no pointer-identity assertion or destructive update is assumed.
@unsafe
def p164xc_observe(fixture: P164XCase, new: Bool) -> List<&2,KDef>:
  match fixture:
    case P164XCase{+tree,record,hash}: [tree,p164xc_apply(tree,record,hash,new)]

@unsafe
def p164xc_edge(n: U32, new: Bool) -> List<&2,KDef>:
  p164xc_observe(p164xc_fixture(n),new)

@unsafe
def p164xc_row(+name: String, ok: Bool) -> String:
  nt_choose(String,ok,u => name ++ ":pass",u => name ++ ":FAIL")

@unsafe
def p164xc_rows(+n: U32, +left: U32) -> List<&2,String>:
  nt_choose(List<&2,String>,U32.is_eq(left,0),u => [],u =>
    Con{p164xc_row("zipper-edge-" ++ U32.show(n),p140eq_list(p164xc_edge(n,False{}),p164xc_edge(n,True{}))),
      p164xc_rows(U32.inc(n),U32.sub(left,1))})

@unsafe
def p164xc_controls() -> List<&2,String>:
  Con{p164xc_row("duplicate-replacement-explicit",p140eq_def(
    p164x_insert(KIndexLeaf{0,[p164xc_record("a",1),p164xc_record("b",2),p164xc_record("a",3)]},p164xc_record("a",99),0),
    KIndexLeaf{0,[p164xc_record("a",99),p164xc_record("b",2)]})),
    p164xc_rows(0,16)}
