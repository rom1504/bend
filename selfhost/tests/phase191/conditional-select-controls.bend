def p191cc_v(name: String) -> N111Value: N111Local{name}
def p191cc_row(name: String, ok: Bool) -> String:
  name ++ "=" ++ nt_choose(String,ok,u => "1",u => "0")
def p191cc_present(plan: Maybe<&2,X191SelectPlan>) -> Bool:
  match plan:
    case Some{p}: True{}
    case None{}: False{}

def p191cc_names() -> List<&2,String>: ["a","b","c","d"]

@unsafe
def p191cc_chain(names: List<&2,String>, +typ: N111Type, source: N111Value) -> List<&2,P113DStmt>:
  match names:
    case Nil{}: []
    case Con{+name,rest}: Con{P113DScalar{N111Set{name,typ,source}},p191cc_chain(rest,typ,p191cc_v(name))}

def p191cc_empty_selected(result: Maybe<&2,X188Seq>) -> Bool:
  match result:
    case Some{X188Empty{}}: True{}
    case _: False{}

@unsafe
def p191cc_empty_control() -> Bool:
  Bool.not(Bool.xor(x191_conditional_select_enabled(),p191cc_empty_selected(
    x191_conditional_select(p191cc_v("condition"),[],[],N111Ids{missing(),missing()},
      X181Frame{missing(),0,0,[],"empty-control"}))))

@unsafe
def p191cc_controls() -> List<&2,String>:
  +yes = p191cc_chain(["a","b"],N111U32{},p191cc_v("yes"))
  +no = p191cc_chain(["a","b"],N111U32{},p191cc_v("no"))
  [p191cc_row("single",p191cc_present(x191_select_plan(p191cc_chain(["a"],N111U64{},p191cc_v("yes")),p191cc_chain(["a"],N111U64{},p191cc_v("no"))))),
   p191cc_row("two-copy",p191cc_present(x191_select_plan(yes,no))),
   p191cc_row("four-copy",p191cc_present(x191_select_plan(p191cc_chain(p191cc_names(),N111U64{},p191cc_v("b")),p191cc_chain(p191cc_names(),N111U64{},p191cc_v("a"))))),
   p191cc_row("constant",p191cc_present(x191_select_plan(p191cc_chain(["a"],N111U32{},N111Const{4294967295,4294967295}),p191cc_chain(["a"],N111U32{},N111Const{0,1})))),
   p191cc_row("empty-refused",Bool.not(p191cc_present(x191_select_plan([],[])))),
   p191cc_row("fifth-refused",Bool.not(p191cc_present(x191_select_plan(p191cc_chain(["a","b","c","d","e"],N111U64{},p191cc_v("yes")),p191cc_chain(["a","b","c","d","e"],N111U64{},p191cc_v("no")))))),
   p191cc_row("different-writes-refused",Bool.not(p191cc_present(x191_select_plan(yes,p191cc_chain(["a","c"],N111U32{},p191cc_v("no")))))),
   p191cc_row("different-width-refused",Bool.not(p191cc_present(x191_select_plan(yes,p191cc_chain(["a","b"],N111U64{},p191cc_v("no")))))),
   p191cc_row("pointer-refused",Bool.not(p191cc_present(x191_select_plan(p191cc_chain(["a"],N111Ptr{},p191cc_v("yes")),p191cc_chain(["a"],N111Ptr{},p191cc_v("no")))))),
   p191cc_row("symbol-refused",Bool.not(p191cc_present(x191_select_plan(p191cc_chain(["a","b"],N111U32{},N111Symbol{"external"}),no)))),
   p191cc_row("broken-chain-refused",Bool.not(p191cc_present(x191_select_plan(yes,[P113DScalar{N111Set{"a",N111U32{},p191cc_v("no")}},P113DScalar{N111Set{"b",N111U32{},p191cc_v("no")}}])))),
   p191cc_row("load-refused",Bool.not(p191cc_present(x191_select_plan([P113DScalar{N111Load{"a",N111U32{},p191cc_v("base"),0}}],no)))),
   p191cc_row("store-refused",Bool.not(p191cc_present(x191_select_plan([P113DScalar{N111Store{N111U32{},p191cc_v("base"),0,p191cc_v("yes")}}],no)))),
   p191cc_row("reserved-refused",Bool.not(p191cc_present(x191_select_plan(p191cc_chain(["state"],N111U64{},p191cc_v("yes")),p191cc_chain(["state"],N111U64{},p191cc_v("no")))))),
   p191cc_row("empty-arms-selected",p191cc_empty_control())]

@unsafe
def p191cc_slot(slots: KDef, name: String, +stack: Bool, reg: U32, offset: U32) -> KDef:
  p111v_put(slots,name,nt_choose(String,stack,u => "X181Stack",u => "X185Transient"),
    nt_choose(U32,stack,u => offset,u => reg),8)

