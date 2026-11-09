# Independent AMD64 byte labels. Architectural register numbers are used
# directly; expectations are literals, never another encoder's output.
# This suite performs no assembler/linker or generated-code execution.

def x187ec_r(index: U32, width: U32) -> X187Operand:
  X187Reg{index,width,False{}}

def x187ec_x(index: U32) -> X187Operand:
  X187Reg{index,128,True{}}

@unsafe
def x187ec_bytes(left: List<&2,U32>, right: List<&2,U32>) -> Bool:
  match left right:
    case Nil{} Nil{}: True{}
    case Con{a,rest} Con{b,more}: U32.is_eq(a,b) && x187ec_bytes(rest,more)
    case _ _: False{}

def x187ec_relocation(left: X187Relocation, right: X187Relocation) -> Bool:
  match left right:
    case X187Relocation{section,offset,kind,symbol,lo,hi} X187Relocation{other,field,typ,target,low,high}:
      U32.is_eq(section,other) && U32.is_eq(offset,field) && U32.is_eq(kind,typ) &&
        String.eq(symbol,target) && U32.is_eq(lo,low) && U32.is_eq(hi,high)

@unsafe
def x187ec_relocations(left: List<&2,X187Relocation>, right: List<&2,X187Relocation>) -> Bool:
  match left right:
    case Nil{} Nil{}: True{}
    case Con{a,rest} Con{b,more}: x187ec_relocation(a,b) && x187ec_relocations(rest,more)
    case _ _: False{}

@unsafe
def x187ec_matches(encoded: X187Encoded, expected: List<&2,U32>, relocations: List<&2,X187Relocation>) -> Bool:
  match encoded:
    case X187Encoded{bytes,links,error}:
      String.is_empty(error) && x187ec_bytes(bytes,expected) && x187ec_relocations(links,relocations)

@unsafe
def x187ec_row(name: String, good: Bool) -> String:
  name ++ nt_choose(String,good,u => "=1",u => "=0")

@unsafe
def x187ec_case(name: String, op: String, operands: List<&2,X187Operand>, expected: List<&2,U32>) -> String:
  x187ec_row(name,x187ec_matches(x187_encode(X187Instruction{op,operands},0),expected,[]))

@unsafe
def x187ec_link(name: String, op: String, operands: List<&2,X187Operand>, offset: U32,
    expected: List<&2,U32>, relocation: X187Relocation) -> String:
  x187ec_row(name,x187ec_matches(x187_encode(X187Instruction{op,operands},offset),expected,[relocation]))

def x187ec_failed(encoded: X187Encoded) -> Bool:
  match encoded:
    case X187Encoded{bytes,relocations,error}: Bool.not(String.is_empty(error))

@unsafe
def x187ec_reject(name: String, op: String, operands: List<&2,X187Operand>) -> String:
  x187ec_row(name,x187ec_failed(x187_encode(X187Instruction{op,operands},0)))

