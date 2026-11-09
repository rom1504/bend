# Independent typed-boundary controls. Literal expected assembly is not parsed
# to create the typed instruction tree. Machine observers are separate C.
@unsafe
def p188tc_row(name: String, good: Bool) -> String:
  name ++ "=" ++ nt_choose(String,good,u => "1",u => "0")
@unsafe
def p188tc_text(name: String, seq: X188Seq, expected: String) -> String:
  p188tc_row(name,String.eq(x188_render(seq),expected))
def p188tc_refused(result: X187ObjectResult) -> Bool:
  match result:
    case X187ObjectResult{bytes,error}: List.is_empty(&2,U32,bytes) && Bool.not(String.is_empty(error))
def p188tc_error(result: X187ObjectResult) -> String:
  match result:
    case X187ObjectResult{bytes,error}: error

@unsafe
def p188tc_function(+name: String, body: X188Seq) -> X188Seq:
  x188_many([X188One{PGlobal{name}},X188One{PType{name,2}},x188_label(name),body,X188One{PSize{name}}])

@unsafe
def p188tc_program() -> X188Seq:
  x188_many([X188One{PSection{1}},X188One{PAlign{16}},
    p188tc_function("p188tc_value",x188_many([
      x188_i2("movabsq",X187Imm{4294967295,4294967295},x188_reg(0,64)),x188_i0("ret")])),
    p188tc_function("p188tc_math",x188_many([
      x188_i2("movq",x188_reg(7,64),x188_reg(0,64)),
      x188_i2("addq",x188_reg(6,64),x188_reg(0,64)),
      x188_i2("movq",x188_reg(0,64),X187Mem{2,0}),
      x188_i2("movl",x188_reg(7,32),x188_reg(0,32)),
      x188_i2("addl",x188_reg(6,32),x188_reg(0,32)),
      x188_i2("movq",x188_reg(0,64),X187Mem{2,8}),
      x188_i2("cmpq",x188_reg(6,64),x188_reg(7,64)),x188_i1("setb",x188_reg(10,8)),
      x188_i2("movzbl",x188_reg(10,8),x188_reg(0,32)),
      x188_i2("movq",x188_reg(0,64),X187Mem{2,16}),x188_i0("ret")])),
    p188tc_function("p188tc_branch",x188_many([
      x188_i2("testq",x188_reg(7,64),x188_reg(7,64)),x188_i1("jz",X187Target{".Lp188_zero"}),
      x188_i2("movl",X187Imm{23,0},x188_reg(0,32)),x188_i1("jmp",X187Target{".Lp188_done"}),
      x188_label(".Lp188_zero"),x188_i2("movl",X187Imm{17,0},x188_reg(0,32)),
      x188_label(".Lp188_done"),x188_i0("ret")])),
    p188tc_function("p188tc_loop",x188_many([
      x188_i2("movq",x188_reg(7,64),x188_reg(1,64)),x188_i2("xorl",x188_reg(0,32),x188_reg(0,32)),
      x188_i2("testq",x188_reg(1,64),x188_reg(1,64)),x188_i1("jz",X187Target{".Lp188_loop_done"}),
      x188_label(".Lp188_loop"),x188_i2("addq",x188_reg(1,64),x188_reg(0,64)),
      x188_i2("subq",X187Imm{1,0},x188_reg(1,64)),x188_i1("jnz",X187Target{".Lp188_loop"}),
      x188_label(".Lp188_loop_done"),x188_i0("ret")])),
    p188tc_function("p188tc_read",x188_many([
      x188_i2("movq",X187Rip{"p188tc_data",0,0},x188_reg(0,64)),x188_i0("ret")])),
    p188tc_function("p188tc_call",x188_i1("jmp",X187Target{"p188tc_external"})),
    p188tc_function("p188tc_stack",x188_many([
      x188_i1("pushq",x188_reg(5,64)),x188_i2("movq",x188_reg(4,64),x188_reg(5,64)),
      x188_i2("subq",X187Imm{16,0},x188_reg(4,64)),
      x188_i2("movq",x188_reg(7,64),X187Mem{5,4294967288}),
      x188_i2("movq",X187Mem{5,4294967288},x188_reg(0,64)),
      x188_i2("movq",x188_reg(5,64),x188_reg(4,64)),x188_i1("popq",x188_reg(5,64)),x188_i0("ret")])),
    p188tc_function("p188tc_float",x188_many([
      x188_i2("movd",x188_reg(7,32),x188_xmm(15)),x188_i2("movd",x188_reg(6,32),x188_xmm(2)),
      x188_i2("addss",x188_xmm(2),x188_xmm(15)),x188_i2("movd",x188_xmm(15),x188_reg(0,32)),x188_i0("ret")])),
    X188One{PSection{3}},X188One{PAlign{8}},X188One{PGlobal{"p188tc_data"}},
    X188One{PType{"p188tc_data",1}},x188_label("p188tc_data"),
    X188One{PDatum{P111QLong{1432778632,287454020}}},X188One{PDatum{P111QWord{4294967295}}},
    X188One{PDatum{P111QByte{165}}},X188One{PDatum{P111QZeros{3}}},X188One{PSize{"p188tc_data"}},
    X188One{PGlobal{"p188tc_pointer"}},X188One{PType{"p188tc_pointer",1}},x188_label("p188tc_pointer"),
    X188One{PDatum{P111QReloc{"p188tc_data",8}}},X188One{PSize{"p188tc_pointer"}},
    X188One{PSection{2}},X188One{PAlign{8}},X188One{PGlobal{"p188tc_rodata"}},
    X188One{PType{"p188tc_rodata",1}},x188_label("p188tc_rodata"),
    X188One{PDatum{P111QLong{0,2147483648}}},X188One{PSize{"p188tc_rodata"}},X188One{PSection{4}}])

