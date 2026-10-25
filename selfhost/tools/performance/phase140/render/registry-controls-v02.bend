# Registry controls compare complete results to the unchanged p112c_index.
# The tiny transition shapes are derived from the frozen Phase112 region-multi
# controls: scratch allocation, runtime return/jump, and incoming continuation.

@unsafe
def p140gc_return(value: N111Value) -> List<&2,N111Stmt>:
  [N111Store{N111U64{},N111Local{"scratch"},0,value},
   N111Call{"reply",N111U64{},"p111_rt_return",[N111Arg{N111Ptr{},N111Local{"state"}},
     N111Arg{N111Ptr{},N111Local{"scratch"}},N111Arg{N111U32{},N111Const{1,0}}]},
   N111Return{N111Local{"reply"}}]

@unsafe
def p140gc_leaf(name: String, value: U32) -> N111Segment:
  N111Segment{name,0,1,0,0,Con{N111Alloca{"scratch",2048,8},p140gc_return(N111Const{value,0})}}

@unsafe
def p140gc_jump(name: String) -> List<&2,N111Stmt>:
  [N111Call{"reply",N111U64{},"p111_rt_jump",[N111Arg{N111Ptr{},N111Local{"state"}},
     N111Arg{N111U32{},N111FuncId{name}},N111Arg{N111Ptr{},N111Local{"scratch"}},
     N111Arg{N111U32{},N111Const{0,0}}]},N111Return{N111Local{"reply"}}]

@unsafe
def p140gc_caller(name: String, target: String) -> N111Segment:
  N111Segment{name,0,1,0,0,Con{N111Alloca{"scratch",2048,8},p140gc_jump(target)}}

@unsafe
def p140gc_frame() -> N111Segment:
  N111Segment{"main",0,1,0,0,
    Con{N111Alloca{"scratch",2048,8},Con{p140rc_frame("continuation"),p140gc_jump("leaf")}}}

@unsafe
def p140gc_continuation(value: U32) -> N111Segment:
  N111Segment{"continuation",1,1,1,0,
    Con{N111Alloca{"scratch",2048,8},Con{
      N111Call{"result",N111U64{},"p111_rt_reg_get",
        [N111Arg{N111Ptr{},N111Local{"state"}},N111Arg{N111U32{},N111Const{0,0}}]},
      p140gc_return(N111Const{value,0})}}}

@unsafe
def p140gc_registry(a: P112RegionRegistry, b: P112RegionRegistry) -> Bool:
  match a b:
    case P112RegionRegistry{ar,as,ae,aw,af} P112RegionRegistry{br,bs,be,bw,bf}:
      p140r_def(ar,br) && p140r_def(as,bs) && p134v_list(P112RegionEntry,p140r_legacy,ae,be) &&
        U32.is_eq(aw,bw) && U32.is_eq(af,bf)

@unsafe
def p140gc_result(+segments: List<&2,N111Segment>, result: P140GResult, +require_hit: Bool) -> Bool:
  match result:
    case P140GResult{registry,passes,hits,misses}:
      p140gc_registry(registry,p112c_index(segments)) && U32.is_le(nt_count(P140GPass,passes),6) &&
        nt_choose(Bool,require_hit,u => U32.is_gt(hits,0),u => True{})

@unsafe
def p140gc_cold(+segments: List<&2,N111Segment>) -> Bool:
  p140gc_result(segments,p140g_index(segments,p112f_index(segments),P140GCache{[]}),False{})

@unsafe
def p140gc_warm_next(+segments: List<&2,N111Segment>, require_hit: Bool, old: P140GResult) -> Bool:
  match old:
    case P140GResult{registry,passes,hits,misses}:
      p140gc_result(segments,p140g_index(segments,p112f_index(segments),P140GCache{passes}),require_hit)

@unsafe
def p140gc_warm(+old: List<&2,N111Segment>, current: List<&2,N111Segment>, require_hit: Bool) -> Bool:
  p140gc_warm_next(current,require_hit,p140g_index(old,p112f_index(old),P140GCache{[]}))

@unsafe
def p140gc_chain(+count: U32, +at: U32) -> List<&2,N111Segment>:
  nt_choose(List<&2,N111Segment>,U32.is_eq(count,0),u => [],u =>
    Con{nt_choose(N111Segment,U32.is_eq(count,1),v => p140gc_leaf("c" ++ U32.show(at),7),
      v => p140gc_caller("c" ++ U32.show(at),"c" ++ U32.show(U32.inc(at)))),
      p140gc_chain(U32.sub(count,1),U32.inc(at))})

@unsafe
def p140gc_six_result(result: P140GResult) -> Bool:
  match result:
    case P140GResult{P112RegionRegistry{ready,symbols,entries,workers,fusions},passes,hits,misses}:
      U32.is_eq(workers,6) && U32.is_eq(nt_count(P140GPass,passes),6)

