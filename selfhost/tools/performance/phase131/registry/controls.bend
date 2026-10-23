@unsafe
def p131rg_row(+name: String, ok: Bool) -> String:
  name ++ nt_choose(String,ok,u => ":pass",u => ":FAIL")

# Exercise both classifier polarities; malformed frame calls conservatively
# retain the original scan. The control emitter is an observation, not a
# universal structural proof; complete real-request QBE equality remains a gate.
@unsafe
def p131rg_observe(scan: P112FusionBody) -> String:
  match scan:
    case P112FusionBody{body,count,site}:
      U32.show(count) ++ "/" ++ U32.show(site) ++ "/" ++
      p111q_body_text(p111q_stmts(body,N111Ids{missing(),missing()},P111QCode{[],0,False{},""}))

@unsafe
def p131rg_same(+body: List<&2,N111Stmt>, +site: U32) -> Bool:
  +index = p112f_index([])
  String.eq(p131rg_observe(p131rg_scan(body,index,missing(),site)),
    p131rg_observe(p112c_scan(body,index,missing(),site)))

@unsafe
def p131rg_controls() -> List<&2,String>:
  +ret : N111Stmt = N111Return{N111Const{0,0}}
  +scalar : N111Stmt = N111Set{"x",N111U64{},N111Const{17,0}}
  +frame : N111Stmt = N111Call{"f",N111U64{},"p111_rt_frame",[]}
  +other : N111Stmt = N111Call{"f",N111U64{},"p111_rt_frame_suffix",[]}
  +plain : List<&2,N111Stmt> = [scalar,ret]
  +nested : List<&2,N111Stmt> = [N111If{N111Const{1,0},[scalar],[other]},ret]
  +yes_frame : List<&2,N111Stmt> = [N111If{N111Const{1,0},[frame],[scalar]},ret]
  +no_frame : List<&2,N111Stmt> = [N111If{N111Const{1,0},[scalar],[frame]},ret]
  +tail_frame : List<&2,N111Stmt> = [N111If{N111Const{1,0},[scalar],[scalar]},frame,ret]
  [p131rg_row("registry-empty-admitted",p131rg_no_frame([])),
   p131rg_row("registry-scalar-admitted",p131rg_no_frame(plain)),
   p131rg_row("registry-nested-admitted",p131rg_no_frame(nested)),
   p131rg_row("registry-exact-frame-refused",Bool.not(p131rg_no_frame([frame,ret]))),
   p131rg_row("registry-prefix-not-frame",p131rg_no_frame([other,ret])),
   p131rg_row("registry-yes-frame-refused",Bool.not(p131rg_no_frame(yes_frame))),
   p131rg_row("registry-no-frame-refused",Bool.not(p131rg_no_frame(no_frame))),
   p131rg_row("registry-tail-frame-refused",Bool.not(p131rg_no_frame(tail_frame))),
   p131rg_row("registry-empty-metadata",p131rg_same([],7)),
   p131rg_row("registry-scalar-observation",p131rg_same(plain,0)),
   p131rg_row("registry-nested-observation",p131rg_same(nested,3)),
   p131rg_row("registry-site-limit-observation",p131rg_same(plain,8)),
   p131rg_row("registry-frame-fallback-observation",p131rg_same([frame,ret],0)),
   p131rg_row("registry-nested-frame-fallback",p131rg_same(tail_frame,0))]
