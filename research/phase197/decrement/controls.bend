@unsafe
def p197d_pair(op: String, lo: U32, hi: U32, +source: U32, +dest: U32, +width: U32) -> X188Seq:
  x188_many([x188_i2(nt_choose(String,U32.is_eq(width,64),u => "movq",u => "movl"),x188_reg(source,width),x188_reg(dest,width)),
    x188_i2(op,X187Imm{lo,hi},x188_reg(dest,width))])

def p197d_kill() -> X188Seq: x188_i2("cmpq",x188_reg(6,64),x188_reg(7,64))

@unsafe
def p197d_accept(op: String, lo: U32, hi: U32, disp: U32) -> Bool:
  String.eq(x188_render(x197d_select(x188_cat(p197d_pair(op,lo,hi,7,10,64),p197d_kill()))),
    x188_render(x188_cat(x188_i2("leaq",X187Mem{7,disp},x188_reg(10,64)),p197d_kill())))

@unsafe
def p197d_refuse(+code: X188Seq) -> Bool:
  String.eq(x188_render(code),x188_render(x197d_select(code)))

@unsafe
def p197d_row(label: String, yes: Bool) -> String:
  label ++ "=" ++ nt_choose(String,yes,u => "1",u => "0")

@unsafe
def p197d_padding(n: U32) -> X188Seq:
  nt_choose(X188Seq,U32.is_eq(n,0),u => p197d_kill(),u =>
    x188_cat(x188_i2("movq",x188_reg(6,64),x188_reg(0,64)),p197d_padding(U32.sub(n,1))))

# A partial writer with zero shift count does not certify dead flags.
@unsafe
def p197d_tail_refused(tail: X188Seq) -> Bool:
  p197d_refuse(x188_cat(p197d_pair("subq",1,0,7,10,64),tail))

@unsafe
def p197d_controls() -> List<&2,String>:
  [p197d_row("sub-one",p197d_accept("subq",1,0,4294967295)),
   p197d_row("add-one",p197d_accept("addq",1,0,1)),
   p197d_row("add-int32-max",p197d_accept("addq",2147483647,0,2147483647)),
   p197d_row("add-int32-min",p197d_accept("addq",2147483648,4294967295,2147483648)),
   p197d_row("sub-negative-one",p197d_accept("subq",4294967295,4294967295,1)),
   p197d_row("sub-negative-max",p197d_accept("subq",2147483649,4294967295,2147483647)),
   p197d_row("sub-int32-min-refused",p197d_refuse(x188_cat(p197d_pair("subq",2147483648,4294967295,7,10,64),p197d_kill()))),
   p197d_row("positive-high-bit-refused",p197d_refuse(x188_cat(p197d_pair("addq",2147483648,0,7,10,64),p197d_kill()))),
   p197d_row("high-word-refused",p197d_refuse(x188_cat(p197d_pair("subq",1,1,7,10,64),p197d_kill()))),
   p197d_row("u32-refused",p197d_refuse(x188_cat(p197d_pair("subl",1,0,7,10,32),p197d_kill()))),
   p197d_row("rsp-source-refused",p197d_refuse(x188_cat(p197d_pair("subq",1,0,4,10,64),p197d_kill()))),
   p197d_row("rbp-destination-refused",p197d_refuse(x188_cat(p197d_pair("subq",1,0,7,5,64),p197d_kill()))),
   p197d_row("same-register-refused",p197d_refuse(x188_cat(p197d_pair("subq",1,0,7,7,64),p197d_kill()))),
   p197d_row("memory-source-refused",p197d_refuse(x188_many([
     x188_i2("movq",X187Mem{7,0},x188_reg(10,64)),x188_i2("subq",X187Imm{1,0},x188_reg(10,64)),p197d_kill()]))),
   p197d_row("different-destination-refused",p197d_refuse(x188_many([
     x188_i2("movq",x188_reg(7,64),x188_reg(10,64)),x188_i2("subq",X187Imm{1,0},x188_reg(11,64)),p197d_kill()]))),
   p197d_row("carry-consumer-refused",p197d_tail_refused(x188_cat(x188_i1("setb",x188_reg(0,8)),p197d_kill()))),
   p197d_row("cmov-consumer-refused",p197d_tail_refused(x188_cat(x188_i2("cmovbq",x188_reg(6,64),x188_reg(0,64)),p197d_kill()))),
   p197d_row("branch-consumer-refused",p197d_tail_refused(x188_cat(x188_i1("jne",X187Target{"else"}),p197d_kill()))),
   p197d_row("carry-arithmetic-refused",p197d_tail_refused(x188_cat(x188_i2("adcq",x188_reg(6,64),x188_reg(0,64)),p197d_kill()))),
   p197d_row("zero-shift-refused",p197d_tail_refused(x188_many([
     x188_i2("shrq",X187Imm{0,0},x188_reg(6,64)),x188_i1("setb",x188_reg(0,8)),p197d_kill()]))),
   p197d_row("label-refused",p197d_tail_refused(x188_cat(x188_label("joined"),p197d_kill()))),
   p197d_row("call-refused",p197d_tail_refused(x188_cat(x188_i1("call",X187Target{"other"}),p197d_kill()))),
   p197d_row("directive-refused",p197d_tail_refused(x188_cat(X188One{PAlign{16}},p197d_kill()))),
   p197d_row("empty-item-refused",p197d_tail_refused(x188_cat(X188One{PEmpty{}},p197d_kill()))),
   p197d_row("end-refused",p197d_tail_refused(X188Empty{})),
   p197d_row("window-bound-refused",p197d_tail_refused(p197d_padding(16))),
   p197d_row("partial-flags-until-cmp",String.eq(x188_render(x197d_select(x188_many([
     p197d_pair("subq",1,0,7,10,64),x188_i2("shrq",X187Imm{40,0},x188_reg(6,64)),
     x188_i2("andq",X187Imm{65535,0},x188_reg(6,64)),p197d_kill()]))),
     x188_render(x188_many([x188_i2("leaq",X187Mem{7,4294967295},x188_reg(10,64)),
       x188_i2("shrq",X187Imm{40,0},x188_reg(6,64)),x188_i2("andq",X187Imm{65535,0},x188_reg(6,64)),p197d_kill()])))),
   p197d_row("structural-empty-crossed",String.eq(x188_render(x197d_select(X188Join{
     x188_i2("movq",x188_reg(7,64),x188_reg(10,64)),X188Join{X188Empty{},X188Join{
       x188_i2("subq",X187Imm{1,0},x188_reg(10,64)),p197d_kill()}}})),
     x188_render(x188_cat(x188_i2("leaq",X187Mem{7,4294967295},x188_reg(10,64)),p197d_kill()))))]