@unsafe
def x187ec_integer() -> List<&2,String>:
  [x187ec_case("ret","ret",[],[195]),
   x187ec_case("push-rbp","pushq",[x187ec_r(5,64)],[85]),
   x187ec_case("push-r15","pushq",[x187ec_r(15,64)],[65,87]),
   x187ec_case("pop-r12","popq",[x187ec_r(12,64)],[65,92]),
   x187ec_case("movq-low","movq",[x187ec_r(0,64),x187ec_r(3,64)],[72,137,195]),
   x187ec_case("movq-high","movq",[x187ec_r(8,64),x187ec_r(15,64)],[77,137,199]),
   x187ec_case("movl-high","movl",[x187ec_r(8,32),x187ec_r(9,32)],[69,137,193]),
   x187ec_case("movb-sil-dil-rex","movb",[x187ec_r(6,8),x187ec_r(7,8)],[64,136,247]),
   x187ec_case("movb-r8b-spl","movb",[x187ec_r(8,8),x187ec_r(4,8)],[68,136,196]),
   x187ec_case("movb-bpl-r9b","movb",[x187ec_r(5,8),x187ec_r(9,8)],[65,136,233]),
   x187ec_case("movb-imm-spl-rex","movb",[X187Imm{255,0},x187ec_r(4,8)],[64,180,255]),
   x187ec_case("movabs-full64","movabsq",[X187Imm{2309737967,19088743},x187ec_r(10,64)],
     [73,186,239,205,171,137,103,69,35,1]),
   x187ec_case("movq-imm64","movq",[X187Imm{2147483648,0},x187ec_r(0,64)],[72,184,0,0,0,128,0,0,0,0]),
   x187ec_case("movl-full32","movl",[X187Imm{2309737967,0},x187ec_r(8,32)],[65,184,239,205,171,137]),
   x187ec_case("addq-reg","addq",[x187ec_r(8,64),x187ec_r(9,64)],[77,1,193]),
   x187ec_case("subq-reg","subq",[x187ec_r(9,64),x187ec_r(8,64)],[77,41,200]),
   x187ec_case("andq-reg","andq",[x187ec_r(13,64),x187ec_r(14,64)],[77,33,238]),
   x187ec_case("xorq-reg","xorq",[x187ec_r(0,64),x187ec_r(0,64)],[72,49,192]),
   x187ec_case("xorl-high","xorl",[x187ec_r(9,32),x187ec_r(9,32)],[69,49,201]),
   x187ec_case("cmpq-high","cmpq",[x187ec_r(8,64),x187ec_r(15,64)],[77,57,199]),
   x187ec_case("testl-high","testl",[x187ec_r(9,32),x187ec_r(9,32)],[69,133,201]),
   x187ec_case("andb-low-rex","andb",[x187ec_r(6,8),x187ec_r(7,8)],[64,32,247]),
   x187ec_case("orb-high-low","orb",[x187ec_r(8,8),x187ec_r(5,8)],[68,8,197]),
   x187ec_case("imulq-high","imulq",[x187ec_r(8,64),x187ec_r(9,64)],[77,15,175,200]),
   x187ec_case("imull-high-destination","imull",[x187ec_r(0,32),x187ec_r(10,32)],[68,15,175,208]),
   x187ec_case("addq-imm32","addq",[X187Imm{1,0},x187ec_r(8,64)],[73,129,192,1,0,0,0]),
   x187ec_case("addq-signed32-min","addq",[X187Imm{2147483648,4294967295},x187ec_r(10,64)],[73,129,194,0,0,0,128]),
   x187ec_case("addq-signed32-max","addq",[X187Imm{2147483647,0},x187ec_r(0,64)],[72,129,192,255,255,255,127]),
   x187ec_case("cmpq-negative-imm32","cmpq",[X187Imm{4294967295,4294967295},x187ec_r(9,64)],[73,129,249,255,255,255,255]),
   x187ec_case("andl-unsigned-imm32","andl",[X187Imm{4294967295,0},x187ec_r(10,32)],[65,129,226,255,255,255,255]),
   x187ec_case("imulq-imm32","imulq",[X187Imm{4,0},x187ec_r(10,64)],[77,105,210,4,0,0,0]),
   x187ec_case("shlq-imm8","shlq",[X187Imm{65,0},x187ec_r(8,64)],[73,193,224,65]),
   x187ec_case("shrq-cl","shrq",[x187ec_r(1,8),x187ec_r(8,64)],[73,211,232]),
   x187ec_case("sarl-cl","sarl",[x187ec_r(1,8),x187ec_r(13,32)],[65,211,253]),
   x187ec_case("setne-dil","setne",[x187ec_r(7,8)],[64,15,149,199]),
   x187ec_case("setb-r12b","setb",[x187ec_r(12,8)],[65,15,146,196]),
   x187ec_case("movzbl-dil-r9d","movzbl",[x187ec_r(7,8),x187ec_r(9,32)],[68,15,182,207]),
   x187ec_case("movzbl-spl-eax","movzbl",[x187ec_r(4,8),x187ec_r(0,32)],[64,15,182,196])]

@unsafe
def x187ec_memory() -> List<&2,String>:
  [x187ec_case("rbp-zero-disp8","movq",[X187Mem{5,0},x187ec_r(0,64)],[72,139,69,0]),
   x187ec_case("rsp-zero-sib","movq",[X187Mem{4,0},x187ec_r(0,64)],[72,139,4,36]),
   x187ec_case("r12-zero-sib-rex","movq",[X187Mem{12,0},x187ec_r(9,64)],[77,139,12,36]),
   x187ec_case("r13-zero-disp8-rex","movq",[X187Mem{13,0},x187ec_r(8,64)],[77,139,69,0]),
   x187ec_case("store-r10-r12-disp8","movq",[x187ec_r(10,64),X187Mem{12,8}],[77,137,84,36,8]),
   x187ec_case("store-r9d-rsp-negative8","movl",[x187ec_r(9,32),X187Mem{4,4294967288}],[68,137,76,36,248]),
   x187ec_case("rbp-positive127","movq",[X187Mem{5,127},x187ec_r(6,64)],[72,139,117,127]),
   x187ec_case("rbp-positive128","movq",[X187Mem{5,128},x187ec_r(6,64)],[72,139,181,128,0,0,0]),
   x187ec_case("r13-negative128","movq",[X187Mem{13,4294967168},x187ec_r(10,64)],[77,139,85,128]),
   x187ec_case("r13-negative129","movq",[X187Mem{13,4294967167},x187ec_r(10,64)],[77,139,149,127,255,255,255]),
   x187ec_case("rax-disp32-r11","movq",[X187Mem{0,305419896},x187ec_r(11,64)],[76,139,152,120,86,52,18]),
   x187ec_case("lea-r12-disp32-r13","leaq",[X187Mem{12,256},x187ec_r(13,64)],[77,141,172,36,0,1,0,0]),
   x187ec_case("addq-memory-source","addq",[X187Mem{12,0},x187ec_r(13,64)],[77,3,44,36]),
   x187ec_case("cmpb-memory-destination","cmpb",[x187ec_r(0,8),X187Mem{5,0}],[56,69,0]),
   x187ec_case("movl-imm-r12-disp32","movl",[X187Imm{2864434397,0},X187Mem{12,128}],
     [65,199,132,36,128,0,0,0,221,204,187,170]),
   x187ec_case("movb-imm-rbp-negative1","movb",[X187Imm{255,0},X187Mem{5,4294967295}],[198,69,255,255]),
   x187ec_case("movq-imm-negative-r13","movq",[X187Imm{4294967295,4294967295},X187Mem{13,0}],
     [73,199,69,0,255,255,255,255])]