@unsafe
def p191cc_prefix(mode: U32) -> X188Seq:
  x188_many([x188_i1("pushq",x188_reg(5,64)),x188_i2("movq",x188_reg(4,64),x188_reg(5,64)),
    x188_i2("subq",X187Imm{64,0},x188_reg(4,64)),
    nt_choose(X188Seq,U32.is_eq(mode,4),u => x188_many([
      x188_i2("movq",x188_reg(7,64),X187Mem{5,4294967288}),
      x188_i2("movq",x188_reg(6,64),X187Mem{5,4294967280}),
      x188_i2("movq",x188_reg(2,64),X187Mem{5,4294967272})]),u => X188Empty{})])

# ABI: condition, yes value, no value, output pointer. Modes0/1 overwrite all
# three input homes in different orders; mode2 has stack inputs and outputs;
# mode3 uses high-bit constants. Output records every original destination.
@unsafe
def p191cc_frame(+mode: U32) -> X181Frame:
  +stack = U32.is_eq(mode,2)
  +slots = p191cc_slot(p191cc_slot(p191cc_slot(missing(),"condition",stack,0,8),"yes",stack,1,16),"no",stack,2,24)
  +slots = p191cc_slot(slots,"a",stack,nt_choose(U32,U32.is_eq(mode,1),u => 0,u => 1),32)
  +slots = p191cc_slot(slots,"b",stack,nt_choose(U32,U32.is_eq(mode,1),u => 1,u => 2),40)
  +slots = p191cc_slot(slots,"c",stack,nt_choose(U32,U32.is_eq(mode,1),u => 2,u => 0),48)
  X181Frame{p191cc_slot(slots,"d",stack,3,56),64,0,[],"p191cc"}

@unsafe
def p191cc_source(+yes: Bool, mode: U32) -> N111Value:
  nt_choose(N111Value,U32.is_eq(mode,3),u => nt_choose(N111Value,yes,
    v => N111Const{4294967295,3735928559},v => N111Const{2147483648,305419896}),
    u => nt_choose(N111Value,yes,v => p191cc_v("yes"),v => p191cc_v("no")))

@unsafe
def p191cc_selected(plan: Maybe<&2,X191SelectPlan>, frame: X181Frame) -> X188Seq:
  match plan:
    case Some{selected}: x191_select_emit(p191cc_v("condition"),selected,N111Ids{missing(),missing()},frame)
    case None{}: x188_error("conditional-select fixture refused")

@unsafe
def p191cc_record(names: List<&2,String>, +offset: U32, +frame: X181Frame) -> X188Seq:
  match names:
    case Nil{}: X188Empty{}
    case Con{name,rest}: x188_many([x181_load(p191cc_v(name),N111Ids{missing(),missing()},frame,x188_reg(0,64)),
      x188_i2("movq",x188_reg(0,64),X187Mem{9,offset}),p191cc_record(rest,U32.add(offset,8),frame)])

@unsafe
def p191cc_function(+typ: N111Type, +mode: U32, +count: U32) -> X188Seq:
  +names = nt_choose(List<&2,String>,U32.is_eq(count,1),u => ["a"],u => p191cc_names())
  +symbol = "p191cc_" ++ x181_width(typ,"64","32") ++ "_" ++ U32.show(mode) ++ "_" ++ U32.show(count)
  +frame = p191cc_frame(mode)
  x188_many([X188One{PGlobal{symbol}},X188One{PType{symbol,2}},x188_label(symbol),
    p191cc_prefix(nt_choose(U32,U32.is_eq(mode,2),u => 4,u => 0)),
    x188_i2("movq",x188_reg(1,64),x188_reg(9,64)),
    p191cc_selected(x191_select_plan(p191cc_chain(names,typ,p191cc_source(True{},mode)),p191cc_chain(names,typ,p191cc_source(False{},mode))),frame),
    p191cc_record(names,0,frame),x188_i2("movq",x188_reg(5,64),x188_reg(4,64)),
    x188_i1("popq",x188_reg(5,64)),x188_i0("ret"),X188One{PSize{symbol}}])

@unsafe
def p191cc_modes(+mode: U32) -> X188Seq:
  nt_choose(X188Seq,U32.is_ge(mode,4),u => X188Empty{},u => x188_many([
    p191cc_function(N111U32{},mode,1),p191cc_function(N111U32{},mode,4),
    p191cc_function(N111U64{},mode,1),p191cc_function(N111U64{},mode,4),p191cc_modes(U32.inc(mode))]))

@unsafe
def p191cc_emit() -> X181Output:
  X181Output{[x188_many([X188One{PSection{1}},p191cc_modes(0),X188One{PSection{4}}])],""}
