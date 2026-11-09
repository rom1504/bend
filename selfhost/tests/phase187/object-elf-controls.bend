# Independent GNU-as source and a relocatable byte fixture describe the same
# four public functions, local branch, readonly bytes and relocated pointers.
# The C observer links against either object with no Bend runtime.
def p187el_input() -> X187Object:
  X187Object{
    [72,184,0,0,0,0,0,0,0,0,195,
     72,139,5,0,0,0,0,195,233,0,0,0,0,233,0,0,0,0,184,37,0,0,0,195],
    [1,3,5,7,9,11,13,15,0,0,0,0,0,0,0,0],
    [136,119,102,85,68,51,34,17,153,0,170,187,204,221,238,255,
     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
    [X187Symbol{"p187elf_value",1,0,11,True{},2},
     X187Symbol{"p187elf_read",1,11,8,True{},2},
     X187Symbol{"p187elf_local",1,29,0,False{},0},
     X187Symbol{"p187elf_call",1,19,5,True{},2},
     X187Symbol{"p187elf_jump",1,24,11,True{},2},
     X187Symbol{"p187elf_data",3,0,16,True{},1},
     X187Symbol{"p187elf_pointer",3,16,8,True{},1},
     X187Symbol{"p187elf_function",3,24,8,True{},1},
     X187Symbol{"p187elf_rodata",2,0,16,True{},1},
     X187Symbol{"p187elf_external",0,0,0,True{},2}],
    [X187Relocation{1,2,1,"p187elf_data",0,0},
     X187Relocation{1,14,2,"p187elf_data",4294967292,4294967295},
     X187Relocation{1,20,4,"p187elf_external",4294967292,4294967295},
     X187Relocation{1,25,2,"p187elf_local",4294967292,4294967295},
     X187Relocation{2,8,1,"p187elf_data",8,0},
     X187Relocation{3,16,1,"p187elf_data",8,0},
     X187Relocation{3,24,1,"p187elf_call",0,0}]}

@unsafe
def p187el_object() -> X187ObjectResult:
  x187_elf(p187el_input())

def p187el_assembly() -> String:
  ".text\n.balign 16\n.globl p187elf_value\n.type p187elf_value,@function\np187elf_value:\n  movabsq $p187elf_data,%rax\n  ret\n.size p187elf_value,.-p187elf_value\n.globl p187elf_read\n.type p187elf_read,@function\np187elf_read:\n  movq p187elf_data(%rip),%rax\n  ret\n.size p187elf_read,.-p187elf_read\n.globl p187elf_call\n.type p187elf_call,@function\np187elf_call:\n  jmp p187elf_external\n.size p187elf_call,.-p187elf_call\n.globl p187elf_jump\n.type p187elf_jump,@function\np187elf_jump:\n  .byte 233\n  .long p187elf_local-.-4\np187elf_local:\n  movl $37,%eax\n  ret\n.size p187elf_jump,.-p187elf_jump\n.type p187elf_external,@function\n.section .rodata\n.balign 8\n.globl p187elf_rodata\n.type p187elf_rodata,@object\np187elf_rodata:\n  .byte 1,3,5,7,9,11,13,15\n  .quad p187elf_data+8\n.size p187elf_rodata,.-p187elf_rodata\n.data\n.balign 8\n.globl p187elf_data\n.type p187elf_data,@object\np187elf_data:\n  .quad 0x1122334455667788,0xffeeddccbbaa0099\n.size p187elf_data,.-p187elf_data\n.globl p187elf_pointer\n.type p187elf_pointer,@object\np187elf_pointer:\n  .quad p187elf_data+8\n.size p187elf_pointer,.-p187elf_pointer\n.globl p187elf_function\n.type p187elf_function,@object\np187elf_function:\n  .quad p187elf_call\n.size p187elf_function,.-p187elf_function\n.section .note.GNU-stack,\"\",@progbits\n"

def p187el_error(result: X187ObjectResult) -> String:
  match result:
    case X187ObjectResult{bytes,error}: error

def p187el_bytes(result: X187ObjectResult) -> List<&2,U32>:
  match result:
    case X187ObjectResult{bytes,error}: bytes

def p187el_refused(result: X187ObjectResult) -> Bool:
  match result:
    case X187ObjectResult{bytes,error}: Bool.not(String.is_empty(error)) && List.is_empty(&2,U32,bytes)

@unsafe
def p187el_refuses(object: X187Object) -> Bool:
  p187el_refused(x187_elf(object))

def p187el_one(symbol: X187Symbol) -> X187Object:
  X187Object{[0,0,0,0,0,0,0,0],[],[],[symbol],[]}

def p187el_reloc(relocation: X187Relocation) -> X187Object:
  X187Object{[0,0,0,0,0,0,0,0],[],[],[X187Symbol{"import",0,0,0,True{},0}],[relocation]}

@unsafe
def p187el_row(name: String, good: Bool) -> String:
  name ++ "=" ++ nt_choose(String,good,u => "1",u => "0")

@unsafe
def p187el_controls() -> List<&2,String>:
  +bytes = p187el_bytes(p187el_object())
  [p187el_row("valid-object",String.is_empty(p187el_error(p187el_object()))),
   p187el_row("elf-magic",U32.is_eq(p111v_at(bytes,0),127) && U32.is_eq(p111v_at(bytes,1),69) && U32.is_eq(p111v_at(bytes,2),76) && U32.is_eq(p111v_at(bytes,3),70)),
   p187el_row("elf64-little-endian",U32.is_eq(p111v_at(bytes,4),2) && U32.is_eq(p111v_at(bytes,5),1)),
   p187el_row("relocatable-amd64",U32.is_eq(p111v_at(bytes,16),1) && U32.is_eq(p111v_at(bytes,18),62)),
   p187el_row("fixed-section-table",U32.is_eq(p111v_at(bytes,58),64) && U32.is_eq(p111v_at(bytes,60),11) && U32.is_eq(p111v_at(bytes,62),9)),
   p187el_row("empty-object",String.is_empty(p187el_error(x187_elf(X187Object{[],[],[],[],[]})))),
   p187el_row("bad-byte",p187el_refuses(X187Object{[256],[],[],[],[]})),
   p187el_row("bad-rodata-byte",p187el_refuses(X187Object{[],[4294967295],[],[],[]})),
   p187el_row("bad-data-byte",p187el_refuses(X187Object{[],[],[256],[],[]})),
   p187el_row("empty-symbol",p187el_refuses(p187el_one(X187Symbol{"",1,0,0,True{},0}))),
   p187el_row("nul-symbol",p187el_refuses(p187el_one(X187Symbol{"bad\0name",1,0,0,True{},0}))),
   p187el_row("non-ascii-symbol",p187el_refuses(p187el_one(X187Symbol{"é",1,0,0,True{},0}))),
   p187el_row("bad-symbol-section",p187el_refuses(p187el_one(X187Symbol{"bad",4,0,0,True{},0}))),
   p187el_row("bad-symbol-kind",p187el_refuses(p187el_one(X187Symbol{"bad",1,0,0,True{},3}))),
   p187el_row("symbol-outside",p187el_refuses(p187el_one(X187Symbol{"bad",1,9,0,True{},0}))),
   p187el_row("symbol-size-outside",p187el_refuses(p187el_one(X187Symbol{"bad",1,4,5,True{},0}))),
   p187el_row("symbol-size-overflow",p187el_refuses(p187el_one(X187Symbol{"bad",1,1,4294967295,True{},0}))),
   p187el_row("undefined-local",p187el_refuses(p187el_one(X187Symbol{"bad",0,0,0,False{},0}))),
   p187el_row("undefined-nonzero",p187el_refuses(p187el_one(X187Symbol{"bad",0,1,0,True{},0}))),
   p187el_row("duplicate-cross-binding",p187el_refuses(X187Object{[],[],[],[X187Symbol{"same",1,0,0,True{},0},X187Symbol{"same",1,0,0,False{},0}],[]})),
   p187el_row("unknown-relocation-symbol",p187el_refuses(p187el_reloc(X187Relocation{1,0,1,"missing",0,0}))),
   p187el_row("unknown-relocation-kind",p187el_refuses(p187el_reloc(X187Relocation{1,0,3,"import",0,0}))),
   p187el_row("unknown-relocation-section",p187el_refuses(p187el_reloc(X187Relocation{0,0,1,"import",0,0}))),
   p187el_row("relocation-overrun",p187el_refuses(p187el_reloc(X187Relocation{1,1,1,"import",0,0}))),
   p187el_row("relocation-offset-overflow",p187el_refuses(p187el_reloc(X187Relocation{1,4294967295,2,"import",0,0}))),
   p187el_row("absolute-last-byte",String.is_empty(p187el_error(x187_elf(p187el_reloc(X187Relocation{1,0,1,"import",4294967295,4294967295}))))),
   p187el_row("pc32-last-byte",String.is_empty(p187el_error(x187_elf(p187el_reloc(X187Relocation{1,4,2,"import",4294967292,4294967295})))))]