@unsafe
def x187ec_sse() -> List<&2,String>:
  [x187ec_case("addss-prefix-before-rex","addss",[x187ec_x(8),x187ec_x(9)],[243,69,15,88,200]),
   x187ec_case("subss-operand-order","subss",[x187ec_x(9),x187ec_x(8)],[243,69,15,92,193]),
   x187ec_case("mulss-high-destination","mulss",[x187ec_x(2),x187ec_x(15)],[243,68,15,89,250]),
   x187ec_case("divss-high-source","divss",[x187ec_x(15),x187ec_x(2)],[243,65,15,94,215]),
   x187ec_case("ucomiss-high","ucomiss",[x187ec_x(9),x187ec_x(10)],[69,15,46,209]),
   x187ec_case("movaps-high","movaps",[x187ec_x(14),x187ec_x(13)],[69,15,40,238]),
   x187ec_case("pxor-low","pxor",[x187ec_x(0),x187ec_x(0)],[102,15,239,192]),
   x187ec_case("pxor-high","pxor",[x187ec_x(8),x187ec_x(15)],[102,69,15,239,248]),
   x187ec_case("movd-gpr-to-xmm","movd",[x187ec_r(0,32),x187ec_x(2)],[102,15,110,208]),
   x187ec_case("movd-xmm-to-gpr","movd",[x187ec_x(2),x187ec_r(0,32)],[102,15,126,208]),
   x187ec_case("movd-high-gpr-to-xmm","movd",[x187ec_r(8,32),x187ec_x(9)],[102,69,15,110,200]),
   x187ec_case("movd-high-xmm-to-gpr","movd",[x187ec_x(9),x187ec_r(8,32)],[102,69,15,126,200]),
   x187ec_case("movd-rsp-to-xmm8","movd",[X187Mem{4,0},x187ec_x(8)],[102,68,15,110,4,36]),
   x187ec_case("movd-xmm8-to-r13","movd",[x187ec_x(8),X187Mem{13,0}],[102,69,15,126,69,0]),
   x187ec_case("cvtsi2ssq-r10-xmm3","cvtsi2ssq",[x187ec_r(10,64),x187ec_x(3)],[243,73,15,42,218]),
   x187ec_case("cvtsi2ssq-rax-xmm8","cvtsi2ssq",[x187ec_r(0,64),x187ec_x(8)],[243,76,15,42,192])]

