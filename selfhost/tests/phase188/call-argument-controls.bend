# Phase188 test-only type/render adaptation; Phase186 source and C oracle remain frozen.
# Isolated machine-call placement controls. Custom frames deliberately contain
# ABI-register sources that the ordinary transient allocator excludes. These
# fixtures test the emitter and SysV boundary, not whole-program IR admission.

def p186ca_local(name: String) -> N111Value: N111Local{name}

@unsafe
def p186ca_ids() -> N111Ids:
  N111Ids{p111v_put(missing(),"target","N111Id",7,0),p111v_put(missing(),"tag","N111Id",9,0)}

@unsafe
def p186ca_frame(+name: String, +transient: Bool) -> X181Frame:
  +slots = p111v_put(p111v_put(p111v_put(p111v_put(missing(),
    "a","X181Stack",48,8),"b","X181Register",1,8),"u","X181Stack",56,8),"buffer","X181Buffer",80,16)
  X181Frame{nt_choose(KDef,transient,u =>
    p111v_put(p111v_put(p111v_put(p111v_put(p111v_put(slots,
      "a","X185Transient",0,8),"b","X185Transient",1,8),"c","X185Transient",2,8),
      "d","X185Transient",3,8),"e","X185Transient",4,8),u => slots),80,160,[],name}

def p186ca_direct_args() -> List<&2,N111Arg>:
  [N111Arg{N111U64{},p186ca_local("a")},N111Arg{N111U64{},p186ca_local("b")},
   N111Arg{N111U64{},N111Const{1432778632,287454020}},N111Arg{N111U32{},N111Const{42,4294967295}},
   N111Arg{N111Ptr{},N111Symbol{"p186ca_cookie"}},N111Arg{N111U32{},N111FuncId{"target"}},
   N111Arg{N111U32{},N111CtorId{"tag"}},N111Arg{N111Ptr{},p186ca_local("buffer")},
   N111Arg{N111U64{},p186ca_local("a")},N111Arg{N111U32{},p186ca_local("u")}]

def p186ca_snapshot_args() -> List<&2,N111Arg>:
  [N111Arg{N111U64{},p186ca_local("b")},N111Arg{N111U32{},p186ca_local("a")},
   N111Arg{N111U64{},p186ca_local("c")},N111Arg{N111U32{},p186ca_local("e")},
   N111Arg{N111U64{},p186ca_local("d")},N111Arg{N111U64{},N111Const{11,0}},
   N111Arg{N111U64{},p186ca_local("a")},N111Arg{N111U64{},p186ca_local("b")},
   N111Arg{N111U64{},p186ca_local("e")},N111Arg{N111U32{},p186ca_local("d")}]

def p186ca_six_args() -> List<&2,N111Arg>:
  [N111Arg{N111U32{},N111Const{1,4294967295}},N111Arg{N111U32{},N111Const{2,4294967295}},
   N111Arg{N111U32{},N111Const{3,4294967295}},N111Arg{N111U32{},N111Const{4,4294967295}},
   N111Arg{N111U32{},N111Const{5,4294967295}},N111Arg{N111U32{},N111Const{6,4294967295}}]

@unsafe
def p186ca_seed(name: String, value: N111Value, +frame: X181Frame) -> String:
  p188_test_load(value,p186ca_ids(),frame,"%r10") ++ p188_test_store(name,frame,"%r10")

@unsafe
def p186ca_setup(+frame: X181Frame, transient: Bool) -> String:
  p186ca_seed("a",N111Const{2309737967,19088743},frame) ++
  p186ca_seed("b",N111Const{1985229328,4275878552},frame) ++
  nt_choose(String,transient,u =>
    p186ca_seed("c",N111Const{1432778632,287454020},frame) ++
    p186ca_seed("d",N111Const{2863289685,4294901760},frame) ++
    p186ca_seed("e",N111Const{7,2147483648},frame),u =>
    p186ca_seed("u",N111Const{42,4294967295},frame) ++
    p188_test_load(p186ca_local("buffer"),p186ca_ids(),frame,"%r10") ++
    p188_test_load(N111Const{1144201745,2289526357},p186ca_ids(),frame,"%r11") ++ "  movq %r11, (%r10)\n")

@unsafe
def p186ca_one(+name: String, helper: String, +args: List<&2,N111Arg>,
    +frame: X181Frame, setup: String, enabled: Bool) -> String:
  p188_test_prologue(frame) ++ setup ++
    p188_test_call_selected(enabled,args,p186ca_ids(),frame,x186_call_plan(args,frame)) ++
    "  xorl %eax, %eax\n  call " ++ helper ++ "\n" ++ p188_test_epilogue(frame)