@unsafe
def p197d_machine_body(mode: U32) -> X188Seq:
  match mode:
    case 0: x188_many([p197d_pair("subq",1,0,7,10,64),p197d_kill(),x188_i2("movq",x188_reg(10,64),x188_reg(0,64)),x188_i0("ret")])
    case 1: x188_many([p197d_pair("addq",1,0,7,10,64),p197d_kill(),x188_i2("movq",x188_reg(10,64),x188_reg(0,64)),x188_i0("ret")])
    case 2: x188_many([p197d_pair("addq",2147483648,4294967295,7,10,64),p197d_kill(),x188_i2("movq",x188_reg(10,64),x188_reg(0,64)),x188_i0("ret")])
    case 3: x188_many([p197d_pair("subq",4294967295,4294967295,7,10,64),p197d_kill(),x188_i2("movq",x188_reg(10,64),x188_reg(0,64)),x188_i0("ret")])
    case 4: x188_many([p197d_pair("subq",1,0,7,10,64),x188_i1("setb",x188_reg(0,8)),x188_i2("movzbl",x188_reg(0,8),x188_reg(0,32)),x188_i0("ret")])
    case 5: x188_many([p197d_pair("subq",1,0,7,10,64),x188_i1("sete",x188_reg(0,8)),x188_i2("movzbl",x188_reg(0,8),x188_reg(0,32)),x188_i0("ret")])
    case 6: x188_many([p197d_pair("subq",1,0,7,10,64),x188_i1("setl",x188_reg(0,8)),x188_i2("movzbl",x188_reg(0,8),x188_reg(0,32)),x188_i0("ret")])
    case _: x188_many([p197d_pair("subq",1,0,7,10,64),p197d_kill(),x188_i1("setb",x188_reg(0,8)),x188_i2("movzbl",x188_reg(0,8),x188_reg(0,32)),x188_i0("ret")])

@unsafe
def p197d_machine(+mode: U32) -> X188Seq:
  +name = "p197d_machine_" ++ U32.show(mode)
  x188_many([X188One{PGlobal{name}},X188One{PType{name,2}},x188_label(name),
    x197d_select(p197d_machine_body(mode)),X188One{PSize{name}}])

@unsafe
def p197d_emit() -> X181Output:
  X181Output{[X188One{PSection{1}},p197d_machine(0),p197d_machine(1),p197d_machine(2),p197d_machine(3),
    p197d_machine(4),p197d_machine(5),p197d_machine(6),p197d_machine(7),X188One{PSection{4}}],""}
