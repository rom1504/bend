# The original verifier proves call contracts independently of the late
# renderer. Raw machine wrappers exercise only valid ABI11102 transfers.

@unsafe
def p186rc_ids() -> N111Ids:
  N111Ids{p111q_insert(missing(),"target",37),missing()}

@unsafe
def p186rc_jump(state: String, buffer: String, fid: N111Value, count: N111Value, typ: N111Type) -> N111Stmt:
  N111Call{"status",typ,"p111_rt_jump",[N111Arg{N111Ptr{},N111Local{state}},
    N111Arg{N111U32{},fid},N111Arg{N111Ptr{},N111Local{buffer}},N111Arg{N111U32{},count}]}

@unsafe
def p186rc_return(state: String, buffer: String, count: N111Value, typ: N111Type) -> N111Stmt:
  N111Call{"status",typ,"p111_rt_return",[N111Arg{N111Ptr{},N111Local{state}},
    N111Arg{N111Ptr{},N111Local{buffer}},N111Arg{N111U32{},count}]}

@unsafe
def p186rc_call(+jump: Bool, +buffer: String, +count: U32) -> N111Stmt:
  nt_choose(N111Stmt,jump,u => p186rc_jump("state",buffer,N111FuncId{"target"},N111Const{count,0},N111U64{}),
    u => p186rc_return("state",buffer,N111Const{count,0},N111U64{}))

def p186rc_changed(expansion: P114TExpansion) -> Bool:
  match expansion:
    case P114TExpansion{body,changed}: changed

@unsafe
def p186rc_admitted(stmt: N111Stmt, ids: N111Ids, site: U32) -> Bool:
  p186rc_changed(p186rt_expand(stmt,ids,site))

@unsafe
def p186rc_verify_call(call: N111Stmt, live: KDef, ids: N111Ids, result: U32) -> Bool:
  match call:
    case N111Call{dest,typ,symbol,args}: p111v_call(symbol,typ,args,live,ids,0,0,result)
    case _: False{}

@unsafe
def p186rc_verified(+jump: Bool, +count: U32, arity: U32, incoming: U32, result: U32, capacity: U32) -> Bool:
  +ids : N111Ids = N111Ids{p111v_put(missing(),"target","function",arity,incoming),missing()}
  +live = p111v_put(p111v_put(missing(),"state","local",3,0),"scratch","alloca",3,capacity)
  p186rc_verify_call(p186rc_call(jump,"scratch",count),live,ids,result)

@unsafe
def p186rc_text(+stmt: N111Stmt, original: Bool) -> String:
  +ids = p186rc_ids()
  +code : P111QCode = P111QCode{[],0,False{},""}
  +emitted = nt_choose(P111QCode,original,u => p186rt_previous(stmt,ids,code),u => p186rt_stmt(stmt,ids,code))
  p111q_body_text(p186rt_previous(N111Return{N111Local{"status"}},ids,emitted))

@unsafe
def p186rc_row(name: String, +ok: Bool) -> String:
  name ++ nt_choose(String,ok,u => "=1",u => "=0")

