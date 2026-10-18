@unsafe
def nx_i_keep(+stmt: NxStmt, +state: NxIState) -> NxIBlock:
  NxIBlock{[stmt], state}

@unsafe
def nx_i_body(+body: List<&2, NxStmt>, +params: List<&2, NxParam>, +fs: List<&2, NxFunction>, +state: NxIState, +depth: U32) -> NxIBlock:
  match body:
    case Nil{}: NxIBlock{Nil{}, state}
    case Con{head, rest}:
      nx_i_after_head(nx_i_stmt(head, params, fs, state, depth), rest, params, fs, depth)

@unsafe
def nx_i_after_head(+head: NxIBlock, +rest: List<&2, NxStmt>, +params: List<&2, NxParam>, +fs: List<&2, NxFunction>, +depth: U32) -> NxIBlock:
  match head:
    case NxIBlock{body, state}: nx_i_prepend(body, nx_i_body(rest, params, fs, state, depth))

@unsafe
def nx_i_prepend(+prefix: List<&2, NxStmt>, +tail: NxIBlock) -> NxIBlock:
  match tail:
    case NxIBlock{body, state}: NxIBlock{nx_i_join(prefix, body), state}

@unsafe
def nx_i_stmt(+stmt: NxStmt, +params: List<&2, NxParam>, +fs: List<&2, NxFunction>, +state: NxIState, +depth: U32) -> NxIBlock:
  match stmt:
    case NxSet{target, NxCall{name, args}}:
      nx_i_call(stmt, name, args, params, fs, state, depth)
    case NxReturn{NxCall{name, args}}:
      nx_i_call(stmt, name, args, params, fs, state, depth)
    case NxIf{condition, yes, no}:
      nx_i_if_yes(condition, nx_i_body(yes, params, fs, state, depth), no, params, fs, depth)
    case NxWhile{condition, body}:
      nx_i_while(condition, nx_i_body(body, params, fs, state, depth))
    case _: nx_i_keep(stmt, state)

@unsafe
def nx_i_if_yes(+condition: NxExpr, +yes: NxIBlock, +no: List<&2, NxStmt>, +params: List<&2, NxParam>, +fs: List<&2, NxFunction>, +depth: U32) -> NxIBlock:
  match yes:
    case NxIBlock{body, state}: nx_i_if_no(condition, body, nx_i_body(no, params, fs, state, depth))

@unsafe
def nx_i_if_no(+condition: NxExpr, +yes: List<&2, NxStmt>, +no: NxIBlock) -> NxIBlock:
  match no:
    case NxIBlock{body, state}: NxIBlock{[NxIf{condition, yes, body}], state}

@unsafe
def nx_i_while(+condition: NxExpr, +block: NxIBlock) -> NxIBlock:
  match block:
    case NxIBlock{body, state}: NxIBlock{[NxWhile{condition, body}], state}

@unsafe
def nx_i_call(+original: NxStmt, +name: String, +args: List<&2, NxExpr>, +params: List<&2, NxParam>, +fs: List<&2, NxFunction>, +state: NxIState, +depth: U32) -> NxIBlock:
  match state:
    case NxIState{locals, next, fuel, eligible}:
      nx_choose(NxIBlock, U32.is_eq(depth, 0) || U32.is_eq(fuel, 0), u => nx_i_keep(original, state),
        u => nx_choose(NxIBlock, nx_i_allowed(name, fs, eligible),
          u => nx_i_found(original, nx_find(name, fs), args, params, fs, state, depth),
          u => nx_i_keep(original, state)))

# None preserves the original four-level admission algorithm. Some is a bounded
# original-program acyclicity certificate, never derived from expanded bodies.
@unsafe
def nx_i_allowed(+name: String, +fs: List<&2, NxFunction>, +eligible: Maybe<&2, List<&2, String>>) -> Bool:
  match eligible:
    case None{}: nx_i_safe(name, fs, Nil{}, 4)
    case Some{names}: nx_i_names_has(name, names)

@unsafe
def nx_i_found(+original: NxStmt, +found: Maybe<&2, NxFunction>, +args: List<&2, NxExpr>, +caller_params: List<&2, NxParam>, +fs: List<&2, NxFunction>, +state: NxIState, +depth: U32) -> NxIBlock:
  match found state:
    case Some{NxFunction{name, params, result, locals, body}} NxIState{caller_locals, next, fuel, eligible}:
      nx_choose(NxIBlock, U32.is_le(nx_i_cost(params, locals, body), fuel),
        u => nx_i_expand_fresh(original, nx_i_fresh(params, result, locals, nx_params_join(caller_params, caller_locals), next, 64),
          params, result, locals, body, args, caller_params, fs, state, depth),
        u => nx_i_keep(original, state))
    case _ _: nx_i_keep(original, state)

