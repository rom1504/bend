# Independent byte literals and explicit assembly oracle; no parser round trip.
@unsafe
def p191ac_equal(a: List<&2,U32>, b: List<&2,U32>) -> Bool:
  match a b:
    case Nil{} Nil{}: True{}
    case Con{x,xs} Con{y,ys}: U32.is_eq(x,y) && p191ac_equal(xs,ys)
    case _ _: False{}

def p191ac_row(name: String, good: Bool) -> String:
  name ++ nt_choose(String,good,u => "=1",u => "=0")

@unsafe
def p191ac_bytes(result: X187Encoded, expected: List<&2,U32>) -> Bool:
  match result:
    case X187Encoded{bytes,relocs,error}:
      String.is_empty(error) && List.is_empty(&2,X187Relocation,relocs) && p191ac_equal(bytes,expected)

@unsafe
def p191ac_case(name: String, op: String, args: List<&2,X187Operand>, expected: List<&2,U32>) -> String:
  p191ac_row(name,p191ac_bytes(x187_encode(X187Instruction{op,args},0),expected))

def p191ac_failed(result: X187Encoded) -> Bool:
  match result:
    case X187Encoded{bytes,relocs,error}:
      Bool.not(String.is_empty(error)) && List.is_empty(&2,U32,bytes) && List.is_empty(&2,X187Relocation,relocs)

@unsafe
def p191ac_reject(name: String, op: String, args: List<&2,X187Operand>) -> String:
  p191ac_row(name,p191ac_failed(x187_encode(X187Instruction{op,args},0)))

@unsafe
def p191ac_function(+name: String, body: X188Seq) -> X188Seq:
  x188_many([X188One{PGlobal{name}},X188One{PType{name,2}},x188_label(name),body,X188One{PSize{name}}])

