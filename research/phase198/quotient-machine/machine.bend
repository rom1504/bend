# The window is the reverse output of the existing bounded-stack machine walk.
# A label, store to another address, nonliteral divisor, or other instruction
# breaks the shape. Both scratch writes precede the seven call-argument moves.
@unsafe
def x198qm_rr(item: X188Seq, want: String, src: U32, dst: U32, +width: U32) -> Bool:
  match item:
    case X188One{PInst{X187Instruction{op,[X187Reg{a,b,False{}},X187Reg{c,d,False{}}]}}}:
      String.eq(op,want) && U32.is_eq(a,src) && U32.is_eq(c,dst) && U32.is_eq(b,width) && U32.is_eq(d,width)
    case _: False{}

@unsafe
def x198qm_state(item: X188Seq) -> Bool:
  match item:
    case X188One{PInst{X187Instruction{op,[X187Reg{src,64,False{}},X187Reg{7,64,False{}}]}}}:
      String.eq(op,"movq") && U32.is_lt(src,16)
    case _: False{}

@unsafe
def x198qm_imm(item: X188Seq, target: U32) -> U32:
  match item:
    case X188One{PInst{X187Instruction{op,[X187Imm{value,0},X187Reg{dst,64,False{}}]}}}:
      nt_choose(U32,String.eq(op,"movabsq") && U32.is_eq(dst,target),u => value,u => 0)
    case _: 0

@unsafe
def x198qm_lea(item: X188Seq, target: U32) -> U32:
  match item:
    case X188One{PInst{X187Instruction{op,[X187Mem{5,offset},X187Reg{dst,64,False{}}]}}}:
      nt_choose(U32,String.eq(op,"leaq") && U32.is_eq(dst,target),u => offset,u => 0)
    case _: 0

@unsafe
def x198qm_store(item: X188Seq) -> Bool:
  match item:
    case X188One{PInst{X187Instruction{op,[X187Reg{11,64,False{}},X187Mem{10,8}]}}}: String.eq(op,"movq")
    case _: False{}

@unsafe
def x198qm_calculate(+d: U32, +modulo: Bool, plan: P198Quot) -> X188Seq:
  match plan:
    case P198Shift{shift}:
      x188_many([x188_i2("movl",X187Mem{10,0},x188_reg(0,32)),
        nt_choose(X188Seq,modulo,u => x188_i2("andl",X187Imm{U32.sub(d,1),0},x188_reg(0,32)),
          u => x188_i2("shrl",X187Imm{shift,0},x188_reg(0,32)))])
    case P198Magic{m,s}:
      x188_many([x188_i2("movl",X187Mem{10,0},x188_reg(0,32)),
        nt_choose(X188Seq,modulo,u => x188_i2("movl",x188_reg(0,32),x188_reg(10,32)),u => X188Empty{}),
        x188_i2("movabsq",X187Imm{m,0},x188_reg(11,64)),x188_i2("imulq",x188_reg(11,64),x188_reg(0,64)),
        x188_i2("shrq",X187Imm{s,0},x188_reg(0,64)),nt_choose(X188Seq,modulo,
          u => x188_many([x188_i2("movabsq",X187Imm{d,0},x188_reg(11,64)),x188_i2("imull",x188_reg(11,32),x188_reg(0,32)),
            x188_i2("subl",x188_reg(0,32),x188_reg(10,32)),x188_i2("movl",x188_reg(10,32),x188_reg(0,32))]),
          u => X188Empty{})])
    case P198NoQuot{}: X188Empty{}

@unsafe
def x198qm_accept(+d: U32, +id: U32, +plan: P198Quot,
    call: X188Seq, output: List<&2,X188Seq>) -> List<&2,X188Seq>:
  match plan:
    case P198NoQuot{}: Con{call,output}
    case _: Con{x198qm_calculate(d,U32.is_eq(id,19),plan),output}

@unsafe
def x198qm_window(+output: List<&2,X188Seq>, +call: X188Seq) -> List<&2,X188Seq>:
  match output:
    case Con{a,Con{b,Con{c,Con{ptr,Con{e,Con{opid,Con{state,+stores}}}}}}}:
      match stores:
        case Con{write,Con{literal,Con{address,rest}}}:
          +arg = x198qm_lea(ptr,2)
          +id = x198qm_imm(opid,6)
          +d = x198qm_imm(literal,11)
          nt_choose(List<&2,X188Seq>,x198qm_rr(a,"xorl",0,0,32) && x198qm_rr(b,"movl",1,1,32) &&
            U32.is_eq(x198qm_imm(c,1),2) && x191_ff_private(arg) && U32.is_eq(arg,x198qm_lea(address,10)) &&
            x198qm_rr(e,"movl",6,6,32) && (U32.is_eq(id,18) || U32.is_eq(id,19)) &&
            x198qm_state(state) && x198qm_store(write),
            u => x198qm_accept(d,id,p198q_plan(d),call,output),
            u => Con{call,output})
        case _: Con{call,output}
    case _: Con{call,output}

@unsafe
def x198qm_item(+item: X187Parsed, +previous: X191FrameStore, +output: List<&2,X188Seq>) -> List<&2,X188Seq>:
  match item:
    case PInst{X187Instruction{op,[X187Target{name}]}}:
      nt_choose(List<&2,X188Seq>,String.eq(op,"call") && String.eq(name,"p111_rt_op"),
        u => x198qm_window(output,X188One{item}),u => Con{x191_ff_item(item,previous),output})
    case _: Con{x191_ff_item(item,previous),output}

@unsafe
def x191_ff_work(todo: List<&2,X188Seq>, previous: X191FrameStore, output: List<&2,X188Seq>) -> X188Seq:
  match todo:
    case Nil{}: x188_finish(output)
    case Con{X188Empty{},rest}: x191_ff_work(rest,previous,output)
    case Con{X188Join{left,right},rest}: x191_ff_work(Con{left,Con{right,rest}},previous,output)
    case Con{X188One{+item},rest}: x191_ff_work(rest,x191_ff_store(item),x198qm_item(item,previous,output))
