# Direct placement controls: retain all writes, branch joins and Again edges.
# These bypass scalar copy/dead passes so hazards cannot disappear first.
def p190lv_v(name: String) -> N111Value: N111Local{name}
def p190lv_c(n: U32) -> N111Value: N111Const{n,0}
def p190lv_set(name: String, value: N111Value) -> P113DStmt: P113DScalar{N111Set{name,N111U64{},value}}
def p190lv_bin(name: String, op: String, left: N111Value, right: N111Value) -> P113DStmt:
  P113DScalar{N111Bin{name,N111U64{},op,left,right}}

@unsafe
def p190lv_frame(+params: List<&2,String>, +setup: List<&2,P113DStmt>, +body: List<&2,P113DStmt>) -> X181Frame:
  x190_liveness_frame(x181_frame("p190lv",params,nt_append(P113DStmt,setup,body)),params,setup,body)

@unsafe
def p190lv_slot(name: String, frame: X181Frame) -> KDef:
  match frame:
    case X181Frame{slots,bytes,calls,params,symbol}: p111v_get(slots,name)

@unsafe
def p190lv_kind(name: String, frame: X181Frame, kind: String) -> Bool: String.eq(dk(p190lv_slot(name,frame)),kind)

@unsafe
def p190lv_distinct(a: String, b: String, +frame: X181Frame) -> Bool:
  Bool.not(x186_p_same(p190lv_slot(a,frame),p190lv_slot(b,frame)))

@unsafe
def p190lv_abi(params: List<&2,String>, +frame: X181Frame, +position: U32) -> Bool:
  match params:
    case Nil{}: True{}
    case Con{+name,rest}:
      +slot = p190lv_slot(name,frame)
      (Bool.not(String.eq(dk(slot),"X185Transient")) || U32.is_ge(position,x190_l_abi(da(slot)))) &&
        p190lv_abi(rest,frame,U32.inc(position))

def p190lv_loop_setup() -> List<&2,P113DStmt>:
  [p190lv_bin("invariant","add",p190lv_v("seed"),p190lv_c(3))]

def p190lv_loop_body() -> List<&2,P113DStmt>:
  [p190lv_bin("cond","ugt",p190lv_v("n"),p190lv_c(0)),
   P113DIf{p190lv_v("cond"),
     [p190lv_bin("next_n","sub",p190lv_v("n"),p190lv_c(1)),
      p190lv_bin("next_acc","add",p190lv_v("acc"),p190lv_v("invariant")),
      P113DAgain{[p190lv_v("next_n"),p190lv_v("next_acc"),p190lv_v("seed")]}],
     [p190lv_bin("answer","add",p190lv_v("acc"),p190lv_v("invariant")),P113DResult{[p190lv_v("answer")]}]}]

@unsafe
def p190lv_emit_one(+name: String, +params: List<&2,String>, +setup: List<&2,P113DStmt>, +body: List<&2,P113DStmt>) -> X181Output:
  x185_function_frame(name,setup,body,N111Ids{missing(),missing()},
    x190_liveness_frame(x181_frame(name,params,nt_append(P113DStmt,setup,body)),params,setup,body))

def p190lv_dead_setup() -> List<&2,P113DStmt>:
  [p190lv_set("keep",p190lv_v("seed")),p190lv_set("dead",p190lv_c(91))]

def p190lv_dead_body() -> List<&2,P113DStmt>:
  [p190lv_bin("value","add",p190lv_v("keep"),p190lv_c(1)),
   p190lv_set("dead",p190lv_c(7)),p190lv_bin("answer","add",p190lv_v("value"),p190lv_v("dead")),
   P113DResult{[p190lv_v("answer")]}]

# The old full-width source survives a narrowed producer, so its home must
# differ even when both names come from the same source at this instruction.
def p190lv_incoming_body() -> List<&2,P113DStmt>:
  [p190lv_set("unused",p190lv_c(1)),p190lv_bin("answer","add",p190lv_v("keep"),p190lv_v("unused")),
   P113DResult{[p190lv_v("answer")]}]

def p190lv_narrow_body() -> List<&2,P113DStmt>:
  [P113DScalar{N111Set{"small",N111U32{},p190lv_v("wide")}},
   p190lv_bin("answer","xor",p190lv_v("wide"),p190lv_v("small")),P113DResult{[p190lv_v("answer")]}]

# Branch arms define the same local; the incoming seed remains live at join.
def p190lv_branch_body() -> List<&2,P113DStmt>:
  [P113DIf{p190lv_v("pick"),
     [p190lv_bin("value","add",p190lv_v("seed"),p190lv_c(11))],
     [p190lv_bin("value","xor",p190lv_v("seed"),p190lv_c(53))]},
   p190lv_bin("answer","add",p190lv_v("value"),p190lv_v("seed")),P113DResult{[p190lv_v("answer")]}]

