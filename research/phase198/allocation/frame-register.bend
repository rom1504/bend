# RBP remains caller-preserved via the canonical push/pop. While the fixed
# allocation is in force, old RBP+d equals current RSP+frameSize+d.
type X198FRSlot is Data:
  X198FRSlot{+bytes: U32, +disp: U32}

type X198FRResult is Data:
  X198FRResult{+text: X188Seq, +read: Bool, +wrote: Bool}
  X198FRRefused{}

def x198fr_special(+r: U32) -> Bool: U32.is_eq(r,4) || U32.is_eq(r,5)

@unsafe
def x198fr_operand(+o: X187Operand, +slot: X198FRSlot) -> Maybe<&2,X187Operand>:
  match o slot:
    case X187Mem{5,+disp} X198FRSlot{+bytes,target}:
      +offset = U32.add(bytes,disp)
      nt_choose(Maybe<&2,X187Operand>,U32.is_lt(offset,2147483648),
        u => Some{X187Mem{4,offset}},u => None{})
    case X187Reg{index,width,False{}} _:
      nt_choose(Maybe<&2,X187Operand>,x198fr_special(index),u => None{},u => Some{o})
    case X187Indexed{base,index,scale,disp} _:
      nt_choose(Maybe<&2,X187Operand>,U32.is_eq(base,5) || U32.is_eq(index,5),u => None{},u => Some{o})
    case _ _: Some{o}

def x198fr_hit(value: X187Operand, slot: X198FRSlot) -> Bool:
  match value slot:
    case X187Mem{5,d} X198FRSlot{bytes,t}: U32.is_eq(d,t)
    case _ _: False{}

@unsafe
def x198fr_pair_ready(+op: String, +read: Bool, +wrote: Bool,
    left: Maybe<&2,X187Operand>, right: Maybe<&2,X187Operand>) -> X198FRResult:
  match left right:
    case Some{+aa} Some{+bb}:
      nt_choose(X198FRResult,read || wrote,u =>
        nt_choose(X198FRResult,(read && Bool.not(wrote) && (String.eq(op,"movq") || String.eq(op,"movl") || String.eq(op,"movd"))) ||
            (wrote && Bool.not(read) && String.eq(op,"movq")),v =>
          X198FRResult{x188_i2(op,nt_choose(X187Operand,read,w =>
            x188_reg(5,nt_choose(U32,String.eq(op,"movq"),k => 64,k => 32)),w => aa),
            nt_choose(X187Operand,wrote,w => x188_reg(5,64),w => bb)),read,wrote},v => X198FRRefused{}),
        u => X198FRResult{x188_i2(op,aa,bb),False{},False{}})
    case _ _: X198FRRefused{}

@unsafe
def x198fr_binary(+op: String, +a: X187Operand, +b: X187Operand, +slot: X198FRSlot) -> X198FRResult:
  x198fr_pair_ready(op,x198fr_hit(a,slot),x198fr_hit(b,slot),x198fr_operand(a,slot),x198fr_operand(b,slot))

@unsafe
def x198fr_unary(op: String, candidate: Maybe<&2,X187Operand>) -> X198FRResult:
  match candidate:
    case Some{operand}: X198FRResult{x188_i1(op,operand),False{},False{}}
    case None{}: X198FRRefused{}

