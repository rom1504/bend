# Finite AMD64 instruction encoder for the maintained AT&T selection surface.
# No instruction relaxation: calls/jumps use rel32; base memory uses disp0/8/32.
# Unsupported forms return an error and no bytes, never a guessed encoding.
type X187RM is Data:
  X187RM{+bytes: List<&2,U32>, +relocations: List<&2,X187Relocation>, +error: String}
type X187Op is Data:
  X187Op{+family: U32, +width: U32, +code: U32, +extra: U32, +prefix: U32}
  X187OpNone{}

def x187_e_error() -> X187Encoded: X187Encoded{[],[],"unsupported x86 instruction or operand form"}
def x187_e_ok(bytes: List<&2,U32>) -> X187Encoded: X187Encoded{bytes,[],""}

@unsafe
def x187_e_le(+word: U32, +count: U32) -> List<&2,U32>:
  nt_choose(List<&2,U32>,U32.is_eq(count,0),u => [],
    u => Con{U32.mod(word,256),x187_e_le(U32.div(word,256),U32.sub(count,1))})

@unsafe
def x187_e_imm(+lo: U32, hi: U32, +width: U32) -> List<&2,U32>:
  nt_choose(List<&2,U32>,U32.is_eq(width,64),u => nt_append(U32,x187_e_le(lo,4),x187_e_le(hi,4)),
    u => x187_e_le(lo,nt_choose(U32,U32.is_eq(width,8),v => 1,v => 4)))

@unsafe
def x187_e_reg(value: X187Operand, +width: U32, +vector: Bool) -> Bool:
  match value:
    case X187Reg{index,bits,simd}: U32.is_lt(index,16) && U32.is_eq(width,bits) && Bool.not(Bool.xor(vector,simd))
    case _: False{}

@unsafe
def x187_e_rm(value: X187Operand, width: U32, vector: Bool) -> Bool:
  match value:
    case X187Mem{base,disp}: U32.is_lt(base,16)
    case X187Indexed{base,index,scale,disp}: x191_e_indexed_valid(base,index,scale)
    case X187Rip{symbol,lo,hi}: Bool.not(String.is_empty(symbol))
    case _: x187_e_reg(value,width,vector)

@unsafe
def x187_e_index(value: X187Operand) -> U32:
  match value:
    case X187Reg{index,width,vector}: index
    case X187Mem{base,disp}: base
    case X187Indexed{base,index,scale,disp}: base
    case _: 0

# RSP cannot be an index: SIB index4 without REX.X denotes no index.
# R12 is a real index: SIB index4 with REX.X denotes R12.
def x191_e_indexed_valid(base: U32, +index: U32, +scale: U32) -> Bool:
  U32.is_lt(base,16) && U32.is_lt(index,16) && Bool.not(U32.is_eq(index,4)) &&
    (U32.is_eq(scale,1) || U32.is_eq(scale,2) || U32.is_eq(scale,4) || U32.is_eq(scale,8))

def x191_e_rex_x(value: X187Operand) -> U32:
  match value:
    case X187Indexed{base,index,scale,disp}: nt_choose(U32,U32.is_ge(index,8),u => 2,u => 0)
    case _: 0

@unsafe
def x187_e_byte(value: X187Operand) -> Bool:
  match value:
    case X187Reg{index,8,False{}}: U32.is_ge(index,4)
    case _: False{}

@unsafe
def x187_e_signed32(+lo: U32, +hi: U32) -> Bool:
  (U32.is_eq(hi,0) && U32.is_le(lo,2147483647)) || (U32.is_eq(hi,4294967295) && U32.is_ge(lo,2147483648))

@unsafe
def x187_e_fits(+lo: U32, +hi: U32, +width: U32) -> Bool:
  nt_choose(Bool,U32.is_eq(width,64),u => x187_e_signed32(lo,hi),u =>
    U32.is_eq(hi,0) && nt_choose(Bool,U32.is_eq(width,8),v => U32.is_le(lo,255),v => True{}))

