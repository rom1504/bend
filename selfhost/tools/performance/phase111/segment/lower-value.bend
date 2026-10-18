# Native special constructors and primitive calls remain ordered operations.
@unsafe
def p111_constructor(+name: String, +values: List<&2, N111Value>) -> P111ValueCode:
  +kind = p111_special(name)
  +call = nt_choose(N111Stmt, U32.is_eq(kind, 0),
    u => N111Call{"value", N111U64{}, "p111_rt_ctor", [p111_state(), N111Arg{N111U32{}, N111CtorId{name}}, p111_scratch(), p111_u32(nt_count(N111Value, values))]},
    u => N111Call{"value", N111U64{}, "p111_rt_special_ctor", [p111_state(), p111_u32(kind), p111_scratch(), p111_u32(nt_count(N111Value, values))]})
  P111ValueCode{nt_append(N111Stmt, p111_store(values, 0), [call]), N111Local{"value"}, ""}

@unsafe
def p111_intrinsic(+name: String, +values: List<&2, N111Value>) -> P111ValueCode:
  +id = p111_op_id(name)
  nt_choose(P111ValueCode, U32.is_eq(id, 0), u => P111ValueCode{Nil{}, N111Const{0, 0}, "unknown native primitive " ++ name},
    u => P111ValueCode{nt_append(N111Stmt, p111_store(values, 0), [N111Call{"value", N111U64{}, "p111_rt_op", [p111_state(), p111_u32(id), p111_scratch(), p111_u32(nt_count(N111Value, values))]}]), N111Local{"value"}, ""})

@unsafe
def p111_value(+t: KTerm, +env: List<&2, NC_Binding>) -> P111ValueCode:
  nt_choose(P111ValueCode, String.eq(tg(t), "Var"), u => P111ValueCode{Nil{}, N111Local{nc_word(ix(t), env)}, ""}, u =>
  nt_choose(P111ValueCode, String.eq(tg(t), "NWord"), u => p111_uint(U32.read(nm(t))), u =>
  nt_choose(P111ValueCode, String.eq(tg(t), "NCtr"), u => p111_constructor(nm(t), p111_values(ks(t), env)), u =>
  nt_choose(P111ValueCode, String.eq(tg(t), "NOp"), u => p111_intrinsic(nm(t), p111_values(ks(t), env)), u =>
    P111ValueCode{Nil{}, N111Const{0, 0}, "not a native evaluated value"}))))

@unsafe
def p111_load_fields(+count: U32, +i: U32, +n: U32) -> List<&2, N111Stmt>:
  nt_choose(List<&2, N111Stmt>, U32.is_eq(count, i), u => Nil{},
    u => Con{N111Load{"v_" ++ U32.show(nc_id(U32.add(n, i))), N111U64{}, N111Local{"scratch"}, U32.mul(i, 8)}, p111_load_fields(count, U32.inc(i), n)})

@unsafe
def p111_field_env(+count: U32, +i: U32, +n: U32) -> List<&2, NC_Binding>:
  nt_choose(List<&2, NC_Binding>, U32.is_eq(count, i), u => Nil{}, u => Con{nc_binding(nc_id(U32.add(n, i))), p111_field_env(count, U32.inc(i), n)})

@unsafe
def p111_take(+name: String, +word: N111Value, +count: U32, +n: U32) -> List<&2, N111Stmt>:
  +kind = p111_special(name)
  nt_choose(List<&2, N111Stmt>, U32.is_eq(count, 0), u => Nil{},
    u => Con{nt_choose(N111Stmt, U32.is_eq(kind, 0),
      v => N111Call{"ignored", N111U64{}, "p111_rt_take", [p111_state(), p111_word(word), p111_scratch(), p111_u32(count)]},
      v => N111Call{"ignored", N111U64{}, "p111_rt_special_take", [p111_state(), p111_u32(kind), p111_word(word), p111_scratch(), p111_u32(count)]}), p111_load_fields(count, 0, n)})

@unsafe
def p111_test(+name: String, +word: N111Value) -> List<&2, N111Stmt>:
  +kind = p111_special(name)
  nt_choose(List<&2, N111Stmt>, U32.is_eq(kind, 0),
    u => [N111Call{"tag", N111U64{}, "p111_rt_tag", [p111_state(), p111_word(word)]}, N111Bin{"match_condition", N111U64{}, "eq", N111Local{"tag"}, N111CtorId{name}}],
    u => [N111Call{"test", N111U64{}, "p111_rt_special_test", [p111_state(), p111_u32(kind), p111_word(word)]}, N111Bin{"match_condition", N111U64{}, "ne", N111Local{"test"}, N111Const{0, 0}}])
