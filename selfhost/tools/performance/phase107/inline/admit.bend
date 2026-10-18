# Only scalar, terminating-by-acyclic-call-graph helpers. Each helper is at most
# 256 statement/expression nodes and four direct call sites; proof depth is four.
@unsafe
def nx_i_names_has(+name: String, +seen: List<&2, String>) -> Bool:
  match seen:
    case Nil{}: False{}
    case Con{head, rest}: String.eq(name, head) || nx_i_names_has(name, rest)

@unsafe
def nx_i_scalar_params(+params: List<&2, NxParam>) -> Bool:
  match params:
    case Nil{}: True{}
    case Con{NxParam{name, typ}, rest}: nx_scalar(typ) && nx_i_scalar_params(rest)

@unsafe
def nx_i_expr_pure(+expr: NxExpr) -> Bool:
  match expr:
    case NxConst{typ, value}: nx_scalar(typ)
    case NxVar{name}: True{}
    case NxBin{op, a, b}: nx_i_expr_pure(a) && nx_i_expr_pure(b)
    case _: False{}

@unsafe
def nx_i_args_pure(+args: List<&2, NxExpr>) -> Bool:
  match args:
    case Nil{}: True{}
    case Con{head, rest}: nx_i_expr_pure(head) && nx_i_args_pure(rest)

@unsafe
def nx_i_rhs_safe(+expr: NxExpr, +fs: List<&2, NxFunction>, +seen: List<&2, String>, +depth: U32) -> Bool:
  match expr:
    case NxCall{name, args}: nx_i_args_pure(args) && nx_i_safe(name, fs, seen, depth)
    case _: nx_i_expr_pure(expr)

# Return-free conditionals also admit the checked frontend's merge-local shape.
# An early return followed by another statement remains outside this grammar.
@unsafe
def nx_i_fallthrough_safe(+body: List<&2, NxStmt>, +fs: List<&2, NxFunction>, +seen: List<&2, String>, +depth: U32) -> Bool:
  match body:
    case Nil{}: True{}
    case Con{NxSet{name, value}, rest}: nx_i_rhs_safe(value, fs, seen, depth) && nx_i_fallthrough_safe(rest, fs, seen, depth)
    case Con{NxIf{condition, yes, no}, rest}:
      nx_i_expr_pure(condition) && nx_i_fallthrough_safe(yes, fs, seen, depth) && nx_i_fallthrough_safe(no, fs, seen, depth) && nx_i_fallthrough_safe(rest, fs, seen, depth)
    case _: False{}

@unsafe
def nx_i_tail_safe(+body: List<&2, NxStmt>, +fs: List<&2, NxFunction>, +seen: List<&2, String>, +depth: U32) -> Bool:
  match body:
    case Con{NxSet{name, value}, rest}: nx_i_rhs_safe(value, fs, seen, depth) && nx_i_tail_safe(rest, fs, seen, depth)
    case Con{NxReturn{value}, Nil{}}: nx_i_rhs_safe(value, fs, seen, depth)
    case Con{NxIf{condition, yes, no}, Nil{}}: nx_i_expr_pure(condition) && nx_i_tail_safe(yes, fs, seen, depth) && nx_i_tail_safe(no, fs, seen, depth)
    case Con{NxIf{condition, yes, no}, rest}:
      nx_i_expr_pure(condition) && nx_i_fallthrough_safe(yes, fs, seen, depth) && nx_i_fallthrough_safe(no, fs, seen, depth) && nx_i_tail_safe(rest, fs, seen, depth)
    case _: False{}

@unsafe
def nx_i_expr_calls(+expr: NxExpr) -> U32:
  match expr:
    case NxCall{name, args}: 1
    case _: 0

@unsafe
def nx_i_body_calls(+body: List<&2, NxStmt>) -> U32:
  match body:
    case Nil{}: 0
    case Con{NxSet{name, value}, rest}: U32.add(nx_i_expr_calls(value), nx_i_body_calls(rest))
    case Con{NxReturn{value}, rest}: U32.add(nx_i_expr_calls(value), nx_i_body_calls(rest))
    case Con{NxIf{condition, yes, no}, rest}: U32.add(nx_i_body_calls(yes), U32.add(nx_i_body_calls(no), nx_i_body_calls(rest)))
    case _: 5

@unsafe
def nx_i_safe(+name: String, +fs: List<&2, NxFunction>, +seen: List<&2, String>, +depth: U32) -> Bool:
  nx_choose(Bool, U32.is_eq(depth, 0) || nx_i_names_has(name, seen), u => False{},
    u => nx_i_safe_found(nx_find(name, fs), fs, Con{name, seen}, U32.sub(depth, 1)))

@unsafe
def nx_i_safe_found(+found: Maybe<&2, NxFunction>, +fs: List<&2, NxFunction>, +seen: List<&2, String>, +depth: U32) -> Bool:
  match found:
    case None{}: False{}
    case Some{NxFunction{name, params, result, locals, body}}:
      nx_choose(Bool,
        nx_scalar(result) && nx_i_scalar_params(params) && nx_i_scalar_params(locals)
        && U32.is_le(nx_i_param_count(params), 16) && U32.is_le(nx_i_param_count(locals), 32)
        && U32.is_le(nx_i_body_nodes(body), 256) && U32.is_le(nx_i_body_calls(body), 4),
        u => nx_i_tail_safe(body, fs, seen, depth), u => False{})