@unsafe
def x187_e_prefix(+legacy: U32, wide: Bool, reg: U32, +operand: X187Operand, force: Bool) -> List<&2,U32>:
  +rex = U32.add(64,U32.add(nt_choose(U32,wide,u => 8,u => 0),U32.add(
    nt_choose(U32,U32.is_ge(reg,8),u => 4,u => 0),U32.add(x191_e_rex_x(operand),
      nt_choose(U32,U32.is_ge(x187_e_index(operand),8),u => 1,u => 0)))))
  nt_append(U32,nt_choose(List<&2,U32>,U32.is_eq(legacy,0),u => [],u => [legacy]),
    nt_choose(List<&2,U32>,U32.is_gt(rex,64) || force,u => [rex],u => []))

@unsafe
def x187_e_mem(+base: U32, +disp: U32, +reg: U32) -> List<&2,U32>:
  +low = U32.mod(base,8)
  +mode = nt_choose(U32,U32.is_eq(disp,0) && Bool.not(U32.is_eq(low,5)),u => 0,u =>
    nt_choose(U32,U32.is_le(disp,127) || U32.is_ge(disp,4294967168),v => 1,v => 2))
  Con{U32.add(U32.mul(mode,64),U32.add(U32.mul(U32.mod(reg,8),8),low)),
    nt_append(U32,nt_choose(List<&2,U32>,U32.is_eq(low,4),u => [36],u => []),
      nt_choose(List<&2,U32>,U32.is_eq(mode,0),u => [],u =>
        x187_e_le(disp,nt_choose(U32,U32.is_eq(mode,1),v => 1,v => 4))))}

def x191_e_scale(scale: U32) -> U32:
  match scale:
    case 1: 0
    case 2: 1
    case 4: 2
    case _: 3

@unsafe
def x191_e_indexed(+base: U32, index: U32, scale: U32, +disp: U32, reg: U32) -> List<&2,U32>:
  +low = U32.mod(base,8)
  +mode = nt_choose(U32,U32.is_eq(disp,0) && Bool.not(U32.is_eq(low,5)),u => 0,u =>
    nt_choose(U32,U32.is_le(disp,127) || U32.is_ge(disp,4294967168),v => 1,v => 2))
  +shift = x191_e_scale(scale)
  Con{U32.add(U32.mul(mode,64),U32.add(U32.mul(U32.mod(reg,8),8),4)),
    Con{U32.add(U32.mul(shift,64),U32.add(U32.mul(U32.mod(index,8),8),low)),
      nt_choose(List<&2,U32>,U32.is_eq(mode,0),u => [],u =>
        x187_e_le(disp,nt_choose(U32,U32.is_eq(mode,1),v => 1,v => 4)))}}

@unsafe
def x187_e_address(value: X187Operand, +reg: U32, field: U32, +trailing: U32) -> X187RM:
  match value:
    case X187Reg{index,width,vector}: X187RM{[U32.add(192,U32.add(U32.mul(U32.mod(reg,8),8),U32.mod(index,8)))],[],""}
    case X187Mem{base,disp}: X187RM{x187_e_mem(base,disp,reg),[],""}
    case X187Indexed{+base,+index,+scale,+disp}:
      nt_choose(X187RM,x191_e_indexed_valid(base,index,scale),u =>
        X187RM{x191_e_indexed(base,index,scale,disp,reg),[],""},
        u => X187RM{[],[],"invalid indexed ModRM operand"})
    case X187Rip{symbol,+lo,+hi}:
      +sub = U32.add(4,trailing)
      X187RM{[U32.add(5,U32.mul(U32.mod(reg,8),8)),0,0,0,0],
        [X187Relocation{1,U32.inc(field),2,symbol,U32.sub(lo,sub),
          U32.sub(hi,nt_choose(U32,U32.is_lt(lo,sub),u => 1,u => 0))}],""}
    case _: X187RM{[],[],"invalid ModRM operand"}

@unsafe
def x187_e_finish(prefix: List<&2,U32>, tail: List<&2,U32>, rm: X187RM) -> X187Encoded:
  match rm:
    case X187RM{bytes,relocations,error}: X187Encoded{nt_append(U32,prefix,nt_append(U32,bytes,tail)),relocations,error}

