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

@unsafe
def p163w_reverse_go(left: U32, +i: U32, acc: List<&2,KDef>) -> List<&2,KDef>:
  match left:
    case 0: acc
    case n: p163w_reverse_go(U32.sub(n,1),U32.add(i,8),book_final_reverse(p163w_rows(i),acc))

@unsafe
def p163w_reverse(n: U32) -> List<&2,KDef>:
  p163w_reverse_go(n,0,[])

@unsafe
def p163w_reverse_expected_go(left: U32, +i: U32, acc: List<&2,KDef>) -> List<&2,KDef>:
  match left:
    case 0: acc
    case n:
      p163w_reverse_expected_go(U32.sub(n,1),U32.add(i,8),
        Con{p163w_row("",U32.add(i,4)),
        Con{p163w_row("λ.树",U32.add(i,3)),
        Con{p163w_row("alpha",U32.add(i,2)),
        Con{p163w_row("alpha",U32.add(i,1)),acc}}}})

@unsafe
def p163w_reverse_expected(n: U32) -> List<&2,KDef>:
  p163w_reverse_expected_go(n,0,[])

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
def p163w_lookup_go(left: U32, +i: U32, acc: List<&2,KDef>) -> List<&2,KDef>:
  match left:
    case 0: acc
    case n: p163w_lookup_go(U32.sub(n,1),U32.add(i,8),p163w_lookup_round(i,acc))

@unsafe
def p163w_lookup(n: U32) -> List<&2,KDef>:
  p163w_lookup_go(n,0,[])

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

@unsafe
def p163w_lookup_expected_go(left: U32, +i: U32, acc: List<&2,KDef>) -> List<&2,KDef>:
  match left:
    case 0: acc
    case n: p163w_lookup_expected_go(U32.sub(n,1),U32.add(i,8),p163w_lookup_expected_round(i,acc))

@unsafe
def p163w_lookup_expected(n: U32) -> List<&2,KDef>:
  p163w_lookup_expected_go(n,0,[])
