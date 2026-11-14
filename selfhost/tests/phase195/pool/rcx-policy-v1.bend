# False is the RCX-only ablation. True reconstructs original eleven-color
# profitability; neither setting changes which forced assignments are legal.
def x195_pc_r12_enabled() -> Bool: False{}

@unsafe
def x195_p_color(names: List<&2,String>, rows: List<&2,U32>, params: List<&2,String>,
    bit: U32, groups: List<&2,U32>, affinities: KDef, shifts: U32) -> List<&2,U32>:
  x195_pc_color(names,rows,params,bit,groups,affinities,shifts,
    nt_choose(U32,x195_pc_r12_enabled(),u => 11,u => 10))