@unsafe
def x187_e_modrm(+legacy: U32, +codes: List<&2,U32>, wide: Bool, +reg: U32, +operand: X187Operand,
    force: Bool, +tail: List<&2,U32>, offset: U32) -> X187Encoded:
  +prefix = nt_append(U32,x187_e_prefix(legacy,wide,reg,operand,force),codes)
  x187_e_finish(prefix,tail,x187_e_address(operand,reg,U32.add(offset,nt_count(U32,prefix)),nt_count(U32,tail)))

@unsafe
def x187_e_reg_immediate(+dst: X187Operand, +lo: U32, +hi: U32, +width: U32) -> X187Encoded:
  match dst:
    case X187Reg{+index,bits,vector}:
      nt_choose(X187Encoded,x187_e_reg(dst,width,False{}) &&
          (U32.is_eq(width,64) || (U32.is_eq(hi,0) && (Bool.not(U32.is_eq(width,8)) || U32.is_le(lo,255)))),u =>
        x187_e_ok(nt_append(U32,x187_e_prefix(0,U32.is_eq(width,64),0,dst,x187_e_byte(dst)),
          Con{U32.add(nt_choose(U32,U32.is_eq(width,8),v => 176,v => 184),U32.mod(index,8)),x187_e_imm(lo,hi,width)})),u => x187_e_error())
    case _: x187_e_error()

@unsafe
def x187_e_mov_immediate(+dst: X187Operand, +lo: U32, +hi: U32, +width: U32, +offset: U32) -> X187Encoded:
  nt_choose(X187Encoded,x187_e_reg(dst,width,False{}),u => x187_e_reg_immediate(dst,lo,hi,width),u =>
    nt_choose(X187Encoded,x187_e_rm(dst,width,False{}) && x187_e_fits(lo,hi,width),v =>
      x187_e_modrm(0,[nt_choose(U32,U32.is_eq(width,8),w => 198,w => 199)],U32.is_eq(width,64),0,dst,
        False{},x187_e_le(lo,nt_choose(U32,U32.is_eq(width,8),w => 1,w => 4)),offset),v => x187_e_error()))

@unsafe
def x187_e_mov(+src: X187Operand, +dst: X187Operand, +width: U32, +offset: U32) -> X187Encoded:
  match src:
    case X187Imm{lo,hi}: x187_e_mov_immediate(dst,lo,hi,width,offset)
    case _:
      nt_choose(X187Encoded,x187_e_reg(src,width,False{}) && x187_e_rm(dst,width,False{}),u =>
        x187_e_modrm(0,[nt_choose(U32,U32.is_eq(width,8),v => 136,v => 137)],U32.is_eq(width,64),
          x187_e_index(src),dst,x187_e_byte(src) || x187_e_byte(dst),[],offset),u =>
      nt_choose(X187Encoded,x187_e_rm(src,width,False{}) && x187_e_reg(dst,width,False{}),u =>
        x187_e_modrm(0,[nt_choose(U32,U32.is_eq(width,8),v => 138,v => 139)],U32.is_eq(width,64),
          x187_e_index(dst),src,x187_e_byte(src) || x187_e_byte(dst),[],offset),u => x187_e_error()))

@unsafe
def x187_e_movabs(src: X187Operand, dst: X187Operand) -> X187Encoded:
  match src:
    case X187Imm{lo,hi}: x187_e_reg_immediate(dst,lo,hi,64)
    case _: x187_e_error()

@unsafe
def x187_e_alu(+src: X187Operand, +dst: X187Operand, +width: U32, +ext: U32, +offset: U32) -> X187Encoded:
  match src:
    case X187Imm{+lo,+hi}:
      nt_choose(X187Encoded,x187_e_rm(dst,width,False{}) && x187_e_fits(lo,hi,width),u =>
        x187_e_modrm(0,[nt_choose(U32,U32.is_eq(width,8),v => 128,v => 129)],U32.is_eq(width,64),ext,dst,
          x187_e_byte(dst),x187_e_le(lo,nt_choose(U32,U32.is_eq(width,8),v => 1,v => 4)),offset),u => x187_e_error())
    case _:
      +code = U32.add(U32.mul(ext,8),nt_choose(U32,U32.is_eq(width,8),u => 0,u => 1))
      nt_choose(X187Encoded,x187_e_reg(src,width,False{}) && x187_e_rm(dst,width,False{}),u =>
        x187_e_modrm(0,[code],U32.is_eq(width,64),x187_e_index(src),dst,x187_e_byte(src) || x187_e_byte(dst),[],offset),u =>
      nt_choose(X187Encoded,x187_e_rm(src,width,False{}) && x187_e_reg(dst,width,False{}),u =>
        x187_e_modrm(0,[U32.add(code,2)],U32.is_eq(width,64),x187_e_index(dst),src,x187_e_byte(src) || x187_e_byte(dst),[],offset),u => x187_e_error()))

