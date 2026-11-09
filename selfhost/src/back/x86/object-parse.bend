# Strict parser for the finite AT&T dialect emitted by this backend. Selection
# remains shared with assembly output. No source-language semantics live here.
# Decimal words preserve all 64 bits; no Nat/Float conversion is involved.
type X187Number is Data:
  X187Number{+lo: U32, +hi: U32, +negative: Bool, +error: String}
type X187Head is Data:
  X187Head{+head: String, +tail: String}
type X187OperandResult is Data:
  X187OperandResult{+value: X187Operand, +error: String}
type X187Operands is Data:
  X187Operands{+values: List<&2,X187Operand>, +error: String}
type X187Expression is Data:
  X187Expression{+symbol: String, +lo: U32, +hi: U32, +error: String}

@unsafe
def x187p_tail(text: String) -> String:
  match text:
    case SNil{}: ""
    case SCon{head,tail}: tail

@unsafe
def x187p_member(+text: String, names: List<&2,String>) -> Bool:
  match names:
    case Nil{}: False{}
    case Con{head,tail}: String.eq(text,head) || x187p_member(text,tail)

@unsafe
def x187p_symbol_go(text: String, +count: U32) -> Bool:
  match text:
    case SNil{}: U32.is_gt(count,0)
    case SCon{head,tail}:
      +n = Char.to_u32(head)
      U32.is_lt(count,4096) && ((U32.is_ge(n,65) && U32.is_le(n,90)) ||
        (U32.is_ge(n,97) && U32.is_le(n,122)) || U32.is_eq(n,95) || U32.is_eq(n,46) ||
        (U32.is_gt(count,0) && U32.is_ge(n,48) && U32.is_le(n,57))) &&
        x187p_symbol_go(tail,U32.inc(count))

@unsafe
def x187p_symbol(+text: String) -> Bool:
  x187p_symbol_go(text,0) && Bool.not(String.eq(text,"."))

@unsafe
def x187p_head(text: String, +reversed: String) -> X187Head:
  match text:
    case SNil{}: X187Head{String.reverse(reversed),""}
    case SCon{+head,+tail}:
      nt_choose(X187Head,Char.is_eq(head,' ') || Char.is_eq(head,'\t'),
        u => X187Head{String.reverse(reversed),String.trim(tail)},
        u => x187p_head(tail,SCon{head,reversed}))

@unsafe
def x187p_negative(number: X187Number) -> X187Number:
  match number:
    case X187Number{+lo,+hi,negative,+error}:
      nt_choose(X187Number,String.is_empty(error) &&
          (U32.is_lt(hi,2147483648) || (U32.is_eq(hi,2147483648) && U32.is_eq(lo,0))),
        u => X187Number{U32.sub(0,lo),U32.sub(U32.sub(0,hi),
          nt_choose(U32,U32.is_eq(lo,0),v => 0,v => 1)),True{},""},
        u => X187Number{0,0,True{},nt_choose(String,String.is_empty(error),v => "signed64 overflow",v => error)})

@unsafe
def x187p_digit_next(+tail: String, +lo: U32, +hi: U32, +digit: U32) -> X187Number:
  +a = U32.add(U32.mul(U32.and(lo,65535),10),digit)
  +b = U32.add(U32.mul(U32.shrn(lo,16n),10),U32.shrn(a,16n))
  x187p_digits(tail,U32.or(U32.shln(U32.and(b,65535),16n),U32.and(a,65535)),
    U32.add(U32.mul(hi,10),U32.shrn(b,16n)),True{})

@unsafe
def x187p_digits(text: String, +lo: U32, +hi: U32, +seen: Bool) -> X187Number:
  match text:
    case SNil{}: X187Number{lo,hi,False{},nt_choose(String,seen,u => "",u => "empty decimal")}
    case SCon{head,+tail}:
      +digit = U32.sub(Char.to_u32(head),48)
      nt_choose(X187Number,U32.is_le(digit,9),u =>
        nt_choose(X187Number,U32.is_lt(hi,429496729) ||
          (U32.is_eq(hi,429496729) && (U32.is_lt(lo,2576980377) ||
            (U32.is_eq(lo,2576980377) && U32.is_le(digit,5)))),
          v => x187p_digit_next(tail,lo,hi,digit),v => X187Number{0,0,False{},"unsigned64 overflow"}),
        u => X187Number{0,0,False{},"invalid decimal"})

