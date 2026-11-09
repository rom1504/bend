# Select copies and loads directly into an assigned machine home. A memory
# source's address is snapshotted in reserved r10 before its destination changes.
# Every U32 publication still clears high bits. Stack destinations retain the
# old sequence; these rules neither remove memory accesses nor alter lifetimes.
@unsafe
def x186_set_selected(+name: String, +typ: N111Type, +value: N111Value,
    +ids: N111Ids, +frame: X181Frame, physical: X185Physical) -> String:
  match physical:
    case X185Physical{+wide,narrow,byte}:
      x185_physical_load(value,ids,frame,wide) ++ x181_mask(typ,narrow)
    case X185PhysicalNone{}:
      x181_load(value,ids,frame,"%r10") ++ x181_mask(typ,"%r10d") ++ x181_store(name,frame,"%r10")

@unsafe
def x186_set_text(+name: String, typ: N111Type, value: N111Value, ids: N111Ids, +frame: X181Frame) -> String:
  x186_set_selected(name,typ,value,ids,frame,x185_physical_home(name,frame))

@unsafe
def x186_load_selected(+name: String, +typ: N111Type, +base: N111Value, +offset: U32,
    +ids: N111Ids, +frame: X181Frame, physical: X185Physical) -> String:
  match physical:
    case X185Physical{+wide,+narrow,byte}:
      nt_choose(String,U32.is_le(offset,2147483647),
        u => x181_load(base,ids,frame,"%r10") ++ x181_width(typ,"  movq ","  movl ") ++ U32.show(offset) ++
          "(%r10), " ++ x181_width(typ,wide,narrow) ++ "\n",
        u => x181_address(base,offset,ids,frame) ++ x181_width(typ,"  movq ","  movl ") ++
          "(%r10), " ++ x181_width(typ,wide,narrow) ++ "\n")
    case X185PhysicalNone{}: x185_load_memory(name,typ,base,offset,ids,frame)

@unsafe
def x186_load_text(+name: String, typ: N111Type, base: N111Value, offset: U32,
    ids: N111Ids, +frame: X181Frame) -> String:
  x186_load_selected(name,typ,base,offset,ids,frame,x185_physical_home(name,frame))