@unsafe
def x187_e_test(+src: X187Operand, +dst: X187Operand, +width: U32, offset: U32) -> X187Encoded:
  nt_choose(X187Encoded,x187_e_reg(src,width,False{}) && x187_e_rm(dst,width,False{}),u =>
    x187_e_modrm(0,[nt_choose(U32,U32.is_eq(width,8),v => 132,v => 133)],U32.is_eq(width,64),
      x187_e_index(src),dst,x187_e_byte(src) || x187_e_byte(dst),[],offset),u => x187_e_error())

@unsafe
def x187_e_shift(+src: X187Operand, +dst: X187Operand, +width: U32, +ext: U32, +offset: U32) -> X187Encoded:
  match src:
    case X187Imm{+lo,0}:
      nt_choose(X187Encoded,U32.is_le(lo,255) && x187_e_rm(dst,width,False{}),u =>
        x187_e_modrm(0,[193],U32.is_eq(width,64),ext,dst,False{},[lo],offset),u => x187_e_error())
    case X187Reg{1,8,False{}}:
      nt_choose(X187Encoded,x187_e_rm(dst,width,False{}),u =>
        x187_e_modrm(0,[211],U32.is_eq(width,64),ext,dst,False{},[],offset),u => x187_e_error())
    case _: x187_e_error()

@unsafe
def x187_e_imul(+src: X187Operand, +dst: X187Operand, +width: U32, +offset: U32) -> X187Encoded:
  match src:
    case X187Imm{+lo,+hi}:
      nt_choose(X187Encoded,x187_e_reg(dst,width,False{}) && x187_e_fits(lo,hi,width),u =>
        x187_e_modrm(0,[105],U32.is_eq(width,64),x187_e_index(dst),dst,False{},x187_e_le(lo,4),offset),u => x187_e_error())
    case _:
      nt_choose(X187Encoded,x187_e_reg(dst,width,False{}) && x187_e_rm(src,width,False{}),u =>
        x187_e_modrm(0,[15,175],U32.is_eq(width,64),x187_e_index(dst),src,False{},[],offset),u => x187_e_error())

@unsafe
def x187_e_sse(+src: X187Operand, +dst: X187Operand, legacy: U32, code: U32, offset: U32) -> X187Encoded:
  nt_choose(X187Encoded,x187_e_reg(dst,128,True{}) && x187_e_rm(src,128,True{}),u =>
    x187_e_modrm(legacy,[15,code],False{},x187_e_index(dst),src,False{},[],offset),u => x187_e_error())

@unsafe
def x187_e_movd(+src: X187Operand, +dst: X187Operand, +offset: U32) -> X187Encoded:
  nt_choose(X187Encoded,x187_e_reg(dst,128,True{}) && x187_e_rm(src,32,False{}),u =>
    x187_e_modrm(102,[15,110],False{},x187_e_index(dst),src,False{},[],offset),u =>
  nt_choose(X187Encoded,x187_e_reg(src,128,True{}) && x187_e_rm(dst,32,False{}),u =>
    x187_e_modrm(102,[15,126],False{},x187_e_index(src),dst,False{},[],offset),u => x187_e_error()))

@unsafe
def x187_e_branch(operand: X187Operand, +code: U32, +extra: U32, +offset: U32) -> X187Encoded:
  match operand:
    case X187Target{+symbol}:
      +codes: List<&2,U32> = nt_choose(List<&2,U32>,U32.is_eq(code,15),u => [15,extra],u => [code])
      nt_choose(X187Encoded,Bool.not(String.is_empty(symbol)),u =>
        X187Encoded{nt_append(U32,codes,[0,0,0,0]),[X187Relocation{1,U32.add(offset,nt_count(U32,codes)),
          nt_choose(U32,U32.is_eq(code,232),v => 4,v => 2),symbol,4294967292,4294967295}],""},u => x187_e_error())
    case _: x187_e_error()

