# Joint allocator controls reuse the independent scalar/ABI fixtures in
# liveness-controls.bend. The explicit entry ignores the experimental switch.
@unsafe
def p190j_frame(+params: List<&2,String>, +setup: List<&2,P113DStmt>, +body: List<&2,P113DStmt>) -> X181Frame:
  x190_joint_frame(x181_frame("p190j",params,nt_append(P113DStmt,setup,body)),params,setup,body,body)

def p190j_pressure_params() -> List<&2,String>:
  ["state","__x181_result_out","n","a","b","c","d","e","f","g","h"]

def p190j_pressure_body() -> List<&2,P113DStmt>:
  [p190lv_bin("done","eq",p190lv_v("n"),p190lv_c(0)),
   P113DIf{p190lv_v("done"),
     [P113DResult{[p190lv_v("a"),p190lv_v("b"),p190lv_v("c"),p190lv_v("d"),
       p190lv_v("e"),p190lv_v("f"),p190lv_v("g"),p190lv_v("h")]}],
     [p190lv_bin("next","sub",p190lv_v("n"),p190lv_c(1)),
      P113DAgain{[p190lv_v("next"),p190lv_v("b"),p190lv_v("c"),p190lv_v("d"),p190lv_v("e"),
        p190lv_v("f"),p190lv_v("g"),p190lv_v("h"),p190lv_v("a")]}]}]

def p190j_chain() -> List<&2,P113DStmt>:
  [p190lv_bin("a","add",p190lv_v("seed"),p190lv_c(1)),
   p190lv_bin("b","add",p190lv_v("a"),p190lv_c(1)),
   p190lv_bin("c","add",p190lv_v("b"),p190lv_c(1)),P113DResult{[p190lv_v("c")]}]

@unsafe
def p190j_pool(name: String, frame: X181Frame) -> Bool:
  +slot = p190lv_slot(name,frame)
  (String.eq(dk(slot),"X181Register") && U32.is_ge(da(slot),1) && U32.is_le(da(slot),4)) ||
  (String.eq(dk(slot),"X185Transient") && U32.is_lt(da(slot),5))

@unsafe
def p190j_different(+name: String, names: List<&2,String>, +frame: X181Frame) -> Bool:
  match names:
    case Nil{}: True{}
    case Con{other,rest}: p190lv_distinct(name,other,frame) && p190j_different(name,rest,frame)

@unsafe
def p190j_nine(names: List<&2,String>, +frame: X181Frame) -> Bool:
  match names:
    case Nil{}: True{}
    case Con{+name,+rest}: p190j_pool(name,frame) && p190j_different(name,rest,frame) && p190j_nine(rest,frame)

@unsafe
def p190j_fallback() -> Bool:
  +body: List<&2,P113DStmt> =
    [p190lv_bin("x","add",p190lv_v("a"),p190lv_v("a")),
     p190lv_bin("answer","add",p190lv_v("x"),p190lv_v("a")),P113DResult{[p190lv_v("answer")]}]
  p190lv_kind("a",x190_j_checked(x181_frame("probe",["state","a"],body),["state","a"],[],body,body,
    ["a"],[1],[0,0,0,0,1,0,0,0,0]),"X181Register")

