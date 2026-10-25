@unsafe
def p140gmc_index(a: P112FusionIndex, b: P112FusionIndex) -> Bool:
  match a b:
    case P112FusionEmpty{} P112FusionEmpty{}: True{}
    case P112FusionLeaf{ah,ab} P112FusionLeaf{bh,bb}: U32.is_eq(ah,bh) && p134v_list(N111Segment,p140r_segment,ab,bb)
    case P112FusionNode{am,al,ar} P112FusionNode{bm,bl,br}: U32.is_eq(am,bm) && p140gmc_index(al,bl) && p140gmc_index(ar,br)
    case _ _: False{}

@unsafe
def p140gmc_update(+old: List<&2,N111Segment>, +current: List<&2,N111Segment>) -> Bool:
  p140gmc_index(p112f_index(current),p140gm_changed(current,old,current,p112f_index(old),[],0))

@unsafe
def p140gmc_program(segments: List<&2,N111Segment>) -> P111Program:
  P111Program{segments,[],[],[],[],True{}}

@unsafe
def p140gmc_prepared(+program: P111Program, result: P140GPrepared) -> Bool:
  match result:
    case P140GPrepared{cursor,cache,hits,misses}: p140gmc_cursor(P134Raw{program},p140g_prepare(P134Raw{program},cache))

@unsafe
def p140gmc_emit(+old: P111Program, current: P111Program) -> Bool:
  p140gmc_prepared(current,p140g_prepare(P134Raw{old},P140GCache{[]}))

@unsafe
def p140gmc_headers(+old: P111Program, current: P111Program, +expected: Bool) -> Bool:
  p134v_bool(p140gm_headers(old,current),expected)

@unsafe
def p140gm_controls() -> List<&2,String>:
  +a = p140gmc_leaf("main",7)
  +b = p140gmc_leaf("b",8)
  +edit = p140gmc_leaf("main",9)
  +left = p140gmc_leaf("costarring",1)
  +right = p140gmc_leaf("liquid",2)
  +changed = p140gmc_leaf("liquid",3)
  +old = p140gmc_program([a,b])
  +new = p140gmc_program([edit,b])
  [p131u_row(p140gmc_update([],[]),"metadata-empty-index"),
   p131u_row(p140gmc_update([a,b],[a,b]),"metadata-index-identity"),
   p131u_row(p140gmc_update([a,b],[edit,b]),"metadata-index-body-change"),
   p131u_row(p140gmc_update([left,right],[left,changed]),"metadata-index-real-collision"),
   p131u_row(p140gmc_update([a,a],[a,edit]),"metadata-index-later-duplicate-change"),
   p131u_row(p140gmc_update([a,a],[edit,a]),"metadata-index-first-duplicate-change"),
   p131u_row(p140gmc_update([a,a],[edit,edit]),"metadata-index-both-duplicates-change"),
   p131u_row(p140gmc_index(p140gm_changed([edit],[a],[edit],p112f_index([a]),[],16),p112f_index([edit])),"metadata-index-bound-fallback"),
   p131u_row(p140gmc_headers(old,new,True{}),"metadata-body-not-header"),
   p131u_row(p140gmc_headers(old,p140gmc_program([b,a]),False{}),"metadata-order-refusal"),
   p131u_row(p140gmc_headers(old,P111Program{[a,b],[],[1],[],[],True{}},False{}),"metadata-show-refusal"),
   p131u_row(p140gmc_headers(old,P111Program{[a,b],[],[],["x"],[],True{}},False{}),"metadata-names-refusal"),
   p131u_row(p140gmc_headers(old,P111Program{[a,b],[],[],[],["IO"],True{}},False{}),"metadata-effects-refusal"),
   p131u_row(p140gmc_headers(old,P111Program{[a,b],[],[],[],[],False{}},False{}),"metadata-pure-refusal"),
   p131u_row(p140gmc_emit(old,new),"metadata-edited-emission-exact"),
   p131u_row(p140gmc_emit(old,p140gmc_program([b,a])),"metadata-reorder-emission-exact")]

@unsafe
def p140gmc_leaf(name: String, value: U32) -> N111Segment:
  N111Segment{name,0,1,0,0,[N111Alloca{"scratch",2048,8},
    N111Store{N111U64{},N111Local{"scratch"},0,N111Const{value,0}},
    N111Call{"reply",N111U64{},"p111_rt_return",[N111Arg{N111Ptr{},N111Local{"state"}},N111Arg{N111Ptr{},N111Local{"scratch"}},N111Arg{N111U32{},N111Const{1,0}}]},
    N111Return{N111Local{"reply"}}]}

@unsafe
def p140gmc_cursor(+plan: P134EmissionPlan, prepared: P140GPrepared) -> Bool:
  match prepared:
    case P140GPrepared{cursor,cache,hits,misses}:
      p140gmc_emitted(p134e_collect_cursor(cursor,[],[]),p134e_collect_cursor(p134e_begin(plan),[],[]))

@unsafe
def p140gmc_emitted(a: P111Emission, b: P111Emission) -> Bool:
  match a b:
    case P111Emission{ac,ae} P111Emission{bc,be}: String.eq(ae,be) && p140o_strings(ac,bc)
    case _ _: False{}
