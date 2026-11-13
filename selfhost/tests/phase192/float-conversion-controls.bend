# Typed generated fixtures: both object/rendered routes consume the same output.
# Core, XMM home, stack home and destructive buffer-pointer destination routes.
@unsafe
def p192fc_frame() -> X181Frame:
  X181Frame{p111v_put(p111v_put(missing(),"buffer","X185Transient",0,8),
    "result","X181Stack",48,8),64,0,[],"p192fc"}

@unsafe
def p192fc_function(+name: String, body: X188Seq) -> X188Seq:
  x188_many([X188One{PGlobal{name}},X188One{PType{name,2}},x188_label(name),
    x188_i1("pushq",x188_reg(5,64)),x188_i2("movq",x188_reg(4,64),x188_reg(5,64)),
    x188_i2("subq",X187Imm{64,0},x188_reg(4,64)),body,
    x188_i2("movq",x188_reg(5,64),x188_reg(4,64)),x188_i1("popq",x188_reg(5,64)),
    x188_i0("ret"),X188One{PSize{name}}])

@unsafe
def p192fc_core(name: String, id: U32) -> X188Seq:
  p192fc_function(name,x188_many([x188_i2("movd",x188_reg(7,32),x188_xmm(0)),
    x192_float_conversion_core(id),x188_i2("movq",x188_reg(10,64),x188_reg(0,64))]))

@unsafe
def p192fc_xmm(name: String, id: U32) -> X188Seq:
  p192fc_function(name,x188_many([x188_i2("movd",x188_reg(7,32),x188_xmm(2)),
    x192_float_conversion("result",id,N111Local{"input"},N111Ids{missing(),missing()},p192fc_frame(),
      p111v_put(p111v_put(missing(),"input","X186Xmm",0,0),"result","X186Xmm",1,0)),
    x188_i2("movd",x188_xmm(3),x188_reg(0,32))]))

@unsafe
def p192fc_buffer(name: String, id: U32, +alias: Bool) -> X188Seq:
  +destination = nt_choose(String,alias,u => "buffer",u => "result")
  p192fc_function(name,x188_many([
    x188_i2("movq",X187Imm{4294967295,4294967295},X187Mem{5,4294967248}),
    x192_float_conversion_buffer(destination,id,"buffer",N111Ids{missing(),missing()},p192fc_frame()),
    nt_choose(X188Seq,alias,u => x188_i2("movq",x188_reg(7,64),x188_reg(0,64)),
      u => x188_i2("movq",X187Mem{5,4294967248},x188_reg(0,64)))]))

@unsafe
def p192fc_emit() -> X181Output:
  X181Output{[x188_many([X188One{PSection{1}},
    p192fc_core("p192fc_f58",58),p192fc_core("p192fc_u23",23),
    p192fc_xmm("p192fc_x58",58),p192fc_xmm("p192fc_x23",23),
    p192fc_buffer("p192fc_b58",58,False{}),p192fc_buffer("p192fc_b23",23,False{}),
    p192fc_buffer("p192fc_a58",58,True{}),p192fc_buffer("p192fc_a23",23,True{})])],""}

@unsafe
def p192fc_row(name: String, good: Bool) -> String:
  name ++ nt_choose(String,good,u => "=1",u => "=0")

@unsafe
def p192fc_encoded(result: X187Encoded, expected: List<&2,U32>) -> Bool:
  match result:
    case X187Encoded{bytes,relocations,error}:
      String.is_empty(error) && List.is_empty(&2,X187Relocation,relocations) && p192fc_equal(bytes,expected)

@unsafe
def p192fc_refused(result: X187Encoded) -> Bool:
  match result:
    case X187Encoded{bytes,relocations,error}: Bool.not(String.is_empty(error))

@unsafe
def p192fc_controls() -> List<&2,String>:
  [p192fc_row("cvtt-high-registers",p192fc_encoded(x187_encode(X187Instruction{"cvttss2siq",[x188_xmm(9),x188_reg(10,64)]},0),[243,77,15,44,209])),
   p192fc_row("comiss",p192fc_encoded(x187_encode(X187Instruction{"comiss",[x188_xmm(1),x188_xmm(0)]},0),[15,47,193])),
   p192fc_row("cvtt-reject-word",p192fc_refused(x187_encode(X187Instruction{"cvttss2siq",[x188_xmm(0),x188_reg(10,32)]},0))),
   p192fc_row("cvtt-reject-gpr-source",p192fc_refused(x187_encode(X187Instruction{"cvttss2siq",[x188_reg(0,64),x188_reg(10,64)]},0))),
   p192fc_row("cvtt-reject-memory-destination",p192fc_refused(x187_encode(X187Instruction{"cvttss2siq",[x188_xmm(0),X187Mem{7,0}]},0))),
   p192fc_row("cvtt-reject-arity",p192fc_refused(x187_encode(X187Instruction{"cvttss2siq",[x188_xmm(0)]},0)))]

@unsafe
def p192fc_equal(a: List<&2,U32>, b: List<&2,U32>) -> Bool:
  match a b:
    case Nil{} Nil{}: True{}
    case Con{x,xs} Con{y,ys}: U32.is_eq(x,y) && p192fc_equal(xs,ys)
    case _ _: False{}
