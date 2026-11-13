# Select copies and loads directly into an assigned machine home. A memory
# source's address defaults to a reserved r10 snapshot before its destination changes.
# Every U32 publication still clears high bits. Stack destinations retain the
# old sequence; these rules neither remove memory accesses nor alter lifetimes.
@unsafe
def x186_set_selected(+name: String, +typ: N111Type, +value: N111Value,
    +ids: N111Ids, +frame: X181Frame, physical: X185Physical) -> X188Seq:
  match physical:
    case X185Physical{+wide,+narrow,byte}:
      +direct = nt_choose(X188Seq,x190_operands_enabled() && U32.is_eq(p111v_type(typ),1),
        u => x190_narrow_value(value,frame,narrow),u => X188Empty{})
      nt_choose(X188Seq,x188_empty(direct),
        u => x188_cat(x185_physical_load(value,ids,frame,wide),x181_mask(typ,narrow)),u => direct)
    case X185PhysicalNone{}:
      x188_many([x181_load(value,ids,frame,x188_reg(10,64)),x181_mask(typ,x188_reg(10,32)),x181_store(name,frame,x188_reg(10,64))])

@unsafe
def x186_set_text(+name: String, typ: N111Type, value: N111Value, ids: N111Ids, +frame: X181Frame) -> X188Seq:
  x186_set_selected(name,typ,value,ids,frame,x185_physical_home(name,frame))

@unsafe
def x186_load_selected(+name: String, +typ: N111Type, +base: N111Value, +offset: U32,
    +ids: N111Ids, +frame: X181Frame, physical: X185Physical) -> X188Seq:
  match physical:
    case X185Physical{+wide,+narrow,byte}:
      +direct = nt_choose(X188Seq,x190_operands_enabled() && U32.is_le(offset,2147483647),
        u => x190_load_direct(typ,offset,x188_physical_width(typ,wide,narrow),x190_value_home(base,frame)),u => X188Empty{})
      nt_choose(X188Seq,Bool.not(x188_empty(direct)),u => direct,u =>
      nt_choose(X188Seq,U32.is_le(offset,2147483647),u =>
        x188_cat(x181_load(base,ids,frame,x188_reg(10,64)),
          x188_i2(x181_width(typ,"movq","movl"),X187Mem{10,offset},x188_physical_width(typ,wide,narrow))),u =>
        x188_cat(x181_address(base,offset,ids,frame),
          x188_i2(x181_width(typ,"movq","movl"),X187Mem{10,0},x188_physical_width(typ,wide,narrow)))))
    case X185PhysicalNone{}: x185_load_memory(name,typ,base,offset,ids,frame)

@unsafe
def x186_load_text(+name: String, typ: N111Type, base: N111Value, offset: U32,
    ids: N111Ids, +frame: X181Frame) -> X188Seq:
  x186_load_selected(name,typ,base,offset,ids,frame,x185_physical_home(name,frame))

# Address evaluation precedes destination publication even when base=destination.
@unsafe
def x190_load_direct(typ: N111Type, offset: U32, dest: X187Operand, base: X185Physical) -> X188Seq:
  match base:
    case X185Physical{X187Reg{index,width,vector},narrow,byte}:
      x188_i2(x181_width(typ,"movq","movl"),X187Mem{index,offset},dest)
    case _: X188Empty{}

# Only two known physical operands can bypass both snapshots. Their homes are
# outside selector scratch registers, and this instruction preserves base=value.
@unsafe
def x190_store_direct(+typ: N111Type, offset: U32, base: X185Physical, value: X185Physical) -> X188Seq:
  match base:
    case X185Physical{X187Reg{index,width,vector},narrow,byte}:
      match value:
        case X185Physical{wide,narrow,byte}:
          x188_i2(x181_width(typ,"movq","movl"),x188_physical_width(typ,wide,narrow),X187Mem{index,offset})
        case _: X188Empty{}
    case _: X188Empty{}

@unsafe
def x190_store_memory(+typ: N111Type, +base: N111Value, +offset: U32, +value: N111Value,
    +ids: N111Ids, +frame: X181Frame) -> X188Seq:
  +direct = nt_choose(X188Seq,x190_operands_enabled() && U32.is_le(offset,2147483647),
    u => x190_store_direct(typ,offset,x190_value_home(base,frame),x190_value_home(value,frame)),u => X188Empty{})
  nt_choose(X188Seq,x188_empty(direct),u => x185_store_memory(typ,base,offset,value,ids,frame),u => direct)

# The parallel-copy scheduler has already established this move's order. Its
# values are full 64-bit words; cycle snapshots still use the original plan.
@unsafe
def x190_move(+name: String, +value: N111Value, +ids: N111Ids, +frame: X181Frame) -> X188Seq:
  x190_move_selected(name,value,ids,frame,nt_choose(X185Physical,x190_operands_enabled(),
    u => x190_value_home(value,frame),u => X185PhysicalNone{}))

@unsafe
def x190_move_selected(name: String, value: N111Value, ids: N111Ids, +frame: X181Frame, physical: X185Physical) -> X188Seq:
  match physical:
    case X185Physical{wide,narrow,byte}: x181_store(name,frame,wide)
    case _: x188_cat(x181_load(value,ids,frame,x188_reg(10,64)),x181_store(name,frame,x188_reg(10,64)))

# A 32-bit destination write both truncates and clears the upper half, including
# source=destination. Stack locals are complete allocated 64-bit frame words.
@unsafe
def x190_narrow_slot(+slot: KDef, +dest: X187Operand) -> X188Seq:
  x190_narrow_physical(slot,dest,x185_physical_slot(slot))

@unsafe
def x190_narrow_physical(+slot: KDef, +dest: X187Operand, physical: X185Physical) -> X188Seq:
  match physical:
    case X185Physical{wide,narrow,byte}: x188_i2("movl",narrow,dest)
    case _: nt_choose(X188Seq,String.eq(dk(slot),"X181Stack"),
      u => x188_i2("movl",X187Mem{5,U32.sub(0,da(slot))},dest),u => X188Empty{})

@unsafe
def x190_narrow_value(value: N111Value, frame: X181Frame, dest: X187Operand) -> X188Seq:
  match value:
    case N111Const{lo,hi}: x188_i2("movl",X187Imm{lo,0},dest)
    case N111Local{name}:
      match frame:
        case X181Frame{slots,bytes,calls,params,symbol}: x190_narrow_slot(p111v_get(slots,name),dest)
    case _: X188Empty{}
