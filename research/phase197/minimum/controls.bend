# Requires existing predicate-controls-v3.bend for the ten independent opcode names.
def p197ms_v(name: String) -> N111Value: N111Local{name}
@unsafe
def p197ms_frame(+mode: U32) -> X181Frame:
  +slots = p111v_put(p111v_put(missing(),"a","X185Transient",3,8),"b","X185Transient",4,8)
  +placed = nt_choose(KDef,U32.is_eq(U32.div(mode,80),3),u => p111v_put(slots,"out","X181Stack",8,8),u =>
    p111v_put(slots,"out","X185Transient",nt_choose(U32,U32.is_eq(U32.div(mode,80),0),v => 3,v =>
      nt_choose(U32,U32.is_eq(U32.div(mode,80),1),w => 4,w => 2)),8))
  X181Frame{p111v_put(placed,"echo","X181Stack",16,8),32,0,[],"minimum-control"}
@unsafe
def p197ms_plan(+mode: U32) -> X194Select:
  X194Select{[],nt_choose(N111Type,U32.is_lt(U32.mod(mode,20),10),u => N111U32{},u => N111U64{}),
    p194pc_op(U32.mod(mode,10)),p197ms_v("a"),p197ms_v("b"),U32.is_ge(U32.mod(mode,80),40),
    X191SelectPlan{nt_choose(N111Type,U32.is_lt(U32.mod(mode,40),20),u => N111U32{},u => N111U64{}),
      p197ms_v("a"),p197ms_v("b"),["out","echo"]},[]}
@unsafe
def p197ms_text(+mode: U32) -> String:
  x188_render(x197ms_pick(p197ms_plan(mode),p197ms_frame(mode)))
def p197ms_row(name: String, ok: Bool) -> String:
  name ++ "=" ++ nt_choose(String,ok,u => "1",u => "0")
@unsafe
def p197ms_controls() -> List<&2,String>:
  [p197ms_row("minimum-left-home",String.contains(p197ms_text(32),"cmovaeq %r9, %r8")),
   p197ms_row("minimum-right-home",String.contains(p197ms_text(112),"cmovbq %r8, %r9")),
   p197ms_row("minimum-third-home",String.contains(p197ms_text(192),"movq %r9, %rdx") && String.contains(p197ms_text(192),"cmovbq %r8, %rdx")),
   p197ms_row("minimum-stack-home",String.contains(p197ms_text(272),"cmovbq %r8, %r11") && String.contains(p197ms_text(272),"movq %r11, -8(%rbp)")),
   p197ms_row("minimum-u32-normalized",String.contains(p197ms_text(2),"movl %r8d, %r8d") && String.contains(p197ms_text(2),"cmovael %r9d, %r8d")),
   p197ms_row("minimum-inverted",String.contains(p197ms_text(72),"cmovbq %r9, %r8")),
   p197ms_row("minimum-publish-all",String.contains(p197ms_text(32),"movq %r8, -16(%rbp)")),
   p197ms_row("minimum-missing-home-refused",x188_empty(x197ms_pick(p197ms_plan(32),X181Frame{missing(),0,0,[],"missing"})))]
@unsafe
def p197ms_function(+mode: U32) -> X188Seq:
  +symbol = "p197ms_" ++ U32.show(mode)
  +frame = p197ms_frame(mode)
  x188_many([X188One{PGlobal{symbol}},X188One{PType{symbol,2}},x188_label(symbol),
    x188_i1("pushq",x188_reg(5,64)),x188_i2("movq",x188_reg(4,64),x188_reg(5,64)),x188_i2("subq",X187Imm{32,0},x188_reg(4,64)),
    x188_i2("movq",X187Mem{7,0},x188_reg(8,64)),x188_i2("movq",X187Mem{7,8},x188_reg(9,64)),
    x194_ps_emit(p197ms_plan(mode),N111Ids{missing(),missing()},frame),
    x181_load(p197ms_v("out"),N111Ids{missing(),missing()},frame,x188_reg(0,64)),
    x188_i2("movq",x188_reg(0,64),X187Mem{7,16}),
    x188_i2("movq",X187Mem{5,4294967280},x188_reg(10,64)),x188_i2("movq",x188_reg(10,64),X187Mem{7,24}),
    x188_i2("movq",x188_reg(5,64),x188_reg(4,64)),x188_i1("popq",x188_reg(5,64)),x188_i0("ret"),X188One{PSize{symbol}}])
@unsafe
def p197ms_functions(+mode: U32) -> X188Seq:
  nt_choose(X188Seq,U32.is_ge(mode,320),u => X188Empty{},u => x188_cat(p197ms_function(mode),p197ms_functions(U32.inc(mode))))
def p197ms_emit() -> X181Output:
  X181Output{[x188_many([X188One{PSection{1}},p197ms_functions(0),X188One{PSection{4}}])],""}