@unsafe
def p190j_controls() -> List<&2,String>:
  +pressure = p190j_frame(p190j_pressure_params(),[],p190j_pressure_body())
  +call = p190j_frame(["state","arg"],[],p190lv_call_body())
  +chain = p190j_frame(["state","seed"],[],p190j_chain())
  +dead = p190j_frame(["state","seed"],p190lv_dead_setup(),p190lv_dead_body())
  +incoming = p190j_frame(["state","keep","unused"],[],p190lv_incoming_body())
  +narrow = p190j_frame(["state","wide"],[],p190lv_narrow_body())
  [p190lv_row("joint-nine-distinct-homes",p190j_nine(["n","a","b","c","d","e","f","g","h"],pressure)),
   p190lv_row("joint-incoming-abi",p190lv_abi(p190j_pressure_params(),pressure,0)),
   p190lv_row("joint-state-reserved",p190lv_kind("state",pressure,"X181Register") && U32.is_eq(da(p190lv_slot("state",pressure)),0)),
   p190lv_row("joint-output-reserved",p190lv_kind("__x181_result_out",pressure,"X181Stack")),
   p190lv_row("joint-scratch-reserved",p190lv_kind("scratch",pressure,"X181Buffer")),
   p190lv_row("joint-call-crossing-callee",p190lv_kind("live",call,"X181Register")),
   p190lv_row("joint-callee-sharing",p190lv_kind("a",chain,"X181Register") &&
     x186_p_same(p190lv_slot("a",chain),p190lv_slot("b",chain)) && x186_p_same(p190lv_slot("b",chain),p190lv_slot("c",chain))),
   p190lv_row("joint-dead-write",p190lv_distinct("keep","dead",dead)),
   p190lv_row("joint-dead-incoming",p190lv_distinct("keep","unused",incoming)),
   p190lv_row("joint-narrow-live-source",p190lv_distinct("wide","small",narrow)),
   p190lv_row("joint-refusal-keeps-saved-placement",p190j_fallback()),
   p190lv_row("joint-checker-accept-call-callee",x190_j_valid(["a"],[1],[],1,[1,0,0,0,0,0,0,0,0])),
   p190lv_row("joint-checker-reject-call-caller",Bool.not(x190_j_valid(["a"],[1],[],1,[0,0,0,0,1,0,0,0,0]))),
   p190lv_row("joint-checker-reject-cross-edge",Bool.not(x190_j_valid(["a","b"],[3,3],[],1,[3,0,0,0,0,0,0,0,0]))),
   p190lv_row("joint-checker-reject-duplicate",Bool.not(x190_j_valid(["a"],[0],[],1,[1,0,0,0,1,0,0,0,0]))),
   p190lv_row("joint-checker-reject-pool-size",Bool.not(x190_j_valid(["a"],[0],[],1,[1,0,0,0,0]))),
   p190lv_row("joint-checker-reject-incoming",Bool.not(x190_j_valid(["a"],[0],["state","a"],1,[0,0,0,0,0,0,0,0,1]))),
   p190lv_row("joint-checker-callee-incoming",x190_j_valid(["a"],[0],["state","a"],1,[0,0,0,1,0,0,0,0,0]))]

@unsafe
def p190j_emit_one(+name: String, +params: List<&2,String>, +setup: List<&2,P113DStmt>, +body: List<&2,P113DStmt>) -> X181Output:
  x185_function_frame(name,setup,body,N111Ids{missing(),missing()},
    x190_joint_frame(x181_frame(name,params,nt_append(P113DStmt,setup,body)),params,setup,body,body))

@unsafe
def p190j_outputs() -> List<&2,X181Output>:
  [p190j_emit_one("p190lv_loop",["state","n","acc","seed"],p190lv_loop_setup(),p190lv_loop_body()),
   p190j_emit_one("p190lv_dead",["state","seed"],p190lv_dead_setup(),p190lv_dead_body()),
   p190j_emit_one("p190lv_narrow",["state","wide"],[],p190lv_narrow_body()),
   p190j_emit_one("p190lv_branch",["state","pick","seed"],[],p190lv_branch_body()),
   p190j_emit_one("p190lv_incoming",["state","keep","unused"],[],p190lv_incoming_body()),
   p190j_emit_one("p190lv_call",["state","arg"],[],p190lv_call_body()),
   p190j_emit_one("p190lv_cold",["state","pick","seed"],p190lv_cold_setup(),[P113DResult{[p190lv_v("invariant")]}]),
   p190j_emit_one("p190j_nine",p190j_pressure_params(),[],p190j_pressure_body())]

def p190j_assembly() -> List<&2,String>: p190lv_render(p190j_outputs())