@unsafe
def x187p_number(text: String) -> X187Number:
  match text:
    case SNil{}: X187Number{0,0,False{},"empty decimal"}
    case SCon{+head,+tail}:
      nt_choose(X187Number,Char.is_eq(head,'-'),u => x187p_negative(x187p_digits(tail,0,0,False{})),u =>
        nt_choose(X187Number,Char.is_eq(head,'+'),u => x187p_digits(tail,0,0,False{}),
          u => x187p_digits(SCon{head,tail},0,0,False{})))

@unsafe
def x187p_numeric(text: String) -> Bool:
  match text:
    case SNil{}: False{}
    case SCon{+head,tail}: Char.is_digit(head) || Char.is_eq(head,'-') || Char.is_eq(head,'+')

@unsafe
def x187p_lookup(+name: String, names: List<&2,String>, +index: U32) -> U32:
  match names:
    case Nil{}: 16
    case Con{head,tail}: nt_choose(U32,String.eq(name,head),u => index,
      u => x187p_lookup(name,tail,U32.inc(index)))

@unsafe
def x187p_reg_finish(+index: U32, +width: U32, +vector: Bool) -> X187OperandResult:
  nt_choose(X187OperandResult,U32.is_lt(index,16),
    u => X187OperandResult{X187Reg{index,width,vector},""},
    u => X187OperandResult{X187Imm{0,0},"unsupported register"})

@unsafe
def x187p_register(+name: String) -> X187OperandResult:
  +wide = x187p_lookup(name,["%rax","%rcx","%rdx","%rbx","%rsp","%rbp","%rsi","%rdi",
    "%r8","%r9","%r10","%r11","%r12","%r13","%r14","%r15"],0)
  +narrow = x187p_lookup(name,["%eax","%ecx","%edx","%ebx","%esp","%ebp","%esi","%edi",
    "%r8d","%r9d","%r10d","%r11d","%r12d","%r13d","%r14d","%r15d"],0)
  +byte = x187p_lookup(name,["%al","%cl","%dl","%bl","%spl","%bpl","%sil","%dil",
    "%r8b","%r9b","%r10b","%r11b","%r12b","%r13b","%r14b","%r15b"],0)
  nt_choose(X187OperandResult,U32.is_lt(wide,16),u => x187p_reg_finish(wide,64,False{}),u =>
    nt_choose(X187OperandResult,U32.is_lt(narrow,16),u => x187p_reg_finish(narrow,32,False{}),u =>
      nt_choose(X187OperandResult,U32.is_lt(byte,16),u => x187p_reg_finish(byte,8,False{}),u =>
        x187p_reg_finish(x187p_lookup(name,["%xmm0","%xmm1","%xmm2","%xmm3","%xmm4","%xmm5","%xmm6","%xmm7",
          "%xmm8","%xmm9","%xmm10","%xmm11","%xmm12","%xmm13","%xmm14","%xmm15"],0),128,True{}))))

@unsafe
def x187p_expression_number(+symbol: String, number: X187Number) -> X187Expression:
  match number:
    case X187Number{lo,hi,negative,error}: X187Expression{symbol,lo,hi,error}

@unsafe
def x187p_expression_end(+symbol: String, +tail: String) -> X187Expression:
  nt_choose(X187Expression,x187p_symbol(symbol),
    u => nt_choose(X187Expression,String.is_empty(tail),v => X187Expression{symbol,0,0,""},
      v => x187p_expression_number(symbol,x187p_number(tail))),
    u => X187Expression{"",0,0,"invalid symbol expression"})

