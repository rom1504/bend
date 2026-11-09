# Machine sequences concatenate in constant time. Consumers use an explicit
# work list, so neither output needs a recursive walk on the host stack.
def x188_empty(code: X188Seq) -> Bool:
  match code:
    case X188Empty{}: True{}
    case _: False{}

def x188_cat(left: X188Seq, right: X188Seq) -> X188Seq:
  match left right:
    case X188Empty{} r: r
    case l X188Empty{}: l
    case l r: X188Join{l,r}

@unsafe
def x188_finish(chunks: List<&2,X188Seq>) -> X188Seq:
  x188_finish_go(chunks,X188Empty{})

@unsafe
def x188_finish_go(chunks: List<&2,X188Seq>, acc: X188Seq) -> X188Seq:
  match chunks:
    case Nil{}: acc
    case Con{head,rest}: x188_finish_go(rest,x188_cat(head,acc))

@unsafe
def x188_many(chunks: List<&2,X188Seq>) -> X188Seq:
  x188_finish(nt_reverse(X188Seq,chunks,[]))

def x188_i0(op: String) -> X188Seq:
  X188One{PInst{X187Instruction{op,[]}}}

def x188_i1(op: String, a: X187Operand) -> X188Seq:
  X188One{PInst{X187Instruction{op,[a]}}}

def x188_i2(op: String, a: X187Operand, b: X187Operand) -> X188Seq:
  X188One{PInst{X187Instruction{op,[a,b]}}}

def x188_reg(index: U32, width: U32) -> X187Operand:
  X187Reg{index,width,False{}}

def x188_xmm(index: U32) -> X187Operand:
  X187Reg{index,128,True{}}

def x188_width_reg(typ: N111Type, index: U32) -> X187Operand:
  match typ:
    case N111U32{}: x188_reg(index,32)
    case _: x188_reg(index,64)

def x188_label(name: String) -> X188Seq:
  X188One{PLabel{name}}

def x188_error(message: String) -> X188Seq:
  X188One{PError{message}}

def x188_operand_same(a: X187Operand, b: X187Operand) -> Bool:
  match a b:
    case X187Reg{ai,aw,av} X187Reg{bi,bw,bv}:
      U32.is_eq(ai,bi) && U32.is_eq(aw,bw) && Bool.not(Bool.xor(av,bv))
    case _ _: False{}

def x188_gpr_text(index: U32, +width: U32) -> String:
  match index:
    case 0: nt_choose(String,U32.is_eq(width,64),u => "%rax",u => nt_choose(String,U32.is_eq(width,32),v => "%eax",v => "%al"))
    case 1: nt_choose(String,U32.is_eq(width,64),u => "%rcx",u => nt_choose(String,U32.is_eq(width,32),v => "%ecx",v => "%cl"))
    case 2: nt_choose(String,U32.is_eq(width,64),u => "%rdx",u => nt_choose(String,U32.is_eq(width,32),v => "%edx",v => "%dl"))
    case 3: nt_choose(String,U32.is_eq(width,64),u => "%rbx",u => nt_choose(String,U32.is_eq(width,32),v => "%ebx",v => "%bl"))
    case 4: nt_choose(String,U32.is_eq(width,64),u => "%rsp",u => nt_choose(String,U32.is_eq(width,32),v => "%esp",v => "%spl"))
    case 5: nt_choose(String,U32.is_eq(width,64),u => "%rbp",u => nt_choose(String,U32.is_eq(width,32),v => "%ebp",v => "%bpl"))
    case 6: nt_choose(String,U32.is_eq(width,64),u => "%rsi",u => nt_choose(String,U32.is_eq(width,32),v => "%esi",v => "%sil"))
    case 7: nt_choose(String,U32.is_eq(width,64),u => "%rdi",u => nt_choose(String,U32.is_eq(width,32),v => "%edi",v => "%dil"))
    case n: "%r" ++ U32.show(n) ++ nt_choose(String,U32.is_eq(width,64),u => "",u => nt_choose(String,U32.is_eq(width,32),v => "d",v => "b"))

