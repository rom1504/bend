def p194cr_op(n: U32) -> String:
  match n:
    case 0: "add"
    case 1: "mul"
    case 2: "and"
    case 3: "or"
    case _: "xor"

@unsafe
def p194cr_type(mode: U32) -> N111Type:
  nt_choose(N111Type,U32.is_lt(U32.mod(mode,10),5),u => N111U32{},u => N111U64{})

@unsafe
def p194cr_left_register(mode: U32) -> U32:
  nt_choose(U32,U32.is_eq(U32.div(mode,10),1),u => 9,u => 8)

@unsafe
def p194cr_destination(+mode: U32) -> U32:
  nt_choose(U32,U32.is_eq(U32.div(mode,10),2),u => 8,u =>
    nt_choose(U32,U32.is_eq(U32.div(mode,10),3),v => 2,v => 9))

@unsafe
def p194cr_frame(mode: U32) -> X181Frame:
  X181Frame{p111v_put(p111v_put(missing(),"a","X185Transient",
    nt_choose(U32,U32.is_eq(U32.div(mode,10),1),u => 4,u => 3),8),"b","X185Transient",4,8),0,0,[],"fixture"}

@unsafe
def p194cr_left(mode: U32) -> N111Value:
  nt_choose(N111Value,U32.is_eq(U32.div(mode,10),4),u => N111Const{7,0},u => N111Local{"a"})

@unsafe
def p194cr_pick(typ: N111Type, op: String, right: X185Physical, left: X185Physical) -> X188Seq:
  x194_cr_select(typ,op,x188_reg(9,64),x188_reg(9,32),x188_reg(9,8),right,left)

def p194cr_row(name: String, ok: Bool) -> String:
  name ++ "=" ++ nt_choose(String,ok,u => "1",u => "0")

@unsafe
def p194cr_positive(+mode: U32) -> List<&2,String>:
  nt_choose(List<&2,String>,U32.is_ge(mode,10),u => [],u =>
    Con{p194cr_row("commute-" ++ U32.show(mode),String.eq(
      x188_render(p194cr_pick(p194cr_type(mode),p194cr_op(U32.mod(mode,5)),x188_physical(9),x188_physical(8))),
      x188_render(x188_i2(x181_alu(p194cr_op(U32.mod(mode,5))) ++ x181_width(p194cr_type(mode),"q","l"),
        x188_width_reg(p194cr_type(mode),8),x188_width_reg(p194cr_type(mode),9))))),p194cr_positive(U32.inc(mode))})

@unsafe
def p194cr_controls() -> List<&2,String>:
  nt_append(String,p194cr_positive(0),[
    p194cr_row("sub-refused",x188_empty(p194cr_pick(N111U64{},"sub",x188_physical(9),x188_physical(8)))),
    p194cr_row("shift-refused",x188_empty(p194cr_pick(N111U64{},"shl",x188_physical(9),x188_physical(8)))),
    p194cr_row("compare-refused",x188_empty(p194cr_pick(N111U64{},"eq",x188_physical(9),x188_physical(8)))),
    p194cr_row("pointer-refused",x188_empty(p194cr_pick(N111Ptr{},"add",x188_physical(9),x188_physical(8)))),
    p194cr_row("left-stack-refused",x188_empty(p194cr_pick(N111U64{},"xor",x188_physical(9),X185PhysicalNone{}))),
    p194cr_row("right-stack-refused",x188_empty(p194cr_pick(N111U64{},"xor",X185PhysicalNone{},x188_physical(8)))),
    p194cr_row("different-destination-refused",x188_empty(p194cr_pick(N111U64{},"xor",x188_physical(2),x188_physical(8))))])

# Controlled physical homes test the actual hooked x185_physical_selected path.
# All used registers are caller-saved. ABI input is a pointer to two full words.
@unsafe
def p194cr_function(+mode: U32) -> X188Seq:
  +symbol = "p194cr_" ++ U32.show(mode)
  +destination = p194cr_destination(mode)
  x188_many([X188One{PGlobal{symbol}},X188One{PType{symbol,2}},x188_label(symbol),
    x188_i2("movq",X187Mem{7,0},x188_reg(8,64)),
    x188_i2("movq",X187Mem{7,8},x188_reg(9,64)),
    x185_physical_selected(p194cr_type(mode),p194cr_op(U32.mod(mode,5)),p194cr_left(mode),N111Local{"b"},
      N111Ids{missing(),missing()},p194cr_frame(mode),x188_physical(destination)),
    x188_i2("movq",x188_reg(destination,64),x188_reg(0,64)),x188_i0("ret"),X188One{PSize{symbol}}])

@unsafe
def p194cr_functions(+mode: U32) -> X188Seq:
  nt_choose(X188Seq,U32.is_ge(mode,50),u => X188Empty{},u =>
    x188_cat(p194cr_function(mode),p194cr_functions(U32.inc(mode))))

def p194cr_emit() -> X181Output:
  X181Output{[x188_many([X188One{PSection{1}},p194cr_functions(0),X188One{PSection{4}}])],""}
