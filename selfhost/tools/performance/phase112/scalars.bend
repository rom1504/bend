# Exact raw-U32 intrinsic specialization for the generic Phase111 IR.
# Input/output machine values remain U64. Comparison predicates are U32,
# then both branches assign the legal U64 raw Bool result. No cast IR is needed.
# Source assembly replaces only p111_intrinsic with p112_intrinsic delegation.

@unsafe
def p112_intrinsic_fallback(+name: String, +values: List<&2, N111Value>) -> P111ValueCode:
  +id = p111_op_id(name)
  nt_choose(P111ValueCode, U32.is_eq(id, 0), u => P111ValueCode{Nil{}, N111Const{0, 0}, "unknown native primitive " ++ name},
    u => P111ValueCode{nt_append(N111Stmt, p111_store(values, 0), [N111Call{"value", N111U64{}, "p111_rt_op", [p111_state(), p111_u32(id), p111_scratch(), p111_u32(nt_count(N111Value, values))]}]), N111Local{"value"}, ""})

@unsafe
def p112_scalar_safe_value(value: N111Value) -> Bool:
  match value:
    case N111Local{+name}: Bool.not(String.eq(name, "p112_s_a") || String.eq(name, "p112_s_b") || String.eq(name, "p112_s_test"))
    case _: True{}

@unsafe
def p112_scalar_safe(values: List<&2, N111Value>) -> Bool:
  match values:
    case Nil{}: True{}
    case Con{head, rest}: p112_scalar_safe_value(head) && p112_scalar_safe(rest)

@unsafe
def p112_scalar_arity(+id: U32) -> U32:
  nt_choose(U32, (U32.is_ge(id, 1) && U32.is_le(id, 12)) || U32.is_eq(id, 16) || U32.is_eq(id, 17), u => 2, u =>
  nt_choose(U32, (U32.is_ge(id, 13) && U32.is_le(id, 15)) || U32.is_eq(id, 20) || U32.is_eq(id, 21), u => 1, u => 0))

@unsafe
def p112_scalar_op(+id: U32) -> String:
  nt_choose(String, U32.is_eq(id, 1), u => "add", u =>
  nt_choose(String, U32.is_eq(id, 2), u => "sub", u =>
  nt_choose(String, U32.is_eq(id, 3), u => "and", u =>
  nt_choose(String, U32.is_eq(id, 4), u => "or", u =>
  nt_choose(String, U32.is_eq(id, 5), u => "xor", u =>
  nt_choose(String, U32.is_eq(id, 6), u => "mul", u =>
  nt_choose(String, U32.is_eq(id, 7), u => "eq", u =>
  nt_choose(String, U32.is_eq(id, 8), u => "ne", u =>
  nt_choose(String, U32.is_eq(id, 9), u => "ult", u =>
  nt_choose(String, U32.is_eq(id, 10), u => "ule", u =>
  nt_choose(String, U32.is_eq(id, 11), u => "ugt", u => "uge")))))))))))

def p112_scalar_result(body: List<&2, N111Stmt>) -> P111ValueCode:
  P111ValueCode{body, N111Local{"value"}, ""}

def p112_scalar_mask() -> N111Value:
  N111Const{4294967295, 0}

@unsafe
def p112_scalar_operands(+a: N111Value, +b: N111Value, body: List<&2, N111Stmt>) -> List<&2, N111Stmt>:
  Con{N111Bin{"p112_s_a", N111U64{}, "and", a, p112_scalar_mask()},
    Con{N111Bin{"p112_s_b", N111U64{}, "and", b, p112_scalar_mask()}, body}}

@unsafe
def p112_scalar_binary(op: String, a: N111Value, b: N111Value) -> P111ValueCode:
  p112_scalar_result(p112_scalar_operands(a, b,
    [N111Bin{"value", N111U64{}, op, N111Local{"p112_s_a"}, N111Local{"p112_s_b"}},
     N111Bin{"value", N111U64{}, "and", N111Local{"value"}, p112_scalar_mask()}]))

@unsafe
def p112_scalar_compare(op: String, a: N111Value, b: N111Value) -> P111ValueCode:
  p112_scalar_result(p112_scalar_operands(a, b,
    [N111Bin{"p112_s_test", N111U64{}, op, N111Local{"p112_s_a"}, N111Local{"p112_s_b"}},
     N111If{N111Local{"p112_s_test"},
       [N111Set{"value", N111U64{}, N111Const{1, 0}}],
       [N111Set{"value", N111U64{}, N111Const{0, 0}}]}]))

# The shift count is a full Nat word. Inspect it before narrowing; in particular
# 2^32 must produce zero, not behave like a zero shift. Both branches avoid a
# machine shift by an out-of-range count.
@unsafe
def p112_scalar_shift(op: String, a: N111Value, count: N111Value) -> P111ValueCode:
  p112_scalar_result(
    [N111Bin{"p112_s_a", N111U64{}, "and", a, p112_scalar_mask()},
     N111Set{"p112_s_b", N111U64{}, count},
     N111Bin{"p112_s_test", N111U64{}, "ult", N111Local{"p112_s_b"}, N111Const{32, 0}},
     N111If{N111Local{"p112_s_test"},
       [N111Bin{"value", N111U64{}, op, N111Local{"p112_s_a"}, N111Local{"p112_s_b"}},
        N111Bin{"value", N111U64{}, "and", N111Local{"value"}, p112_scalar_mask()}],
       [N111Set{"value", N111U64{}, N111Const{0, 0}}]}])

@unsafe
def p112_scalar_dispatch(+id: U32, +values: List<&2, N111Value>) -> P111ValueCode:
  +a = p111_head(values)
  +b = p111_head(p111_tail(values))
  nt_choose(P111ValueCode, U32.is_le(id, 6), u => p112_scalar_binary(p112_scalar_op(id), a, b), u =>
  nt_choose(P111ValueCode, U32.is_le(id, 12), u => p112_scalar_compare(p112_scalar_op(id), a, b), u =>
  nt_choose(P111ValueCode, U32.is_eq(id, 13), u => p112_scalar_binary("add", a, N111Const{1, 0}), u =>
  nt_choose(P111ValueCode, U32.is_eq(id, 14), u => p112_scalar_binary("shl", a, N111Const{1, 0}), u =>
  nt_choose(P111ValueCode, U32.is_eq(id, 15), u => p112_scalar_binary("shr", a, N111Const{1, 0}), u =>
  nt_choose(P111ValueCode, U32.is_eq(id, 16), u => p112_scalar_shift("shl", a, b), u =>
  nt_choose(P111ValueCode, U32.is_eq(id, 17), u => p112_scalar_shift("shr", a, b), u =>
  nt_choose(P111ValueCode, U32.is_eq(id, 20), u => p112_scalar_binary("xor", a, p112_scalar_mask()),
    u => p112_scalar_compare("eq", a, N111Const{0, 0})))))))))

@unsafe
def p112_intrinsic(+name: String, +values: List<&2, N111Value>) -> P111ValueCode:
  +id = p111_op_id(name)
  +arity = p112_scalar_arity(id)
  nt_choose(P111ValueCode, U32.is_gt(arity, 0) && U32.is_eq(arity, nt_count(N111Value, values)) && p112_scalar_safe(values),
    u => p112_scalar_dispatch(id, values),
    u => p112_intrinsic_fallback(name, values))
