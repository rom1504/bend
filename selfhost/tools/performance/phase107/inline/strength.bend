# Optional modular constant multiply reduction. Only typed atoms are duplicated.
# Literal payloads are U32 even for NxU64, so the power search stops at bit31.
@unsafe
def nx_sr_atom_type(+value: NxExpr, +env: List<&2, NxParam>) -> NxType:
  match value:
    case NxConst{typ, number}: typ
    case NxVar{name}: nx_lookup(name, env)
    case _: NxBad{}

@unsafe
def nx_sr_power(+value: U32, +shift: U32) -> Maybe<&2, U32>:
  nx_choose(Maybe<&2, U32>, U32.is_eq(value, 1), u => Some{shift},
    u => nx_choose(Maybe<&2, U32>, U32.is_eq(value, 0) || U32.is_eq(U32.and(value, 1), 1) || U32.is_eq(shift, 31),
      u => None{}, u => nx_sr_power(U32.shr(value), U32.inc(shift))))

def nx_sr_shift(+found: Maybe<&2, U32>, +atom: NxExpr, +typ: NxType, +plus: Bool, +original: NxExpr) -> NxExpr:
  match found:
    case None{}: original
    case Some{shift}:
      nx_choose(NxExpr, plus,
        u => NxBin{"add", NxBin{"shl", atom, NxConst{typ, shift}}, atom},
        u => NxBin{"shl", atom, NxConst{typ, shift}})

@unsafe
def nx_sr_factor(+atom: NxExpr, +typ: NxType, +factor: U32, +original: NxExpr) -> NxExpr:
  nx_choose(NxExpr, U32.is_eq(factor, 0), u => NxConst{typ, 0}, u =>
  nx_choose(NxExpr, U32.is_eq(factor, 1), u => atom, u =>
  nx_choose(NxExpr, U32.is_eq(U32.and(factor, U32.sub(factor, 1)), 0),
    u => nx_sr_shift(nx_sr_power(factor, 0), atom, typ, False{}, original),
    u => nx_sr_shift(nx_sr_power(U32.sub(factor, 1), 0), atom, typ, True{}, original))))

@unsafe
def nx_sr_typed(+atom: NxExpr, +typ: NxType, +factor: U32, +env: List<&2, NxParam>, +original: NxExpr) -> NxExpr:
  nx_choose(NxExpr, nx_scalar(typ) && nx_type_equal(nx_sr_atom_type(atom, env), typ),
    u => nx_sr_factor(atom, typ, factor, original), u => original)

@unsafe
def nx_sr_bin(+op: String, +left: NxExpr, +right: NxExpr, +env: List<&2, NxParam>) -> NxExpr:
  nx_choose(NxExpr, String.eq(op, "mul"),
    u => nx_sr_mul(left, right, env), u => NxBin{op, left, right})

@unsafe
def nx_sr_mul(+left: NxExpr, +right: NxExpr, +env: List<&2, NxParam>) -> NxExpr:
  match left right:
    case _ NxConst{typ, factor}: nx_sr_typed(left, typ, factor, env, NxBin{"mul", left, right})
    case NxConst{typ, factor} _: nx_sr_typed(right, typ, factor, env, NxBin{"mul", left, right})
    case _ _: NxBin{"mul", left, right}

@unsafe
def nx_sr_expr(+value: NxExpr, +env: List<&2, NxParam>) -> NxExpr:
  match value:
    case NxBin{op, left, right}: nx_sr_bin(op, nx_sr_expr(left, env), nx_sr_expr(right, env), env)
    case NxCall{name, args}: NxCall{name, nx_sr_args(args, env)}
    case NxAlloc{bytes}: NxAlloc{nx_sr_expr(bytes, env)}
    case NxLoad{typ, ptr, offset}: NxLoad{typ, nx_sr_expr(ptr, env), offset}
    case NxOffset{ptr, bytes}: NxOffset{nx_sr_expr(ptr, env), nx_sr_expr(bytes, env)}
    case NxICall{callee, args, params, result}: NxICall{nx_sr_expr(callee, env), nx_sr_args(args, env), params, result}
    case _: value

@unsafe
def nx_sr_args(+args: List<&2, NxExpr>, +env: List<&2, NxParam>) -> List<&2, NxExpr>:
  match args:
    case Nil{}: []
    case Con{head, rest}: Con{nx_sr_expr(head, env), nx_sr_args(rest, env)}

@unsafe
def nx_sr_stmt(+stmt: NxStmt, +env: List<&2, NxParam>) -> NxStmt:
  match stmt:
    case NxSet{name, value}: NxSet{name, nx_sr_expr(value, env)}
    case NxReturn{value}: NxReturn{nx_sr_expr(value, env)}
    case NxIf{condition, yes, no}: NxIf{nx_sr_expr(condition, env), nx_sr_body(yes, env), nx_sr_body(no, env)}
    case NxWhile{condition, body}: NxWhile{nx_sr_expr(condition, env), nx_sr_body(body, env)}
    case NxStore{typ, ptr, offset, value}: NxStore{typ, nx_sr_expr(ptr, env), offset, nx_sr_expr(value, env)}
    case NxFree{ptr}: NxFree{nx_sr_expr(ptr, env)}

@unsafe
def nx_sr_body(+body: List<&2, NxStmt>, +env: List<&2, NxParam>) -> List<&2, NxStmt>:
  match body:
    case Nil{}: []
    case Con{head, rest}: Con{nx_sr_stmt(head, env), nx_sr_body(rest, env)}

@unsafe
def nx_sr_function(+function: NxFunction) -> NxFunction:
  match function:
    case NxFunction{name, params, result, locals, body}:
      nx_choose(NxFunction, U32.is_le(nx_i_body_nodes(body), 4096),
        u => NxFunction{name, params, result, locals, nx_sr_body(body, nx_params_join(params, locals))}, u => function)

@unsafe
def nx_sr_functions(+functions: List<&2, NxFunction>) -> List<&2, NxFunction>:
  match functions:
    case Nil{}: []
    case Con{head, rest}: Con{nx_sr_function(head), nx_sr_functions(rest)}

@unsafe
def nx_sr_finish(+candidate: NxProgram, +original: NxProgram) -> NxProgram:
  nx_choose(NxProgram, U32.is_le(nx_inline_nodes(candidate), U32.add(nx_inline_nodes(original), 4096)),
    u => nx_r_finish(candidate, original), u => original)

@unsafe
def nx_sr_program(+program: NxProgram) -> NxProgram:
  match program:
    case NxProgram{entry, functions}:
      nx_choose(NxProgram, U32.is_le(nx_i_function_count(functions), 256) && U32.is_le(nx_inline_nodes(program), 65536),
        u => nx_sr_finish(NxProgram{entry, nx_sr_functions(functions)}, program), u => program)

@unsafe
def nx_strength_reduce(+program: NxProgram) -> NxProgram:
  nx_choose(NxProgram, nx_verify(program), u => nx_sr_program(program), u => program)
