# Independent adversarial controls for process-local rendered-unit reuse.
# These test cache admission, not validity of arbitrary synthetic N111 bodies.
# The actual compiler's admission and final verifier remain independent.

@unsafe
def p140rc_segment(name: String, value: U32) -> N111Segment:
  N111Segment{name,0,1,0,0,[N111Return{N111Const{value,0}}]}

@unsafe
def p140rc_frame(name: String) -> N111Stmt:
  N111Call{"frame",N111U64{},"p111_rt_frame",
    [N111Arg{N111Ptr{},N111Local{"state"}},N111Arg{N111U32{},N111FuncId{name}},
     N111Arg{N111Ptr{},N111Local{"scratch"}},N111Arg{N111U32{},N111Const{0,0}}]}

@unsafe
def p140rc_ref(name: String, target: String) -> N111Segment:
  N111Segment{name,0,1,0,0,[p140rc_frame(target),N111Return{N111Const{0,0}}]}

@unsafe
def p140rc_context(index: P112FusionIndex) -> P134Context:
  P134Context{N111Ids{missing(),missing()},index,missing(),missing(),missing(),[],0,0}

@unsafe
def p140rc_cursor(segment: N111Segment, index: P112FusionIndex) -> P134Cursor:
  P134Public{[segment],p140rc_context(index),P134End{}}

@unsafe
def p140rc_same(old: N111Segment, current: N111Segment) -> Bool:
  p140r_hit(p140rc_cursor(current,P112FusionEmpty{}),
    p140r_key(p140rc_cursor(old,P112FusionEmpty{})))

@unsafe
def p140rc_dependencies(+segment: N111Segment, old: List<&2,N111Segment>, current: List<&2,N111Segment>) -> Bool:
  p140r_hit(p140rc_cursor(segment,p112f_index(current)),
    p140r_key(p140rc_cursor(segment,p112f_index(old))))

# A chain of n distinct literal frame targets, with the final node a return.
# The original root references c0, so n=64 exactly fills the closure budget.
@unsafe
def p140rc_chain(+count: U32, +at: U32) -> List<&2,N111Segment>:
  nt_choose(List<&2,N111Segment>,U32.is_eq(count,0),u => [],u =>
    Con{nt_choose(N111Segment,U32.is_eq(count,1),v => p140rc_segment("c" ++ U32.show(at),7),
      v => p140rc_ref("c" ++ U32.show(at),"c" ++ U32.show(U32.inc(at)))),
      p140rc_chain(U32.sub(count,1),U32.inc(at))})

@unsafe
def p140rc_budget(+count: U32) -> Bool:
  p140rc_dependencies(p140rc_ref("root","c0"),p140rc_chain(count,0),p140rc_chain(count,0))

@unsafe
def p140rc_cycle_result(facts: P140RFacts) -> Bool:
  match facts:
    case P140RFacts{valid,items}: valid && U32.is_eq(nt_count(P140RFact,items),1)

@unsafe
def p140rc_cycle() -> Bool:
  +loop: N111Segment = p140rc_ref("loop","loop")
  p140rc_cycle_result(p140r_close(["loop"],p112f_index([loop]),[],[],64)) &&
    p140rc_dependencies(p140rc_ref("root","loop"),[loop],[loop])

@unsafe
def p140rc_nested() -> Bool:
  +root: N111Segment = N111Segment{"root",0,1,0,0,
    [N111If{N111Const{1,0},[p140rc_frame("yes")],
      [N111If{N111Const{0,0},[p140rc_frame("deep")],[p140rc_frame("no")]}]},
     N111Return{N111Const{0,0}}]}
  +yes: N111Segment = p140rc_segment("yes",1)
  +no: N111Segment = p140rc_segment("no",2)
  Bool.not(p140rc_dependencies(root,[yes,no,p140rc_segment("deep",3)],
    [yes,no,p140rc_segment("deep",4)]))

@unsafe
def p140rc_ids() -> Bool:
  +empty: KDef = missing()
  +changed: KDef = p111q_insert(missing(),"x",1)
  +base: P134Context = p140rc_context(P112FusionEmpty{})
  Bool.not(p140r_context(base,P134Context{N111Ids{changed,empty},P112FusionEmpty{},empty,empty,empty,[],0,0})) &&
    Bool.not(p140r_context(base,P134Context{N111Ids{empty,changed},P112FusionEmpty{},empty,empty,empty,[],0,0}))

@unsafe
def p140rc_views() -> Bool:
  +empty: KDef = missing()
  +changed: KDef = p111q_insert(missing(),"x",1)
  +ids: N111Ids = N111Ids{empty,empty}
  +base: P134Context = p140rc_context(P112FusionEmpty{})
  Bool.not(p140r_context(base,P134Context{ids,P112FusionEmpty{},changed,empty,empty,[],0,0})) &&
    Bool.not(p140r_context(base,P134Context{ids,P112FusionEmpty{},empty,changed,empty,[],0,0})) &&
    Bool.not(p140r_context(base,P134Context{ids,P112FusionEmpty{},empty,empty,changed,[],0,0}))

