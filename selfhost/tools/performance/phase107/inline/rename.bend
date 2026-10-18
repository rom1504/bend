def nx_i_name(+prefix: String, +name: String) -> String:
  prefix ++ "v_" ++ name

@unsafe
def nx_i_params(+params: List<&2, NxParam>, +prefix: String) -> List<&2, NxParam>:
  match params:
    case Nil{}: Nil{}
    case Con{NxParam{name, typ}, rest}: Con{NxParam{nx_i_name(prefix, name), typ}, nx_i_params(rest, prefix)}

@unsafe
def nx_i_expr(+expr: NxExpr, +prefix: String) -> NxExpr:
  match expr:
    case NxVar{name}: NxVar{nx_i_name(prefix, name)}
    case NxBin{op, a, b}: NxBin{op, nx_i_expr(a, prefix), nx_i_expr(b, prefix)}
    case NxCall{name, args}: NxCall{name, nx_i_args(args, prefix)}
    case _: expr

@unsafe
def nx_i_args(+args: List<&2, NxExpr>, +prefix: String) -> List<&2, NxExpr>:
  match args:
    case Nil{}: Nil{}
    case Con{head, rest}: Con{nx_i_expr(head, prefix), nx_i_args(rest, prefix)}

@unsafe
def nx_i_rename(+body: List<&2, NxStmt>, +prefix: String, +destination: String) -> List<&2, NxStmt>:
  match body:
    case Nil{}: Nil{}
    case Con{NxSet{name, value}, rest}:
      Con{NxSet{nx_i_name(prefix, name), nx_i_expr(value, prefix)}, nx_i_rename(rest, prefix, destination)}
    case Con{NxReturn{value}, Nil{}}: [NxSet{destination, nx_i_expr(value, prefix)}]
    case Con{NxIf{condition, yes, no}, rest}:
      Con{NxIf{nx_i_expr(condition, prefix), nx_i_rename(yes, prefix, destination), nx_i_rename(no, prefix, destination)}, nx_i_rename(rest, prefix, destination)}
    case _: body

# Arguments remain in the caller environment. Bind in source order, once each;
# do not substitute expressions into uses or mutate existing caller names.
@unsafe
def nx_i_bind_args(+params: List<&2, NxParam>, +args: List<&2, NxExpr>, +prefix: String) -> List<&2, NxStmt>:
  match params args:
    case Con{NxParam{name, typ}, tail} Con{value, rest}:
      Con{NxSet{nx_i_name(prefix, name), value}, nx_i_bind_args(tail, rest, prefix)}
    case _ _: Nil{}

# Local zero initialization must happen at every inlined call, including calls
# in a caller loop. Entry-only zero initialization would leak preceding values.
@unsafe
def nx_i_reset(+locals: List<&2, NxParam>, +prefix: String) -> List<&2, NxStmt>:
  match locals:
    case Nil{}: Nil{}
    case Con{NxParam{name, typ}, rest}:
      Con{NxSet{nx_i_name(prefix, name), NxConst{typ, 0}}, nx_i_reset(rest, prefix)}

@unsafe
def nx_i_disjoint(+names: List<&2, NxParam>, +env: List<&2, NxParam>) -> Bool:
  match names:
    case Nil{}: True{}
    case Con{NxParam{name, typ}, rest}: nx_no_name(name, env) && nx_i_disjoint(rest, env)

@unsafe
def nx_i_fresh(+params: List<&2, NxParam>, +result: NxType, +locals: List<&2, NxParam>, +env: List<&2, NxParam>, +next: U32, +attempts: U32) -> Maybe<&2, NxIFresh>:
  nx_choose(Maybe<&2, NxIFresh>, U32.is_eq(attempts, 0), u => None{},
    u => nx_i_fresh_prefix("p107_i" ++ U32.show(next) ++ "_", params, result, locals, env, next, attempts))

@unsafe
def nx_i_fresh_prefix(+prefix: String, +params: List<&2, NxParam>, +result: NxType, +locals: List<&2, NxParam>, +env: List<&2, NxParam>, +next: U32, +attempts: U32) -> Maybe<&2, NxIFresh>:
  +names : List<&2, NxParam> = Con{NxParam{prefix ++ "ret", result}, nx_i_params(nx_params_join(params, locals), prefix)}
  nx_choose(Maybe<&2, NxIFresh>, nx_i_disjoint(names, env),
    u => Some{NxIFresh{prefix, U32.add(next, 1)}},
    u => nx_i_fresh(params, result, locals, env, U32.add(next, 1), U32.sub(attempts, 1)))