@unsafe
def x187ec_links() -> List<&2,String>:
  [x187ec_link("call-plt32-offset","call",[X187Target{"callee"}],100,[232,0,0,0,0],
     X187Relocation{1,101,4,"callee",4294967292,4294967295}),
   x187ec_link("jmp-pc32-offset","jmp",[X187Target{"label"}],200,[233,0,0,0,0],
     X187Relocation{1,201,2,"label",4294967292,4294967295}),
   x187ec_link("jz-pc32-offset","jz",[X187Target{"label"}],300,[15,132,0,0,0,0],
     X187Relocation{1,302,2,"label",4294967292,4294967295}),
   x187ec_link("rip-lea-zero-addend","leaq",[X187Rip{"table",0,0},x187ec_r(0,64)],400,[72,141,5,0,0,0,0],
     X187Relocation{1,403,2,"table",4294967292,4294967295}),
   x187ec_link("rip-load-positive-addend","movq",[X187Rip{"table",8,0},x187ec_r(9,64)],500,[76,139,13,0,0,0,0],
     X187Relocation{1,503,2,"table",4,0}),
   x187ec_link("rip-addend-borrow","leaq",[X187Rip{"table",2,1},x187ec_r(8,64)],600,[76,141,5,0,0,0,0],
     X187Relocation{1,603,2,"table",4294967294,0}),
   x187ec_link("rip-addend-negative","leaq",[X187Rip{"table",4294967293,4294967295},x187ec_r(0,64)],700,[72,141,5,0,0,0,0],
     X187Relocation{1,703,2,"table",4294967289,4294967295}),
   x187ec_link("rip-trailing-imm32","addq",[X187Imm{1,0},X187Rip{"table",0,0}],800,[72,129,5,0,0,0,0,1,0,0,0],
     X187Relocation{1,803,2,"table",4294967288,4294967295}),
   x187ec_link("rip-trailing-imm8","addb",[X187Imm{255,0},X187Rip{"table",0,0}],900,[128,5,0,0,0,0,255],
     X187Relocation{1,902,2,"table",4294967291,4294967295}),
   x187ec_link("rip-sse-prefix-offset","addss",[X187Rip{"table",8,0},x187ec_x(9)],1000,[243,68,15,88,13,0,0,0,0],
     X187Relocation{1,1005,2,"table",4,0}),
   x187ec_link("rip-movq-trailing-imm32","movq",[X187Imm{1,0},X187Rip{"table",0,0}],100,[72,199,5,0,0,0,0,1,0,0,0],
     X187Relocation{1,103,2,"table",4294967288,4294967295})]

@unsafe
def x187ec_refusals() -> List<&2,String>:
  [x187ec_reject("reject-unknown-op","unsupported",[]),
   x187ec_reject("reject-extra-ret-operand","ret",[x187ec_r(0,64)]),
   x187ec_reject("reject-movq-width32","movq",[x187ec_r(0,32),x187ec_r(1,64)]),
   x187ec_reject("reject-register16","movq",[x187ec_r(16,64),x187ec_r(0,64)]),
   x187ec_reject("reject-vector-integer","movq",[x187ec_x(0),x187ec_r(0,64)]),
   x187ec_reject("reject-movabs-register-register","movabsq",[x187ec_r(0,64),x187ec_r(1,64)]),
   x187ec_reject("reject-memory-memory","movq",[X187Mem{0,0},X187Mem{1,0}]),
   x187ec_reject("reject-memory-base16","movq",[X187Mem{16,0},x187ec_r(0,64)]),
   x187ec_reject("reject-positive64-imm32","addq",[X187Imm{2147483648,0},x187ec_r(0,64)]),
   x187ec_reject("reject-movq-memory-positive64-imm32","movq",[X187Imm{2147483648,0},X187Mem{0,0}]),
   x187ec_reject("reject-negative64-imm32","addq",[X187Imm{2147483647,4294967295},x187ec_r(0,64)]),
   x187ec_reject("reject-movl-highword","movl",[X187Imm{1,1},x187ec_r(0,32)]),
   x187ec_reject("reject-shift-not-cl","shrq",[x187ec_r(2,8),x187ec_r(0,64)]),
   x187ec_reject("reject-shift-imm256","shrq",[X187Imm{256,0},x187ec_r(0,64)]),
   x187ec_reject("reject-set-width32","setne",[x187ec_r(0,32)]),
   x187ec_reject("reject-movzbl-source32","movzbl",[x187ec_r(0,32),x187ec_r(1,32)]),
   x187ec_reject("reject-sse-gpr","addss",[x187ec_r(0,32),x187ec_x(1)]),
   x187ec_reject("reject-sse-register16","addss",[x187ec_x(16),x187ec_x(1)]),
   x187ec_reject("reject-sse-width32","addss",[X187Reg{0,32,True{}},x187ec_x(1)]),
   x187ec_reject("reject-movd-gpr64","movd",[x187ec_r(0,64),x187ec_x(1)]),
   x187ec_reject("reject-cvtsi-width32","cvtsi2ssq",[x187ec_r(0,32),x187ec_x(1)]),
   x187ec_reject("reject-call-register","call",[x187ec_r(0,64)]),
   x187ec_reject("reject-empty-call-target","call",[X187Target{""}]),
   x187ec_row("reject-offset-overflow",x187ec_failed(x187_encode(X187Instruction{"ret",[]},4294967295)))]

@unsafe
def x187ec_controls() -> List<&2,String>:
  nt_append(String,x187ec_integer(),nt_append(String,x187ec_memory(),
    nt_append(String,x187ec_sse(),nt_append(String,x187ec_links(),x187ec_refusals()))))
