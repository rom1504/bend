@unsafe
def p198h_ids() -> N111Ids: N111Ids{p111q_insert(missing(),"target",7),missing()}

@unsafe
def p198h_call(+fid: String, +count: U32) -> N111Stmt:
  N111Call{"status",N111U64{},"p111_rt_jump",[
    N111Arg{N111Ptr{},N111Local{"state"}},N111Arg{N111U32{},N111FuncId{fid}},
    N111Arg{N111Ptr{},N111Local{"scratch"}},N111Arg{N111U32{},N111Const{count,0}}]}

@unsafe
def p198h_body(+fid: String, +count: U32) -> List<&2,P113DStmt>:
  p198h_expanded(p186rt_expand(p198h_call(fid,count),p198h_ids(),0))

@unsafe
def p198h_expanded(expansion: P114TExpansion) -> List<&2,P113DStmt>:
  match expansion:
    case P114TExpansion{body,changed}:
      match body:
        case Con{a,Con{b,Con{branch,Nil{}}}}: [x181_scalar_row(branch),P113DScalar{N111Return{N111Local{"status"}}}]
        case _: []

@unsafe
def p198h_frame(symbol: String, params: List<&2,String>) -> X181Frame: X181Frame{missing(),0,0,params,symbol}

@unsafe
def p198h_admit(body: List<&2,P113DStmt>, ids: N111Ids, frame: X181Frame) -> Bool:
  p198h_has_target(x198h_target(body,ids,frame))

@unsafe
def p198h_has_target(target: Maybe<&2,String>) -> Bool:
  match target:
    case Some{fid}: True{}
    case None{}: False{}

@unsafe
def p198h_row(label: String, yes: Bool) -> String: label ++ nt_choose(String,yes,u => "=1",u => "=0")

@unsafe
def p198h_controls() -> List<&2,String>:
  +ids = p198h_ids()
  +frame = p198h_frame("p111_FID_source",["state"])
  +body = p198h_body("target",2)
  [p198h_row("static-zero",p198h_admit(p198h_body("target",0),ids,frame)),
   p198h_row("static-eight",p198h_admit(p198h_body("target",8),ids,frame)),
   p198h_row("nine-refused",Bool.not(p198h_admit(p198h_body("target",9),ids,frame))),
   p198h_row("unknown-fid-refused",Bool.not(p198h_admit(body,N111Ids{missing(),missing()},frame))),
   p198h_row("runtime-fid-refused",Bool.not(p198h_admit(body,N111Ids{p111q_insert(missing(),"target",65532),missing()},frame))),
   p198h_row("worker-abi-refused",Bool.not(p198h_admit(body,ids,p198h_frame("p113d_FID_source",["state"])))),
   p198h_row("extra-params-refused",Bool.not(p198h_admit(body,ids,p198h_frame("p111_FID_source",["state","arg"])))),
   p198h_row("foreign-state-refused",Bool.not(p198h_admit(body,ids,p198h_frame("p111_FID_source",["other"])))),
   p198h_row("unpaired-call-refused",Bool.not(p198h_admit([P113DScalar{p198h_call("target",2)}],ids,frame))),
   p198h_row("post-return-work-refused",Bool.not(p198h_admit(nt_append(P113DStmt,body,[P113DScalar{N111Set{"after",N111U64{},N111Const{0,0}}}]),ids,frame))),
   p198h_row("wrong-finish-fid-refused",Bool.not(x198h_finish(x181_scalar_rows(p186rt_jump("status","other")),"status","target"))),
   p198h_row("wrong-finish-result-refused",Bool.not(x198h_finish(x181_scalar_rows(p186rt_jump("other","target")),"status","target"))),
   p198h_row("missing-finish-refused",Bool.not(x198h_finish([],"status","target")))]

@unsafe
def p198h_emit_wrap(result: X181Output) -> X181Output:
  match result:
    case X181Output{chunks,error}: X181Output{nt_append(X188Seq,[X188One{PSection{1}}],nt_append(X188Seq,chunks,[X188One{PSection{4}}])),error}

@unsafe
def p198h_emit() -> X181Output:
  p198h_emit_wrap(x181_function("p111_FID_source",["state"],x181_scalar_rows([
    N111Alloca{"scratch",16,8},
    N111Load{"first",N111U64{},N111Local{"state"},40},
    N111Load{"second",N111U64{},N111Local{"state"},48},
    N111Store{N111U64{},N111Local{"scratch"},0,N111Local{"second"}},
    N111Store{N111U64{},N111Local{"scratch"},8,N111Local{"first"}},
    p198h_call("target",2),N111Return{N111Local{"status"}}]),p198h_ids()))
