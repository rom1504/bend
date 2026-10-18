# Closed-program function reachability. The sole external root is program.entry;
# this API is not applicable to libraries whose other functions are exported.
# Keep all direct calls and address-taken functions, including both branch arms.
@unsafe
def nx_r_add(+name: String, +names: List<&2, String>) -> List<&2, String>:
  nx_choose(List<&2, String>, nx_i_names_has(name, names), u => names, u => Con{name, names})

@unsafe
def nx_r_expr(+expr: NxExpr, +names: List<&2, String>) -> List<&2, String>:
  match expr:
    case NxConst{typ, value}: names
    case NxVar{name}: names
    case NxBin{op, left, right}: nx_r_expr(left, nx_r_expr(right, names))
    case NxCall{name, args}: nx_r_args(args, nx_r_add(name, names))
    case NxAlloc{bytes}: nx_r_expr(bytes, names)
    case NxLoad{typ, ptr, offset}: nx_r_expr(ptr, names)
    case NxOffset{ptr, bytes}: nx_r_expr(ptr, nx_r_expr(bytes, names))
    case NxFunc{name}: nx_r_add(name, names)
    case NxICall{callee, args, params, result}: nx_r_expr(callee, nx_r_args(args, names))

@unsafe
def nx_r_args(+args: List<&2, NxExpr>, +names: List<&2, String>) -> List<&2, String>:
  match args:
    case Nil{}: names
    case Con{head, rest}: nx_r_args(rest, nx_r_expr(head, names))

@unsafe
def nx_r_stmt(+stmt: NxStmt, +names: List<&2, String>) -> List<&2, String>:
  match stmt:
    case NxSet{name, value}: nx_r_expr(value, names)
    case NxReturn{value}: nx_r_expr(value, names)
    case NxIf{condition, yes, no}: nx_r_expr(condition, nx_r_body(yes, nx_r_body(no, names)))
    case NxWhile{condition, body}: nx_r_expr(condition, nx_r_body(body, names))
    case NxStore{typ, ptr, offset, value}: nx_r_expr(ptr, nx_r_expr(value, names))
    case NxFree{ptr}: nx_r_expr(ptr, names)

@unsafe
def nx_r_body(+body: List<&2, NxStmt>, +names: List<&2, String>) -> List<&2, String>:
  match body:
    case Nil{}: names
    case Con{head, rest}: nx_r_body(rest, nx_r_stmt(head, names))

@unsafe
def nx_r_schedule(+refs: List<&2, String>, +todo: List<&2, String>, +seen: List<&2, String>) -> List<&2, String>:
  match refs:
    case Nil{}: todo
    case Con{head, rest}:
      nx_r_schedule(rest, nx_choose(List<&2, String>, nx_i_names_has(head, seen), u => todo, u => nx_r_add(head, todo)), seen)

@unsafe
def nx_r_work(+todo: List<&2, String>, +seen: List<&2, String>, +fs: List<&2, NxFunction>, +fuel: U32) -> Maybe<&2, List<&2, String>>:
  match todo:
    case Nil{}: Some{seen}
    case Con{head, rest}:
      nx_choose(Maybe<&2, List<&2, String>>, nx_i_names_has(head, seen),
        u => nx_r_work(rest, seen, fs, fuel),
        u => nx_choose(Maybe<&2, List<&2, String>>, U32.is_eq(fuel, 0), u => None{},
          u => nx_r_visit(nx_find(head, fs), rest, Con{head, seen}, fs, U32.sub(fuel, 1))))

@unsafe
def nx_r_visit(+found: Maybe<&2, NxFunction>, +todo: List<&2, String>, +seen: List<&2, String>, +fs: List<&2, NxFunction>, +fuel: U32) -> Maybe<&2, List<&2, String>>:
  match found:
    case None{}: None{}
    case Some{NxFunction{name, params, result, locals, body}}:
      nx_r_work(nx_r_schedule(nx_r_body(body, []), todo, seen), seen, fs, fuel)

@unsafe
def nx_r_filter(+fs: List<&2, NxFunction>, +names: List<&2, String>) -> List<&2, NxFunction>:
  match fs:
    case Nil{}: []
    case Con{NxFunction{name, params, result, locals, body}, rest}:
      nx_choose(List<&2, NxFunction>, nx_i_names_has(name, names),
        u => Con{NxFunction{name, params, result, locals, body}, nx_r_filter(rest, names)},
        u => nx_r_filter(rest, names))

@unsafe
def nx_r_result(+found: Maybe<&2, List<&2, String>>, +program: NxProgram) -> NxProgram:
  match found program:
    case None{} _: program
    case Some{names} NxProgram{entry, fs}: nx_r_finish(NxProgram{entry, nx_r_filter(fs, names)}, program)

@unsafe
def nx_r_finish(+candidate: NxProgram, +original: NxProgram) -> NxProgram:
  nx_choose(NxProgram, nx_verify(candidate), u => candidate, u => original)

@unsafe
def nx_r_program(+program: NxProgram) -> NxProgram:
  match program:
    case NxProgram{entry, fs}:
      nx_choose(NxProgram, U32.is_le(nx_i_function_count(fs), 256) && U32.is_le(nx_inline_nodes(program), 65536),
        u => nx_r_result(nx_r_work([entry], [], fs, 256), program), u => program)

@unsafe
def nx_reachable(+program: NxProgram) -> NxProgram:
  nx_choose(NxProgram, nx_verify(program), u => nx_r_program(program), u => program)
