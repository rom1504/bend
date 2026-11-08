# Complete heap observations and finite equality/directional-comparison checks.
def p182s_cell(id: U32) -> KTerm:
  KTerm{"GCell","",id,0,[],[],0,0}

def p182s_value(+id: U32) -> KTerm:
  KTerm{"GValue","",0,0,
    [KTerm{"Ctr","Z",0,0,[],["distinct-preserved-metadata"],id,U32.add(id,10)}],[],0,0}

@unsafe
def p182s_state() -> GState:
  GState{g_put(g_put(g_put(g_put(GEmpty{},1,p182s_value(1)),2,p182s_value(2)),
    3,p182s_value(3)),4,p182s_value(4)),5}

@unsafe
def p182s_joined() -> GState:
  g_class_join(g_class_join(g_class_join(p182s_state(),1,2),3,4),2,4)

@unsafe
def p182s_original_heap() -> GHeap:
  g_heap(p182s_state())

@unsafe
def p182s_joined_heap() -> GHeap:
  g_heap(p182s_joined())

@unsafe
def p182s_cached() -> GState:
  +st = p182s_joined()
  g_cache(st,1,kid(g_get(g_heap(st),1),0))

@unsafe
def p182s_shared() -> GResult:
  g_share(p182s_joined(),KTerm{"Ref","new",0,0,[],[],61,62})

@unsafe
def p182s_shared_expected_heap() -> GHeap:
  g_put(p182s_original_heap(),5,
    KTerm{"GThunk","",0,0,[KTerm{"Ref","new",0,0,[],[],61,62}],[],0,0})

@unsafe
def p182s_heap_observations() -> List<&2,GHeap>:
  [p182s_original_heap(),p182s_joined_heap(),g_heap(p182s_cached()),
   g_heap(g_state(p182s_shared())),p182s_shared_expected_heap()]

@unsafe
def p182s_checks() -> List<&2,Bool>:
  +st = p182s_joined()
  [Bool.not(g_class_same(p182s_state(),1,2)),
   g_class_same(st,1,2),g_class_same(st,1,3),g_class_same(st,1,4),
   g_class_same(st,4,1),Bool.not(g_class_same(st,1,5)),
   g_class_same(g_class_join(st,4,1),2,3),
   g_class_same(p182s_cached(),1,4),
   g_class_same(g_state(p182s_shared()),1,4),
   Bool.not(g_class_same(GState{g_heap(st),g_next(st)},1,4)),
   U32.is_eq(g_next(st),5),U32.is_eq(g_next(p182s_cached()),5),
   U32.is_eq(g_next(g_state(p182s_shared())),6),
   U32.is_eq(ix(g_term(p182s_shared())),5),
   norm_cmp_shared(st,p182s_cell(1),p182s_cell(4)),
   Bool.not(norm_cmp_shared(st,p182s_cell(1),KTerm{"Var","",4,0,[],[],0,0}))]

# Data fits Type in LE, but those two cells must never become an EQ class.
@unsafe
def p182s_directional_state() -> GState:
  GState{g_put(g_put(GEmpty{},1,
    KTerm{"GValue","",0,0,[KTerm{"Typ","",0,0,[qua(2)],[],0,0}],[],0,0}),2,
    KTerm{"GValue","",0,0,[KTerm{"Typ","",0,0,[qua(0)],[],0,0}],[],0,0}),3}

@unsafe
def p182s_le_only() -> Bool:
  norm_cmp_loop([],p182s_directional_state(),[KNormCmp{p182s_cell(1),p182s_cell(2),True{},10}],[])

@unsafe
def p182s_le_then_eq() -> Bool:
  norm_cmp_loop([],p182s_directional_state(),
    [KNormCmp{p182s_cell(1),p182s_cell(2),True{},10},
     KNormCmp{p182s_cell(1),p182s_cell(2),False{},10}],[])

@unsafe
def p182s_failed_eq_alternative() -> Bool:
  norm_cmp_loop([],p182s_directional_state(),
    [KNormCmp{p182s_cell(1),p182s_cell(2),False{},10}],
    [KNormAlt{[KNormCmp{p182s_cell(1),p182s_cell(2),False{},10}]}])

@unsafe
def p182s_eq_then_le() -> Bool:
  norm_cmp_loop([],p182s_state(),
    [KNormCmp{p182s_cell(1),p182s_cell(2),False{},10},
     KNormCmp{p182s_cell(1),p182s_cell(2),True{},10}],[])

@unsafe
def p182s_relations() -> List<&2,Bool>:
  [p182s_le_only(),p182s_le_then_eq(),p182s_failed_eq_alternative(),p182s_eq_then_le()]

def p182s_relations_expected() -> List<&2,Bool>:
  [True{},False{},False{},True{}]
