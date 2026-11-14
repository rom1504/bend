# Profitability-only color limit. Always retain eleven group slots, sentinel11,
# original interference masks and the complete eleven-color final validator.
@unsafe
def x195_pc_plain(+groups: List<&2,U32>, +bit: U32, +edges: U32, +position: U32,
    +shifts: U32, +limit: U32) -> U32:
  +caller = nt_choose(U32,x190_caller_first_enabled(),
    u => x195_p_pick(x190_j_callers(groups),bit,edges,position,4,10,shifts),u => 11)
  nt_choose(U32,U32.is_lt(caller,10),u => caller,
    u => x195_p_pick(groups,bit,edges,position,0,limit,shifts))

@unsafe
def x195_pc_choose(+groups: List<&2,U32>, partners: U32, +bit: U32, +edges: U32,
    +position: U32, +shifts: U32, +limit: U32) -> U32:
  +preferred = nt_choose(U32,x190_coalescing_enabled(),
    u => x195_p_affinity(groups,partners,bit,edges,position,0,shifts),u => 11)
  nt_choose(U32,U32.is_lt(preferred,limit),u => preferred,
    u => x195_pc_plain(groups,bit,edges,position,shifts,limit))

@unsafe
def x195_pc_color(names: List<&2,String>, rows: List<&2,U32>, +params: List<&2,String>,
    +bit: U32, +groups: List<&2,U32>, +affinities: KDef, +shifts: U32, +limit: U32) -> List<&2,U32>:
  match names rows:
    case Con{+name,rest} Con{edges,more}:
      x195_pc_color(rest,more,params,U32.shl(bit),
        x190_l_group(groups,x195_pc_choose(groups,da(p111v_get(affinities,name)),bit,edges,
          x190_l_position(name,params,0),shifts,limit),bit),affinities,shifts,limit)
    case _ _: groups
