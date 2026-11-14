# Independent forced-home machine witnesses. Root owns checked acquisition and execution.
def p195pm_v(name: String) -> N111Value: N111Local{name}
def p195pm_c(value: U32) -> N111Value: N111Const{value,0}
def p195pm_bin(name: String, op: String, left: N111Value, right: N111Value) -> P113DStmt:
  P113DScalar{N111Bin{name,N111U64{},op,left,right}}

def p195pm_symbol(mode: U32) -> String: "p195pm_" ++ U32.show(mode)

def p195pm_params(mode: U32) -> List<&2,String>:
  match mode:
    case 0: ["state","a","b","fourth","n"]
    case 1: ["state","n","a","b"]
    case 4: ["state","count","other","value"]
    case 6: ["state","value","count","keep"]
    case _: ["state","value","other","count"]

def p195pm_names(mode: U32) -> List<&2,String>:
  match mode:
    case 0: ["fourth","carry"]
    case 1: ["a","b"]
    case 2: ["value","count","result"]
    case 3: ["value","count","result"]
    case 4: ["value","result"]
    case 5: ["result"]
    case _: ["keep","result"]

def p195pm_groups(mode: U32) -> List<&2,U32>:
  match mode:
    case 0: [0,0,0,0,0,0,0,0,0,1,2]
    case 1: [0,0,0,0,0,0,0,0,0,2,1]
    case 2: [0,0,0,0,0,0,0,0,0,2,5]
    case 3: [0,0,0,0,0,0,0,0,0,2,5]
    case 4: [0,0,0,0,0,0,0,0,0,1,2]
    case 5: [0,0,0,0,0,0,0,0,0,1,0]
    case _: [0,0,0,0,0,0,0,0,0,1,2]

def p195pm_call_body() -> List<&2,P113DStmt>:
  [p195pm_bin("carry","add",p195pm_v("a"),p195pm_v("fourth")),
   P113DScalar{N111Call{"answer",N111U64{},"p195pm_effect",[
     N111Arg{N111Ptr{},p195pm_v("state")},N111Arg{N111U64{},p195pm_v("carry")},
     N111Arg{N111U64{},p195pm_v("fourth")}] }},
   P113DScalar{N111Load{"stamp",N111U64{},p195pm_v("state"),8}},
   p195pm_bin("sum","add",p195pm_v("carry"),p195pm_v("answer")),
   p195pm_bin("sum","add",p195pm_v("sum"),p195pm_v("stamp")),
   P113DScalar{N111Store{N111U64{},p195pm_v("state"),16,p195pm_v("sum")}},
   P113DResult{[p195pm_v("sum")]}]

def p195pm_loop_body() -> List<&2,P113DStmt>:
  [p195pm_bin("done","eq",p195pm_v("n"),p195pm_c(0)),
   P113DIf{p195pm_v("done"),
     [p195pm_bin("result","mul",p195pm_v("b"),p195pm_c(3)),
      p195pm_bin("result","add",p195pm_v("result"),p195pm_v("a")),
      P113DScalar{N111Load{"stamp",N111U64{},p195pm_v("state"),0}},
      p195pm_bin("result","add",p195pm_v("result"),p195pm_v("stamp")),
      P113DResult{[p195pm_v("result")]}],
     [p195pm_bin("n","sub",p195pm_v("n"),p195pm_c(1)),
      P113DAgain{[p195pm_v("n"),p195pm_v("b"),p195pm_v("a")]}]}]

@unsafe
def p195pm_shift_body(+mode: U32) -> List<&2,P113DStmt>:
  Con{P113DScalar{N111Bin{"result",nt_choose(N111Type,U32.is_eq(mode,3),u => N111U32{},u => N111U64{}),
    nt_choose(String,U32.is_eq(mode,4),u => "shr",u => "shl"),p195pm_v("value"),p195pm_v("count")}},
    nt_choose(List<&2,P113DStmt>,U32.is_eq(mode,6),
      u => [p195pm_bin("result","xor",p195pm_v("result"),p195pm_v("keep")),P113DResult{[p195pm_v("result")]}],
      u => [P113DResult{[p195pm_v("result")]}])}

def p195pm_body(mode: U32) -> List<&2,P113DStmt>:
  match mode:
    case 0: p195pm_call_body()
    case 1: p195pm_loop_body()
    case _: p195pm_shift_body(mode)

@unsafe
def p195pm_ids(names: List<&2,String>, +bit: U32, +ids: KDef) -> KDef:
  match names:
    case Nil{}: ids
    case Con{name,rest}: p195pm_ids(rest,U32.shl(bit),p111v_put(ids,name,"X190LBit",bit,0))

# Force only the requested colors, but derive their real graph and shift mask
# from these exact bodies before the production candidate validator installs them.
@unsafe
def p195pm_graphed(frame: X181Frame, params: List<&2,String>, +body: List<&2,P113DStmt>,
    names: List<&2,String>, groups: List<&2,U32>, shifts: U32, flow: X190LFlow) -> X181Frame:
  match flow:
    case X190LFlow{live,rows}: x195_p_checked(frame,params,[],body,body,names,rows,groups,shifts)

