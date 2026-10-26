# Isolated per-input occurrence summary. No production declaration is changed.
# The original routine remains the independent executable reference.
@unsafe
def p143o_original(body: KTerm, args: List<&2,KTerm>, env: List<&2,NC_Binding>, n: U32, left: U32) -> Bool:
  nd_comb_fresh(body,args,env,n,left)

# left=0 must not materialize a summary. The syntax is fixed for the complete
# query; nc_uses preserves nc_occurs's Var-leaf behavior, including raw Var kids.
@unsafe
def p143o_summary(+body: KTerm, +args: List<&2,KTerm>, +env: List<&2,NC_Binding>, +n: U32, +left: U32) -> Bool:
  nt_choose(Bool,U32.is_eq(left,0),u => True{},
    u => p143o_walk(nc_uses_list(args,nc_uses(body)),env,n,left))

# Keep the exact nc_id sequence, U32 increment/subtract and environment lookup.
# A binding whose word is NATIVE_UNBOUND_VARIABLE remains accepted, as before.
@unsafe
def p143o_walk(+uses: NU_Set, +env: List<&2,NC_Binding>, +n: U32, +left: U32) -> Bool:
  nt_choose(Bool,U32.is_eq(left,0),u => True{},u =>
    nt_choose(Bool,Bool.not(nc_uses_has(uses,nc_id(n))) &&
      p88_string_eq(nc_word(nc_id(n),env),"NATIVE_UNBOUND_VARIABLE"),
      u => p143o_walk(uses,env,U32.inc(n),U32.sub(left,1)),u => False{}))