def x188_signed32(+value: U32) -> String:
  nt_choose(String,U32.is_gt(value,2147483647),u => "-" ++ U32.show(U32.sub(0,value)),u => U32.show(value))

def x188_operand_text(operand: X187Operand) -> String:
  match operand:
    case X187Reg{index,width,vector}:
      nt_choose(String,vector,u => "%xmm" ++ U32.show(index),u => x188_gpr_text(index,width))
    case X187Imm{lo,hi}: "$" ++ p111q_u64(lo,hi)
    case X187Mem{base,disp}: x188_signed32(disp) ++ "(" ++ x188_gpr_text(base,64) ++ ")"
    case X187Rip{symbol,+lo,+hi}: symbol ++ nt_choose(String,U32.is_eq(lo,0) && U32.is_eq(hi,0),u => "",u => "+" ++ p111q_u64(lo,hi)) ++ "(%rip)"
    case X187Target{symbol}: symbol

@unsafe
def x188_operands_text(operands: List<&2,X187Operand>, separator: String) -> String:
  match operands:
    case Nil{}: ""
    case Con{head,rest}: separator ++ x188_operand_text(head) ++ x188_operands_text(rest,", ")

def x188_instruction_text(instruction: X187Instruction) -> String:
  match instruction:
    case X187Instruction{op,operands}: "  " ++ op ++ x188_operands_text(operands," ") ++ "\n"

def x188_datum_text(datum: P111QDatum) -> String:
  match datum:
    case P111QByte{value}: ".byte " ++ U32.show(value) ++ "\n"
    case P111QWord{value}: ".long " ++ U32.show(value) ++ "\n"
    case P111QLong{lo,hi}: ".quad " ++ p111q_u64(lo,hi) ++ "\n"
    case P111QReloc{symbol,offset}: ".quad " ++ symbol ++ "+" ++ U32.show(offset) ++ "\n"
    case P111QZeros{bytes}: ".zero " ++ U32.show(bytes) ++ "\n"

@unsafe
def x188_bytes_text(bytes: List<&2,U32>) -> String:
  match bytes:
    case Nil{}: ""
    case Con{head,rest}: ".byte " ++ U32.show(head) ++ "\n" ++ x188_bytes_text(rest)

def x188_item_text(item: X187Parsed) -> String:
  match item:
    case PInst{instruction}: x188_instruction_text(instruction)
    case PLabel{name}: name ++ ":\n"
    case PSection{section}:
      match section:
        case 1: ".text\n"
        case 2: ".section .rodata\n"
        case 3: ".data\n"
        case 4: ".section .note.GNU-stack,\"\",@progbits\n"
        case _: ".error \"invalid machine section\"\n"
    case PGlobal{name}: ".globl " ++ name ++ "\n"
    case PType{name,kind}: ".type " ++ name ++ nt_choose(String,U32.is_eq(kind,2),u => ", @function\n",u => ", @object\n")
    case PSize{+name}: ".size " ++ name ++ ", .-" ++ name ++ "\n"
    case PAlign{alignment}: ".balign " ++ U32.show(alignment) ++ "\n"
    case PBytes{bytes}: x188_bytes_text(bytes)
    case PDataReloc{symbol,lo,hi}: ".quad " ++ symbol ++ "+" ++ p111q_u64(lo,hi) ++ "\n"
    case PDatum{datum}: x188_datum_text(datum)
    case PEmpty{}: ""
    case PError{error}: ".error \"" ++ error ++ "\"\n"

@unsafe
def x188_render_go(pending: List<&2,X188Seq>, acc: List<&2,String>) -> String:
  match pending:
    case Nil{}: nt_text_finish(acc,"")
    case Con{X188Empty{},rest}: x188_render_go(rest,acc)
    case Con{X188One{item},rest}: x188_render_go(rest,Con{x188_item_text(item),acc})
    case Con{X188Join{left,right},rest}: x188_render_go(Con{left,Con{right,rest}},acc)

@unsafe
def x188_render(code: X188Seq) -> String:
  x188_render_go([code],[])

@unsafe
def x188_assemble(code: X188Seq) -> X187ObjectResult:
  x187_build_finish(x187_build_seq(code,x187_build_empty()))