@unsafe
def x187p_expression(text: String, +reversed: String) -> X187Expression:
  match text:
    case SNil{}: x187p_expression_end(String.reverse(reversed),"")
    case SCon{+head,+tail}:
      nt_choose(X187Expression,Char.is_eq(head,'+') || Char.is_eq(head,'-'),
        u => x187p_expression_end(String.reverse(reversed),SCon{head,tail}),
        u => x187p_expression(tail,SCon{head,reversed}))

@unsafe
def x187p_immediate(number: X187Number) -> X187OperandResult:
  match number:
    case X187Number{lo,hi,negative,error}: X187OperandResult{X187Imm{lo,hi},error}

@unsafe
def x187p_rip(expression: X187Expression) -> X187OperandResult:
  match expression:
    case X187Expression{symbol,lo,hi,error}: X187OperandResult{X187Rip{symbol,lo,hi},error}

@unsafe
def x187p_memory_number(+base: U32, number: X187Number) -> X187OperandResult:
  match number:
    case X187Number{+lo,+hi,negative,+error}:
      nt_choose(X187OperandResult,String.is_empty(error) &&
        ((U32.is_eq(hi,0) && U32.is_le(lo,2147483647)) ||
          (U32.is_eq(hi,4294967295) && U32.is_ge(lo,2147483648))),
        u => X187OperandResult{X187Mem{base,lo},""},
        u => X187OperandResult{X187Imm{0,0},"invalid signed32 displacement"})

@unsafe
def x187p_memory_reg(+displacement: String, reg: X187OperandResult) -> X187OperandResult:
  match reg:
    case X187OperandResult{X187Reg{+index,+width,+vector},+error}:
      nt_choose(X187OperandResult,String.is_empty(error) && U32.is_eq(width,64) && Bool.not(vector),
        u => x187p_memory_number(index,x187p_number(nt_choose(String,String.is_empty(displacement),v => "0",v => displacement))),
        u => X187OperandResult{X187Imm{0,0},"invalid memory base"})
    case _: X187OperandResult{X187Imm{0,0},"invalid memory base"}

@unsafe
def x187p_memory_parts(parts: List<&2,String>) -> X187OperandResult:
  match parts:
    case Con{+displacement,Con{+base,Nil{}}}:
      nt_choose(X187OperandResult,String.ends_with(base,")"),u =>
        nt_choose(X187OperandResult,String.eq(base,"%rip)"),
          v => x187p_rip(x187p_expression(displacement,"")),
          v => x187p_memory_reg(displacement,x187p_register(String.reverse(x187p_tail(String.reverse(base)))))),
        u => X187OperandResult{X187Imm{0,0},"unterminated memory operand"})
    case _: X187OperandResult{X187Imm{0,0},"invalid memory operand"}

@unsafe
def x187p_operand(+text: String) -> X187OperandResult:
  nt_choose(X187OperandResult,String.starts_with(text,"%"),u => x187p_register(text),u =>
    nt_choose(X187OperandResult,String.starts_with(text,"$"),u => x187p_immediate(x187p_number(x187p_tail(text))),u =>
      nt_choose(X187OperandResult,String.contains(text,"("),u => x187p_memory_parts(String.split(text,'(')),u =>
        nt_choose(X187OperandResult,x187p_symbol(text),u => X187OperandResult{X187Target{text},""},
          u => X187OperandResult{X187Imm{0,0},"unsupported operand"}))))

@unsafe
def x187p_operands_next(+rest: List<&2,String>, +acc: List<&2,X187Operand>, item: X187OperandResult) -> X187Operands:
  match item:
    case X187OperandResult{+value,+error}:
      nt_choose(X187Operands,String.is_empty(error),u => x187p_operands(rest,Con{value,acc}),
        u => X187Operands{[],error})

@unsafe
def x187p_operands(parts: List<&2,String>, +acc: List<&2,X187Operand>) -> X187Operands:
  match parts:
    case Nil{}: X187Operands{nt_reverse(X187Operand,acc,[]),""}
    case Con{head,rest}: x187p_operands_next(rest,acc,x187p_operand(String.trim(head)))