@unsafe
def p191ac_controls() -> List<&2,String>:
  [p191ac_case("scale1","movq",[X187Indexed{0,1,1,0},x188_reg(2,64)],[72,139,20,8]),
   p191ac_case("scale2","movq",[X187Indexed{0,1,2,0},x188_reg(2,64)],[72,139,20,72]),
   p191ac_case("scale4","movq",[X187Indexed{0,1,4,0},x188_reg(2,64)],[72,139,20,136]),
   p191ac_case("scale8","movq",[X187Indexed{0,1,8,0},x188_reg(2,64)],[72,139,20,200]),
   p191ac_case("rsp-base","movq",[X187Indexed{4,1,8,0},x188_reg(2,64)],[72,139,20,204]),
   p191ac_case("rbp-zero","movq",[X187Indexed{5,1,8,0},x188_reg(2,64)],[72,139,84,205,0]),
   p191ac_case("r13-r12-zero","movq",[X187Indexed{13,12,8,0},x188_reg(15,64)],[79,139,124,229,0]),
   p191ac_case("r12-index","movq",[X187Indexed{0,12,4,0},x188_reg(0,64)],[74,139,4,160]),
   p191ac_case("r12-base32","movl",[X187Indexed{12,1,2,0},x188_reg(0,32)],[65,139,4,76]),
   p191ac_case("plus127","movl",[X187Indexed{7,6,4,127},x188_reg(8,32)],[68,139,68,183,127]),
   p191ac_case("plus128","movl",[X187Indexed{7,6,4,128},x188_reg(8,32)],[68,139,132,183,128,0,0,0]),
   p191ac_case("minus128","movl",[X187Indexed{7,6,4,4294967168},x188_reg(8,32)],[68,139,68,183,128]),
   p191ac_case("minus129","movl",[X187Indexed{7,6,4,4294967167},x188_reg(8,32)],[68,139,132,183,127,255,255,255]),
   p191ac_case("signed-min","movl",[X187Indexed{7,6,4,2147483648},x188_reg(8,32)],[68,139,132,183,0,0,0,128]),
   p191ac_case("signed-max","movl",[X187Indexed{7,6,4,2147483647},x188_reg(8,32)],[68,139,132,183,255,255,255,127]),
   p191ac_case("byte-rex-store","movb",[x188_reg(6,8),X187Indexed{7,1,1,0}],[64,136,52,15]),
   p191ac_case("byte-rex-load","movb",[X187Indexed{0,1,1,0},x188_reg(7,8)],[64,138,60,8]),
   p191ac_case("byte-all-high","movb",[x188_reg(15,8),X187Indexed{12,13,2,8}],[71,136,124,108,8]),
   p191ac_case("zeroextend","movzbl",[X187Indexed{12,13,2,0},x188_reg(8,32)],[71,15,182,4,108]),
   p191ac_case("sse-store","movd",[x188_xmm(9),X187Indexed{12,13,4,0}],[102,71,15,126,12,172]),
   p191ac_case("sse-add","addss",[X187Indexed{12,13,4,0},x188_xmm(9)],[243,71,15,88,12,172]),
   p191ac_case("lea-high","leaq",[X187Indexed{13,12,8,0},x188_reg(10,64)],[79,141,84,229,0]),
   p191ac_case("imul-memory","imulq",[X187Indexed{13,12,8,4294967288},x188_reg(10,64)],[79,15,175,84,229,248]),
   p191ac_case("add-memory","addl",[X187Indexed{7,6,4,0},x188_reg(0,32)],[3,4,183]),
   p191ac_case("imm-store","movl",[X187Imm{305419896,0},X187Indexed{12,13,4,128}],[67,199,132,172,128,0,0,0,120,86,52,18]),
   p191ac_case("set-memory","setne",[X187Indexed{13,12,1,0}],[67,15,149,68,37,0]),
   p191ac_case("old-mem-r12","movq",[X187Mem{12,0},x188_reg(9,64)],[77,139,12,36]),
   p191ac_reject("reject-rsp-index","movq",[X187Indexed{0,4,1,0},x188_reg(0,64)]),
   p191ac_reject("reject-base16","movq",[X187Indexed{16,1,1,0},x188_reg(0,64)]),
   p191ac_reject("reject-index16","movq",[X187Indexed{0,16,1,0},x188_reg(0,64)]),
   p191ac_reject("reject-scale0","movq",[X187Indexed{0,1,0,0},x188_reg(0,64)]),
   p191ac_reject("reject-scale3","movq",[X187Indexed{0,1,3,0},x188_reg(0,64)]),
   p191ac_reject("reject-scale16","movq",[X187Indexed{0,1,16,0},x188_reg(0,64)]),
   p191ac_reject("reject-memory-memory","movq",[X187Indexed{0,1,1,0},X187Indexed{2,3,1,0}]),
   p191ac_reject("reject-width","movq",[X187Indexed{0,1,1,0},x188_reg(0,32)]),
   p191ac_row("render-negative",String.eq(x188_operand_text(X187Indexed{13,12,8,4294967167}),"-129(%r13,%r12,8)")),
   p191ac_row("render-signed-min",String.eq(x188_operand_text(X187Indexed{4,15,1,2147483648}),"-2147483648(%rsp,%r15,1)"))]

