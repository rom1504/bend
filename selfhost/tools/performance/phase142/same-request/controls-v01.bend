# Independent controls for SAME-request judgment transport. Prior judgments are
# returned by the original checker. Changed-original fixtures enter diagnostic
# mode only; invalid IR is inspected, never emitted/executed.
def p142srt_original(value: U32, flags: U32, nodes: List<&2,P112SNode>, effects: List<&2,String>) -> P112StaticProgram:
  P112StaticProgram{P111Program{[N111Segment{"main",0,1,0,flags,[N111Return{N111Const{value,0}}]}],
    [N_Constructor{"Box",1,True{}}],[0],["display"],effects,True{}},nodes}

def p142srt_array(original: P112StaticProgram, functions: List<&2,P113DFunction>, certificate: P113ACertificate) -> P113AProgram:
  P113AProgram{P113DProgram{original,functions},certificate}

def p142srt_array_cache(result: P140VArrayChecked) -> P140VCache:
  match result:
    case P140VArrayChecked{cache,error,counts}: cache

@unsafe
def p142srt_cache_same(a: P140VCache, b: P140VCache) -> Bool:
  match a b:
    case P140VEmpty{} P140VEmpty{}: True{}
    case P140VCache{P113DProgram{ao,af},P140VMetadata{afs,acs,ai}}
      P140VCache{P113DProgram{bo,bf},P140VMetadata{bfs,bcs,bi}}:
        p142sr_original(ao,bo) && p134v_list(~P113DFunction,~p134v_function,af,bf) &&
        p140vm_scan(afs,bfs) && p140vm_scan(acs,bcs) && p140vm_ids(ai,bi)
    case _ _: False{}

@unsafe
def p142srt_checked_same(a: P140VArrayChecked, b: P140VArrayChecked) -> Bool:
  match a b:
    case P140VArrayChecked{ac,ae,an} P140VArrayChecked{bc,be,bn}:
      String.eq(ae,be) && p142srt_cache_same(ac,bc)

@unsafe
def p142srt_equivalent(first: P113DProgram, +current: P113AProgram, +previous: P140VCache) -> Bool:
  p142srt_checked_same(p140v_array(current,previous),
    p142sr_array(current,p140vt_cache(p140v_check(first,P140VEmpty{})),previous))

def p142srt_rejected(result: P142SRDiagnostic) -> Bool:
  match result:
    case P142SRDiagnostic{P140VArrayChecked{cache,error,counts},same}:
      Bool.not(same) && p140vt_empty(cache) && String.eq(error,"same-request original conservation mismatch")

@unsafe
def p142srt_changed(first: P113DProgram, current: P113AProgram) -> Bool:
  p142srt_rejected(p142sr_diagnose(current,p140vt_cache(p140v_check(first,P140VEmpty{})),P140VEmpty{}))

# Unlike p134v_boundary_same, compare the complete original AND both ID maps.
@unsafe
def p142srt_preserved(before: P114SBoundary, after: P114SBoundary) -> Bool:
  match before after:
    case P114SBoundary{bo,bi,bf,bv} P114SBoundary{ao,ai,af,av}:
      p142sr_original(bo,ao) && p140vm_ids(bi,ai)

@unsafe
def p142srt_optimized(before: P114SBoundary, after: P134UOptimized) -> Bool:
  match after:
    case P134UOptimized{boundary,cache,stats}: p142srt_preserved(before,boundary)

@unsafe
def p142srt_optimize(+program: P113DProgram, cache: P134UCache) -> Bool:
  +opened = p140vt_opened(p140v_open(program,P140VEmpty{}))
  p142srt_optimized(opened,p134u_optimize(opened,cache))

def p142srt_units(result: P134UOptimized) -> P134UCache:
  match result:
    case P134UOptimized{boundary,cache,stats}: cache

@unsafe
def p142srt_rollback(+program: P113DProgram) -> Bool:
  +opened = p140vt_opened(p140v_open(program,P140VEmpty{}))
  p142srt_preserved(opened,p134v_commit(opened,[p140vt_bad_direct()]))

def p142srt_reserved(+name: String) -> P113DFunction:
  P113DFunction{"reserved",[NC_Binding{0,name,N_W64{}}],1,False{},[P113DResult{[N111Local{name}]}]}

