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

# Additional v02 controls. A legacy KDef can have the same getter view as a
# compact index node, but the cache contract requires exact variants recursively.
@unsafe
def p140rc_legacy_leaf() -> KDef:
  KDef{"","IndexLeaf",7,0,atom("Absent"),atom("Absent"),[],True{},False{}}

@unsafe
def p140rc_wrap(value: KDef) -> KDef:
  KDef{"outer","test",0,0,atom("Absent"),atom("Absent"),[value],False{},False{}}

@unsafe
def p140rc_data(items: List<&2,P111QDatum>, first: Bool) -> P134Cursor:
  P134Data{items,first,[]}

@unsafe
def p140rc_data_same(old: List<&2,P111QDatum>, current: List<&2,P111QDatum>) -> Bool:
  p140r_hit(p140rc_data(current,True{}),p140r_key(p140rc_data(old,True{})))

@unsafe
def p140rc_header(name: String, alignment: U32, exported: Bool) -> P134Cursor:
  P134Tables{[P111QData{name,alignment,exported,[P111QWord{7}]}]}

@unsafe
def p140rc_prefix(+count: U32, +tail: List<&2,P111QDatum>) -> List<&2,P111QDatum>:
  nt_choose(List<&2,P111QDatum>,U32.is_eq(count,0),u => tail,
    u => Con{P111QWord{7},p140rc_prefix(U32.sub(count,1),tail)})

@unsafe
def p140rc_entry(valid: Bool, calls: U32, params: List<&2,String>, body: List<&2,P112WorkerStmt>, rank: U32, sites: U32) -> P112RegionEntry:
  P112RegionEntry{p140rc_segment("root",7),P112WorkerPlan{valid,calls,params,body},rank,sites}

@unsafe
def p140rc_legacy_cursor(entry: P112RegionEntry) -> P134Cursor:
  P134Legacy{[entry],p140rc_context(P112FusionEmpty{}),P134End{}}

@unsafe
def p140rc_legacy_same(old: P112RegionEntry, current: P112RegionEntry) -> Bool:
  p140r_hit(p140rc_legacy_cursor(current),p140r_key(p140rc_legacy_cursor(old)))

@unsafe
def p140rc_qdata(a: P111QData, b: P111QData) -> Bool:
  match a b:
    case P111QData{an,aa,ae,ai} P111QData{bn,ba,be,bi}:
      String.eq(an,bn) && U32.is_eq(aa,ba) && p134v_bool(ae,be) &&
        p134v_list(P111QDatum,p140r_datum,ai,bi)

# Compare the skip result with the next cursor produced by the original actual
# renderer. Test contexts here have empty fusion indexes; exact context matching
# is separately checked above and production cursors retain the same context.
@unsafe
def p140rc_cursor_equal(a: P134Cursor, b: P134Cursor) -> Bool:
  match a b:
    case P134Private{af,ac,an} P134Private{bf,bc,bn}:
      p134v_list(P113DFunction,p134v_function,af,bf) && p140r_context(ac,bc) && p140rc_cursor_equal(an,bn)
    case P134Legacy{af,ac,an} P134Legacy{bf,bc,bn}:
      p134v_list(P112RegionEntry,p140r_legacy,af,bf) && p140r_context(ac,bc) && p140rc_cursor_equal(an,bn)
    case P134Public{af,ac,an} P134Public{bf,bc,bn}:
      p134v_list(N111Segment,p140r_segment,af,bf) && p140r_context(ac,bc) && p140rc_cursor_equal(an,bn)
    case P134Tables{a} P134Tables{b}: p134v_list(P111QData,p140rc_qdata,a,b)
    case P134Data{ai,af,ar} P134Data{bi,bf,br}:
      p134v_list(P111QDatum,p140r_datum,ai,bi) && p134v_bool(af,bf) && p134v_list(P111QData,p140rc_qdata,ar,br)
    case P134Main{} P134Main{}: True{}
    case P134End{} P134End{}: True{}
    case _ _: False{}

@unsafe
def p140rc_skip_step(cursor: P134Cursor, step: P134Step) -> Bool:
  match step:
    case P134Piece{text,ending,next}: p140rc_cursor_equal(p140r_skip(cursor),next)
    case _: False{}

@unsafe
def p140rc_skip(+cursor: P134Cursor) -> Bool:
  p140rc_skip_step(cursor,p134e_next(cursor))

@unsafe
def p140rc_ordinal_step(step: P140RStep) -> Bool:
  match step:
    case P140RReuse{old,P140RState{P134Data{items,first,rest},context,valid,prior,
      Con{P140RSlot{P140RHeader{name,alignment,exported},slot},Nil{}},ordinal,hits,misses}}:
      U32.is_eq(old,9) && U32.is_eq(slot,0) && U32.is_eq(ordinal,1) &&
        U32.is_eq(hits,1) && U32.is_eq(misses,0) && first &&
        p134v_list(P111QDatum,p140r_datum,items,[P111QWord{7}])
    case _: False{}