@unsafe
def p195pm_solved(+frame: X181Frame, +params: List<&2,String>, +body: List<&2,P113DStmt>,
    +names: List<&2,String>, +ids: KDef, groups: List<&2,U32>, +parameters: U32,
    fixed: X190LFixed) -> X181Frame:
  match fixed:
    case X190LFixed{+header,ready}:
      nt_choose(X181Frame,ready,
        u => p195pm_graphed(frame,params,body,names,groups,
          x195_p_shifts(body,0,X190LEnv{ids,parameters,header,False{}},0),
          x190_l_incoming(params,x190_l_body(body,X190LFlow{0,x190_l_zeros(names)},
            X190LEnv{ids,parameters,header,True{}}),X190LEnv{ids,parameters,header,True{}})),u => frame)

@unsafe
def p195pm_frame(+mode: U32) -> X181Frame:
  +params = p195pm_params(mode)
  +body = p195pm_body(mode)
  +names = p195pm_names(mode)
  +ids = p195pm_ids(names,1,missing())
  +frame = x181_frame(p195pm_symbol(mode),params,body)
  +parameters = x190_l_names(x181_tail_args(frame),ids)
  p195pm_solved(frame,params,body,names,ids,p195pm_groups(mode),parameters,x190_l_fixed(body,ids,parameters,0,33))

@unsafe
def p195pm_home(frame: X181Frame, name: String, kind: String, home: U32) -> Bool:
  match frame:
    case X181Frame{slots,bytes,calls,params,symbol}:
      +slot = p111v_get(slots,name)
      String.eq(dk(slot),kind) && U32.is_eq(da(slot),home) && U32.is_eq(dx(slot),8)

def p195pm_state_stack(frame: X181Frame) -> Bool:
  match frame:
    case X181Frame{slots,bytes,calls,params,symbol}:
      +slot = p111v_get(slots,"state")
      String.eq(dk(slot),"X181Stack") && U32.is_eq(da(slot),bytes) && U32.is_eq(dx(slot),8)

def p195pm_refused(plan: Maybe<&2,X188Seq>) -> Bool:
  match plan:
    case None{}: True{}
    case Some{code}: False{}

def p195pm_snapshot(plan: X186CallPlan) -> Bool:
  match plan:
    case X186CallPlan{kind,count}: U32.is_eq(kind,2) && U32.is_eq(count,3)

@unsafe
def p195pm_row(label: String, pass: Bool) -> String:
  label ++ "=" ++ nt_choose(String,pass,u => "1",u => "0")

@unsafe
def p195pm_controls() -> List<&2,String>:
  [p195pm_row("calls-fourth-rcx",p195pm_home(p195pm_frame(0),"fourth","X185Transient",5)),
   p195pm_row("calls-carry-r12",p195pm_home(p195pm_frame(0),"carry","X181Register",0)),
   p195pm_row("calls-state-stack",p195pm_state_stack(p195pm_frame(0))),
   p195pm_row("calls-rcx-argument-snapshot",p195pm_snapshot(x186_call_plan([
     N111Arg{N111Ptr{},p195pm_v("state")},N111Arg{N111U64{},p195pm_v("carry")},
     N111Arg{N111U64{},p195pm_v("fourth")}],p195pm_frame(0)))),
   p195pm_row("again-a-r12",p195pm_home(p195pm_frame(1),"a","X181Register",0)),
   p195pm_row("again-b-rcx",p195pm_home(p195pm_frame(1),"b","X185Transient",5)),
   p195pm_row("again-cycle-snapshot",p195pm_refused(x186_parallel(["n","a","b"],
     [p195pm_v("n"),p195pm_v("b"),p195pm_v("a")],N111Ids{missing(),missing()},p195pm_frame(1)))),
   p195pm_row("right64-count-rcx",p195pm_home(p195pm_frame(2),"count","X185Transient",5)),
   p195pm_row("right64-result-r12",p195pm_home(p195pm_frame(2),"result","X181Register",0)),
   p195pm_row("right32-count-rcx",p195pm_home(p195pm_frame(3),"count","X185Transient",5)),
   p195pm_row("right32-result-r12",p195pm_home(p195pm_frame(3),"result","X181Register",0)),
   p195pm_row("left64-value-rcx",p195pm_home(p195pm_frame(4),"value","X185Transient",5)),
   p195pm_row("left64-result-r12",p195pm_home(p195pm_frame(4),"result","X181Register",0)),
   p195pm_row("shift-destination-rcx-refused",Bool.not(p195pm_home(p195pm_frame(5),"result","X185Transient",5))),
   p195pm_row("shift-liveout-rcx-refused",Bool.not(p195pm_home(p195pm_frame(6),"keep","X185Transient",5))),
   p195pm_row("refusals-retain-state",p195pm_home(p195pm_frame(5),"state","X181Register",0) &&
     p195pm_home(p195pm_frame(6),"state","X181Register",0))]

@unsafe
def p195pm_emit_modes(+mode: U32) -> X181Output:
  nt_choose(X181Output,U32.is_eq(mode,7),u => X181Output{[],""},u =>
    x181_program_join(x185_function_frame(p195pm_symbol(mode),[],p195pm_body(mode),
      N111Ids{missing(),missing()},p195pm_frame(mode)),p195pm_emit_modes(U32.inc(mode))))

def p195pm_emit() -> X181Output: p195pm_emit_modes(0)
