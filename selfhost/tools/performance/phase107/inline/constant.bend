# Known U32 facts only. No effects or control-flow nodes are removed.
type NxCPFact is Data:
  NxCPFact{+name: String, +value: U32}
type NxCPBlock is Data:
  NxCPBlock{+body: List<&2, NxStmt>, +facts: List<&2, NxCPFact>}

@unsafe
def nx_cp_lookup(+name: String, +facts: List<&2, NxCPFact>) -> Maybe<&2, U32>:
  match facts:
    case Nil{}: None{}
    case Con{NxCPFact{key, value}, rest}:
      nx_choose(Maybe<&2, U32>, String.eq(name, key), u => Some{value}, u => nx_cp_lookup(name, rest))

@unsafe
def nx_cp_forget(+name: String, +facts: List<&2, NxCPFact>) -> List<&2, NxCPFact>:
  match facts:
    case Nil{}: []
    case Con{NxCPFact{key, value}, rest}:
      nx_choose(List<&2, NxCPFact>, String.eq(name, key), u => nx_cp_forget(name, rest),
        u => Con{NxCPFact{key, value}, nx_cp_forget(name, rest)})

def nx_cp_same(value: U32, found: Maybe<&2, U32>) -> Bool:
  match found:
    case None{}: False{}
    case Some{other}: U32.is_eq(value, other)

@unsafe
def nx_cp_meet(+left: List<&2, NxCPFact>, +right: List<&2, NxCPFact>) -> List<&2, NxCPFact>:
  match left:
    case Nil{}: []
    case Con{NxCPFact{name, value}, rest}:
      nx_choose(List<&2, NxCPFact>, nx_cp_same(value, nx_cp_lookup(name, right)),
        u => Con{NxCPFact{name, value}, nx_cp_meet(rest, right)}, u => nx_cp_meet(rest, right))

@unsafe
def nx_cp_count(+facts: List<&2, NxCPFact>) -> U32:
  match facts:
    case Nil{}: 0
    case Con{head, rest}: U32.inc(nx_cp_count(rest))

@unsafe
def nx_cp_initial(+locals: List<&2, NxParam>) -> List<&2, NxCPFact>:
  match locals:
    case Nil{}: []
    case Con{NxParam{name, NxU32{}}, rest}: Con{NxCPFact{name, 0}, nx_cp_initial(rest)}
    case Con{head, rest}: nx_cp_initial(rest)

def nx_cp_variable(+name: String, +found: Maybe<&2, U32>) -> NxExpr:
  match found:
    case None{}: NxVar{name}
    case Some{value}: NxConst{NxU32{}, value}

@unsafe
def nx_cp_expr(+expr: NxExpr, +facts: List<&2, NxCPFact>) -> NxExpr:
  match expr:
    case NxVar{name}: nx_cp_variable(name, nx_cp_lookup(name, facts))
    case NxBin{op, left, right}: nx_fold_bin(op, nx_cp_expr(left, facts), nx_cp_expr(right, facts))
    case NxCall{name, args}: NxCall{name, nx_cp_args(args, facts)}
    case NxAlloc{bytes}: NxAlloc{nx_cp_expr(bytes, facts)}
    case NxLoad{typ, ptr, offset}: NxLoad{typ, nx_cp_expr(ptr, facts), offset}
    case NxOffset{ptr, bytes}: NxOffset{nx_cp_expr(ptr, facts), nx_cp_expr(bytes, facts)}
    case NxICall{callee, args, params, result}:
      NxICall{nx_cp_expr(callee, facts), nx_cp_args(args, facts), params, result}
    case _: expr

@unsafe
def nx_cp_args(+args: List<&2, NxExpr>, +facts: List<&2, NxCPFact>) -> List<&2, NxExpr>:
  match args:
    case Nil{}: []
    case Con{head, rest}: Con{nx_cp_expr(head, facts), nx_cp_args(rest, facts)}

@unsafe
def nx_cp_bind(+name: String, +value: NxExpr, +facts: List<&2, NxCPFact>) -> List<&2, NxCPFact>:
  match value:
    case NxConst{NxU32{}, number}: Con{NxCPFact{name, number}, nx_cp_forget(name, facts)}
    case _: nx_cp_forget(name, facts)

# Nested loops in abstract transfer conservatively kill every assigned name.
@unsafe
def nx_cp_havoc(+body: List<&2, NxStmt>, +facts: List<&2, NxCPFact>) -> List<&2, NxCPFact>:
  match body:
    case Nil{}: facts
    case Con{head, rest}: nx_cp_havoc(rest, nx_cp_havoc_stmt(head, facts))