@unsafe
def p140gc_six() -> Bool:
  +segments: List<&2,N111Segment> = p140gc_chain(8,0)
  p140gc_six_result(p140g_index(segments,p112f_index(segments),P140GCache{[]}))

@unsafe
def p140gc_zero() -> Bool:
  +registry: P112RegionRegistry = P112RegionRegistry{missing(),missing(),[],0,0}
  p140gc_zero_result(registry,p140g_passes([],P112FusionEmpty{},registry,1,0,[],[],0,0))

@unsafe
def p140gc_zero_result(registry: P112RegionRegistry, result: P140GResult) -> Bool:
  match result:
    case P140GResult{actual,passes,hits,misses}:
      p140gc_registry(actual,registry) && U32.is_eq(nt_count(P140GPass,passes),0) &&
        U32.is_eq(hits,0) && U32.is_eq(misses,0)

@unsafe
def p140gc_prepared(+plan: P134EmissionPlan, result: P140GPrepared) -> Bool:
  match result:
    case P140GPrepared{cursor,cache,hits,misses}:
      p134ec_chunks(p134e_collect_cursor(cursor,[],[]),p134e_collect_cursor(p134e_begin(plan),[],[]))

@unsafe
def p140gc_prepare_cold(+plan: P134EmissionPlan) -> Bool:
  p140gc_prepared(plan,p140g_prepare(plan,P140GCache{[]}))

@unsafe
def p140gc_prepare_warm_next(+plan: P134EmissionPlan, old: P140GPrepared) -> Bool:
  match old:
    case P140GPrepared{cursor,cache,hits,misses}: p140gc_prepared(plan,p140g_prepare(plan,cache))

@unsafe
def p140gc_prepare_warm(+plan: P134EmissionPlan) -> Bool:
  p140gc_prepare_warm_next(plan,p140g_prepare(plan,P140GCache{[]}))

@unsafe
def p140gc_controls() -> List<&2,String>:
  +leaf: N111Segment = p140gc_leaf("leaf",7)
  +caller: N111Segment = p140gc_caller("main","leaf")
  +frame: N111Segment = p140gc_frame()
  +cont: N111Segment = p140gc_continuation(7)
  +program: P111Program = p134ec_program()
  +raw: P134EmissionPlan = P134Raw{program}
  +static: P134EmissionPlan = P134Static{P112StaticProgram{program,[]}}
  +direct: P134EmissionPlan = P134Direct{P113DProgram{P112StaticProgram{program,[]},[p134ec_function()]}}
  [p128bs_control_row("registry-empty-exact",p140gc_cold([])),
   p128bs_control_row("registry-leaf-cold-exact",p140gc_cold([leaf])),
   p128bs_control_row("registry-leaf-warm-hit-exact",p140gc_warm([leaf],[leaf],True{})),
   p128bs_control_row("registry-next-pass-caller-cold-exact",p140gc_cold([caller,leaf])),
   p128bs_control_row("registry-next-pass-caller-warm-hit-exact",p140gc_warm([caller,leaf],[caller,leaf],True{})),
   p128bs_control_row("registry-candidate-edit-exact",p140gc_warm([caller,leaf],[caller,p140gc_leaf("leaf",8)],False{})),
   p128bs_control_row("registry-candidate-order-change-exact",p140gc_warm([caller,leaf],[leaf,caller],False{})),
   p128bs_control_row("registry-ready-view-changed-exact",p140gc_warm([caller,leaf],[caller,p140gc_leaf("other",7)],False{})),
   p128bs_control_row("registry-frame-cold-exact",p140gc_cold([frame,leaf,cont])),
   p128bs_control_row("registry-frame-warm-hit-exact",p140gc_warm([frame,leaf,cont],[frame,leaf,cont],True{})),
   p128bs_control_row("registry-continuation-edit-exact",p140gc_warm([frame,leaf,cont],[frame,leaf,p140gc_continuation(8)],False{})),
   p128bs_control_row("registry-continuation-removed-exact",p140gc_warm([frame,leaf,cont],[frame,leaf],False{})),
   p128bs_control_row("registry-continuation-added-exact",p140gc_warm([frame,leaf],[frame,leaf,cont],False{})),
   p128bs_control_row("registry-six-pass-limit-independent",p140gc_six()),
   p128bs_control_row("registry-six-pass-cold-exact",p140gc_cold(p140gc_chain(8,0))),
   p128bs_control_row("registry-six-pass-warm-hit-exact",p140gc_warm(p140gc_chain(8,0),p140gc_chain(8,0),True{})),
   p128bs_control_row("registry-zero-pass-identity",p140gc_zero()),
   p128bs_control_row("registry-raw-preparation-exact",p140gc_prepare_cold(raw)),
   p128bs_control_row("registry-static-preparation-exact",p140gc_prepare_cold(static)),
   p128bs_control_row("registry-direct-preparation-exact",p140gc_prepare_cold(direct)),
   p128bs_control_row("registry-warm-preparation-exact",p140gc_prepare_warm(raw))]