@unsafe
def x198fr_item(+item: X187Parsed, +slot: X198FRSlot) -> X198FRResult:
  match item slot:
    case PInst{X187Instruction{+op,[X187Reg{4,64,False{}},X187Reg{5,64,False{}}]}} _:
      nt_choose(X198FRResult,String.eq(op,"movq"),u => X198FRResult{X188Empty{},False{},False{}},u => X198FRRefused{})
    case PInst{X187Instruction{+op,[X187Reg{5,64,False{}},X187Reg{4,64,False{}}]}} X198FRSlot{bytes,disp}:
      nt_choose(X198FRResult,String.eq(op,"movq"),
        u => X198FRResult{x188_i2("leaq",X187Mem{4,bytes},x188_reg(4,64)),False{},False{}},u => X198FRRefused{})
    case PInst{X187Instruction{+op,[X187Imm{lo,0},X187Reg{4,64,False{}}]}} X198FRSlot{bytes,disp}:
      nt_choose(X198FRResult,String.eq(op,"subq") && U32.is_eq(lo,bytes),
        u => X198FRResult{X188One{item},False{},False{}},u => X198FRRefused{})
    case PInst{X187Instruction{+op,[X187Reg{5,64,False{}}]}} _:
      nt_choose(X198FRResult,String.eq(op,"pushq") || String.eq(op,"popq"),
        u => X198FRResult{X188One{item},False{},False{}},u => X198FRRefused{})
    case PInst{X187Instruction{op,[a,b]}} _: x198fr_binary(op,a,b,slot)
    case PInst{X187Instruction{+op,[+a]}} _:
      nt_choose(X198FRResult,x198fr_hit(a,slot) || String.eq(op,"pushq") || String.eq(op,"popq"),
        u => X198FRRefused{},u => x198fr_unary(op,x198fr_operand(a,slot)))
    case PInst{X187Instruction{op,Nil{}}} _: X198FRResult{X188One{item},False{},False{}}
    case PInst{inst} _: X198FRRefused{}
    case _ _: X198FRResult{X188One{item},False{},False{}}

law x198fr_work:
  for todo: List<&2,X188Seq>
  for +slot: X198FRSlot
  for +original: X188Seq
  for +read: Bool
  for +wrote: Bool
  for output: List<&2,X188Seq>
  X188Seq

@unsafe
def x198fr_next(item: X198FRResult, rest: List<&2,X188Seq>, slot: X198FRSlot,
    +original: X188Seq, read: Bool, wrote: Bool, output: List<&2,X188Seq>) -> X188Seq:
  match item:
    case X198FRResult{text,r,w}: x198fr_work(rest,slot,original,read || r,wrote || w,Con{text,output})
    case X198FRRefused{}: original

@unsafe
def x198fr_work(todo,slot,original,read,wrote,output):
  match todo:
    case Nil{}: nt_choose(X188Seq,read && wrote,u => x188_finish(output),u => original)
    case Con{X188Empty{},rest}: x198fr_work(rest,slot,original,read,wrote,output)
    case Con{X188One{item},rest}: x198fr_next(x198fr_item(item,slot),rest,slot,original,read,wrote,output)
    case Con{X188Join{a,b},rest}: x198fr_work(Con{a,Con{b,rest}},slot,original,read,wrote,output)

@unsafe
def x198fr_chosen(+code: X188Seq, +bytes: U32, +calls: U32, slots: KDef, choice: X181RegisterChoice) -> X188Seq:
  match choice:
    case X181RegisterChoice{name,n}:
      +home = p111v_get(slots,name)
      +size = U32.add(x181_frame_align(U32.add(bytes,calls),16),48)
      nt_choose(X188Seq,String.eq(dk(home),"X181Stack") && U32.is_gt(da(home),40) &&
          U32.is_le(da(home),bytes) && U32.is_lt(bytes,1073741824) && U32.is_lt(calls,1073741824) &&
          U32.is_gt(size,bytes) && U32.is_lt(size,2147483648),
        u => x198fr_work([code],X198FRSlot{size,U32.sub(0,da(home))},code,False{},False{},[]),u => code)

@unsafe
def x198fr_apply(code: X188Seq, frame: X181Frame, counts: X181ReadCounts) -> X188Seq:
  match frame counts:
    case X181Frame{+slots,bytes,calls,ps,sym} X181ReadCounts{reads,names}:
      x198fr_chosen(code,bytes,calls,slots,x181_register_best(names,reads,slots,X181RegisterChoice{"",2}))

@unsafe
def x198fr_final(+symbol: String, result: X181Code, +setup: List<&2,P113DStmt>,
    +body: List<&2,P113DStmt>, +frame: X181Frame) -> X181Output:
  match result:
    case X181Code{chunks,next,+terminal,+error}:
      +code = x191_frame_forward(x188_finish(chunks))
      +text = nt_choose(X188Seq,U32.is_le(p113i_add(p113i_size(setup),p113i_size(body)),256) &&
          x190_register_loop(body),u => x198fr_apply(code,frame,x191_joint_reads(setup,body,x181_tail_args(frame))),u => code)
      X181Output{[x188_cat(text,X188One{PSize{symbol}})],
        nt_choose(String,String.is_empty(error) && Bool.not(terminal),u => "x86 unterminated function",u => error)}