@unsafe
def nx_cp_havoc_stmt(+stmt: NxStmt, +facts: List<&2, NxCPFact>) -> List<&2, NxCPFact>:
  match stmt:
    case NxSet{name, value}: nx_cp_forget(name, facts)
    case NxIf{condition, yes, no}: nx_cp_havoc(no, nx_cp_havoc(yes, facts))
    case NxWhile{condition, body}: nx_cp_havoc(body, facts)
    case _: facts

@unsafe
def nx_cp_flow(+body: List<&2, NxStmt>, +facts: List<&2, NxCPFact>) -> List<&2, NxCPFact>:
  match body:
    case Nil{}: facts
    case Con{head, rest}: nx_cp_flow(rest, nx_cp_transfer(head, facts))

@unsafe
def nx_cp_transfer(+stmt: NxStmt, +facts: List<&2, NxCPFact>) -> List<&2, NxCPFact>:
  match stmt:
    case NxSet{name, value}: nx_cp_bind(name, nx_cp_expr(value, facts), facts)
    case NxIf{condition, yes, no}: nx_cp_meet(nx_cp_flow(yes, facts), nx_cp_flow(no, facts))
    case NxWhile{condition, body}: nx_cp_havoc(body, facts)
    case _: facts

# Descending header facts: no fact is introduced or changes its known value.
@unsafe
def nx_cp_header(+body: List<&2, NxStmt>, +header: List<&2, NxCPFact>, +fuel: U32) -> List<&2, NxCPFact>:
  nx_choose(List<&2, NxCPFact>, U32.is_eq(fuel, 0), u => [],
    u => nx_cp_header_next(body, header, nx_cp_meet(header, nx_cp_flow(body, header)), U32.sub(fuel, 1)))

@unsafe
def nx_cp_header_next(+body: List<&2, NxStmt>, +old: List<&2, NxCPFact>, +next: List<&2, NxCPFact>, fuel: U32) -> List<&2, NxCPFact>:
  nx_choose(List<&2, NxCPFact>, U32.is_eq(nx_cp_count(old), nx_cp_count(next)),
    u => next, u => nx_cp_header(body, next, fuel))

@unsafe
def nx_cp_body(+body: List<&2, NxStmt>, +facts: List<&2, NxCPFact>) -> NxCPBlock:
  match body:
    case Nil{}: NxCPBlock{[], facts}
    case Con{head, rest}: nx_cp_after(nx_cp_stmt(head, facts), rest)

@unsafe
def nx_cp_after(+done: NxCPBlock, +rest: List<&2, NxStmt>) -> NxCPBlock:
  match done:
    case NxCPBlock{body, facts}: nx_cp_append(body, nx_cp_body(rest, facts))

@unsafe
def nx_cp_append(+prefix: List<&2, NxStmt>, +done: NxCPBlock) -> NxCPBlock:
  match done:
    case NxCPBlock{body, facts}: NxCPBlock{nx_i_join(prefix, body), facts}

@unsafe
def nx_cp_set(+name: String, +value: NxExpr, +facts: List<&2, NxCPFact>) -> NxCPBlock:
  NxCPBlock{[NxSet{name, value}], nx_cp_bind(name, value, facts)}

@unsafe
def nx_cp_if(+condition: NxExpr, +yes: NxCPBlock, +no: NxCPBlock) -> NxCPBlock:
  match yes no:
    case NxCPBlock{yb, yf} NxCPBlock{nb, nf}:
      NxCPBlock{[NxIf{condition, yb, nb}], nx_cp_meet(yf, nf)}

@unsafe
def nx_cp_loop(+condition: NxExpr, +body: List<&2, NxStmt>, +header: List<&2, NxCPFact>) -> NxCPBlock:
  nx_cp_loop_done(nx_cp_expr(condition, header), nx_cp_body(body, header), header)

def nx_cp_loop_done(+condition: NxExpr, +done: NxCPBlock, +header: List<&2, NxCPFact>) -> NxCPBlock:
  match done:
    case NxCPBlock{body, ignored}: NxCPBlock{[NxWhile{condition, body}], header}