@unsafe
def p188tc_object() -> X187ObjectResult: x188_assemble(p188tc_program())
@unsafe
def p188tc_assembly() -> String: x188_render(p188tc_program())

@unsafe
def p188tc_controls() -> List<&2,String>:
  [p188tc_text("empty",X188Empty{},""),
   p188tc_text("empty-item",X188One{PEmpty{}},""),
   p188tc_text("join-left",x188_cat(X188Empty{},x188_i0("ret")),"  ret\n"),
   p188tc_text("join-right",x188_cat(x188_i0("ret"),X188Empty{}),"  ret\n"),
   p188tc_text("nested-order",X188Join{X188Join{x188_label("a"),X188Empty{}},X188Join{x188_label("b"),x188_i0("ret")}},"a:\nb:\n  ret\n"),
   p188tc_text("forward-chunks",x188_many([x188_label("a"),x188_label("b")]),"a:\nb:\n"),
   p188tc_text("reversed-chunks",x188_finish([x188_label("b"),x188_label("a")]),"a:\nb:\n"),
   p188tc_text("gpr64",x188_i2("movq",x188_reg(8,64),x188_reg(15,64)),"  movq %r8, %r15\n"),
   p188tc_text("gpr32",x188_i2("movl",x188_reg(0,32),x188_reg(15,32)),"  movl %eax, %r15d\n"),
   p188tc_text("low-byte-rex",x188_i2("movb",x188_reg(4,8),x188_reg(7,8)),"  movb %spl, %dil\n"),
   p188tc_text("xmm-registers",x188_i2("movaps",x188_xmm(15),x188_xmm(2)),"  movaps %xmm15, %xmm2\n"),
   p188tc_text("memory-zero",x188_i2("movq",X187Mem{12,0},x188_reg(0,64)),"  movq 0(%r12), %rax\n"),
   p188tc_text("memory-negative",x188_i2("movq",X187Mem{5,4294967288},x188_reg(0,64)),"  movq -8(%rbp), %rax\n"),
   p188tc_text("memory-signed-min",x188_i2("movq",X187Mem{5,2147483648},x188_reg(0,64)),"  movq -2147483648(%rbp), %rax\n"),
   p188tc_text("full64-immediate",x188_i2("movabsq",X187Imm{4294967295,4294967295},x188_reg(0,64)),"  movabsq $18446744073709551615, %rax\n"),
   p188tc_text("rip-addend",x188_i2("leaq",X187Rip{"data",8,0},x188_reg(0,64)),"  leaq data+8(%rip), %rax\n"),
   p188tc_text("section-text",X188One{PSection{1}},".text\n"),
   p188tc_text("section-rodata",X188One{PSection{2}},".section .rodata\n"),
   p188tc_text("section-data",X188One{PSection{3}},".data\n"),
   p188tc_text("section-stack",X188One{PSection{4}},".section .note.GNU-stack,\"\",@progbits\n"),
   p188tc_text("symbol-directives",x188_many([X188One{PGlobal{"f"}},X188One{PType{"f",2}},x188_label("f"),X188One{PSize{"f"}}]),".globl f\n.type f, @function\nf:\n.size f, .-f\n"),
   p188tc_text("alignment",X188One{PAlign{8}},".balign 8\n"),
   p188tc_text("byte-width",X188One{PDatum{P111QByte{255}}},".byte 255\n"),
   p188tc_text("word-width",X188One{PDatum{P111QWord{4294967295}}},".long 4294967295\n"),
   p188tc_text("long-width",X188One{PDatum{P111QLong{0,2147483648}}},".quad 9223372036854775808\n"),
   p188tc_text("data-relocation",X188One{PDatum{P111QReloc{"data",8}}},".quad data+8\n"),
   p188tc_text("zero-width",X188One{PDatum{P111QZeros{3}}},".zero 3\n"),
   p188tc_row("valid-object",String.is_empty(p188tc_error(p188tc_object()))),
   p188tc_row("bad-byte",p188tc_refused(x188_assemble(X188One{PDatum{P111QByte{256}}}))),
   p188tc_row("zero-bound",p188tc_refused(x188_assemble(X188One{PDatum{P111QZeros{8388609}}}))),
   p188tc_row("bad-register",p188tc_refused(x188_assemble(x188_i1("pushq",x188_reg(16,64))))),
   p188tc_row("bad-width",p188tc_refused(x188_assemble(x188_i2("movq",x188_reg(0,32),x188_reg(1,32))))),
   p188tc_row("first-error",String.eq(p188tc_error(x188_assemble(x188_cat(x188_error("first"),x188_error("second")))),"first")),
   p188tc_row("undefined-local",p188tc_refused(x188_assemble(x188_i1("jmp",X187Target{".Lp188_undefined"})))),
   p188tc_row("byte-bound-last",x187_elf_bytes([255],67108863)),
   p188tc_row("byte-bound-overflow",Bool.not(x187_elf_bytes([255],67108864)))]
