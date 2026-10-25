# Finite closure equivalence, not a theorem. Physical Patricia insertion order
# need not agree: the actual consumers observe membership and the stored count.
@unsafe
def p140qc_subset(names: List<&2,String>, +index: KDef) -> Bool:
  match names:
    case Nil{}: True{}
    case Con{name,rest}: p140o_has(index,name) && p140qc_subset(rest,index)

@unsafe
def p140qc_equal(left: P140ODirty, right: P140ODirty) -> Bool:
  match left right:
    case P140ODirty{+a,ac} P140ODirty{+b,bc}:
      U32.is_eq(ac,bc) && p140qc_subset(p140oq_names([a],[]),b) && p140qc_subset(p140oq_names([b],[]),a)

@unsafe
def p140qc_same(+edges: List<&2,P140OEdge>, +initial: P140ODirty) -> Bool:
  p140qc_equal(p140o_fix(edges,initial,U32.inc(nt_count(P140OEdge,edges))),p140oq_fix(edges,initial))

@unsafe
def p140qc_refs(+bits: U32) -> List<&2,String>:
  +tail: List<&2,String> = nt_choose(List<&2,String>,U32.is_ne(U32.and(bits,4),0),u => ["c"],u => [])
  +tail: List<&2,String> = nt_choose(List<&2,String>,U32.is_ne(U32.and(bits,2),0),u => Con{"b",tail},u => tail)
  nt_choose(List<&2,String>,U32.is_ne(U32.and(bits,1),0),u => Con{"a",tail},u => tail)

@unsafe
def p140qc_graph(+bits: U32) -> List<&2,P140OEdge>:
  [P140OEdge{"a",p140qc_refs(bits)},P140OEdge{"b",p140qc_refs(U32.shrn(bits,3n))},P140OEdge{"c",p140qc_refs(U32.shrn(bits,6n))}]

@unsafe
def p140qc_seed(names: List<&2,String>, dirty: P140ODirty) -> P140ODirty:
  match names:
    case Nil{}: dirty
    case Con{name,rest}: p140qc_seed(rest,p140o_mark(name,dirty))

@unsafe
def p140qc_initial(+edges: List<&2,P140OEdge>, +bits: U32) -> Bool:
  nt_choose(Bool,U32.is_eq(bits,8),u => True{},u =>
    p140qc_same(edges,p140qc_seed(p140qc_refs(bits),P140ODirty{missing(),0})) && p140qc_initial(edges,U32.inc(bits)))

@unsafe
def p140qc_graphs(+bits: U32) -> Bool:
  nt_choose(Bool,U32.is_eq(bits,512),u => True{},u => p140qc_initial(p140qc_graph(bits),0) && p140qc_graphs(U32.inc(bits)))

@unsafe
def p140qc_case(+edges: List<&2,P140OEdge>, names: List<&2,String>) -> Bool:
  p140qc_same(edges,p140qc_seed(names,P140ODirty{missing(),0}))

@unsafe
def p140oq_controls() -> List<&2,String>:
  [p140oc_row("reverse-4096-three-node-closures",p140qc_graphs(0)),
   p140oc_row("reverse-duplicate-edges-and-owners",p140qc_case([P140OEdge{"a",["b","b"]},P140OEdge{"a",["c"]},P140OEdge{"b",["a"]}],["c"])),
   p140oc_row("reverse-dirty-unknown-dependency",p140qc_case([P140OEdge{"a",["unknown"]},P140OEdge{"b",["a"]}],["unknown"])),
   p140oc_row("reverse-unrelated-unknown-preserved",p140qc_case([P140OEdge{"a",["b"]}],["elsewhere"])),
   p140oc_row("reverse-empty-string-reference",p140qc_case([P140OEdge{"a",[""]}],[""])),
   p140oc_row("reverse-empty-graph-preserves-seed",p140qc_case([],["a","unknown"])),
   p140oc_row("reverse-real-hash-collision",U32.is_eq(index_hash("costarring",2166136261),index_hash("liquid",2166136261)) &&
     p140qc_case([P140OEdge{"a",["costarring"]},P140OEdge{"b",["liquid"]},P140OEdge{"c",["a"]}],["liquid"])),
   p140oc_row("reverse-collision-does-not-alias",p140qc_no_alias(p140oq_fix([P140OEdge{"a",["costarring"]},P140OEdge{"b",["liquid"]}],p140qc_seed(["liquid"],P140ODirty{missing(),0}))))]

@unsafe
def p140qc_no_alias(dirty: P140ODirty) -> Bool:
  match dirty:
    case P140ODirty{+names,count}: U32.is_eq(count,2) && p140o_has(names,"b") && Bool.not(p140o_has(names,"a"))