@unsafe
def nx_cp_stmt(+stmt: NxStmt, +facts: List<&2, NxCPFact>) -> NxCPBlock:
  match stmt:
    case NxSet{name, value}: nx_cp_set(name, nx_cp_expr(value, facts), facts)
    case NxIf{condition, yes, no}:
      nx_cp_if(nx_cp_expr(condition, facts), nx_cp_body(yes, facts), nx_cp_body(no, facts))
    case NxWhile{condition, body}:
      nx_cp_loop(condition, body, nx_cp_header(body, facts, U32.inc(nx_cp_count(facts))))
    case NxReturn{value}: NxCPBlock{[NxReturn{nx_cp_expr(value, facts)}], facts}
    case NxStore{typ, ptr, offset, value}:
      NxCPBlock{[NxStore{typ, nx_cp_expr(ptr, facts), offset, nx_cp_expr(value, facts)}], facts}
    case NxFree{ptr}: NxCPBlock{[NxFree{nx_cp_expr(ptr, facts)}], facts}

@unsafe
def nx_cp_depth(+body: List<&2, NxStmt>, +depth: U32) -> Bool:
  match body:
    case Nil{}: True{}
    case Con{head, rest}: nx_cp_depth_stmt(head, depth) && nx_cp_depth(rest, depth)

@unsafe
def nx_cp_depth_stmt(+stmt: NxStmt, +depth: U32) -> Bool:
  match stmt:
    case NxIf{condition, yes, no}: nx_choose(Bool, U32.is_eq(depth, 0), u => False{},
      u => nx_cp_depth(yes, U32.sub(depth, 1)) && nx_cp_depth(no, U32.sub(depth, 1)))
    case NxWhile{condition, body}: nx_choose(Bool, U32.is_eq(depth, 0), u => False{},
      u => nx_cp_depth(body, U32.sub(depth, 1)))
    case _: True{}

@unsafe
def nx_cp_eligible(+function: NxFunction) -> Bool:
  match function:
    case NxFunction{name, params, result, locals, body}:
      nx_choose(Bool, U32.is_le(U32.add(nx_i_param_count(params), nx_i_param_count(locals)), 128),
        u => U32.is_le(nx_i_body_nodes(body), 4096) && nx_cp_depth(body, 16), u => False{})

@unsafe
def nx_cp_function(+function: NxFunction) -> NxFunction:
  match function:
    case NxFunction{name, params, result, locals, body}:
      nx_choose(NxFunction, nx_cp_eligible(function),
        u => nx_cp_function_done(function, nx_cp_body(body, nx_cp_initial(locals))), u => function)

def nx_cp_function_done(+function: NxFunction, +done: NxCPBlock) -> NxFunction:
  match function done:
    case NxFunction{name, params, result, locals, oldbody} NxCPBlock{body, facts}:
      NxFunction{name, params, result, locals, body}

@unsafe
def nx_cp_functions(+functions: List<&2, NxFunction>) -> List<&2, NxFunction>:
  match functions:
    case Nil{}: []
    case Con{head, rest}: Con{nx_cp_function(head), nx_cp_functions(rest)}

@unsafe
def nx_cp_finish(+candidate: NxProgram, +original: NxProgram) -> NxProgram:
  nx_choose(NxProgram, U32.is_le(nx_inline_nodes(candidate), nx_inline_nodes(original)) && nx_verify(candidate),
    u => candidate, u => original)

@unsafe
def nx_cp_program(+program: NxProgram) -> NxProgram:
  match program:
    case NxProgram{entry, functions}:
      nx_choose(NxProgram, U32.is_le(nx_i_function_count(functions), 256) && U32.is_le(nx_inline_nodes(program), 65536),
        u => nx_cp_finish(NxProgram{entry, nx_cp_functions(functions)}, program), u => program)

@unsafe
def nx_cp_any_eligible(+functions: List<&2, NxFunction>) -> Bool:
  match functions:
    case Nil{}: False{}
    case Con{head, rest}:
      nx_choose(Bool, nx_cp_eligible(head), u => True{}, u => nx_cp_any_eligible(rest))

@unsafe
def nx_cp_has_eligible(+program: NxProgram) -> Bool:
  match program:
    case NxProgram{entry, functions}: nx_cp_any_eligible(functions)

# This necessary-condition check returns identity; it does not admit invalid IR.
@unsafe
def nx_constant_propagate(+program: NxProgram) -> NxProgram:
  nx_choose(NxProgram, nx_cp_has_eligible(program),
    u => nx_choose(NxProgram, nx_verify(program), v => nx_cp_program(program), v => program), u => program)