@unsafe
def p140rc_layout() -> Bool:
  +empty: KDef = missing()
  +ids: N111Ids = N111Ids{empty,empty}
  +base: P134Context = p140rc_context(P112FusionEmpty{})
  Bool.not(p140r_context(base,P134Context{ids,P112FusionEmpty{},empty,empty,empty,[P126ITable{"table",1}],0,0})) &&
    Bool.not(p140r_context(base,P134Context{ids,P112FusionEmpty{},empty,empty,empty,[],1,0})) &&
    Bool.not(p140r_context(base,P134Context{ids,P112FusionEmpty{},empty,empty,empty,[],0,1}))

@unsafe
def p140rc_private(+value: U32) -> P134Cursor:
  P134Private{[P113DFunction{"main",[],1,False{},[P113DResult{[N111Const{value,0}]}]}],
    p140rc_context(P112FusionEmpty{}),P134End{}}

@unsafe
def p140rc_fresh(step: P140RStep) -> Bool:
  match step:
    case P140RText{text,ending,P140RState{cursor,context,valid,prior,slots,ordinal,hits,misses}}:
      Bool.not(valid) && U32.is_eq(ordinal,1) && U32.is_eq(hits,0) && U32.is_eq(misses,1)
    case _: False{}

# Use the actual begin/next gate: identical private code must still render fresh
# when the global heap context changes, rather than merely testing its comparer.
@unsafe
def p140rc_gate() -> Bool:
  +empty: KDef = missing()
  +context: P134Context = P134Context{N111Ids{empty,empty},P112FusionEmpty{},empty,empty,empty,[],1,0}
  +function: P113DFunction = p134ec_function()
  p140rc_fresh(p140r_next(p140r_begin_context(P134Private{[function],context,P134End{}},context,
    P140RCache{p140rc_context(P112FusionEmpty{}),[P140RSlot{P140RPrivate{function},7}]})))

@unsafe
def p140rc_controls() -> List<&2,String>:
  +plain: N111Segment = p140rc_segment("root",7)
  +frame: N111Segment = p140rc_ref("root","cont")
  +cont: N111Segment = p140rc_segment("cont",7)
  +first: N111Segment = p140rc_ref("cont","deep")
  +private: P140RKey = p140r_key(p140rc_private(7))
  [p128bs_control_row("render-same-segment-hit",p140rc_same(plain,plain)),
   p128bs_control_row("render-segment-name-miss",Bool.not(p140rc_same(plain,p140rc_segment("other",7)))),
   p128bs_control_row("render-segment-arity-miss",Bool.not(p140rc_same(plain,N111Segment{"root",1,1,0,0,[N111Return{N111Const{7,0}}]}))),
   p128bs_control_row("render-segment-result-miss",Bool.not(p140rc_same(plain,N111Segment{"root",0,2,0,0,[N111Return{N111Const{7,0}}]}))),
   p128bs_control_row("render-segment-incoming-miss",Bool.not(p140rc_same(plain,N111Segment{"root",0,1,1,0,[N111Return{N111Const{7,0}}]}))),
   p128bs_control_row("render-segment-flags-miss",Bool.not(p140rc_same(plain,N111Segment{"root",0,1,0,1,[N111Return{N111Const{7,0}}]}))),
   p128bs_control_row("render-segment-body-miss",Bool.not(p140rc_same(plain,p140rc_segment("root",8)))),
   p128bs_control_row("render-continuation-body-miss",Bool.not(p140rc_dependencies(frame,[cont],[p140rc_segment("cont",8)]))),
   p128bs_control_row("render-continuation-header-miss",Bool.not(p140rc_dependencies(frame,[cont],[N111Segment{"cont",0,1,1,0,[N111Return{N111Const{7,0}}]}]))),
   p128bs_control_row("render-continuation-removed-miss",Bool.not(p140rc_dependencies(frame,[cont],[]))),
   p128bs_control_row("render-missing-now-present-miss",Bool.not(p140rc_dependencies(frame,[],[cont]))),
   p128bs_control_row("render-missing-still-missing-hit",p140rc_dependencies(frame,[],[])),
   p128bs_control_row("render-transitive-change-miss",Bool.not(p140rc_dependencies(frame,[first,p140rc_segment("deep",7)],[first,p140rc_segment("deep",8)]))),
   p128bs_control_row("render-unrelated-index-change-hit",p140rc_dependencies(frame,[cont,p140rc_segment("other",7)],[cont,p140rc_segment("other",8)])),
   p128bs_control_row("render-closure-64-hit",p140rc_budget(64)),
   p128bs_control_row("render-closure-65-refused",Bool.not(p140rc_budget(65))),
   p128bs_control_row("render-cycle-terminates-hit",p140rc_cycle()),
   p128bs_control_row("render-nested-branch-change-miss",p140rc_nested()),
   p128bs_control_row("render-context-both-id-maps-miss",p140rc_ids()),
   p128bs_control_row("render-context-direct-ready-view-miss",p140rc_views()),
   p128bs_control_row("render-context-lookups-heap-mode-miss",p140rc_layout()),
   p128bs_control_row("render-private-same-hit",p140r_hit(p140rc_private(7),private)),
   p128bs_control_row("render-private-body-miss",Bool.not(p140r_hit(p140rc_private(8),private))),
   p128bs_control_row("render-private-public-kind-miss",Bool.not(p140r_hit(p140rc_cursor(plain,P112FusionEmpty{}),private))),
   p128bs_control_row("render-global-context-gates-next",p140rc_gate())]
