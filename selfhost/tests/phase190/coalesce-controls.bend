# Add to the pinned liveness and joint-caller fixtures; never replace them.
# Graph hazards remain independently checked by p190j_controls and the shared
# 802-observation joint runtime. These rows isolate affinity collection/choice.
@unsafe
def p190co_ids() -> KDef:
  p111v_put(p111v_put(p111v_put(missing(),"a","X190LBit",1,0),"b","X190LBit",2,0),"c","X190LBit",4,0)

@unsafe
def p190co_masks(+affinities: KDef, a: U32, b: U32, c: U32) -> Bool:
  U32.is_eq(da(p111v_get(affinities,"a")),a) && U32.is_eq(da(p111v_get(affinities,"b")),b) &&
    U32.is_eq(da(p111v_get(affinities,"c")),c)

@unsafe
def p190co_coloring() -> Bool:
  +groups = x190_a_color(["a","b","c"],[2,1,0],[],1,[0,0,0,0,0,0,0,0,0],
    x190_a_pair("c",N111Local{"b"},p190co_ids(),missing()))
  x190_j_valid(["a","b","c"],[2,1,0],[],1,groups) &&
    U32.is_eq(x190_j_home(groups,2,0),x190_j_home(groups,4,0)) &&
    Bool.not(U32.is_eq(x190_j_home(groups,1,0),x190_j_home(groups,4,0)))

@unsafe
def p190co_controls() -> List<&2,String>:
  [p190lv_row("affinity-copy-undirected",p190co_masks(
     x190_a_body([P113DScalar{N111Set{"b",N111U64{},N111Local{"a"}}}],p190co_ids(),[],missing()),2,1,0)),
   p190lv_row("affinity-narrow-copy",p190co_masks(
     x190_a_body([P113DScalar{N111Set{"b",N111U32{},N111Local{"a"}}}],p190co_ids(),[],missing()),2,1,0)),
   p190lv_row("affinity-again-pairs",p190co_masks(
     x190_a_body([P113DAgain{[N111Local{"b"},N111Local{"c"}]}],p190co_ids(),["a","b"],missing()),2,5,2)),
   p190lv_row("affinity-nested-branches",p190co_masks(x190_a_body(
     [P113DIf{N111Const{1,0},[P113DScalar{N111Set{"a",N111U64{},N111Local{"b"}}}],
       [P113DScalar{N111If{N111Const{1,0},[N111Set{"b",N111U64{},N111Local{"c"}}],[]}}]}],
     p190co_ids(),[],missing()),2,5,2)),
   p190lv_row("affinity-noncandidate-ignored",p190co_masks(
     x190_a_pair("missing",N111Local{"a"},p190co_ids(),missing()),0,0,0)),
   p190lv_row("affinity-prefers-partner",U32.is_eq(x190_a_choose([0,0,0,0,0,1,0,0,0],1,2,0,4294967295),5)),
   p190lv_row("affinity-conflicting-partner",U32.is_eq(x190_a_pick([0,0,0,0,1,0,0,0,0],1,2,1,4294967295,0),9)),
   p190lv_row("affinity-conflicting-neighbor",U32.is_eq(x190_a_pick([0,0,0,0,5,0,0,0,0],1,2,4,4294967295,0),9)),
   p190lv_row("affinity-call-caller-rejected",U32.is_eq(x190_a_pick([0,0,0,0,1,0,0,0,0],1,2,2,4294967295,0),9)),
   p190lv_row("affinity-call-callee-accepted",U32.is_eq(x190_a_pick([1,0,0,0,0,0,0,0,0],1,2,2,4294967295,0),0)),
   p190lv_row("affinity-incoming-rejected",U32.is_eq(x190_a_pick([0,0,0,0,0,0,0,0,1],1,2,0,1,0),9)),
   p190lv_row("affinity-coloring-valid",p190co_coloring())]

def p190co_outputs() -> List<&2,X181Output>: p190j_outputs()
