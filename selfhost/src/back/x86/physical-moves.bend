# Select copies and loads directly into an assigned machine home. A memory
# source's address is snapshotted in reserved r10 before its destination changes.
# Every U32 publication still clears high bits. Stack destinations retain the
# old sequence; these rules neither remove memory accesses nor alter lifetimes.
@unsafe
def x186_set_selected(+name: String, +typ: N111Type, +value: N111Value,
    +ids: N111Ids, +frame: X181Frame, physical: X185Physical) -> X188Seq:
  match physical:
    case X185Physical{+wide,narrow,byte}:
      x188_cat(x185_physical_load(value,ids,frame,wide),x181_mask(typ,narrow))
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
      nt_choose(X188Seq,U32.is_le(offset,2147483647),u =>
        x188_cat(x181_load(base,ids,frame,x188_reg(10,64)),
          x188_i2(x181_width(typ,"movq","movl"),X187Mem{10,offset},x188_physical_width(typ,wide,narrow))),u =>
        x188_cat(x181_address(base,offset,ids,frame),
          x188_i2(x181_width(typ,"movq","movl"),X187Mem{10,0},x188_physical_width(typ,wide,narrow))))
    case X185PhysicalNone{}: x185_load_memory(name,typ,base,offset,ids,frame)

@unsafe
def x186_load_text(+name: String, typ: N111Type, base: N111Value, offset: U32,
    ids: N111Ids, +frame: X181Frame) -> X188Seq:
  x186_load_selected(name,typ,base,offset,ids,frame,x185_physical_home(name,frame))