@unsafe
def x187p_instruction_done(+op: String, operands: X187Operands) -> X187Parsed:
  match operands:
    case X187Operands{+values,+error}:
      nt_choose(X187Parsed,String.is_empty(error),u => PInst{X187Instruction{op,values}},u => PError{error})

@unsafe
def x187p_instruction(+op: String, +tail: String) -> X187Parsed:
  nt_choose(X187Parsed,x187p_member(op,["movq","movl","movb","movabsq","movzbl","leaq",
    "addq","addl","subq","subl","imulq","imull","andq","andl","andb","orq","orl","orb",
    "xorq","xorl","xorb","shlq","shll","shrq","shrl","sarq","sarl","cmpq","cmpl","cmpb",
    "testq","testl","testb","sete","setne","setb","setbe","seta","setae","setl","setle","setg","setge","setp","setnp",
    "pushq","popq","ret","call","jmp","jz","jnz","je","jne","ja","jae","jb","jbe","jl","jle","jg","jge",
    "movd","movaps","pxor","addss","subss","mulss","divss","ucomiss","cvtsi2ssq"]),
    u => x187p_instruction_done(op,nt_choose(X187Operands,String.is_empty(tail),
      v => X187Operands{[],""},v => x187p_operands(String.split(tail,','),[]))),
    u => PError{"unsupported instruction: " ++ op})

@unsafe
def x187p_little(+lo: U32, +hi: U32, count: U32) -> List<&2,U32>:
  match count:
    case 0: []
    case _: Con{U32.and(lo,255),x187p_little(U32.or(U32.shrn(lo,8n),U32.shln(hi,24n)),U32.shrn(hi,8n),U32.sub(count,1))}

@unsafe
def x187p_data_number(+width: U32, number: X187Number) -> X187Parsed:
  match number:
    case X187Number{+lo,+hi,+negative,+error}:
      nt_choose(X187Parsed,String.is_empty(error),u =>
        nt_choose(X187Parsed,U32.is_eq(width,8) ||
          (U32.is_eq(width,4) && (U32.is_eq(hi,0) || (negative && U32.is_eq(hi,4294967295) && U32.is_ge(lo,2147483648)))) ||
          (U32.is_eq(width,1) && ((U32.is_eq(hi,0) && U32.is_le(lo,255)) ||
            (negative && U32.is_eq(hi,4294967295) && U32.is_ge(lo,4294967168)))),
          v => PBytes{x187p_little(lo,hi,width)},v => PError{"data width overflow"}),u => PError{error})

@unsafe
def x187p_data_expression(expression: X187Expression) -> X187Parsed:
  match expression:
    case X187Expression{+symbol,lo,hi,+error}:
      nt_choose(X187Parsed,String.is_empty(error),u => PDataReloc{symbol,lo,hi},u => PError{error})

@unsafe
def x187p_zero(count: U32) -> List<&2,U32>:
  match count:
    case 0: []
    case _: Con{0,x187p_zero(U32.sub(count,1))}

@unsafe
def x187p_directive_number(+op: String, number: X187Number) -> X187Parsed:
  match number:
    case X187Number{+lo,+hi,+negative,+error}:
      nt_choose(X187Parsed,String.is_empty(error) && U32.is_eq(hi,0) && Bool.not(negative),u =>
        nt_choose(X187Parsed,String.eq(op,".zero"),
          v => nt_choose(X187Parsed,U32.is_le(lo,8388608),w => PBytes{x187p_zero(lo)},w => PError{"zero directive exceeds 8MiB"}),
          v => nt_choose(X187Parsed,U32.is_gt(lo,0) && U32.is_le(lo,65536) && U32.is_eq(U32.and(lo,U32.sub(lo,1)),0),
            w => PAlign{lo},w => PError{"unsupported alignment"})),u => PError{"invalid directive integer"})

