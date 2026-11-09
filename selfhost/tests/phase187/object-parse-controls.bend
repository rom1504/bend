# Pure parser controls. Every returned row must end in =1. No encoder or
# host assembler participates in these exact-value expectations.
@unsafe
def x187pc_row(name: String, ok: Bool) -> String:
  name ++ nt_choose(String,ok,u => "=1",u => "=0")

@unsafe
def x187pc_number(number: X187Number, +lo: U32, +hi: U32) -> Bool:
  match number:
    case X187Number{a,b,negative,error}: U32.is_eq(a,lo) && U32.is_eq(b,hi) && String.is_empty(error)

@unsafe
def x187pc_bad_number(number: X187Number) -> Bool:
  match number:
    case X187Number{lo,hi,negative,error}: Bool.not(String.is_empty(error))

@unsafe
def x187pc_bad(parsed: X187Parsed) -> Bool:
  match parsed:
    case PError{error}: Bool.not(String.is_empty(error))
    case _: False{}

@unsafe
def x187pc_bytes(parsed: X187Parsed, expected: List<&2,U32>) -> Bool:
  match parsed:
    case PBytes{bytes}: x187pc_byte_list(bytes,expected)
    case _: False{}

@unsafe
def x187pc_byte_list(a: List<&2,U32>, b: List<&2,U32>) -> Bool:
  match a b:
    case Nil{} Nil{}: True{}
    case Con{x,xs} Con{y,ys}: U32.is_eq(x,y) && x187pc_byte_list(xs,ys)
    case _ _: False{}

@unsafe
def x187pc_reloc(parsed: X187Parsed, +lo: U32, +hi: U32) -> Bool:
  match parsed:
    case PDataReloc{symbol,a,b}: String.eq(symbol,"target") && U32.is_eq(a,lo) && U32.is_eq(b,hi)
    case _: False{}

@unsafe
def x187pc_register(result: X187OperandResult, +index: U32, +width: U32, +vector: Bool) -> Bool:
  match result:
    case X187OperandResult{X187Reg{a,b,+c},error}:
      U32.is_eq(a,index) && U32.is_eq(b,width) && ((c && vector) || (Bool.not(c) && Bool.not(vector))) && String.is_empty(error)
    case _: False{}

@unsafe
def x187pc_memory(result: X187OperandResult, +base: U32, +disp: U32) -> Bool:
  match result:
    case X187OperandResult{X187Mem{a,b},error}: U32.is_eq(a,base) && U32.is_eq(b,disp) && String.is_empty(error)
    case _: False{}

@unsafe
def x187pc_rip(parsed: X187Parsed) -> Bool:
  match parsed:
    case PInst{X187Instruction{op,Con{X187Rip{symbol,lo,hi},Con{X187Reg{index,width,vector},Nil{}}}}}:
      String.eq(op,"leaq") && String.eq(symbol,"target") && U32.is_eq(lo,4294967292) &&
        U32.is_eq(hi,4294967295) && U32.is_eq(index,10) && U32.is_eq(width,64) && Bool.not(vector)
    case _: False{}

@unsafe
def x187pc_kind(parsed: X187Parsed, +tag: U32, +value: U32) -> Bool:
  match parsed:
    case PSection{section}: U32.is_eq(tag,1) && U32.is_eq(section,value)
    case PType{name,kind}: U32.is_eq(tag,2) && String.eq(name,"target") && U32.is_eq(kind,value)
    case PAlign{alignment}: U32.is_eq(tag,3) && U32.is_eq(alignment,value)
    case PLabel{name}: U32.is_eq(tag,4) && String.eq(name,".Ltarget")
    case PSize{name}: U32.is_eq(tag,5) && String.eq(name,"target")
    case PEmpty{}: U32.is_eq(tag,6)
    case _: False{}