@unsafe
def p191ac_emit() -> X181Output:
  X181Output{[x188_many([X188One{PSection{1}},
    p191ac_function("p191ac_bytes_0",x188_i2("movq",X187Indexed{0,1,1,0},x188_reg(2,64))),
    p191ac_function("p191ac_bytes_1",x188_i2("movq",X187Indexed{0,1,2,0},x188_reg(2,64))),
    p191ac_function("p191ac_bytes_2",x188_i2("movq",X187Indexed{0,1,4,0},x188_reg(2,64))),
    p191ac_function("p191ac_bytes_3",x188_i2("movq",X187Indexed{0,1,8,0},x188_reg(2,64))),
    p191ac_function("p191ac_bytes_4",x188_i2("movq",X187Indexed{4,1,8,0},x188_reg(2,64))),
    p191ac_function("p191ac_bytes_5",x188_i2("movq",X187Indexed{5,1,8,0},x188_reg(2,64))),
    p191ac_function("p191ac_bytes_6",x188_i2("movq",X187Indexed{13,12,8,0},x188_reg(15,64))),
    p191ac_function("p191ac_bytes_7",x188_i2("movq",X187Indexed{0,12,4,0},x188_reg(0,64))),
    p191ac_function("p191ac_bytes_8",x188_i2("movl",X187Indexed{12,1,2,0},x188_reg(0,32))),
    p191ac_function("p191ac_bytes_9",x188_i2("movl",X187Indexed{7,6,4,127},x188_reg(8,32))),
    p191ac_function("p191ac_bytes_10",x188_i2("movl",X187Indexed{7,6,4,128},x188_reg(8,32))),
    p191ac_function("p191ac_bytes_11",x188_i2("movl",X187Indexed{7,6,4,4294967168},x188_reg(8,32))),
    p191ac_function("p191ac_bytes_12",x188_i2("movl",X187Indexed{7,6,4,4294967167},x188_reg(8,32))),
    p191ac_function("p191ac_bytes_13",x188_i2("movl",X187Indexed{7,6,4,2147483648},x188_reg(8,32))),
    p191ac_function("p191ac_bytes_14",x188_i2("movl",X187Indexed{7,6,4,2147483647},x188_reg(8,32))),
    p191ac_function("p191ac_bytes_15",x188_i2("movb",x188_reg(6,8),X187Indexed{7,1,1,0})),
    p191ac_function("p191ac_bytes_16",x188_i2("movb",X187Indexed{0,1,1,0},x188_reg(7,8))),
    p191ac_function("p191ac_bytes_17",x188_i2("movb",x188_reg(15,8),X187Indexed{12,13,2,8})),
    p191ac_function("p191ac_bytes_18",x188_i2("movzbl",X187Indexed{12,13,2,0},x188_reg(8,32))),
    p191ac_function("p191ac_bytes_19",x188_i2("movd",x188_xmm(9),X187Indexed{12,13,4,0})),
    p191ac_function("p191ac_bytes_20",x188_i2("addss",X187Indexed{12,13,4,0},x188_xmm(9))),
    p191ac_function("p191ac_bytes_21",x188_i2("leaq",X187Indexed{13,12,8,0},x188_reg(10,64))),
    p191ac_function("p191ac_bytes_22",x188_i2("imulq",X187Indexed{13,12,8,4294967288},x188_reg(10,64))),
    p191ac_function("p191ac_bytes_23",x188_i2("addl",X187Indexed{7,6,4,0},x188_reg(0,32))),
    p191ac_function("p191ac_bytes_24",x188_i2("movl",X187Imm{305419896,0},X187Indexed{12,13,4,128})),
    p191ac_function("p191ac_bytes_25",x188_i1("setne",X187Indexed{13,12,1,0})),
    p191ac_function("p191ac_bytes_26",x188_i2("movq",X187Mem{12,0},x188_reg(9,64))),
    p191ac_function("p191ac_load64",x188_many([x188_i2("movq",X187Indexed{7,6,8,4294967288},x188_reg(0,64)),x188_i0("ret")])),
    p191ac_function("p191ac_load32",x188_many([x188_i2("movl",X187Indexed{7,6,4,4},x188_reg(0,32)),x188_i0("ret")])),
    p191ac_function("p191ac_store64",x188_many([x188_i2("movq",x188_reg(2,64),X187Indexed{7,6,8,0}),x188_i0("ret")])),
    p191ac_function("p191ac_load8",x188_many([x188_i2("movzbl",X187Indexed{7,6,1,0},x188_reg(0,32)),x188_i0("ret")])),
    p191ac_function("p191ac_load_r12",x188_many([x188_i1("pushq",x188_reg(12,64)),x188_i2("movq",x188_reg(6,64),x188_reg(12,64)),x188_i2("movq",X187Indexed{7,12,8,0},x188_reg(0,64)),x188_i1("popq",x188_reg(12,64)),x188_i0("ret")])),X188One{PSection{4}}])],""}
