# Literal byte witnesses and independent C execution controls for CMOVcc.
@unsafe
def p191mc_equal(a: List<&2,U32>, b: List<&2,U32>) -> Bool:
  match a b:
    case Nil{} Nil{}: True{}
    case Con{x,xs} Con{y,ys}: U32.is_eq(x,y) && p191mc_equal(xs,ys)
    case _ _: False{}
def p191mc_row(name: String, good: Bool) -> String:
  name ++ nt_choose(String,good,u => "=1",u => "=0")
@unsafe
def p191mc_bytes(result: X187Encoded, expected: List<&2,U32>) -> Bool:
  match result:
    case X187Encoded{bytes,relocs,error}:
      String.is_empty(error) && List.is_empty(&2,X187Relocation,relocs) && p191mc_equal(bytes,expected)
@unsafe
def p191mc_case(name: String, op: String, args: List<&2,X187Operand>, expected: List<&2,U32>) -> String:
  p191mc_row(name,p191mc_bytes(x187_encode(X187Instruction{op,args},0),expected))
def p191mc_failed(result: X187Encoded) -> Bool:
  match result:
    case X187Encoded{bytes,relocs,error}:
      Bool.not(String.is_empty(error)) && List.is_empty(&2,U32,bytes) && List.is_empty(&2,X187Relocation,relocs)
@unsafe
def p191mc_reject(name: String, op: String, args: List<&2,X187Operand>) -> String:
  p191mc_row(name,p191mc_failed(x187_encode(X187Instruction{op,args},0)))
@unsafe
def p191mc_function(+name: String, body: X188Seq) -> X188Seq:
  x188_many([X188One{PGlobal{name}},X188One{PType{name,2}},x188_label(name),body,X188One{PSize{name}}])
# Prefix48, opcode0f44, ModRM05, then aPC32 field at offset4.
@unsafe
def p191mc_rip(result: X187Encoded) -> Bool:
  match result:
    case X187Encoded{bytes,Con{X187Relocation{1,4,2,symbol,4294967292,4294967295},Nil{}},error}:
      String.is_empty(error) && String.eq(symbol,"p191mc_data") && p191mc_equal(bytes,[72,15,68,5,0,0,0,0])
    case _: False{}

