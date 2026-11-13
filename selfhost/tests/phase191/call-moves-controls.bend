# Finite independent ABI observations: five caller homes, one stack source,
# ten arguments, cycles, duplicate sources, narrow identities and constants.
type P191CallCase is Data:
  P191CallCase{+name: String, +sources: List<&2,U32>, +narrow: U32}

def p191cm_cases() -> List<&2,P191CallCase>:
  [P191CallCase{"identity",[0,1,2,3,4,5,0,1,4,5],0},
   P191CallCase{"swap",[1,0,2,3,4,5,0,1,4,5],0},
   P191CallCase{"cycle3",[1,2,0,3,4,5,0,1,2,5],0},
   P191CallCase{"cycle5",[1,2,4,3,5,0,0,1,4,5],0},
   P191CallCase{"disjoint",[1,0,2,3,5,4,0,1,4,5],0},
   P191CallCase{"duplicates",[1,1,1,0,0,0,1,0,4,5],0},
   P191CallCase{"narrow_identity",[0,0,1,2,4,5,0,1,4,5],1},
   P191CallCase{"narrow_cycle",[1,2,4,3,5,0,0,1,4,5],341},
   P191CallCase{"all_narrow",[5,4,3,2,1,0,0,1,4,5],1023},
   P191CallCase{"stack_source",[3,3,0,1,2,3,3,0,4,5],0},
   P191CallCase{"constants",[6,0,6,2,1,6,0,6,4,5],546},
   P191CallCase{"stack_duplicates",[1,0,5,3,2,4,0,0,0,0],0}]

def p191cm_value(index: U32) -> N111Value:
  match index:
    case 0: N111Local{"x0"}
    case 1: N111Local{"x1"}
    case 2: N111Local{"x2"}
    case 3: N111Local{"x3"}
    case 4: N111Local{"x4"}
    case 5: N111Local{"x5"}
    case _: N111Const{305419896,4275878552}

@unsafe
def p191cm_args(sources: List<&2,U32>, +mask: U32, +bit: U32) -> List<&2,N111Arg>:
  match sources:
    case Nil{}: []
    case Con{source,rest}:
      Con{N111Arg{nt_choose(N111Type,U32.is_eq(U32.and(mask,bit),0),u => N111U64{},u => N111U32{}),p191cm_value(source)},
        p191cm_args(rest,mask,U32.shl(bit))}

@unsafe
def p191cm_frame() -> X181Frame:
  +slots = p111v_put(p111v_put(p111v_put(p111v_put(p111v_put(p111v_put(missing(),
    "x0","X185Transient",0,8),"x1","X185Transient",1,8),"x2","X185Transient",2,8),
    "x3","X181Stack",48,8),"x4","X185Transient",3,8),"x5","X185Transient",4,8)
  X181Frame{slots,64,160,[],"p191cm"}

@unsafe
def p191cm_function(+name: String, planned: Maybe<&2,X188Seq>) -> X188Seq:
  match planned:
    case Some{code}:
      x188_many([X188One{PGlobal{name}},X188One{PType{name,2}},x188_label(name),
        x188_i1("pushq",x188_reg(5,64)),x188_i2("movq",x188_reg(4,64),x188_reg(5,64)),
        x188_i2("subq",X187Imm{224,0},x188_reg(4,64)),
        x188_i2("movq",x188_reg(1,64),X187Mem{5,4294967248}),code,
        x188_i1("call",X187Target{"p191cm_observe"}),
        x188_i2("movq",x188_reg(5,64),x188_reg(4,64)),x188_i1("popq",x188_reg(5,64)),x188_i0("ret"),X188One{PSize{name}}])
    case _: x188_error("call move fixture refused")

@unsafe
def p191cm_functions(cases: List<&2,P191CallCase>) -> List<&2,X188Seq>:
  match cases:
    case Nil{}: []
    case Con{P191CallCase{name,sources,mask},rest}:
      Con{p191cm_function("p191cm_" ++ name,p191cm_when(True{},p191cm_args(sources,mask,1),
        N111Ids{missing(),missing()},p191cm_frame())),p191cm_functions(rest)}

@unsafe
def p191cm_emit() -> X181Output:
  X181Output{nt_append(X188Seq,[X188One{PSection{1}}],
    nt_append(X188Seq,p191cm_functions(p191cm_cases()),[X188One{PSection{4}}])),""}

def p191cm_none(plan: Maybe<&2,X188Seq>) -> Bool:
  match plan:
    case None{}: True{}
    case _: False{}

def p191cm_some(plan: Maybe<&2,X188Seq>) -> Bool:
  match plan:
    case Some{code}: True{}
    case _: False{}

@unsafe
def p191cm_all(cases: List<&2,P191CallCase>) -> Bool:
  match cases:
    case Nil{}: True{}
    case Con{P191CallCase{name,sources,mask},rest}:
      p191cm_some(p191cm_when(True{},p191cm_args(sources,mask,1),N111Ids{missing(),missing()},p191cm_frame())) && p191cm_all(rest)

def p191cm_row(name: String, ok: Bool) -> String:
  name ++ nt_choose(String,ok,u => "=1",u => "=0")

@unsafe
def p191cm_controls() -> List<&2,String>:
  +args = p191cm_args([1,0,2,3,4,5,0,1,4,5],0,1)
  +frame = p191cm_frame()
  +ids: N111Ids = N111Ids{missing(),missing()}
  [p191cm_row("all-plans",p191cm_all(p191cm_cases())),
   p191cm_row("disabled-refusal",p191cm_none(p191cm_when(False{},args,ids,frame))),
   p191cm_row("fuel-refusal",p191cm_none(x191_cm_schedule(x191_cm_first(args,frame,0),ids,frame,[],0))),
   p191cm_row("capacity-refusal",p191cm_none(p191cm_when(True{},args,ids,X181Frame{missing(),64,0,[],"invalid"}))),
   p191cm_row("missing-local-refusal",p191cm_none(p191cm_when(True{},[N111Arg{N111U64{},N111Local{"missing"}}],ids,frame))),
   p191cm_row("direct-kind-refusal",p191cm_none(p191cm_when(True{},[N111Arg{N111U64{},N111Const{1,0}}],ids,frame)))]

@unsafe
def p191cm_when(enabled: Bool, +args: List<&2,N111Arg>, +ids: N111Ids, +frame: X181Frame) -> Maybe<&2,X188Seq>:
  nt_choose(Maybe<&2,X188Seq>,enabled,u => x191_cm_admitted(x186_call_plan(args,frame),args,ids,frame),u => None{})