@unsafe
def nx_i_expand_fresh(+original: NxStmt, +fresh: Maybe<&2, NxIFresh>, +params: List<&2, NxParam>, +result: NxType, +locals: List<&2, NxParam>, +body: List<&2, NxStmt>, +args: List<&2, NxExpr>, +caller_params: List<&2, NxParam>, +fs: List<&2, NxFunction>, +state: NxIState, +depth: U32) -> NxIBlock:
  match fresh state:
    case Some{NxIFresh{prefix, next}} NxIState{caller_locals, oldnext, fuel, eligible}:
      +ret : String = prefix ++ "ret"
      +extra : List<&2, NxParam> = Con{NxParam{ret, result}, nx_i_params(nx_params_join(params, locals), prefix)}
      +newstate : NxIState = NxIState{nx_params_join(caller_locals, extra), next, U32.sub(fuel, nx_i_cost(params, locals, body)), eligible}
      +bindings : List<&2, NxStmt> = nx_i_join(nx_i_bind_args(params, args, prefix), nx_i_reset(locals, prefix))
      nx_i_finish(original, ret, bindings,
        nx_i_body(nx_i_rename(body, prefix, ret), caller_params, fs, newstate, U32.sub(depth, 1)))
    case _ _: nx_i_keep(original, state)

# The caller continuation runs after exactly one terminal branch assigned ret.
@unsafe
def nx_i_finish(+original: NxStmt, +ret: String, +bindings: List<&2, NxStmt>, +expanded: NxIBlock) -> NxIBlock:
  match expanded:
    case NxIBlock{body, state}:
      NxIBlock{nx_i_join(bindings, nx_i_join(body, [nx_i_continuation(original, ret)])), state}

def nx_i_continuation(+original: NxStmt, +ret: String) -> NxStmt:
  match original:
    case NxSet{target, value}: NxSet{target, NxVar{ret}}
    case NxReturn{value}: NxReturn{NxVar{ret}}
    case _: original

@unsafe
def nx_i_function(+f: NxFunction, +fs: List<&2, NxFunction>, +fuel: U32, +eligible: Maybe<&2, List<&2, String>>, +depth: U32) -> NxIFunction:
  match f:
    case NxFunction{name, params, result, locals, body}:
      nx_i_function_done(name, params, result, nx_i_body(body, params, fs, NxIState{locals, 0, fuel, eligible}, depth))

@unsafe
def nx_i_function_done(+name: String, +params: List<&2, NxParam>, +result: NxType, +block: NxIBlock) -> NxIFunction:
  match block:
    case NxIBlock{body, NxIState{locals, next, fuel, eligible}}: NxIFunction{NxFunction{name, params, result, locals, body}, fuel}

@unsafe
def nx_i_functions(+items: List<&2, NxFunction>, +fs: List<&2, NxFunction>, +fuel: U32, +eligible: Maybe<&2, List<&2, String>>, +depth: U32) -> NxIFunctions:
  match items:
    case Nil{}: NxIFunctions{Nil{}, fuel}
    case Con{head, rest}: nx_i_functions_head(nx_i_function(head, fs, fuel, eligible, depth), rest, fs, eligible, depth)

@unsafe
def nx_i_functions_head(+head: NxIFunction, +rest: List<&2, NxFunction>, +fs: List<&2, NxFunction>, +eligible: Maybe<&2, List<&2, String>>, +depth: U32) -> NxIFunctions:
  match head:
    case NxIFunction{function, fuel}: nx_i_functions_tail(function, nx_i_functions(rest, fs, fuel, eligible, depth))

@unsafe
def nx_i_functions_tail(+head: NxFunction, +rest: NxIFunctions) -> NxIFunctions:
  match rest:
    case NxIFunctions{functions, fuel}: NxIFunctions{Con{head, functions}, fuel}

@unsafe
def nx_i_program(+program: NxProgram, +budget: U32) -> NxProgram:
  nx_i_program_policy(program, budget, None{})

@unsafe
def nx_i_program_policy(+program: NxProgram, +budget: U32, +eligible: Maybe<&2, List<&2, String>>) -> NxProgram:
  match program:
    case NxProgram{entry, fs}: nx_i_program_done(entry, nx_i_functions(fs, fs, budget, eligible, 4))

@unsafe
def nx_i_program_done(+entry: String, +done: NxIFunctions) -> NxProgram:
  match done:
    case NxIFunctions{functions, fuel}: NxProgram{entry, functions}

# A global growth budget, capped at4096 nodes, shared across every function.
# Invalid input, zero budget and unsupported call sites preserve their input.
@unsafe
def nx_inline(+program: NxProgram, +budget: U32) -> NxProgram:
  nx_choose(NxProgram, U32.is_eq(budget, 0), u => program,
    u => nx_choose(NxProgram, nx_verify(program),
      u => nx_i_program(program, nx_inline_budget(budget)), u => program))