def p190lv_call_body() -> List<&2,P113DStmt>:
  [p190lv_set("live",p190lv_c(41)),
   P113DScalar{N111Call{"result",N111U64{},"p190lv_clobber",[N111Arg{N111U64{},p190lv_v("arg")}]}},
   p190lv_bin("answer","add",p190lv_v("live"),p190lv_v("result")),P113DResult{[p190lv_v("answer")]}]

# A terminal cold call arm has no live continuation through its clobber.
def p190lv_cold_setup() -> List<&2,P113DStmt>:
  [P113DIf{p190lv_v("pick"),
    [P113DScalar{N111Call{"cold",N111U64{},"p190lv_clobber",[N111Arg{N111U64{},p190lv_v("seed")}]}},P113DResult{[p190lv_v("cold")]}],
    [p190lv_bin("invariant","add",p190lv_v("seed"),p190lv_c(7))]}]

@unsafe
def p190lv_row(name: String, ok: Bool) -> String: name ++ "=" ++ nt_choose(String,ok,u => "1",u => "0")

@unsafe
def p190lv_controls() -> List<&2,String>:
  +loop = p190lv_frame(["state","n","acc","seed"],p190lv_loop_setup(),p190lv_loop_body())
  +dead = p190lv_frame(["state","seed"],p190lv_dead_setup(),p190lv_dead_body())
  +call = p190lv_frame(["state","arg"],[],p190lv_call_body())
  +incoming = p190lv_frame(["state","keep","unused"],[],p190lv_incoming_body())
  +narrow = p190lv_frame(["state","wide"],[],p190lv_narrow_body())
  +cold = p190lv_frame(["state","pick","seed"],p190lv_cold_setup(),[P113DResult{[p190lv_v("invariant")]}])
  [p190lv_row("loop-invariant-register",p190lv_kind("invariant",loop,"X185Transient")),
   p190lv_row("loop-invariant-preserved",p190lv_distinct("invariant","next_n",loop) && p190lv_distinct("invariant","next_acc",loop)),
   p190lv_row("incoming-abi",p190lv_abi(["state","n","acc","seed"],loop,0)),
   p190lv_row("dead-write-interference",p190lv_distinct("keep","dead",dead)),
   p190lv_row("call-crossing-stack",p190lv_kind("live",call,"X181Stack")),
   p190lv_row("call-result-register",p190lv_kind("result",call,"X185Transient")),
   p190lv_row("cold-terminal-call",p190lv_kind("invariant",cold,"X185Transient")),
   p190lv_row("dead-incoming-interference",p190lv_distinct("keep","unused",incoming)),
   p190lv_row("narrow-source-live",p190lv_distinct("wide","small",narrow)),
   p190lv_row("checker-reject-edge",Bool.not(x190_l_valid(["a","b"],[2,1],[],1,[3,0,0,0,0]))),
   p190lv_row("checker-reject-duplicate",Bool.not(x190_l_valid(["a"],[0],[],1,[1,1,0,0,0]))),
   p190lv_row("checker-reject-incoming",Bool.not(x190_l_valid(["a"],[0],["state","a"],1,[0,0,0,0,1]))),
   p190lv_row("checker-reject-call-crossing",Bool.not(x190_l_valid(["a"],[1],[],1,[1,0,0,0,0]))),
   p190lv_row("checker-accept",x190_l_valid(["a","b"],[2,1],[],1,[1,2,0,0,0]))]

@unsafe
def p190lv_outputs() -> List<&2,X181Output>:
  [p190lv_emit_one("p190lv_loop",["state","n","acc","seed"],p190lv_loop_setup(),p190lv_loop_body()),
   p190lv_emit_one("p190lv_dead",["state","seed"],p190lv_dead_setup(),p190lv_dead_body()),
   p190lv_emit_one("p190lv_narrow",["state","wide"],[],p190lv_narrow_body()),
   p190lv_emit_one("p190lv_branch",["state","pick","seed"],[],p190lv_branch_body()),
   p190lv_emit_one("p190lv_incoming",["state","keep","unused"],[],p190lv_incoming_body()),
   p190lv_emit_one("p190lv_call",["state","arg"],[],p190lv_call_body()),
   p190lv_emit_one("p190lv_cold",["state","pick","seed"],p190lv_cold_setup(),[P113DResult{[p190lv_v("invariant")]}])]

@unsafe
def p190lv_render(outputs: List<&2,X181Output>) -> List<&2,String>:
  match outputs:
    case Nil{}: []
    case Con{X181Output{chunks,+error},rest}:
      Con{nt_choose(String,String.is_empty(error),u => x188_render(x188_many(chunks)),u => ".error \"" ++ error ++ "\"\n"),p190lv_render(rest)}

def p190lv_assembly() -> List<&2,String>: p190lv_render(p190lv_outputs())
