# Independent finite admission controls. All prior verifier caches below come
# from p140v_check. Deliberately false LOCAL runs exercise diagnostic rejection;
# they are not legitimate capsules and never authorize the unchecked fast path.
# Invalid IR is inspected only, never emitted or executed.

def p142wt_segment(name: String, value: U32, flags: U32) -> N111Segment:
  N111Segment{name,0,1,0,flags,[N111Return{N111Const{value,0}}]}

def p142wt_program(segments: List<&2,N111Segment>, ctors: List<&2,N_Constructor>,
    nodes: List<&2,P112SNode>, functions: List<&2,P113DFunction>) -> P113DProgram:
  P113DProgram{P112StaticProgram{P111Program{segments,ctors,[0],[],[],True{}},nodes},functions}

def p142wt_boundary(result: P142VOpened) -> P114SBoundary:
  match result:
    case P142VOpened{P140VOpened{boundary,cache,counts},witness}: boundary

def p142wt_valid(result: P142VOpened) -> Bool:
  match result:
    case P142VOpened{P140VOpened{P114SBoundary{original,ids,functions,valid},cache,counts},witness}: valid

def p142wt_unpublished(result: P142VOpened) -> Bool:
  match result:
    case P142VOpened{P140VOpened{boundary,cache,counts},witness}: p140vt_empty(cache)

def p142wt_counts(result: P142VOpened, retained: U32, compared: U32, mismatches: U32) -> Bool:
  match result:
    case P142VOpened{opened,P142WCounts{r,c,m}}:
      U32.is_eq(r,retained) && U32.is_eq(c,compared) && U32.is_eq(m,mismatches)

@unsafe
def p142wt_observe(+old: P113DProgram, +now: P113DProgram, runs: List<&2,P142WRun>) -> P142VOpened:
  p142v_open(now,p140vt_cache(p140v_check(old,P140VEmpty{})),runs,True{})

@unsafe
def p142wt_equivalent(+old: P113DProgram, +now: P113DProgram, runs: List<&2,P142WRun>) -> Bool:
  p134v_boundary_same(p140vt_opened(p140v_open(now,p140vt_cache(p140v_check(old,P140VEmpty{})))),
    p142wt_boundary(p142wt_observe(old,now,runs)))

@unsafe
def p142wt_rejected(+result: P142VOpened, retained: U32, compared: U32) -> Bool:
  Bool.not(p142wt_valid(result)) && p142wt_unpublished(result) && p142wt_counts(result,retained,compared,1)