@unsafe
def p140rc_ordinal() -> Bool:
  +cursor: P134Cursor = p140rc_header("table",8,False{})
  p140rc_ordinal_step(p140r_next(P140RState{cursor,p140rc_context(P112FusionEmpty{}),True{},
    [P140RSlot{p140r_key(cursor),9}],[],0,0,0}))

@unsafe
def p140rc_extra_controls() -> List<&2,String>:
  +header: P140RKey = p140r_key(p140rc_header("table",8,False{}))
  +entry: P112RegionEntry = p140rc_entry(True{},0,["x"],[P112WorkerResult{}],0,0)
  [p128bs_control_row("render-context-variant-exact",Bool.not(p140r_def(p140rc_legacy_leaf(),KIndexLeaf{7,[]}))),
   p128bs_control_row("render-context-nested-variant-exact",Bool.not(p140r_def(p140rc_wrap(p140rc_legacy_leaf()),p140rc_wrap(KIndexLeaf{7,[]})))),
   p128bs_control_row("render-datum-widths-distinct",
     Bool.not(p140rc_data_same([P111QByte{7}],[P111QWord{7}])) &&
     Bool.not(p140rc_data_same([P111QWord{7}],[P111QLong{7,0}])) &&
     Bool.not(p140rc_data_same([P111QWord{7}],[P111QZeros{7}]))),
   p128bs_control_row("render-datum-long-high-miss",Bool.not(p140rc_data_same([P111QLong{7,0}],[P111QLong{7,1}]))),
   p128bs_control_row("render-relocation-symbol-miss",Bool.not(p140rc_data_same([P111QReloc{"a",0}],[P111QReloc{"b",0}]))),
   p128bs_control_row("render-relocation-offset-miss",Bool.not(p140rc_data_same([P111QReloc{"a",0}],[P111QReloc{"a",8}]))),
   p128bs_control_row("render-data-first-separator-miss",Bool.not(p140r_hit(p140rc_data([P111QWord{7}],False{}),p140r_key(p140rc_data([P111QWord{7}],True{}))))),
   p128bs_control_row("render-data-128th-change-miss",Bool.not(p140rc_data_same(p140rc_prefix(127,[P111QWord{1}]),p140rc_prefix(127,[P111QWord{2}])))),
   p128bs_control_row("render-data-129th-change-first-slice-hit",p140rc_data_same(p140rc_prefix(128,[P111QWord{1}]),p140rc_prefix(128,[P111QWord{2}]))),
   p128bs_control_row("render-data-129th-change-next-slice-miss",Bool.not(p140r_hit(
     p140r_skip(p140rc_data(p140rc_prefix(128,[P111QWord{2}]),True{})),
     p140r_key(p140r_skip(p140rc_data(p140rc_prefix(128,[P111QWord{1}]),True{})))))) ,
   p128bs_control_row("render-header-name-miss",Bool.not(p140r_hit(p140rc_header("other",8,False{}),header))),
   p128bs_control_row("render-header-alignment-miss",Bool.not(p140r_hit(p140rc_header("table",4,False{}),header))),
   p128bs_control_row("render-header-export-miss",Bool.not(p140r_hit(p140rc_header("table",8,True{}),header))),
   p128bs_control_row("render-legacy-valid-miss",Bool.not(p140rc_legacy_same(entry,p140rc_entry(False{},0,["x"],[P112WorkerResult{}],0,0)))),
   p128bs_control_row("render-legacy-calls-miss",Bool.not(p140rc_legacy_same(entry,p140rc_entry(True{},1,["x"],[P112WorkerResult{}],0,0)))),
   p128bs_control_row("render-legacy-params-miss",Bool.not(p140rc_legacy_same(entry,p140rc_entry(True{},0,["y"],[P112WorkerResult{}],0,0)))),
   p128bs_control_row("render-legacy-body-miss",Bool.not(p140rc_legacy_same(entry,p140rc_entry(True{},0,["x"],[P112WorkerAgain{}],0,0)))),
   p128bs_control_row("render-legacy-rank-miss",Bool.not(p140rc_legacy_same(entry,p140rc_entry(True{},0,["x"],[P112WorkerResult{}],1,0)))),
   p128bs_control_row("render-legacy-sites-miss",Bool.not(p140rc_legacy_same(entry,p140rc_entry(True{},0,["x"],[P112WorkerResult{}],0,1)))),
   p128bs_control_row("render-close-fixed-hit",p140r_hit(p140rc_data([],False{}),p140r_key(p140rc_data([],True{})))),
   p128bs_control_row("render-main-fixed-hit",p140r_hit(P134Main{},p140r_key(P134Main{}))),
   p128bs_control_row("render-skip-data-header-close-main-exact",
     p140rc_skip(p140rc_header("table",8,False{})) &&
     p140rc_skip(p140rc_data(p140rc_prefix(129,[]),True{})) &&
     p140rc_skip(p140rc_data([],False{})) && p140rc_skip(P134Main{})),
   p128bs_control_row("render-skip-private-public-exact",p140rc_skip(p140rc_private(7)) &&
     p140rc_skip(p140rc_cursor(p140rc_segment("main",7),P112FusionEmpty{}))),
   p128bs_control_row("render-reuse-ordinal-and-progress",p140rc_ordinal())]
