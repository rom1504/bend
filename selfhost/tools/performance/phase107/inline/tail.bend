# First self-tail transform: scalar frames, no existing loops or mixed early
# returns. Mutual recursion and pointer/ownership conventions are unchanged.
@unsafe
def nx_t_normalize(+body: List<&2, NxStmt>) -> List<&2, NxStmt>:
  match body:
    case Con{NxSet{name, value}, rest}: nx_t_set(name, value, nx_t_normalize(rest))
    case Con{NxIf{condition, yes, no}, Nil{}}:
      [NxIf{condition, nx_t_normalize(yes), nx_t_normalize(no)}]
    case Con{NxIf{condition, yes, no}, rest}: nx_t_if(condition, yes, no, nx_t_normalize(rest))
    case _: body

@unsafe
def nx_t_set(+name: String, +value: NxExpr, +tail: List<&2, NxStmt>) -> List<&2, NxStmt>:
  match tail:
    case Con{NxReturn{NxVar{target}}, Nil{}}:
      nx_choose(List<&2, NxStmt>, String.eq(name, target), u => [NxReturn{value}], u => Con{NxSet{name, value}, tail})
    case _: Con{NxSet{name, value}, tail}

@unsafe
def nx_t_if(+condition: NxExpr, +yes: List<&2, NxStmt>, +no: List<&2, NxStmt>, +tail: List<&2, NxStmt>) -> List<&2, NxStmt>:
  match tail:
    case Con{NxReturn{value}, Nil{}}:
      nx_choose(List<&2, NxStmt>, U32.is_le(nx_i_expr_nodes(value), 64),
        u => [NxIf{condition, nx_t_normalize(nx_i_join(yes, tail)), nx_t_normalize(nx_i_join(no, tail))}],
        u => Con{NxIf{condition, yes, no}, tail})
    case _: Con{NxIf{condition, yes, no}, tail}

def nx_t_expr_self(+expr: NxExpr, +name: String) -> U32:
  match expr:
    case NxCall{callee, args}: nx_bool32(String.eq(callee, name))
    case _: 0

@unsafe
def nx_t_count(+body: List<&2, NxStmt>, +name: String) -> U32:
  match body:
    case Nil{}: 0
    case Con{NxSet{target, value}, rest}: U32.add(nx_t_expr_self(value, name), nx_t_count(rest, name))
    case Con{NxReturn{value}, rest}: U32.add(nx_t_expr_self(value, name), nx_t_count(rest, name))
    case Con{NxIf{condition, yes, no}, rest}: U32.add(nx_t_count(yes, name), U32.add(nx_t_count(no, name), nx_t_count(rest, name)))
    case _: 0

@unsafe
def nx_t_only_tail(+body: List<&2, NxStmt>, +name: String) -> Bool:
  match body:
    case Nil{}: True{}
    case Con{NxReturn{NxCall{callee, args}}, Nil{}}: True{}
    case Con{NxSet{target, value}, rest}: U32.is_eq(nx_t_expr_self(value, name), 0) && nx_t_only_tail(rest, name)
    case Con{NxReturn{value}, rest}: U32.is_eq(nx_t_expr_self(value, name), 0) && nx_t_only_tail(rest, name)
    case Con{NxIf{condition, yes, no}, rest}: nx_t_only_tail(yes, name) && nx_t_only_tail(no, name) && nx_t_only_tail(rest, name)
    case _: False{}

@unsafe
def nx_t_update_params(+params: List<&2, NxParam>, +prefix: String) -> List<&2, NxStmt>:
  match params:
    case Nil{}: []
    case Con{NxParam{name, typ}, rest}: Con{NxSet{name, NxVar{nx_i_name(prefix, name)}}, nx_t_update_params(rest, prefix)}

@unsafe
def nx_t_reset(+locals: List<&2, NxParam>) -> List<&2, NxStmt>:
  match locals:
    case Nil{}: []
    case Con{NxParam{name, typ}, rest}: Con{NxSet{name, NxConst{typ, 0}}, nx_t_reset(rest)}