@unsafe
def p191mc_controls() -> List<&2,String>:
  [p191mc_case("cmovel","cmovel",[x188_reg(10,32),x188_reg(9,32)],[69,15,68,202]),
   p191mc_case("cmovnel","cmovnel",[x188_reg(10,32),x188_reg(9,32)],[69,15,69,202]),
   p191mc_case("cmovbl","cmovbl",[x188_reg(10,32),x188_reg(9,32)],[69,15,66,202]),
   p191mc_case("cmovbel","cmovbel",[x188_reg(10,32),x188_reg(9,32)],[69,15,70,202]),
   p191mc_case("cmoval","cmoval",[x188_reg(10,32),x188_reg(9,32)],[69,15,71,202]),
   p191mc_case("cmovael","cmovael",[x188_reg(10,32),x188_reg(9,32)],[69,15,67,202]),
   p191mc_case("cmovll","cmovll",[x188_reg(10,32),x188_reg(9,32)],[69,15,76,202]),
   p191mc_case("cmovlel","cmovlel",[x188_reg(10,32),x188_reg(9,32)],[69,15,78,202]),
   p191mc_case("cmovgl","cmovgl",[x188_reg(10,32),x188_reg(9,32)],[69,15,79,202]),
   p191mc_case("cmovgel","cmovgel",[x188_reg(10,32),x188_reg(9,32)],[69,15,77,202]),
   p191mc_case("cmoveq","cmoveq",[x188_reg(10,64),x188_reg(9,64)],[77,15,68,202]),
   p191mc_case("cmovneq","cmovneq",[x188_reg(10,64),x188_reg(9,64)],[77,15,69,202]),
   p191mc_case("cmovbq","cmovbq",[x188_reg(10,64),x188_reg(9,64)],[77,15,66,202]),
   p191mc_case("cmovbeq","cmovbeq",[x188_reg(10,64),x188_reg(9,64)],[77,15,70,202]),
   p191mc_case("cmovaq","cmovaq",[x188_reg(10,64),x188_reg(9,64)],[77,15,71,202]),
   p191mc_case("cmovaeq","cmovaeq",[x188_reg(10,64),x188_reg(9,64)],[77,15,67,202]),
   p191mc_case("cmovlq","cmovlq",[x188_reg(10,64),x188_reg(9,64)],[77,15,76,202]),
   p191mc_case("cmovleq","cmovleq",[x188_reg(10,64),x188_reg(9,64)],[77,15,78,202]),
   p191mc_case("cmovgq","cmovgq",[x188_reg(10,64),x188_reg(9,64)],[77,15,79,202]),
   p191mc_case("cmovgeq","cmovgeq",[x188_reg(10,64),x188_reg(9,64)],[77,15,77,202]),
   p191mc_case("low-no-rex","cmovel",[x188_reg(1,32),x188_reg(0,32)],[15,68,193]),
   p191mc_case("mem-rbp-zero","cmoveq",[X187Mem{5,0},x188_reg(0,64)],[72,15,68,69,0]),
   p191mc_case("indexed-r12","cmovneq",[X187Indexed{13,12,8,0},x188_reg(10,64)],[79,15,69,84,229,0]),
   p191mc_case("mem32-negative","cmovgel",[X187Mem{12,4294967167},x188_reg(8,32)],[69,15,77,132,36,127,255,255,255]),
   p191mc_reject("reject-byte","cmoveb",[x188_reg(1,8),x188_reg(0,8)]),
   p191mc_reject("reject-word","cmovew",[x188_reg(1,16),x188_reg(0,16)]),
   p191mc_reject("reject-memory-dst","cmoveq",[x188_reg(1,64),X187Mem{0,0}]),
   p191mc_reject("reject-immediate","cmoveq",[X187Imm{1,0},x188_reg(0,64)]),
   p191mc_reject("reject-source-width","cmoveq",[x188_reg(1,32),x188_reg(0,64)]),
   p191mc_reject("reject-destination-width","cmovel",[x188_reg(1,32),x188_reg(0,64)]),
   p191mc_reject("reject-vector","cmovel",[x188_xmm(1),x188_reg(0,32)]),
   p191mc_reject("reject-register16","cmoveq",[x188_reg(16,64),x188_reg(0,64)]),
   p191mc_reject("reject-memory-base16","cmoveq",[X187Mem{16,0},x188_reg(0,64)]),
   p191mc_reject("reject-rsp-index","cmoveq",[X187Indexed{0,4,1,0},x188_reg(0,64)]),
   p191mc_reject("reject-arity","cmoveq",[x188_reg(0,64)]),
   p191mc_reject("reject-unknown-condition","cmovqq",[x188_reg(1,64),x188_reg(0,64)]),
   p191mc_row("rip-relocation",p191mc_rip(x187_encode(X187Instruction{"cmoveq",[X187Rip{"p191mc_data",0,0},x188_reg(0,64)]},0))),
   p191mc_row("render",String.eq(x188_instruction_text(X187Instruction{"cmovlel",[x188_reg(10,32),x188_reg(9,32)]}),"  cmovlel %r10d, %r9d\n"))]

