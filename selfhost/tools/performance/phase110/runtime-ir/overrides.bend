# Exact declaration overrides for additive U64 byte offsets. Historical Nx
# files remain unchanged; the public opaque NxLibrary still refuses memory.

@unsafe
def nx_expr_type(+expr: NxExpr, +env: List<&2, NxParam>, +fs: List<&2, NxFunction>) -> NxType:
  match expr:
    case NxConst{typ, value}:
      nx_choose(NxType, nx_scalar(typ) || (nx_type_equal(typ, NxPtr{}) && U32.is_eq(value, 0)), u => typ, u => NxBad{})
    case NxVar{name}: nx_lookup(name, env)
    case NxBin{op, left, right}:
      nx_choose(NxType, nx_pure(left) && nx_pure(right), u => nx_bin_type(op, nx_expr_type(left, env, fs), nx_expr_type(right, env, fs)), u => NxBad{})
    case NxCall{name, args}: nx_call_type(name, args, env, fs)
    case NxAlloc{bytes}:
      nx_choose(NxType, nx_pure(bytes) && nx_type_equal(nx_expr_type(bytes, env, fs), NxU32{}), u => NxPtr{}, u => NxBad{})
    case NxLoad{typ, ptr, offset}:
      nx_choose(NxType, nx_pure(ptr) && nx_type_equal(nx_expr_type(ptr, env, fs), NxPtr{}), u => typ, u => NxBad{})
    case NxOffset{ptr, bytes}:
      nx_choose(NxType, nx_pure(ptr) && nx_pure(bytes) && nx_type_equal(nx_expr_type(ptr, env, fs), NxPtr{}) && (nx_type_equal(nx_expr_type(bytes, env, fs), NxU32{}) || nx_type_equal(nx_expr_type(bytes, env, fs), NxU64{})), u => NxPtr{}, u => NxBad{})
    case NxFunc{name}:
      nx_function_pointer_type(nx_find(name, fs))
    case NxICall{callee, args, params, result}:
      nx_choose(NxType, nx_pure(callee) && nx_type_equal(nx_expr_type(callee, env, fs), NxPtr{}) && nx_arg_types(args, params, env, fs), u => result, u => NxBad{})

@unsafe
def nxq_offset(+prefix: String, +ptr: String, +bytes: NxqValue) -> NxqValue:
  match bytes:
    case NxqValue{code, word, typ, n}:
      +wide = nxq_tmp(n)
      +out = nxq_tmp(U32.add(n, 1))
      nx_choose(NxqValue,nx_type_equal(typ,NxU64{}),u => NxqValue{prefix ++ code ++ wide ++ " =l add " ++ ptr ++ ", " ++ word ++ "\n",wide,NxPtr{},U32.add(n,1)},u =>
        NxqValue{prefix ++ code ++ wide ++ " =l extuw " ++ word ++ "\n" ++ out ++ " =l add " ++ ptr ++ ", " ++ wide ++ "\n", out, NxPtr{}, U32.add(n, 2)})