@unsafe
def p142wt_controls() -> List<&2,String>:
  +main = p142wt_segment("main",0,0)
  +other = p142wt_segment("other",7,0)
  +plain = p142wt_program([main],[],[],[])
  +changed = p142wt_program([p142wt_segment("main",9,0)],[],[],[])
  +pair = p142wt_program([main,other],[],[],[])
  +pair_changed = p142wt_program([main,p142wt_segment("other",8,0)],[],[],[])
  +flagged = p142wt_program([p142wt_segment("main",0,1)],[],[],[])
  +header = p142wt_program([N111Segment{"main",1,1,0,0,[N111Return{N111Const{0,0}}]}],[],[],[])
  +incoming = p142wt_program([N111Segment{"main",0,1,1,0,[N111Return{N111Const{0,0}}]}],[],[],[])
  +renamed = p142wt_program([p142wt_segment("not_main",0,0)],[],[],[])
  +with_ctor = p142wt_program([main],[N_Constructor{"A",0,True{}}],[],[])
  +ctor_arity = p142wt_program([main],[N_Constructor{"A",1,True{}}],[],[])
  +ctor_hot = p142wt_program([main],[N_Constructor{"A",0,False{}}],[],[])
  +badraw = p142wt_program([N111Segment{"main",0,1,0,0,[N111Return{N111Local{"undefined"}}]}],[],[],[])
  +badimage = p142wt_program([main],[],[P112SNode{0,"missing",[]}],[])
  +badboth = p142wt_program([N111Segment{"main",0,1,0,0,[N111Return{N111Local{"undefined"}}]}],[],[P112SNode{0,"missing",[]}],[])
  +badfn = p142wt_program([main],[],[],[p140vt_bad_direct()])
  +duplicate = p142wt_program([main,main],[],[],[])
  +retained : List<&2,P142WRun> = [P142WRun{1,True{}}]
  +fresh : List<&2,P142WRun> = [P142WRun{1,False{}}]
  [p114st_row("witness-identical-diagnostic",p142wt_equivalent(plain,plain,retained) && p142wt_counts(p142wt_observe(plain,plain,retained),1,1,0)),
   p114st_row("witness-cold-has-no-authority",p142wt_counts(p142v_open(plain,P140VEmpty{},retained,True{}),0,0,0)),
   p114st_row("witness-missing-runs-fallback",p142wt_equivalent(plain,plain,[]) && p142wt_counts(p142wt_observe(plain,plain,[]),0,1,0)),
   p114st_row("witness-fresh-equal-fallback",p142wt_equivalent(plain,plain,fresh) && p142wt_counts(p142wt_observe(plain,plain,fresh),0,1,0)),
   p114st_row("witness-zero-run-cannot-claim",p142wt_equivalent(plain,plain,[P142WRun{0,True{}}]) && p142wt_counts(p142wt_observe(plain,plain,[P142WRun{0,True{}}]),0,1,0)),
   p114st_row("witness-valid-unequal-forgery-rejected",p142wt_rejected(p142wt_observe(plain,changed,retained),0,1)),
   p114st_row("witness-invalid-unequal-forgery-rejected",p142wt_rejected(p142wt_observe(plain,badraw,retained),0,1)),
   p114st_row("witness-stale-prior-judgment-rejected",p142wt_rejected(p142wt_observe(changed,plain,retained),0,1)),
   p114st_row("witness-short-run-falls-back-for-tail",p142wt_equivalent(pair,pair,retained) && p142wt_counts(p142wt_observe(pair,pair,retained),1,2,0)),
   p114st_row("witness-mixed-retained-fresh",p142wt_equivalent(pair,pair_changed,[P142WRun{1,True{}},P142WRun{1,False{}}]) && p142wt_counts(p142wt_observe(pair,pair_changed,[P142WRun{1,True{}},P142WRun{1,False{}}]),1,2,0)),
   p114st_row("witness-run-crosses-changed-owner-rejected",p142wt_rejected(p142wt_observe(pair,pair_changed,[P142WRun{2,True{}}]),1,2)),
   p114st_row("witness-bang-context-refuses",p142wt_equivalent(plain,flagged,retained) && p142wt_counts(p142wt_observe(plain,flagged,retained),0,0,0)),
   p114st_row("witness-main-arity-context-refuses",p142wt_equivalent(plain,header,retained) && p142wt_counts(p142wt_observe(plain,header,retained),0,0,0)),
   p114st_row("witness-incoming-context-refuses",p142wt_equivalent(plain,incoming,retained) && p142wt_counts(p142wt_observe(plain,incoming,retained),0,0,0)),
   p114st_row("witness-mapped-name-context-refuses",p142wt_equivalent(plain,renamed,retained) && p142wt_counts(p142wt_observe(plain,renamed,retained),0,0,0)),
   p114st_row("witness-insertion-context-refuses",p142wt_equivalent(plain,pair,retained) && p142wt_counts(p142wt_observe(plain,pair,retained),0,0,0)),
   p114st_row("witness-duplicate-header-original-refusal",p142wt_equivalent(plain,duplicate,retained) && Bool.not(p142wt_valid(p142wt_observe(plain,duplicate,retained)))),
   p114st_row("witness-constructor-arity-context-refuses",p142wt_equivalent(with_ctor,ctor_arity,retained) && p142wt_counts(p142wt_observe(with_ctor,ctor_arity,retained),0,0,0)),
   p114st_row("witness-constructor-hot-context-refuses",p142wt_equivalent(with_ctor,ctor_hot,retained) && p142wt_counts(p142wt_observe(with_ctor,ctor_hot,retained),0,0,0)),
   p114st_row("witness-static-image-still-rechecked",p142wt_equivalent(plain,badimage,retained) && Bool.not(p142wt_valid(p142wt_observe(plain,badimage,retained))) && p142wt_unpublished(p142wt_observe(plain,badimage,retained))),
   p114st_row("witness-direct-function-still-rechecked",p142wt_equivalent(plain,badfn,retained) && Bool.not(p142wt_valid(p142wt_observe(plain,badfn,retained))) && p142wt_unpublished(p142wt_observe(plain,badfn,retained))),
   p114st_row("witness-invalid-raw-miss-original-refusal",p142wt_equivalent(plain,badraw,fresh) && Bool.not(p142wt_valid(p142wt_observe(plain,badraw,fresh)))),
   p114st_row("witness-raw-before-static-refusal",p142wt_equivalent(plain,badboth,fresh) && Bool.not(p142wt_valid(p142wt_observe(plain,badboth,fresh)))),
   p114st_row("witness-failed-old-judgment-has-no-authority",p142wt_equivalent(badraw,plain,retained) && p142wt_counts(p142wt_observe(badraw,plain,retained),0,0,0)),
   p114st_row("witness-entry-wrapper-exact",p140v_segment(p111_segment("main",[],0,0,[N111Return{N111Const{7,0}}]),N111Segment{"main",0,1,0,0,[N111Alloca{"scratch",2048,8},N111Return{N111Const{7,0}}]}))]