@unsafe
def p186rc_controls() -> List<&2,String>:
  +ids = p186rc_ids()
  +jump = p186rc_call(True{},"scratch",2)
  +ret = p186rc_call(False{},"scratch",2)
  +foreign = p186rc_call(True{},"foreign",2)
  +text = p186rc_text(jump,False{})
  [p186rc_row("jump-zero",p186rc_admitted(p186rc_call(True{},"scratch",0),ids,0)),
   p186rc_row("jump-eight",p186rc_admitted(p186rc_call(True{},"scratch",8),ids,0)),
   p186rc_row("return-zero",p186rc_admitted(p186rc_call(False{},"scratch",0),ids,0)),
   p186rc_row("return-eight",p186rc_admitted(p186rc_call(False{},"scratch",8),ids,0)),
   p186rc_row("fusion-scratch",p186rc_admitted(p186rc_call(True{},"p112f_7_local_scratch",2),ids,0)),
   p186rc_row("inline-scratch",p186rc_admitted(p186rc_call(True{},"p113i_0_local_scratch",2),ids,0)),
   p186rc_row("foreign-buffer-refused",Bool.not(p186rc_admitted(foreign,ids,0))),
   p186rc_row("state-buffer-refused",Bool.not(p186rc_admitted(p186rc_call(True{},"state",2),ids,0))),
   p186rc_row("local-continuation-buffer-refused",Bool.not(p186rc_admitted(p186rc_call(False{},"p114h_case_0_local_scratch",2),ids,0))),
   p186rc_row("jump-nine-refused",Bool.not(p186rc_admitted(p186rc_call(True{},"scratch",9),ids,0))),
   p186rc_row("return-nine-refused",Bool.not(p186rc_admitted(p186rc_call(False{},"scratch",9),ids,0))),
   p186rc_row("counter-refused",Bool.not(p186rc_admitted(jump,ids,4294967295))),
   p186rc_row("unknown-fid-refused",Bool.not(p186rc_admitted(jump,N111Ids{missing(),missing()},0))),
   p186rc_row("runtime-fid-refused",Bool.not(p186rc_admitted(jump,N111Ids{p111q_insert(missing(),"target",65532),missing()},0))),
   p186rc_row("numeric-fid-refused",Bool.not(p186rc_admitted(p186rc_jump("state","scratch",N111Const{37,0},N111Const{2,0},N111U64{}),ids,0))),
   p186rc_row("high-count-refused",Bool.not(p186rc_admitted(p186rc_jump("state","scratch",N111FuncId{"target"},N111Const{2,1},N111U64{}),ids,0))),
   p186rc_row("dynamic-count-refused",Bool.not(p186rc_admitted(p186rc_return("state","scratch",N111Local{"count"},N111U64{}),ids,0))),
   p186rc_row("state-identity-refused",Bool.not(p186rc_admitted(p186rc_return("other","scratch",N111Const{2,0},N111U64{}),ids,0))),
   p186rc_row("result-type-refused",Bool.not(p186rc_admitted(p186rc_return("state","scratch",N111Const{2,0},N111Ptr{}),ids,0))),
   p186rc_row("verifier-jump-valid",p186rc_verified(True{},2,2,0,0,2048)),
   p186rc_row("verifier-jump-arity",Bool.not(p186rc_verified(True{},2,3,0,0,2048))),
   p186rc_row("verifier-jump-incoming",Bool.not(p186rc_verified(True{},2,2,1,0,2048))),
   p186rc_row("verifier-jump-capacity",Bool.not(p186rc_verified(True{},2,2,0,0,8))),
   p186rc_row("verifier-return-valid",p186rc_verified(False{},2,0,0,2,2048)),
   p186rc_row("verifier-return-width",Bool.not(p186rc_verified(False{},2,0,0,1,2048))),
   p186rc_row("verifier-return-capacity",Bool.not(p186rc_verified(False{},2,0,0,2,8))),
   p186rc_row("fallback-byte-identity",String.eq(p186rc_text(foreign,False{}),p186rc_text(foreign,True{}))),
   p186rc_row("capability-guard",String.contains(text,"_transfer_live =l and") && String.contains(text,"$p111_program")),
   p186rc_row("jump-fallback-retained",String.contains(text,"call $p111_rt_jump")),
   p186rc_row("return-fallback-retained",String.contains(p186rc_text(ret,False{}),"call $p111_rt_return"))]

@unsafe
def p186rc_oracle_function(name: String, +jump: Bool, +buffer: String, count: U32) -> String:
  "export function l $" ++ name ++ "(l %state, l " ++ p111q_local(buffer) ++ ") {\n@entry\n" ++
    p186rc_text(p186rc_call(jump,buffer,count),False{}) ++ "}\n"

@unsafe
def p186rc_oracle_module() -> String:
  p186rc_oracle_function("p186rt_j0",True{},"scratch",0) ++
  p186rc_oracle_function("p186rt_j1",True{},"scratch",1) ++
  p186rc_oracle_function("p186rt_j2",True{},"scratch",2) ++
  p186rc_oracle_function("p186rt_j8",True{},"scratch",8) ++
  p186rc_oracle_function("p186rt_r0",False{},"scratch",0) ++
  p186rc_oracle_function("p186rt_r1",False{},"scratch",1) ++
  p186rc_oracle_function("p186rt_r2",False{},"scratch",2) ++
  p186rc_oracle_function("p186rt_r8",False{},"scratch",8) ++
  p186rc_oracle_function("p186rt_jforeign",True{},"foreign",2) ++
  p186rc_oracle_function("p186rt_rforeign",False{},"foreign",2)
