# Experimental pool consumers: transient5=RCX; saved0=R12 remains canonical.
# Allocator supplies independently checked clobber/ABI legality. State is never
# a parallel-assignment destination, including when its canonical home is Stack.

def x185_transient_reg(index):
  match index:
    case 0: x188_reg(7,64)
    case 1: x188_reg(6,64)
    case 2: x188_reg(2,64)
    case 3: x188_reg(8,64)
    case 5: x188_reg(1,64)
    case _: x188_reg(9,64)

def x185_physical_transient(index: U32) -> X185Physical:
  match index:
    case 0: x188_physical(7)
    case 1: x188_physical(6)
    case 2: x188_physical(2)
    case 3: x188_physical(8)
    case 5: x188_physical(1)
    case _: x188_physical(9)

@unsafe
def x186_call_slot(+slot: KDef, +bytes: U32) -> U32:
  nt_choose(U32,String.eq(dk(slot),"X181Stack") && U32.is_ge(da(slot),48) &&
      U32.is_le(da(slot),bytes) && U32.is_eq(dx(slot),8),u => 1,u =>
  nt_choose(U32,String.eq(dk(slot),"X181Buffer") && U32.is_gt(da(slot),40) &&
      U32.is_le(da(slot),bytes) && U32.is_gt(dx(slot),0) &&
      U32.is_le(dx(slot),U32.sub(da(slot),40)),u => 1,u =>
  nt_choose(U32,String.eq(dk(slot),"X181Register") && U32.is_lt(da(slot),5),u => 1,u =>
  nt_choose(U32,String.eq(dk(slot),"X185Transient") && U32.is_lt(da(slot),6),u => 2,u => 0))))

@unsafe
def x186_float_home(name: String, frame: X181Frame, stack: Bool) -> Maybe<&2,X187Operand>:
  match frame:
    case X181Frame{slots,bytes,calls,params,symbol}:
      +slot = p111v_get(slots,name)
      nt_choose(Maybe<&2,X187Operand>,((String.eq(dk(slot),"X181Register") && U32.is_lt(da(slot),5)) ||
          (String.eq(dk(slot),"X185Transient") && U32.is_lt(da(slot),6))),
        u => x186_float_narrow(x185_physical_slot(slot)),u =>
        nt_choose(Maybe<&2,X187Operand>,stack && String.eq(dk(slot),"X181Stack") && U32.is_eq(dx(slot),8) &&
            U32.is_ge(da(slot),48) && U32.is_le(da(slot),bytes) && U32.is_eq(U32.mod(da(slot),8),0),
          v => Some{X187Mem{5,U32.sub(0,da(slot))}},v => None{}))

@unsafe
def x186_p_word_home(+slot: KDef, +destination: Bool) -> Bool:
  (Bool.not(destination) || Bool.not(String.eq(dn(slot),"state"))) &&
  ((String.eq(dk(slot),"X181Stack") && U32.is_ge(da(slot),48) && U32.is_eq(U32.mod(da(slot),8),0) && U32.is_eq(dx(slot),8)) ||
  (String.eq(dk(slot),"X181Register") && U32.is_le(da(slot),4)) ||
  (String.eq(dk(slot),"X185Transient") && U32.is_lt(da(slot),6)))
