# Match the complete scalar segment after public fusion and hygiene admission.
@unsafe
def x202k_index(call: N111Stmt, op: String, +index: U32) -> Bool:
  match call:
    case N111Call{dest,N111U64{},symbol,Con{N111Arg{N111Ptr{},N111Local{state}},Con{N111Arg{N111U32{},N111Const{lo,0}},Nil{}}}}:
      String.eq(symbol,op) && String.eq(state,"state") && U32.is_eq(lo,index)
    case _: False{}

@unsafe
def x202k_digits(text: String) -> Bool:
  match text:
    case SNil{}: True{}
    case SCon{ch,rest}: U32.is_le(U32.sub(Char.to_u32(ch),48),9) && x202k_digits(rest)

@unsafe
def x202k_digit_name(name: String) -> Bool:
  match name:
    case SCon{a,SCon{b,+suffix}}: Char.is_eq(a,'v') && Char.is_eq(b,'_') && Bool.not(String.is_empty(suffix)) && x202k_digits(suffix)
    case _: False{}

@unsafe
def x202k_tail(rows: List<&2,N111Stmt>, +saved: String) -> Bool:
  match rows:
    case Con{N111Load{+incoming,N111U64{},N111Local{base},40},
      Con{N111Set{+alias,N111U64{},N111Local{src}},Con{N111Call{dest,N111U64{},symbol,Con{N111Arg{N111Ptr{},N111Local{state}},
        Con{N111Arg{N111U64{},N111Local{first}},Con{N111Arg{N111U64{},N111Local{second}},Nil{}}}}},
      Con{N111Return{N111Local{reply}},Nil{}}}}}:
      String.eq(base,"state") && String.eq(state,"state") && String.eq(dest,"reply") && String.eq(reply,"reply") &&
        String.eq(symbol,"p111_rt_apply") && x202k_digit_name(incoming) && x202k_digit_name(saved) &&
        x202k_digit_name(alias) && String.eq(saved,src) && Bool.not(String.eq(saved,incoming) || String.eq(alias,incoming) || String.eq(alias,saved)) &&
        String.eq(first,incoming) && String.eq(second,alias)
    case _: False{}

@unsafe
def x202k_calls(+pop: N111Stmt, +get: N111Stmt, rest: List<&2,N111Stmt>, scratch: String) -> Bool:
  match pop get:
    case N111Call{ignored,pt,po,pa} N111Call{saved,gt,go,ga}:
      String.eq(scratch,"scratch") && String.eq(ignored,"ignored") && x202k_index(pop,"p111_rt_stack_pop",1) &&
        x202k_index(get,"p111_rt_stack_get",0) && x202k_tail(rest,saved)
    case _ _: False{}

@unsafe
def x202k_shape(body: List<&2,N111Stmt>) -> Bool:
  match body:
    case Con{N111Alloca{scratch,2048,8},Con{pop,Con{get,rest}}}: x202k_calls(pop,get,rest,scratch)
    case _: False{}

@unsafe
def x202k_template(+symbol: String) -> X181Output:
  X181Output{[x188_many([X188One{PSection{1}},X188One{PGlobal{symbol}},X188One{PType{symbol,2}},x188_label(symbol),
    x188_i1("pushq",x188_reg(5,64)),x188_i2("movq",x188_reg(4,64),x188_reg(5,64)),
    x188_i2("subq",X187Imm{2320,0},x188_reg(4,64)),x188_i2("movq",x188_reg(12,64),X187Mem{5,4294967280}),
    x188_i2("movq",x188_reg(7,64),x188_reg(0,64)),x188_i2("movq",x188_reg(0,64),x188_reg(12,64)),
    x188_label(".L" ++ symbol ++ "_loop"),
    x188_i2("movq",X187Mem{12,16},x188_reg(7,64)),x188_i2("movabsq",X187Imm{4294967288,4294967295},x188_reg(11,64)),
    x188_i2("addq",x188_reg(11,64),x188_reg(7,64)),x188_i2("movq",x188_reg(7,64),X187Mem{12,16}),
    x188_i2("movq",X187Mem{12,16},x188_reg(7,64)),x188_i2("movq",X187Mem{7,0},x188_reg(6,64)),
    x188_i2("movq",X187Mem{12,40},x188_reg(7,64)),x188_i2("movq",x188_reg(12,64),x188_reg(10,64)),
    x188_i2("movq",x188_reg(10,64),X187Mem{4,24}),x188_i2("movq",x188_reg(7,64),x188_reg(10,64)),
    x188_i2("movq",x188_reg(10,64),X187Mem{4,32}),x188_i2("movq",x188_reg(6,64),x188_reg(10,64)),
    x188_i2("movq",x188_reg(10,64),X187Mem{4,40}),x188_i2("movq",X187Mem{4,24},x188_reg(7,64)),
    x188_i2("movq",X187Mem{4,32},x188_reg(6,64)),x188_i2("movq",X187Mem{4,40},x188_reg(2,64)),
    x188_i2("xorl",x188_reg(0,32),x188_reg(0,32)),x188_i1("call",X187Target{"p111_rt_apply"}),
    x188_i2("movq",x188_reg(0,64),x188_reg(7,64)),x188_i2("movq",x188_reg(7,64),x188_reg(0,64)),
    x188_i2("movq",X187Mem{5,4294967280},x188_reg(12,64)),x188_i2("movq",x188_reg(5,64),x188_reg(4,64)),
    x188_i1("popq",x188_reg(5,64)),x188_i0("ret"),X188One{PSize{symbol}}])],""}