@unsafe
def x187_parse_controls() -> List<&2,String>:
  [x187pc_row("u64-max",x187pc_number(x187p_number("18446744073709551615"),4294967295,4294967295)),
   x187pc_row("u64-carry",x187pc_number(x187p_number("4294967296"),0,1)),
   x187pc_row("s64-min",x187pc_number(x187p_number("-9223372036854775808"),0,2147483648)),
   x187pc_row("negative-one",x187pc_number(x187p_number("-1"),4294967295,4294967295)),
   x187pc_row("u64-overflow",x187pc_bad_number(x187p_number("18446744073709551616"))),
   x187pc_row("s64-underflow",x187pc_bad_number(x187p_number("-9223372036854775809"))),
   x187pc_row("decimal-suffix",x187pc_bad_number(x187p_number("12x"))),
   x187pc_row("decimal-empty",x187pc_bad_number(x187p_number("+"))),
   x187pc_row("quad-max",x187pc_bytes(x187_parse_line(".quad 18446744073709551615"),[255,255,255,255,255,255,255,255])),
   x187pc_row("long-carry",x187pc_bytes(x187_parse_line(".long 16909060"),[4,3,2,1])),
   x187pc_row("byte-negative",x187pc_bytes(x187_parse_line(".byte -128"),[128])),
   x187pc_row("byte-overflow",x187pc_bad(x187_parse_line(".byte 256"))),
   x187pc_row("long-overflow",x187pc_bad(x187_parse_line(".long 4294967296"))),
   x187pc_row("reloc-positive",x187pc_reloc(x187_parse_line(".quad target+4294967296"),0,1)),
   x187pc_row("reloc-negative",x187pc_reloc(x187_parse_line(".quad target-4"),4294967292,4294967295)),
   x187pc_row("rip-negative",x187pc_rip(x187_parse_line("leaq target-4(%rip), %r10"))),
   x187pc_row("register-r15",x187pc_register(x187p_register("%r15"),15,64,False{})),
   x187pc_row("register-spl",x187pc_register(x187p_register("%spl"),4,8,False{})),
   x187pc_row("register-xmm15",x187pc_register(x187p_register("%xmm15"),15,128,True{})),
   x187pc_row("memory-negative",x187pc_memory(x187p_operand("-2147483648(%rbp)"),5,2147483648)),
   x187pc_row("memory-empty",x187pc_memory(x187p_operand("(%r12)"),12,0)),
   x187pc_row("memory-overflow",x187pc_bad(x187_parse_line("movq 2147483648(%rbp), %rax"))),
   x187pc_row("high-byte-refusal",x187pc_bad(x187_parse_line("movb %ah, %al"))),
   x187pc_row("indexed-refusal",x187pc_bad(x187_parse_line("movq (%rax,%rcx,4), %rax"))),
   x187pc_row("trailing-comma",x187pc_bad(x187_parse_line("movq %rax,"))),
   x187pc_row("unknown-op",x187pc_bad(x187_parse_line("unknown %rax"))),
   x187pc_row("error-directive",x187pc_bad(x187_parse_line(".error \"refused\""))),
   x187pc_row("section-text",x187pc_kind(x187_parse_line(".text"),1,1)),
   x187pc_row("section-data",x187pc_kind(x187_parse_line(".data"),1,3)),
   x187pc_row("type-function",x187pc_kind(x187_parse_line(".type target, @function"),2,2)),
   x187pc_row("type-object",x187pc_kind(x187_parse_line(".type target, @object"),2,1)),
   x187pc_row("alignment",x187pc_kind(x187_parse_line(".balign 16"),3,16)),
   x187pc_row("alignment-refusal",x187pc_bad(x187_parse_line(".balign 3"))),
   x187pc_row("label",x187pc_kind(x187_parse_line(".Ltarget:"),4,0)),
   x187pc_row("size",x187pc_kind(x187_parse_line(".size target, .-target"),5,0)),
   x187pc_row("size-refusal",x187pc_bad(x187_parse_line(".size target, .-other"))),
   x187pc_row("gnu-stack",x187pc_kind(x187_parse_line(".section .note.GNU-stack,\"\",@progbits"),1,4)),
   x187pc_row("zero-bound",x187pc_bad(x187_parse_line(".zero 8388609")))]
