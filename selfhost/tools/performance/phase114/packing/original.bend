# Exact candidate31 constructor lowering, renamed for unchanged fallback.
@unsafe
def p114p_original_constructor(+name: String, +values: List<&2, N111Value>) -> P111ValueCode:
  +kind = p111_special(name)
  +call = nt_choose(N111Stmt, U32.is_eq(kind, 0),
    u => N111Call{"value", N111U64{}, "p111_rt_ctor", [p111_state(), N111Arg{N111U32{}, N111CtorId{name}}, p111_scratch(), p111_u32(nt_count(N111Value, values))]},
    u => N111Call{"value", N111U64{}, "p111_rt_special_ctor", [p111_state(), p111_u32(kind), p111_scratch(), p111_u32(nt_count(N111Value, values))]})
  P111ValueCode{nt_append(N111Stmt, p111_store(values, 0), [call]), N111Local{"value"}, ""}