@unsafe
def nx_t_rewrite(+body: List<&2, NxStmt>, +name: String, +params: List<&2, NxParam>, +locals: List<&2, NxParam>, +prefix: String) -> List<&2, NxStmt>:
  match body:
    case Nil{}: []
    case Con{NxReturn{NxCall{callee, args}}, Nil{}}:
      nx_choose(List<&2, NxStmt>, String.eq(callee, name),
        u => nx_i_join(nx_i_bind_args(params, args, prefix), nx_i_join(nx_t_reset(locals), nx_t_update_params(params, prefix))),
        u => body)
    case Con{NxIf{condition, yes, no}, rest}:
      Con{NxIf{condition, nx_t_rewrite(yes, name, params, locals, prefix), nx_t_rewrite(no, name, params, locals, prefix)}, nx_t_rewrite(rest, name, params, locals, prefix)}
    case Con{head, rest}: Con{head, nx_t_rewrite(rest, name, params, locals, prefix)}

@unsafe
def nx_t_function(+function: NxFunction) -> NxFunction:
  match function:
    case NxFunction{name, params, result, locals, body}:
      nx_choose(NxFunction, nx_scalar(result) && nx_i_scalar_params(params) && nx_i_scalar_params(locals)
        && U32.is_le(nx_i_param_count(params), 16) && U32.is_le(nx_i_param_count(locals), 32)
        && U32.is_le(nx_i_body_nodes(body), 512) && nx_i_local_tail(body) && U32.is_gt(nx_t_count(body, name), 0),
        u => nx_t_normalized(function, nx_t_normalize(body)), u => function)

@unsafe
def nx_t_normalized(+function: NxFunction, +body: List<&2, NxStmt>) -> NxFunction:
  match function:
    case NxFunction{name, params, result, locals, original}:
      nx_choose(NxFunction, nx_t_only_tail(body, name) && U32.is_le(nx_i_body_nodes(body), 2048),
        u => nx_t_fresh(function, body, nx_i_fresh(params, result, [], nx_params_join(params, locals), 0, 64)), u => function)

@unsafe
def nx_t_fresh(+function: NxFunction, +body: List<&2, NxStmt>, +fresh: Maybe<&2, NxIFresh>) -> NxFunction:
  match function fresh:
    case NxFunction{name, params, result, locals, original} Some{NxIFresh{prefix, next}}:
      nx_t_finished(function, NxFunction{name, params, result, nx_params_join(locals, nx_i_params(params, prefix)),
        [NxWhile{NxConst{NxU32{}, 1}, nx_t_rewrite(body, name, params, locals, prefix)}, NxReturn{NxConst{result, 0}}]})
    case _ _: function

@unsafe
def nx_t_finished(+original: NxFunction, +candidate: NxFunction) -> NxFunction:
  match candidate:
    case NxFunction{name, params, result, locals, body}:
      nx_choose(NxFunction, U32.is_le(nx_i_body_nodes(body), 4096), u => candidate, u => original)

@unsafe
def nx_t_functions(+fs: List<&2, NxFunction>) -> List<&2, NxFunction>:
  match fs:
    case Nil{}: []
    case Con{head, rest}: Con{nx_t_function(head), nx_t_functions(rest)}

@unsafe
def nx_t_program(+program: NxProgram) -> NxProgram:
  match program:
    case NxProgram{entry, fs}:
      nx_choose(NxProgram, U32.is_le(nx_i_function_count(fs), 256),
        u => nx_t_program_done(program, NxProgram{entry, nx_t_functions(fs)}), u => program)

@unsafe
def nx_t_program_done(+original: NxProgram, +candidate: NxProgram) -> NxProgram:
  nx_choose(NxProgram, U32.is_le(nx_inline_nodes(candidate), U32.add(nx_inline_nodes(original), 4096)), u => candidate, u => original)

@unsafe
def nx_tail_optimize(+program: NxProgram) -> NxProgram:
  nx_choose(NxProgram, nx_verify(program), u => nx_t_program(program), u => program)