@unsafe
def x187p_type_parts(parts: List<&2,String>) -> X187Parsed:
  match parts:
    case Con{+name,Con{kind,Nil{}}}:
      x187p_type(String.trim(name),String.trim(kind))
    case _: PError{"invalid type directive"}

@unsafe
def x187p_type(+name: String, +kind: String) -> X187Parsed:
  nt_choose(X187Parsed,x187p_symbol(name) && (String.eq(kind,"@function") || String.eq(kind,"@object")),
    u => PType{name,nt_choose(U32,String.eq(kind,"@function"),v => 2,v => 1)},u => PError{"unsupported symbol type"})

@unsafe
def x187p_size_parts(parts: List<&2,String>) -> X187Parsed:
  match parts:
    case Con{name,Con{size,Nil{}}}: x187p_size(String.trim(name),String.trim(size))
    case _: PError{"invalid size directive"}

@unsafe
def x187p_size(+name: String, +size: String) -> X187Parsed:
  nt_choose(X187Parsed,x187p_symbol(name) && String.eq(size,".-" ++ name),u => PSize{name},
    u => PError{"unsupported size expression"})

@unsafe
def x187p_directive(+op: String, +tail: String) -> X187Parsed:
  nt_choose(X187Parsed,String.eq(op,".text") && String.is_empty(tail),u => PSection{1},u =>
  nt_choose(X187Parsed,String.eq(op,".data") && String.is_empty(tail),u => PSection{3},u =>
  nt_choose(X187Parsed,String.eq(op,".rodata") && String.is_empty(tail),u => PSection{2},u =>
  nt_choose(X187Parsed,String.eq(op,".section"),u =>
    nt_choose(X187Parsed,String.eq(tail,".note.GNU-stack,\"\",@progbits"),v => PSection{4},v =>
    nt_choose(X187Parsed,String.eq(tail,".rodata"),v => PSection{2},v => PError{"unsupported section"})),u =>
  nt_choose(X187Parsed,String.eq(op,".globl"),u =>
    nt_choose(X187Parsed,x187p_symbol(tail),v => PGlobal{tail},v => PError{"invalid global symbol"}),u =>
  nt_choose(X187Parsed,String.eq(op,".type"),u => x187p_type_parts(String.split(tail,',')),u =>
  nt_choose(X187Parsed,String.eq(op,".size"),u => x187p_size_parts(String.split(tail,',')),u =>
  nt_choose(X187Parsed,String.eq(op,".balign") || String.eq(op,".zero"),u => x187p_directive_number(op,x187p_number(tail)),u =>
  nt_choose(X187Parsed,String.eq(op,".byte"),u => x187p_data_number(1,x187p_number(tail)),u =>
  nt_choose(X187Parsed,String.eq(op,".long"),u => x187p_data_number(4,x187p_number(tail)),u =>
  nt_choose(X187Parsed,String.eq(op,".quad"),u =>
    nt_choose(X187Parsed,x187p_numeric(tail),v => x187p_data_number(8,x187p_number(tail)),
      v => x187p_data_expression(x187p_expression(tail,""))),u => PError{"unsupported directive: " ++ op})))))))))))

@unsafe
def x187p_line_head(parts: X187Head) -> X187Parsed:
  match parts:
    case X187Head{+head,+tail}:
      nt_choose(X187Parsed,String.starts_with(head,"."),u => x187p_directive(head,tail),
        u => x187p_instruction(head,tail))

@unsafe
def x187p_line(+line: String) -> X187Parsed:
  nt_choose(X187Parsed,String.is_empty(line),u => PEmpty{},u =>
    nt_choose(X187Parsed,String.ends_with(line,":"),u =>
      x187p_label(String.reverse(x187p_tail(String.reverse(line)))),
      u => x187p_line_head(x187p_head(line,""))))

@unsafe
def x187p_label(+name: String) -> X187Parsed:
  nt_choose(X187Parsed,x187p_symbol(name),u => PLabel{name},u => PError{"invalid label"})

@unsafe
def x187_parse_line(line: String) -> X187Parsed:
  x187p_line(String.trim(line))
