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
def x185_float_compare(id: U32) -> String:
  match id:
    case 30: "  sete %r10b\n  setnp %r11b\n  andb %r11b, %r10b\n"
    case 31: "  setne %r10b\n  setp %r11b\n  orb %r11b, %r10b\n"
    case 32: "  setb %r10b\n  setnp %r11b\n  andb %r11b, %r10b\n"
    case 33: "  setbe %r10b\n  setnp %r11b\n  andb %r11b, %r10b\n"
    case 34: "  seta %r10b\n"
    case _: "  setae %r10b\n"

# Direct MOVD reads the low word and clears the rest of its XMM destination.
# A register result also clears its full64 upper half; a stack result must
# retain the old zero-extended64 store rather than writing only four bytes.
def x186_float_narrow(physical: X185Physical) -> String:
  match physical:
    case X185Physical{wide,narrow,byte}: narrow
    case X185PhysicalNone{}: ""

@unsafe
def x186_float_home(name: String, frame: X181Frame, stack: Bool) -> String:
  match frame:
    case X181Frame{slots,bytes,calls,params,symbol}:
      +slot = p111v_get(slots,name)
      nt_choose(String,(String.eq(dk(slot),"X181Register") || String.eq(dk(slot),"X185Transient")) && U32.is_lt(da(slot),5),
        u => x186_float_narrow(x185_physical_slot(slot)),u =>
        nt_choose(String,stack && String.eq(dk(slot),"X181Stack") && U32.is_eq(dx(slot),8) &&
            U32.is_ge(da(slot),48) && U32.is_le(da(slot),bytes) && U32.is_eq(U32.mod(da(slot),8),0),
          v => "-" ++ U32.show(da(slot)) ++ "(%rbp)",v => ""))

@unsafe
def x186_float_source(value: N111Value, frame: X181Frame) -> String:
  match value:
    case N111Local{name}: x186_float_home(name,frame,True{})
    case _: ""

@unsafe
def x186_float_load(+value: N111Value, ids: N111Ids, +frame: X181Frame, +xmm: String) -> String:
  +source = x186_float_source(value,frame)
  nt_choose(String,String.is_empty(source),
    u => x181_load(value,ids,frame,"%r10") ++ "  movd %r10d, " ++ xmm ++ "\n",
    u => "  movd " ++ source ++ ", " ++ xmm ++ "\n")

@unsafe
def x186_float_result(+name: String, +frame: X181Frame) -> String:
  +register = x186_float_home(name,frame,False{})
  nt_choose(String,String.is_empty(register),
    u => "  movd %xmm0, %r10d\n" ++ x181_store(name,frame,"%r10"),
    u => "  movd %xmm0, " ++ register ++ "\n")

@unsafe
def x186_float_finish(+name: String, +id: U32, +frame: X181Frame) -> String:
  nt_choose(String,U32.is_lt(id,30),
    u => "  " ++ x185_float_arithmetic(id) ++ " %xmm1, %xmm0\n" ++ x186_float_result(name,frame),
    u => "  ucomiss %xmm1, %xmm0\n" ++ x185_float_compare(id) ++ "  movzbl %r10b, %r10d\n" ++ x181_store(name,frame,"%r10"))

@unsafe
def x185_float_text(name: String, +id: U32, buffer: String, +ids: N111Ids, +frame: X181Frame) -> String:
  x181_load(N111Local{buffer},ids,frame,"%r10") ++
    "  movd 0(%r10), %xmm0\n  movd 8(%r10), %xmm1\n" ++
    x186_float_finish(name,id,frame)

@unsafe
def x185_float_probe(stmt: N111Stmt, +ids: N111Ids, +frame: X181Frame) -> String:
  x186_float_operation(x186_inline_op(stmt),ids,frame)

@unsafe
def x186_float_operation(operation: X186InlineOp, ids: N111Ids, frame: X181Frame) -> String:
  match operation:
    case X186InlineF32{name,id,buffer}: x185_float_text(name,id,buffer,ids,frame)
    case X186InlineNone{}: ""

@unsafe
def x185_float_call(+name: String, +typ: N111Type, +symbol: String, +args: List<&2,N111Arg>,
    +ids: N111Ids, +frame: X181Frame, code: X181Code) -> X181Code:
  +text = x185_float_probe(N111Call{name,typ,symbol,args},ids,frame)
  x181_add(nt_choose(String,String.is_empty(text),
    u => x181_call_text(symbol,args,ids,frame) ++
      nt_choose(String,U32.is_eq(p111v_type(typ),1),v => "  movl %eax, %eax\n",v => "") ++
      x181_store(name,frame,"%rax"),u => text),code)