@unsafe
def p191mc_emit() -> X181Output:
  X181Output{[x188_many([X188One{PSection{1}},
    p191mc_function("p191mc_bytes_0",x188_i2("cmovel",x188_reg(10,32),x188_reg(9,32))),
    p191mc_function("p191mc_bytes_1",x188_i2("cmovnel",x188_reg(10,32),x188_reg(9,32))),
    p191mc_function("p191mc_bytes_2",x188_i2("cmovbl",x188_reg(10,32),x188_reg(9,32))),
    p191mc_function("p191mc_bytes_3",x188_i2("cmovbel",x188_reg(10,32),x188_reg(9,32))),
    p191mc_function("p191mc_bytes_4",x188_i2("cmoval",x188_reg(10,32),x188_reg(9,32))),
    p191mc_function("p191mc_bytes_5",x188_i2("cmovael",x188_reg(10,32),x188_reg(9,32))),
    p191mc_function("p191mc_bytes_6",x188_i2("cmovll",x188_reg(10,32),x188_reg(9,32))),
    p191mc_function("p191mc_bytes_7",x188_i2("cmovlel",x188_reg(10,32),x188_reg(9,32))),
    p191mc_function("p191mc_bytes_8",x188_i2("cmovgl",x188_reg(10,32),x188_reg(9,32))),
    p191mc_function("p191mc_bytes_9",x188_i2("cmovgel",x188_reg(10,32),x188_reg(9,32))),
    p191mc_function("p191mc_bytes_10",x188_i2("cmoveq",x188_reg(10,64),x188_reg(9,64))),
    p191mc_function("p191mc_bytes_11",x188_i2("cmovneq",x188_reg(10,64),x188_reg(9,64))),
    p191mc_function("p191mc_bytes_12",x188_i2("cmovbq",x188_reg(10,64),x188_reg(9,64))),
    p191mc_function("p191mc_bytes_13",x188_i2("cmovbeq",x188_reg(10,64),x188_reg(9,64))),
    p191mc_function("p191mc_bytes_14",x188_i2("cmovaq",x188_reg(10,64),x188_reg(9,64))),
    p191mc_function("p191mc_bytes_15",x188_i2("cmovaeq",x188_reg(10,64),x188_reg(9,64))),
    p191mc_function("p191mc_bytes_16",x188_i2("cmovlq",x188_reg(10,64),x188_reg(9,64))),
    p191mc_function("p191mc_bytes_17",x188_i2("cmovleq",x188_reg(10,64),x188_reg(9,64))),
    p191mc_function("p191mc_bytes_18",x188_i2("cmovgq",x188_reg(10,64),x188_reg(9,64))),
    p191mc_function("p191mc_bytes_19",x188_i2("cmovgeq",x188_reg(10,64),x188_reg(9,64))),
    p191mc_function("p191mc_bytes_20",x188_i2("cmovel",x188_reg(1,32),x188_reg(0,32))),
    p191mc_function("p191mc_bytes_21",x188_i2("cmoveq",X187Mem{5,0},x188_reg(0,64))),
    p191mc_function("p191mc_bytes_22",x188_i2("cmovneq",X187Indexed{13,12,8,0},x188_reg(10,64))),
    p191mc_function("p191mc_bytes_23",x188_i2("cmovgel",X187Mem{12,4294967167},x188_reg(8,32))),
    p191mc_function("p191mc_e_32",x188_many([x188_i2("movq",x188_reg(1,64),x188_reg(0,64)),x188_i2("cmpl",x188_reg(6,32),x188_reg(7,32)),x188_i2("cmovel",x188_reg(2,32),x188_reg(0,32)),x188_i0("ret")])),
    p191mc_function("p191mc_ne_32",x188_many([x188_i2("movq",x188_reg(1,64),x188_reg(0,64)),x188_i2("cmpl",x188_reg(6,32),x188_reg(7,32)),x188_i2("cmovnel",x188_reg(2,32),x188_reg(0,32)),x188_i0("ret")])),
    p191mc_function("p191mc_b_32",x188_many([x188_i2("movq",x188_reg(1,64),x188_reg(0,64)),x188_i2("cmpl",x188_reg(6,32),x188_reg(7,32)),x188_i2("cmovbl",x188_reg(2,32),x188_reg(0,32)),x188_i0("ret")])),
    p191mc_function("p191mc_be_32",x188_many([x188_i2("movq",x188_reg(1,64),x188_reg(0,64)),x188_i2("cmpl",x188_reg(6,32),x188_reg(7,32)),x188_i2("cmovbel",x188_reg(2,32),x188_reg(0,32)),x188_i0("ret")])),
    p191mc_function("p191mc_a_32",x188_many([x188_i2("movq",x188_reg(1,64),x188_reg(0,64)),x188_i2("cmpl",x188_reg(6,32),x188_reg(7,32)),x188_i2("cmoval",x188_reg(2,32),x188_reg(0,32)),x188_i0("ret")])),
    p191mc_function("p191mc_ae_32",x188_many([x188_i2("movq",x188_reg(1,64),x188_reg(0,64)),x188_i2("cmpl",x188_reg(6,32),x188_reg(7,32)),x188_i2("cmovael",x188_reg(2,32),x188_reg(0,32)),x188_i0("ret")])),
    p191mc_function("p191mc_l_32",x188_many([x188_i2("movq",x188_reg(1,64),x188_reg(0,64)),x188_i2("cmpl",x188_reg(6,32),x188_reg(7,32)),x188_i2("cmovll",x188_reg(2,32),x188_reg(0,32)),x188_i0("ret")])),
    p191mc_function("p191mc_le_32",x188_many([x188_i2("movq",x188_reg(1,64),x188_reg(0,64)),x188_i2("cmpl",x188_reg(6,32),x188_reg(7,32)),x188_i2("cmovlel",x188_reg(2,32),x188_reg(0,32)),x188_i0("ret")])),
    p191mc_function("p191mc_g_32",x188_many([x188_i2("movq",x188_reg(1,64),x188_reg(0,64)),x188_i2("cmpl",x188_reg(6,32),x188_reg(7,32)),x188_i2("cmovgl",x188_reg(2,32),x188_reg(0,32)),x188_i0("ret")])),
    p191mc_function("p191mc_ge_32",x188_many([x188_i2("movq",x188_reg(1,64),x188_reg(0,64)),x188_i2("cmpl",x188_reg(6,32),x188_reg(7,32)),x188_i2("cmovgel",x188_reg(2,32),x188_reg(0,32)),x188_i0("ret")])),
    p191mc_function("p191mc_e_64",x188_many([x188_i2("movq",x188_reg(1,64),x188_reg(0,64)),x188_i2("cmpq",x188_reg(6,64),x188_reg(7,64)),x188_i2("cmoveq",x188_reg(2,64),x188_reg(0,64)),x188_i0("ret")])),
    p191mc_function("p191mc_ne_64",x188_many([x188_i2("movq",x188_reg(1,64),x188_reg(0,64)),x188_i2("cmpq",x188_reg(6,64),x188_reg(7,64)),x188_i2("cmovneq",x188_reg(2,64),x188_reg(0,64)),x188_i0("ret")])),
    p191mc_function("p191mc_b_64",x188_many([x188_i2("movq",x188_reg(1,64),x188_reg(0,64)),x188_i2("cmpq",x188_reg(6,64),x188_reg(7,64)),x188_i2("cmovbq",x188_reg(2,64),x188_reg(0,64)),x188_i0("ret")])),
    p191mc_function("p191mc_be_64",x188_many([x188_i2("movq",x188_reg(1,64),x188_reg(0,64)),x188_i2("cmpq",x188_reg(6,64),x188_reg(7,64)),x188_i2("cmovbeq",x188_reg(2,64),x188_reg(0,64)),x188_i0("ret")])),
    p191mc_function("p191mc_a_64",x188_many([x188_i2("movq",x188_reg(1,64),x188_reg(0,64)),x188_i2("cmpq",x188_reg(6,64),x188_reg(7,64)),x188_i2("cmovaq",x188_reg(2,64),x188_reg(0,64)),x188_i0("ret")])),
    p191mc_function("p191mc_ae_64",x188_many([x188_i2("movq",x188_reg(1,64),x188_reg(0,64)),x188_i2("cmpq",x188_reg(6,64),x188_reg(7,64)),x188_i2("cmovaeq",x188_reg(2,64),x188_reg(0,64)),x188_i0("ret")])),
    p191mc_function("p191mc_l_64",x188_many([x188_i2("movq",x188_reg(1,64),x188_reg(0,64)),x188_i2("cmpq",x188_reg(6,64),x188_reg(7,64)),x188_i2("cmovlq",x188_reg(2,64),x188_reg(0,64)),x188_i0("ret")])),
    p191mc_function("p191mc_le_64",x188_many([x188_i2("movq",x188_reg(1,64),x188_reg(0,64)),x188_i2("cmpq",x188_reg(6,64),x188_reg(7,64)),x188_i2("cmovleq",x188_reg(2,64),x188_reg(0,64)),x188_i0("ret")])),
    p191mc_function("p191mc_g_64",x188_many([x188_i2("movq",x188_reg(1,64),x188_reg(0,64)),x188_i2("cmpq",x188_reg(6,64),x188_reg(7,64)),x188_i2("cmovgq",x188_reg(2,64),x188_reg(0,64)),x188_i0("ret")])),
    p191mc_function("p191mc_ge_64",x188_many([x188_i2("movq",x188_reg(1,64),x188_reg(0,64)),x188_i2("cmpq",x188_reg(6,64),x188_reg(7,64)),x188_i2("cmovgeq",x188_reg(2,64),x188_reg(0,64)),x188_i0("ret")])),X188One{PSection{4}}])],""}
