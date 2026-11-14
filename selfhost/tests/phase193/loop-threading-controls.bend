# Append with the experimental module before checked API acquisition.
# These assert complete rendered typed instruction sequences; no target runs.
def p193lt_row(name: String, ok: Bool) -> String:
  name ++ "=" ++ nt_choose(String,ok,u => "1",u => "0")

def p193lt_header(home: X187Operand, test: String, branch: String) -> X188Seq:
  x188_many([x188_label(".Lcontrol_loop"),x188_i2("movq",home,x188_reg(10,64)),
    x188_i2(test,x188_reg(10,32),x188_reg(10,32)),x188_i1(branch,X187Target{"zero"})])

def p193lt_edge(home: X187Operand, lo: U32, hi: U32, middle: X188Seq, target: String) -> X188Seq:
  x188_many([x188_i2("movq",X187Imm{lo,hi},x188_reg(10,64)),
    x188_i2("movq",x188_reg(10,64),home),middle,x188_i1("jmp",X187Target{target})])

def p193lt_program(+home: X187Operand, lo: U32, hi: U32, middle: X188Seq,
    test: String, branch: String, target: String, extra: X188Seq) -> X188Seq:
  x188_many([p193lt_header(home,test,branch),x188_i0("ret"),x188_label("zero"),
    p193lt_edge(home,lo,hi,middle,target),extra])

# The expected sequence is independent of the matcher/rewriter and includes
# the repeated TEST required to preserve flags even at an ADC/CMOV consumer.
def p193lt_expected(+home: X187Operand, lo: U32, hi: U32, destination: String) -> X188Seq:
  x188_many([p193lt_header(home,"testl","jz"),x188_label(".Lcontrol_loop_p193_nonzero"),
    x188_i0("ret"),x188_label("zero"),x188_i2("movq",X187Imm{lo,hi},x188_reg(10,64)),
    x188_i2("movq",x188_reg(10,64),home),x188_i2("testl",x188_reg(10,32),x188_reg(10,32)),
    x188_i1("jmp",X187Target{destination})])

@unsafe
def p193lt_accept(+home: X187Operand, +lo: U32, +hi: U32, destination: String) -> Bool:
  String.eq(x188_render(x193lt_thread_when(True{},"control",
    p193lt_program(home,lo,hi,X188Empty{},"testl","jz",".Lcontrol_loop",X188Empty{}))),
    x188_render(p193lt_expected(home,lo,hi,destination)))

@unsafe
def p193lt_unchanged(+code: X188Seq) -> Bool:
  String.eq(x188_render(x193lt_thread_when(True{},"control",code)),x188_render(code))

# A valid header may gain its unreferenced local label even when no edge
# qualifies. Compare the remaining instructions, retaining that inert label.
@unsafe
def p193lt_edge_refused(+middle: X188Seq, +target: String) -> Bool:
  String.eq(x188_render(x193lt_thread_when(True{},"control",
      p193lt_program(x188_reg(7,64),1,0,middle,"testl","jz",target,X188Empty{}))),
    x188_render(x188_many([p193lt_header(x188_reg(7,64),"testl","jz"),
      x188_label(".Lcontrol_loop_p193_nonzero"),x188_i0("ret"),x188_label("zero"),
      p193lt_edge(x188_reg(7,64),1,0,middle,target)])))

@unsafe
def p193lt_controls() -> List<&2,String>:
  +base = p193lt_program(x188_reg(7,64),1,0,X188Empty{},"testl","jz",".Lcontrol_loop",X188Empty{})
  [p193lt_row("zero-register",p193lt_accept(x188_reg(7,64),0,0,"zero")),
   p193lt_row("nonzero-register",p193lt_accept(x188_reg(7,64),1,0,".Lcontrol_loop_p193_nonzero")),
   p193lt_row("high-word-only-is-zero",p193lt_accept(x188_reg(7,64),0,1,"zero")),
   p193lt_row("sign-bit-is-nonzero",p193lt_accept(x188_reg(7,64),2147483648,4294967295,".Lcontrol_loop_p193_nonzero")),
   p193lt_row("private-frame",p193lt_accept(X187Mem{5,4294967232},0,0,"zero")),
   p193lt_row("disabled-identical",String.eq(x188_render(x193lt_thread_when(False{},"control",base)),x188_render(base))),
   p193lt_row("wrong-symbol",String.eq(x188_render(x193lt_thread_when(True{},"other",base)),x188_render(base))),
   p193lt_row("testq-refused",p193lt_unchanged(p193lt_program(x188_reg(7,64),0,1,X188Empty{},"testq","jz",".Lcontrol_loop",X188Empty{}))),
   p193lt_row("jnz-refused",p193lt_unchanged(p193lt_program(x188_reg(7,64),0,0,X188Empty{},"testl","jnz",".Lcontrol_loop",X188Empty{}))),
   p193lt_row("stack-pointer-refused",p193lt_unchanged(p193lt_program(x188_reg(4,64),1,0,X188Empty{},"testl","jz",".Lcontrol_loop",X188Empty{}))),
   p193lt_row("scratch-home-refused",p193lt_unchanged(p193lt_program(x188_reg(10,64),1,0,X188Empty{},"testl","jz",".Lcontrol_loop",X188Empty{}))),
   p193lt_row("external-memory-refused",p193lt_unchanged(p193lt_program(X187Mem{7,0},1,0,X188Empty{},"testl","jz",".Lcontrol_loop",X188Empty{}))),
   p193lt_row("unaligned-frame-refused",p193lt_unchanged(p193lt_program(X187Mem{5,4294967233},1,0,X188Empty{},"testl","jz",".Lcontrol_loop",X188Empty{}))),
   p193lt_row("generated-label-collision",p193lt_unchanged(p193lt_program(x188_reg(7,64),1,0,X188Empty{},"testl","jz",".Lcontrol_loop",x188_label(".Lcontrol_loop_p193_nonzero")))),
   p193lt_row("duplicate-entry",p193lt_unchanged(p193lt_program(x188_reg(7,64),1,0,X188Empty{},"testl","jz",".Lcontrol_loop",x188_label(".Lcontrol_loop")))),
   p193lt_row("duplicate-target",p193lt_unchanged(p193lt_program(x188_reg(7,64),1,0,X188Empty{},"testl","jz",".Lcontrol_loop",x188_label("zero")))),
   p193lt_row("intervening-call",p193lt_edge_refused(x188_i1("call",X187Target{"callee"}),".Lcontrol_loop")),
   p193lt_row("intervening-label",p193lt_edge_refused(x188_label("interior"),".Lcontrol_loop")),
   p193lt_row("intervening-write",p193lt_edge_refused(x188_i2("movq",X187Imm{0,0},x188_reg(10,64)),".Lcontrol_loop")),
   p193lt_row("wrong-jump-target",p193lt_edge_refused(X188Empty{},"zero"))]