@unsafe
def x187_e_single(+operand: X187Operand, +family: U32, +width: U32, +code: U32, +extra: U32, +offset: U32) -> X187Encoded:
  nt_choose(X187Encoded,U32.is_eq(family,9),u => x187_e_branch(operand,code,extra,offset),u =>
  nt_choose(X187Encoded,U32.is_eq(family,8),u => nt_choose(X187Encoded,x187_e_reg(operand,64,False{}),v =>
    x187_e_ok(nt_append(U32,x187_e_prefix(0,False{},0,operand,False{}),[U32.add(code,U32.mod(x187_e_index(operand),8))])),v => x187_e_error()),u =>
  nt_choose(X187Encoded,U32.is_eq(family,5) && x187_e_rm(operand,8,False{}),u =>
    x187_e_modrm(0,[15,code],False{},0,operand,x187_e_byte(operand),[],offset),u => x187_e_error())))

@unsafe
def x187_e_pair(+src: X187Operand, +dst: X187Operand, +family: U32, +width: U32,
    +code: U32, +extra: U32, +prefix: U32, +offset: U32) -> X187Encoded:
  nt_choose(X187Encoded,U32.is_eq(family,1),u => x187_e_alu(src,dst,width,extra,offset),u =>
  nt_choose(X187Encoded,U32.is_eq(family,2),u => x187_e_mov(src,dst,width,offset),u =>
  nt_choose(X187Encoded,U32.is_eq(family,15),u => x187_e_movabs(src,dst),u =>
  nt_choose(X187Encoded,U32.is_eq(family,3),u => x187_e_shift(src,dst,width,extra,offset),u =>
  nt_choose(X187Encoded,U32.is_eq(family,4),u => x187_e_imul(src,dst,width,offset),u =>
  nt_choose(X187Encoded,U32.is_eq(family,6),u => nt_choose(X187Encoded,x187_e_reg(dst,32,False{}) && x187_e_rm(src,8,False{}),v =>
    x187_e_modrm(0,[15,182],False{},x187_e_index(dst),src,x187_e_byte(src),[],offset),v => x187_e_error()),u =>
  nt_choose(X187Encoded,U32.is_eq(family,7),u => x187_e_sse(src,dst,prefix,code,offset),u =>
  nt_choose(X187Encoded,U32.is_eq(family,10),u => x187_e_movd(src,dst,offset),u =>
  nt_choose(X187Encoded,U32.is_eq(family,11),u => nt_choose(X187Encoded,x187_e_reg(dst,128,True{}) && x187_e_rm(src,64,False{}),v =>
    x187_e_modrm(243,[15,42],True{},x187_e_index(dst),src,False{},[],offset),v => x187_e_error()),u =>
  nt_choose(X187Encoded,U32.is_eq(family,12),u => nt_choose(X187Encoded,x187_e_reg(dst,64,False{}) &&
    x187_e_rm(src,64,False{}) && Bool.not(x187_e_reg(src,64,False{})),v =>
      x187_e_modrm(0,[141],True{},x187_e_index(dst),src,False{},[],offset),v => x187_e_error()),u =>
  nt_choose(X187Encoded,U32.is_eq(family,13),u => x187_e_test(src,dst,width,offset),u =>
    nt_choose(X187Encoded,U32.is_eq(family,16),v => x191cm_pair(src,dst,width,code,offset),v => x187_e_error()))))))))))))

@unsafe
def x187_e_selected(spec: X187Op, operands: List<&2,X187Operand>, offset: U32) -> X187Encoded:
  match spec operands:
    case X187Op{14,width,code,extra,prefix} Nil{}: x187_e_ok([195])
    case X187Op{family,width,code,extra,prefix} Con{operand,Nil{}}: x187_e_single(operand,family,width,code,extra,offset)
    case X187Op{family,width,code,extra,prefix} Con{src,Con{dst,Nil{}}}: x187_e_pair(src,dst,family,width,code,extra,prefix,offset)
    case _ _: x187_e_error()

