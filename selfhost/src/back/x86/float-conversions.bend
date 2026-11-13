# ABI11102 unary numeric conversions. Input/output are canonical low32 words.
# Only reserved r10/r11, xmm0/xmm1 and flags are clobbered. Arithmetic rounding
# points remain unchanged; CVTSI2SS rounds once, CVTTSS2SI always truncates.
def x192_float_conversions_enabled() -> Bool: True{}

def x192_float_unary(+id: U32) -> Bool:
  U32.is_eq(id,23) || U32.is_eq(id,58)

# Keep the runtime's initial COMISS against zero, including its MXCSR invalid
# (any NaN) and denormal behavior. Positive finite raw F32 bits have the
# same unsigned order as their values. All negative encodings, NaNs, infinities
# and values >=2^32 are >=0x4f800000. Sanitize them BEFORE conversion, so even
# unmasked invalid exceptions cannot arise from a speculative conversion.
# Signed64 CVTT is required: signed32 would reject valid values >=2^31.
@unsafe
def x192_float_to_u32_core() -> X188Seq:
  x188_many([x188_i2("pxor",x188_xmm(1),x188_xmm(1)),
    x188_i2("comiss",x188_xmm(1),x188_xmm(0)),
    x188_i2("movd",x188_xmm(0),x188_reg(10,32)),
    x188_i2("xorl",x188_reg(11,32),x188_reg(11,32)),
    x188_i2("cmpl",X187Imm{1333788672,0},x188_reg(10,32)),
    x188_i2("cmovael",x188_reg(11,32),x188_reg(10,32)),
    x188_i2("movd",x188_reg(10,32),x188_xmm(0)),
    x188_i2("cvttss2siq",x188_xmm(0),x188_reg(10,64)),
    x188_i2("movl",x188_reg(10,32),x188_reg(10,32))])

@unsafe
def x192_u32_to_float_core() -> X188Seq:
  x188_many([x188_i2("movd",x188_xmm(0),x188_reg(10,32)),
    x188_i2("pxor",x188_xmm(0),x188_xmm(0)),
    x188_i2("cvtsi2ssq",x188_reg(10,64),x188_xmm(0)),
    x188_i2("movd",x188_xmm(0),x188_reg(10,32))])

@unsafe
def x192_float_conversion_core(id: U32) -> X188Seq:
  nt_choose(X188Seq,U32.is_eq(id,58),u => x192_float_to_u32_core(),u => x192_u32_to_float_core())

@unsafe
def x192_float_conversion(+name: String, id: U32, value: N111Value,
    ids: N111Ids, +frame: X181Frame, +homes: KDef) -> X188Seq:
  x188_many([x186_x_load(value,ids,frame,homes,x188_xmm(0)),
    x192_float_conversion_core(id),x186_x_compare_result(x186_x_home(name,homes),name,frame)])

@unsafe
def x192_float_conversion_buffer(name: String, id: U32, buffer: String,
    ids: N111Ids, +frame: X181Frame) -> X188Seq:
  x188_many([x181_load(N111Local{buffer},ids,frame,x188_reg(10,64)),
    x188_i2("movd",X187Mem{10,0},x188_xmm(0)),
    x192_float_conversion_core(id),x181_store(name,frame,x188_reg(10,64))])

# CVTTSS2SI r64,xmm/m32: F3 REX.W 0F 2C /r. Reject every wrong width/class;
# ordinary/indexed/RIP memory forms share the existing checked ModRM encoder.
@unsafe
def x192_float_cvtt(+src: X187Operand, +dst: X187Operand, offset: U32) -> X187Encoded:
  nt_choose(X187Encoded,x187_e_reg(dst,64,False{}) && x187_e_rm(src,128,True{}),
    u => x187_e_modrm(243,[15,44],True{},x187_e_index(dst),src,False{},[],offset),
    u => x187_e_error())

@unsafe
def x192_float_cvtt_operands(operands: List<&2,X187Operand>, offset: U32) -> X187Encoded:
  match operands:
    case Con{src,Con{dst,Nil{}}}: x192_float_cvtt(src,dst,offset)
    case _: x187_e_error()