@unsafe
def p142srt_controls() -> List<&2,String>:
  +nodes : List<&2,P112SNode> = [P112SNode{0,"Box",[P112SRaw{7}]}]
  +original = p142srt_original(0,0,nodes,[])
  +first : P113DProgram = P113DProgram{original,[p114st_identity()]}
  +off : P113ACertificate = P113ACertificate{False{},False{}}
  +on : P113ACertificate = P113ACertificate{True{},True{}}
  +current = p142srt_array(original,[p114st_identity()],off)
  +prior = p142srt_array_cache(p140v_array(current,P140VEmpty{}))
  +changed = p142srt_array(original,[p140vt_changed_direct()],off)
  +bad_direct = p142srt_array(original,[p140vt_bad_direct()],off)
  +header = p142srt_array(original,[P113DFunction{"p114_identity",[],1,False{},[P113DResult{[N111Const{3,0}]}]}],off)
  +ordered : P113DProgram = P113DProgram{original,[p114st_scalar(),p114st_pair(),p114st_caller()]}
  +reordered = p142srt_array(original,[p114st_caller(),p114st_pair(),p114st_scalar()],off)
  +bad_original : P112StaticProgram = P112StaticProgram{P111Program{[N111Segment{"main",0,1,0,0,[N111Return{N111Local{"undefined"}}]}],[],[0],[],[],True{}},[]}
  +bad_first : P113DProgram = P113DProgram{bad_original,[]}
  +bad_array = p142srt_array(bad_original,[],off)
  +bad_static = p142srt_original(0,0,[P112SNode{1,"Box",[P112SRaw{7}]}],[])
  +static_first : P113DProgram = P113DProgram{bad_static,[]}
  +array_namespace = p142srt_array(original,[p142srt_reserved("p113a_reserved")],on)
  +transport_namespace = p142srt_array(original,[p142srt_reserved("p114t_reserved")],off)
  +raw_namespace : P112StaticProgram = P112StaticProgram{P111Program{[N111Segment{"main",0,1,0,0,
    [N111Set{"p114t_reserved",N111U64{},N111Const{0,0}},N111Return{N111Local{"p114t_reserved"}}]}],[],[0],[],[],True{}},[]}
  +raw_namespace_first : P113DProgram = P113DProgram{raw_namespace,[]}
  +raw_namespace_array = p142srt_array(raw_namespace,[],off)
  +show_changed : P112StaticProgram = P112StaticProgram{P111Program{[N111Segment{"main",0,1,0,0,[N111Return{N111Const{0,0}}]}],
    [N_Constructor{"Box",1,True{}}],[9],["display"],[],True{}},nodes}
  +show_name_changed : P112StaticProgram = P112StaticProgram{P111Program{[N111Segment{"main",0,1,0,0,[N111Return{N111Const{0,0}}]}],
    [N_Constructor{"Box",1,True{}}],[0],["different"],[],True{}},nodes}
  +pure_changed : P112StaticProgram = P112StaticProgram{P111Program{[N111Segment{"main",0,1,0,0,[N111Return{N111Const{0,0}}]}],
    [N_Constructor{"Box",1,True{}}],[0],["display"],[],False{}},nodes}
  +ctors_changed : P112StaticProgram = P112StaticProgram{P111Program{[N111Segment{"main",0,1,0,0,[N111Return{N111Const{0,0}}]}],
    [N_Constructor{"Box",1,False{}}],[0],["display"],[],True{}},nodes}
  +units = p142srt_units(p134u_optimize(p140vt_opened(p140v_open(ordered,P140VEmpty{})),P134UCache{[],[]}))
  +other_original : P113DProgram = P113DProgram{p142srt_original(9,0,nodes,[]),[p114st_scalar(),p114st_pair(),p114st_caller()]}
  [p114st_row("same-request-original-first-valid",String.is_empty(p113e_verify(first))),
   p114st_row("same-request-cold-second-equivalent",p142srt_equivalent(first,current,P140VEmpty{})),
   p114st_row("same-request-warm-second-cache-equivalent",p142srt_equivalent(first,current,prior)),
   p114st_row("same-request-empty-first-exact-fallback",p142srt_checked_same(p140v_array(current,prior),p142sr_array(current,P140VEmpty{},prior))),
   p114st_row("same-request-failed-raw-first-fallback",p142srt_equivalent(bad_first,bad_array,P140VEmpty{}) && Bool.not(String.is_empty(p140vt_array_error(p140v_array(bad_array,P140VEmpty{}))))),
   p114st_row("same-request-failed-static-first-fallback",p142srt_equivalent(static_first,p142srt_array(bad_static,[],off),P140VEmpty{})),
   p114st_row("same-request-direct-valid-edit",p142srt_equivalent(first,changed,prior)),
   p114st_row("same-request-direct-invalid-edit",p142srt_equivalent(first,bad_direct,prior) && Bool.not(String.is_empty(p140vt_array_error(p140v_array(bad_direct,prior))))),
   p114st_row("same-request-direct-header-edit",p142srt_equivalent(first,header,prior)),
   p114st_row("same-request-direct-forward-order",p142srt_equivalent(ordered,reordered,P140VEmpty{}) && Bool.not(String.is_empty(p140vt_array_error(p140v_array(reordered,P140VEmpty{}))))),
   p114st_row("same-request-array-namespace-remains",p142srt_equivalent(first,array_namespace,prior) && String.eq(p140vt_array_error(p142sr_array(array_namespace,p140vt_cache(p140v_check(first,P140VEmpty{})),prior)),"reserved private array-template local")),
   p114st_row("same-request-direct-transport-namespace-remains",p142srt_equivalent(first,transport_namespace,prior) && String.eq(p140vt_array_error(p142sr_array(transport_namespace,p140vt_cache(p140v_check(first,P140VEmpty{})),prior)),"reserved transport-template local")),
   p114st_row("same-request-raw-transport-namespace-remains",p142srt_equivalent(raw_namespace_first,raw_namespace_array,P140VEmpty{}) && String.eq(p140vt_array_error(p142sr_array(raw_namespace_array,p140vt_cache(p140v_check(raw_namespace_first,P140VEmpty{})),P140VEmpty{})),"reserved transport-template local")),
   p114st_row("same-request-optimizer-cold-original-and-ids",p142srt_optimize(ordered,P134UCache{[],[]})),
   p114st_row("same-request-optimizer-warm-original-and-ids",p142srt_optimize(ordered,units)),
   p114st_row("same-request-optimizer-cache-keeps-current-original",p142srt_optimize(other_original,units)),
   p114st_row("same-request-commit-rollback-keeps-original-and-ids",p142srt_rollback(first)),
   p114st_row("same-request-diagnostic-raw-body-change",p142srt_changed(first,p142srt_array(p142srt_original(9,0,nodes,[]),[p114st_identity()],off))),
   p114st_row("same-request-diagnostic-wrapper-flag-change",p142srt_changed(first,p142srt_array(p142srt_original(0,1,nodes,[]),[p114st_identity()],off))),
   p114st_row("same-request-diagnostic-constructor-change",p142srt_changed(first,p142srt_array(ctors_changed,[p114st_identity()],off))),
   p114st_row("same-request-diagnostic-static-offset-change",p142srt_changed(first,p142srt_array(bad_static,[p114st_identity()],off))),
   p114st_row("same-request-diagnostic-static-word-change",p142srt_changed(first,p142srt_array(p142srt_original(0,0,[P112SNode{0,"Box",[P112SRaw{8}]}],[]),[p114st_identity()],off))),
   p114st_row("same-request-diagnostic-effect-blocking-change",p142srt_changed(first,p142srt_array(p142srt_original(0,0,nodes,["Box"]),[p114st_identity()],off))),
   p114st_row("same-request-diagnostic-show-words-change",p142srt_changed(first,p142srt_array(show_changed,[p114st_identity()],off))),
   p114st_row("same-request-diagnostic-show-names-change",p142srt_changed(first,p142srt_array(show_name_changed,[p114st_identity()],off))),
   p114st_row("same-request-diagnostic-pure-change",p142srt_changed(first,p142srt_array(pure_changed,[p114st_identity()],off)))]