@unsafe
def x187_e_spec(+op: String) -> X187Op:
  nt_choose(X187Op,String.eq(op,"addb"),u => X187Op{1,8,0,0,0},u =>
  nt_choose(X187Op,String.eq(op,"addl"),u => X187Op{1,32,0,0,0},u =>
  nt_choose(X187Op,String.eq(op,"addq"),u => X187Op{1,64,0,0,0},u =>
  nt_choose(X187Op,String.eq(op,"orb"),u => X187Op{1,8,0,1,0},u =>
  nt_choose(X187Op,String.eq(op,"orl"),u => X187Op{1,32,0,1,0},u =>
  nt_choose(X187Op,String.eq(op,"orq"),u => X187Op{1,64,0,1,0},u =>
  nt_choose(X187Op,String.eq(op,"andb"),u => X187Op{1,8,0,4,0},u =>
  nt_choose(X187Op,String.eq(op,"andl"),u => X187Op{1,32,0,4,0},u =>
  nt_choose(X187Op,String.eq(op,"andq"),u => X187Op{1,64,0,4,0},u =>
  nt_choose(X187Op,String.eq(op,"subb"),u => X187Op{1,8,0,5,0},u =>
  nt_choose(X187Op,String.eq(op,"subl"),u => X187Op{1,32,0,5,0},u =>
  nt_choose(X187Op,String.eq(op,"subq"),u => X187Op{1,64,0,5,0},u =>
  nt_choose(X187Op,String.eq(op,"xorb"),u => X187Op{1,8,0,6,0},u =>
  nt_choose(X187Op,String.eq(op,"xorl"),u => X187Op{1,32,0,6,0},u =>
  nt_choose(X187Op,String.eq(op,"xorq"),u => X187Op{1,64,0,6,0},u =>
  nt_choose(X187Op,String.eq(op,"cmpb"),u => X187Op{1,8,0,7,0},u =>
  nt_choose(X187Op,String.eq(op,"cmpl"),u => X187Op{1,32,0,7,0},u =>
  nt_choose(X187Op,String.eq(op,"cmpq"),u => X187Op{1,64,0,7,0},u =>
  nt_choose(X187Op,String.eq(op,"movb"),u => X187Op{2,8,0,0,0},u =>
  nt_choose(X187Op,String.eq(op,"movl"),u => X187Op{2,32,0,0,0},u =>
  nt_choose(X187Op,String.eq(op,"movq"),u => X187Op{2,64,0,0,0},u =>
  nt_choose(X187Op,String.eq(op,"movabsq"),u => X187Op{15,64,0,0,0},u =>
  nt_choose(X187Op,String.eq(op,"shll"),u => X187Op{3,32,0,4,0},u =>
  nt_choose(X187Op,String.eq(op,"shlq"),u => X187Op{3,64,0,4,0},u =>
  nt_choose(X187Op,String.eq(op,"shrl"),u => X187Op{3,32,0,5,0},u =>
  nt_choose(X187Op,String.eq(op,"shrq"),u => X187Op{3,64,0,5,0},u =>
  nt_choose(X187Op,String.eq(op,"sarl"),u => X187Op{3,32,0,7,0},u =>
  nt_choose(X187Op,String.eq(op,"sarq"),u => X187Op{3,64,0,7,0},u =>
  nt_choose(X187Op,String.eq(op,"imull"),u => X187Op{4,32,0,0,0},u =>
  nt_choose(X187Op,String.eq(op,"imulq"),u => X187Op{4,64,0,0,0},u =>
  nt_choose(X187Op,String.eq(op,"sete"),u => X187Op{5,8,148,0,0},u =>
  nt_choose(X187Op,String.eq(op,"setz"),u => X187Op{5,8,148,0,0},u =>
  nt_choose(X187Op,String.eq(op,"setne"),u => X187Op{5,8,149,0,0},u =>
  nt_choose(X187Op,String.eq(op,"setnz"),u => X187Op{5,8,149,0,0},u =>
  nt_choose(X187Op,String.eq(op,"seta"),u => X187Op{5,8,151,0,0},u =>
  nt_choose(X187Op,String.eq(op,"setae"),u => X187Op{5,8,147,0,0},u =>
  nt_choose(X187Op,String.eq(op,"setb"),u => X187Op{5,8,146,0,0},u =>
  nt_choose(X187Op,String.eq(op,"setbe"),u => X187Op{5,8,150,0,0},u =>
  nt_choose(X187Op,String.eq(op,"setl"),u => X187Op{5,8,156,0,0},u =>
  nt_choose(X187Op,String.eq(op,"setle"),u => X187Op{5,8,158,0,0},u =>
  nt_choose(X187Op,String.eq(op,"setg"),u => X187Op{5,8,159,0,0},u =>
  nt_choose(X187Op,String.eq(op,"setge"),u => X187Op{5,8,157,0,0},u =>
  nt_choose(X187Op,String.eq(op,"setp"),u => X187Op{5,8,154,0,0},u =>
  nt_choose(X187Op,String.eq(op,"setnp"),u => X187Op{5,8,155,0,0},u =>
  nt_choose(X187Op,String.eq(op,"movzbl"),u => X187Op{6,32,0,0,0},u =>
  nt_choose(X187Op,String.eq(op,"addss"),u => X187Op{7,128,88,0,243},u =>
  nt_choose(X187Op,String.eq(op,"subss"),u => X187Op{7,128,92,0,243},u =>
  nt_choose(X187Op,String.eq(op,"mulss"),u => X187Op{7,128,89,0,243},u =>
  nt_choose(X187Op,String.eq(op,"divss"),u => X187Op{7,128,94,0,243},u =>
  nt_choose(X187Op,String.eq(op,"ucomiss") || String.eq(op,"comiss"),
    u => X187Op{7,128,nt_choose(U32,String.eq(op,"comiss"),v => 47,v => 46),0,0},u =>
  nt_choose(X187Op,String.eq(op,"movaps"),u => X187Op{7,128,40,0,0},u =>
  nt_choose(X187Op,String.eq(op,"pxor"),u => X187Op{7,128,239,0,102},u =>
  nt_choose(X187Op,String.eq(op,"pushq"),u => X187Op{8,64,80,0,0},u =>
  nt_choose(X187Op,String.eq(op,"popq"),u => X187Op{8,64,88,0,0},u =>
  nt_choose(X187Op,String.eq(op,"call"),u => X187Op{9,0,232,0,0},u =>
  nt_choose(X187Op,String.eq(op,"jmp"),u => X187Op{9,0,233,0,0},u =>
  nt_choose(X187Op,String.eq(op,"je"),u => X187Op{9,0,15,132,0},u =>
  nt_choose(X187Op,String.eq(op,"jz"),u => X187Op{9,0,15,132,0},u =>
  nt_choose(X187Op,String.eq(op,"jne"),u => X187Op{9,0,15,133,0},u =>
  nt_choose(X187Op,String.eq(op,"jnz"),u => X187Op{9,0,15,133,0},u =>
  nt_choose(X187Op,String.eq(op,"ja"),u => X187Op{9,0,15,135,0},u =>
  nt_choose(X187Op,String.eq(op,"jae"),u => X187Op{9,0,15,131,0},u =>
  nt_choose(X187Op,String.eq(op,"jb"),u => X187Op{9,0,15,130,0},u =>
  nt_choose(X187Op,String.eq(op,"jbe"),u => X187Op{9,0,15,134,0},u =>
  nt_choose(X187Op,String.eq(op,"jl"),u => X187Op{9,0,15,140,0},u =>
  nt_choose(X187Op,String.eq(op,"jle"),u => X187Op{9,0,15,142,0},u =>
  nt_choose(X187Op,String.eq(op,"jg"),u => X187Op{9,0,15,143,0},u =>
  nt_choose(X187Op,String.eq(op,"jge"),u => X187Op{9,0,15,141,0},u =>
  nt_choose(X187Op,String.eq(op,"jp"),u => X187Op{9,0,15,138,0},u =>
  nt_choose(X187Op,String.eq(op,"jnp"),u => X187Op{9,0,15,139,0},u =>
  nt_choose(X187Op,String.eq(op,"movd"),u => X187Op{10,0,0,0,0},u =>
  nt_choose(X187Op,String.eq(op,"cvtsi2ssq"),u => X187Op{11,64,0,0,0},u =>
  nt_choose(X187Op,String.eq(op,"leaq"),u => X187Op{12,64,0,0,0},u =>
  nt_choose(X187Op,String.eq(op,"testb"),u => X187Op{13,8,0,0,0},u =>
  nt_choose(X187Op,String.eq(op,"testl"),u => X187Op{13,32,0,0,0},u =>
  nt_choose(X187Op,String.eq(op,"testq"),u => X187Op{13,64,0,0,0},u =>
  nt_choose(X187Op,String.eq(op,"ret"),u => X187Op{14,0,195,0,0},u =>
  x191cm_spec(op))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))))

@unsafe
def x187_encode(inst: X187Instruction, +offset: U32) -> X187Encoded:
  match inst:
    case X187Instruction{+op,+operands}:
      nt_choose(X187Encoded,U32.is_le(offset,4294967280),
        u => nt_choose(X187Encoded,String.eq(op,"cvttss2siq"),
          v => x192_float_cvtt_operands(operands,offset),
          v => x187_e_selected(x187_e_spec(op),operands,offset)),u => x187_e_error())

# Proposal only: integer CMOVcc, AT&T source first. Memory sources are read
# unconditionally. The32-bit form zeroes destination high32 even when false.
@unsafe
def x191cm_pair(+src: X187Operand, +dst: X187Operand, +width: U32, +code: U32, offset: U32) -> X187Encoded:
  nt_choose(X187Encoded,(U32.is_eq(width,32) || U32.is_eq(width,64)) &&
      U32.is_ge(code,64) && U32.is_le(code,79) &&
      x187_e_reg(dst,width,False{}) && x187_e_rm(src,width,False{}),u =>
    x187_e_modrm(0,[15,code],U32.is_eq(width,64),x187_e_index(dst),src,False{},[],offset),
    u => x187_e_error())

@unsafe
def x191cm_spec(+op: String) -> X187Op:
  nt_choose(X187Op,String.eq(op,"cmovel"),u => X187Op{16,32,68,0,0},u =>
  nt_choose(X187Op,String.eq(op,"cmovnel"),u => X187Op{16,32,69,0,0},u =>
  nt_choose(X187Op,String.eq(op,"cmovbl"),u => X187Op{16,32,66,0,0},u =>
  nt_choose(X187Op,String.eq(op,"cmovbel"),u => X187Op{16,32,70,0,0},u =>
  nt_choose(X187Op,String.eq(op,"cmoval"),u => X187Op{16,32,71,0,0},u =>
  nt_choose(X187Op,String.eq(op,"cmovael"),u => X187Op{16,32,67,0,0},u =>
  nt_choose(X187Op,String.eq(op,"cmovll"),u => X187Op{16,32,76,0,0},u =>
  nt_choose(X187Op,String.eq(op,"cmovlel"),u => X187Op{16,32,78,0,0},u =>
  nt_choose(X187Op,String.eq(op,"cmovgl"),u => X187Op{16,32,79,0,0},u =>
  nt_choose(X187Op,String.eq(op,"cmovgel"),u => X187Op{16,32,77,0,0},u =>
  nt_choose(X187Op,String.eq(op,"cmoveq"),u => X187Op{16,64,68,0,0},u =>
  nt_choose(X187Op,String.eq(op,"cmovneq"),u => X187Op{16,64,69,0,0},u =>
  nt_choose(X187Op,String.eq(op,"cmovbq"),u => X187Op{16,64,66,0,0},u =>
  nt_choose(X187Op,String.eq(op,"cmovbeq"),u => X187Op{16,64,70,0,0},u =>
  nt_choose(X187Op,String.eq(op,"cmovaq"),u => X187Op{16,64,71,0,0},u =>
  nt_choose(X187Op,String.eq(op,"cmovaeq"),u => X187Op{16,64,67,0,0},u =>
  nt_choose(X187Op,String.eq(op,"cmovlq"),u => X187Op{16,64,76,0,0},u =>
  nt_choose(X187Op,String.eq(op,"cmovleq"),u => X187Op{16,64,78,0,0},u =>
  nt_choose(X187Op,String.eq(op,"cmovgq"),u => X187Op{16,64,79,0,0},u =>
  nt_choose(X187Op,String.eq(op,"cmovgeq"),u => X187Op{16,64,77,0,0},u =>
  X187OpNone{}))))))))))))))))))))