@unsafe
def p186ca_emit() -> P188TextOutput:
  +direct = p186ca_frame("p186ca_direct",False{})
  +disabled = p186ca_frame("p186ca_disabled",False{})
  +snapshot = p186ca_frame("p186ca_snapshot",True{})
  +six: X181Frame = X181Frame{missing(),40,96,[],"p186ca_six"}
  +zero: X181Frame = X181Frame{missing(),40,0,[],"p186ca_zero"}
  P188TextOutput{[
    p186ca_one("p186ca_direct","p186ca_check_direct",p186ca_direct_args(),direct,p186ca_setup(direct,False{}),True{}),
    p186ca_one("p186ca_disabled","p186ca_check_direct",p186ca_direct_args(),disabled,p186ca_setup(disabled,False{}),False{}),
    p186ca_one("p186ca_snapshot","p186ca_check_snapshot",p186ca_snapshot_args(),snapshot,p186ca_setup(snapshot,True{}),True{}),
    p186ca_one("p186ca_six","p186ca_check_six",p186ca_six_args(),six,"",True{}),
    p186ca_one("p186ca_zero","p186ca_check_zero",[],zero,"",True{})],""}

def p186ca_is(plan: X186CallPlan, +wanted: U32) -> Bool:
  match plan:
    case X186CallPlan{kind,count}: U32.is_eq(kind,wanted)

@unsafe
def p186ca_row(+name: String, good: Bool) -> String:
  name ++ "=" ++ nt_choose(String,good,u => "1",u => "0")

@unsafe
def p186ca_many(+count: U32) -> List<&2,N111Arg>:
  nt_choose(List<&2,N111Arg>,U32.is_eq(count,0),u => [],u =>
    Con{N111Arg{N111U64{},N111Const{0,0}},p186ca_many(U32.sub(count,1))})

@unsafe
def p186ca_probe(kind: String, slot: U32, size: U32, bytes: U32, calls: U32) -> X186CallPlan:
  x186_call_plan([N111Arg{N111U64{},p186ca_local("probe")}],
    X181Frame{p111v_put(missing(),"probe",kind,slot,size),bytes,calls,[],"probe"})

@unsafe
def p186ca_controls() -> List<&2,String>:
  +direct = p188_test_call_arguments(p186ca_direct_args(),p186ca_ids(),p186ca_frame("direct",False{}))
  +snapshot = p188_test_call_arguments(p186ca_snapshot_args(),p186ca_ids(),p186ca_frame("snapshot",True{}))
  +disabled = p188_test_call_selected(False{},p186ca_direct_args(),p186ca_ids(),p186ca_frame("disabled",False{}),X186CallPlan{1,10})
  [p186ca_row("direct-plan",p186ca_is(x186_call_plan(p186ca_direct_args(),p186ca_frame("direct",False{})),1)),
   p186ca_row("transient-plan",p186ca_is(x186_call_plan(p186ca_snapshot_args(),p186ca_frame("snapshot",True{})),2)),
   p186ca_row("direct-first-home",String.contains(direct,"movq -48(%rbp), %rdi")),
   p186ca_row("direct-no-copy",Bool.not(String.contains(direct,"movq %r10, %rdi"))),
   p186ca_row("direct-stack-args",String.contains(direct,"movq %r10, 24(%rsp)")),
   p186ca_row("snapshot-before-placement",String.contains(snapshot,"movq %r10, 152(%rsp)\n  movq 80(%rsp), %rdi")),
   p186ca_row("disabled-snapshot",String.contains(disabled,"movq %r10, 80(%rsp)")),
   p186ca_row("u32-six-registers",String.contains(p188_test_call_arguments(p186ca_six_args(),p186ca_ids(),
     X181Frame{missing(),40,96,[],"six"}),"movl %r9d, %r9d")),
   p186ca_row("short-capacity-refused",p186ca_is(p186ca_probe("X185Transient",0,8,48,15),0)),
   p186ca_row("unknown-slot-refused",p186ca_is(p186ca_probe("Unknown",0,8,48,16),0)),
   p186ca_row("unknown-register-refused",p186ca_is(p186ca_probe("X181Register",5,8,48,16),0)),
   p186ca_row("unknown-transient-refused",p186ca_is(p186ca_probe("X185Transient",5,8,48,16),0)),
   p186ca_row("outside-frame-refused",p186ca_is(p186ca_probe("X181Stack",56,8,48,16),0)),
   p186ca_row("saved-slot-refused",p186ca_is(p186ca_probe("X181Stack",40,8,48,16),0)),
   p186ca_row("buffer-overlap-refused",p186ca_is(p186ca_probe("X181Buffer",48,16,48,16),0)),
   p186ca_row("maximum-public-arity",p186ca_is(x186_call_plan(p186ca_many(257),X181Frame{missing(),40,4112,[],"many"}),1)),
   p186ca_row("bounded-512",p186ca_is(x186_call_plan(p186ca_many(512),X181Frame{missing(),40,8192,[],"many"}),1)),
   p186ca_row("bounded-513-refused",p186ca_is(x186_call_plan(p186ca_many(513),X181Frame{missing(),40,8208,[],"many"}),0)),
   p186ca_row("empty-call",String.is_empty(p188_test_call_arguments([],p186ca_ids(),X181Frame{missing(),40,0,[],"zero"}))),
   p186ca_row("explicit-invalid-frame",String.contains(p188_test_call_arguments([N111Arg{N111U64{},p186ca_local("absent")}],
     p186ca_ids(),X181Frame{missing(),40,16,[],"invalid"}),".error"))]
