# The existing native F32 ABI carries raw low32 bits in full word homes.
# This mirrors p112fp's verified binary-call admission, keeping all other
# imports on the original call path. xmm0/xmm1 and r10/r11 are ephemeral.
def x185_float_enabled() -> Bool: True{}

def x185_float_arithmetic(id: U32) -> String:
  match id:
    case 26: "addss"
    case 27: "subss"
    case 28: "mulss"
    case _: "divss"

# ucomiss(a,b): unordered sets ZF/PF/CF. Collect both conditions before
# combining bytes changes flags; equality/order exclude unordered, ne includes
# it. Above/above-equal already exclude unordered without a second predicate.
@unsafe
def x185_float_compare(id: U32) -> X188Seq:
  match id:
    case 30: x188_many([x188_i1("sete",x188_reg(10,8)),x188_i1("setnp",x188_reg(11,8)),x188_i2("andb",x188_reg(11,8),x188_reg(10,8))])
    case 31: x188_many([x188_i1("setne",x188_reg(10,8)),x188_i1("setp",x188_reg(11,8)),x188_i2("orb",x188_reg(11,8),x188_reg(10,8))])
    case 32: x188_many([x188_i1("setb",x188_reg(10,8)),x188_i1("setnp",x188_reg(11,8)),x188_i2("andb",x188_reg(11,8),x188_reg(10,8))])
    case 33: x188_many([x188_i1("setbe",x188_reg(10,8)),x188_i1("setnp",x188_reg(11,8)),x188_i2("andb",x188_reg(11,8),x188_reg(10,8))])
    case 34: x188_i1("seta",x188_reg(10,8))
    case _: x188_i1("setae",x188_reg(10,8))

# Direct MOVD reads the low word and clears the rest of its XMM destination.
# A register result also clears its full64 upper half; a stack result must
# retain the old zero-extended64 store rather than writing only four bytes.
def x186_float_narrow(physical: X185Physical) -> Maybe<&2,X187Operand>:
  match physical:
    case X185Physical{wide,narrow,byte}: Some{narrow}
    case X185PhysicalNone{}: None{}

def x186_float_present(home: Maybe<&2,X187Operand>) -> Bool:
  match home:
    case Some{operand}: True{}
    case None{}: False{}

def x186_float_operand(home: Maybe<&2,X187Operand>, fallback: X187Operand) -> X187Operand:
  match home:
    case Some{operand}: operand
    case None{}: fallback

@unsafe
def x186_float_home(name: String, frame: X181Frame, stack: Bool) -> Maybe<&2,X187Operand>:
  match frame:
    case X181Frame{slots,bytes,calls,params,symbol}:
      +slot = p111v_get(slots,name)
      nt_choose(Maybe<&2,X187Operand>,(String.eq(dk(slot),"X181Register") || String.eq(dk(slot),"X185Transient")) && U32.is_lt(da(slot),5),
        u => x186_float_narrow(x185_physical_slot(slot)),u =>
        nt_choose(Maybe<&2,X187Operand>,stack && String.eq(dk(slot),"X181Stack") && U32.is_eq(dx(slot),8) &&
            U32.is_ge(da(slot),48) && U32.is_le(da(slot),bytes) && U32.is_eq(U32.mod(da(slot),8),0),
          v => Some{X187Mem{5,U32.sub(0,da(slot))}},v => None{}))

@unsafe
def x186_float_source(value: N111Value, frame: X181Frame) -> Maybe<&2,X187Operand>:
  match value:
    case N111Local{name}: x186_float_home(name,frame,True{})
    case _: None{}

@unsafe
def x186_float_load_from(source: Maybe<&2,X187Operand>, value: N111Value,
    ids: N111Ids, frame: X181Frame, xmm: X187Operand) -> X188Seq:
  match source:
    case Some{operand}: x188_i2("movd",operand,xmm)
    case None{}: x188_cat(x181_load(value,ids,frame,x188_reg(10,64)),x188_i2("movd",x188_reg(10,32),xmm))

@unsafe
def x186_float_load(+value: N111Value, ids: N111Ids, +frame: X181Frame, xmm: X187Operand) -> X188Seq:
  x186_float_load_from(x186_float_source(value,frame),value,ids,frame,xmm)

@unsafe
def x186_float_publish_to(home: Maybe<&2,X187Operand>, name: String,
    source: X187Operand, frame: X181Frame) -> X188Seq:
  match home:
    case Some{operand}: x188_i2("movd",source,operand)
    case None{}: x188_cat(x188_i2("movd",source,x188_reg(10,32)),x181_store(name,frame,x188_reg(10,64)))

@unsafe
def x186_float_publish(+name: String, source: X187Operand, +frame: X181Frame) -> X188Seq:
  x186_float_publish_to(x186_float_home(name,frame,False{}),name,source,frame)

@unsafe
def x186_float_result(name: String, frame: X181Frame) -> X188Seq:
  x186_float_publish(name,x188_xmm(0),frame)

@unsafe
def x186_float_finish(+name: String, +id: U32, +frame: X181Frame) -> X188Seq:
  nt_choose(X188Seq,U32.is_lt(id,30),
    u => x188_cat(x188_i2(x185_float_arithmetic(id),x188_xmm(1),x188_xmm(0)),x186_float_result(name,frame)),
    u => x188_many([x188_i2("ucomiss",x188_xmm(1),x188_xmm(0)),x185_float_compare(id),
      x188_i2("movzbl",x188_reg(10,8),x188_reg(10,32)),x181_store(name,frame,x188_reg(10,64))]))

@unsafe
def x185_float_text(name: String, id: U32, buffer: String, ids: N111Ids, +frame: X181Frame) -> X188Seq:
  x188_many([x181_load(N111Local{buffer},ids,frame,x188_reg(10,64)),
    x188_i2("movd",X187Mem{10,0},x188_xmm(0)),x188_i2("movd",X187Mem{10,8},x188_xmm(1)),
    x186_float_finish(name,id,frame)])

@unsafe
def x185_float_probe(stmt: N111Stmt, ids: N111Ids, frame: X181Frame) -> X188Seq:
  x186_float_operation(x186_inline_op(stmt),ids,frame)

@unsafe
def x186_float_operation(operation: X186InlineOp, ids: N111Ids, frame: X181Frame) -> X188Seq:
  match operation:
    case X186InlineF32{name,id,buffer}: x185_float_text(name,id,buffer,ids,frame)
    case X186InlineNone{}: X188Empty{}

@unsafe
def x185_float_call(+name: String, +typ: N111Type, +symbol: String, +args: List<&2,N111Arg>,
    +ids: N111Ids, +frame: X181Frame, code: X181Code) -> X181Code:
  +floating = x185_float_probe(N111Call{name,typ,symbol,args},ids,frame)
  +text = nt_choose(X188Seq,x188_empty(floating),
    u => x186_u32_float_probe(N111Call{name,typ,symbol,args},ids,frame),u => floating)
  x181_add(nt_choose(X188Seq,x188_empty(text),
    u => x188_many([x181_call_text(symbol,args,ids,frame),
      nt_choose(X188Seq,U32.is_eq(p111v_type(typ),1),v => x188_i2("movl",x188_reg(0,32),x188_reg(0,32)),v => X188Empty{}),
      x181_store(name,frame,x188_reg(0,64))]),u => text),code)
