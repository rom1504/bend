# Optional ABI entry fusion. The original private entry remains available to
# recursive calls and function pointers. Fuel bounds body duplication to512
# expression/statement nodes; exhaustion falls back to the baseline wrapper.
@unsafe
def nxq_expr_fuel(+expr: NxExpr, +fuel: U32) -> U32:
  nx_choose(U32, U32.is_eq(fuel, 0), u => 0, u => nxq_expr_fuel_go(expr, U32.sub(fuel, 1)))

@unsafe
def nxq_expr_fuel_go(+expr: NxExpr, +fuel: U32) -> U32:
  match expr:
    case NxConst{typ, value}: fuel
    case NxVar{name}: fuel
    case NxFunc{name}: fuel
    case NxBin{op, left, right}: nxq_expr_fuel(right, nxq_expr_fuel(left, fuel))
    case NxCall{name, args}: nxq_args_fuel(args, fuel)
    case NxAlloc{bytes}: nxq_expr_fuel(bytes, fuel)
    case NxLoad{typ, ptr, offset}: nxq_expr_fuel(ptr, fuel)
    case NxOffset{ptr, bytes}: nxq_expr_fuel(bytes, nxq_expr_fuel(ptr, fuel))
    case NxICall{callee, args, params, result}: nxq_args_fuel(args, nxq_expr_fuel(callee, fuel))

@unsafe
def nxq_args_fuel(+args: List<&2, NxExpr>, +fuel: U32) -> U32:
  nx_choose(U32, U32.is_eq(fuel, 0), u => 0, u => nxq_args_fuel_go(args, fuel))

@unsafe
def nxq_args_fuel_go(+args: List<&2, NxExpr>, +fuel: U32) -> U32:
  match args:
    case Nil{}: fuel
    case Con{head, rest}: nxq_args_fuel(rest, nxq_expr_fuel(head, fuel))

@unsafe
def nxq_stmt_fuel(+stmt: NxStmt, +fuel: U32) -> U32:
  nx_choose(U32, U32.is_eq(fuel, 0), u => 0, u => nxq_stmt_fuel_go(stmt, U32.sub(fuel, 1)))

@unsafe
def nxq_stmt_fuel_go(+stmt: NxStmt, +fuel: U32) -> U32:
  match stmt:
    case NxSet{name, value}: nxq_expr_fuel(value, fuel)
    case NxReturn{value}: nxq_expr_fuel(value, fuel)
    case NxFree{ptr}: nxq_expr_fuel(ptr, fuel)
    case NxStore{typ, ptr, offset, value}: nxq_expr_fuel(value, nxq_expr_fuel(ptr, fuel))
    case NxIf{condition, yes, no}: nxq_body_fuel(no, nxq_body_fuel(yes, nxq_expr_fuel(condition, fuel)))
    case NxWhile{condition, body}: nxq_body_fuel(body, nxq_expr_fuel(condition, fuel))

@unsafe
def nxq_body_fuel(+body: List<&2, NxStmt>, +fuel: U32) -> U32:
  nx_choose(U32, U32.is_eq(fuel, 0), u => 0, u => nxq_body_fuel_go(body, fuel))

@unsafe
def nxq_body_fuel_go(+body: List<&2, NxStmt>, +fuel: U32) -> U32:
  match body:
    case Nil{}: fuel
    case Con{head, rest}: nxq_body_fuel(rest, nxq_stmt_fuel(head, fuel))

@unsafe
def nxq_entry_body(+f: NxFunction, +fs: List<&2, NxFunction>, +fuse: Bool) -> String:
  match f:
    case NxFunction{name, params, result, locals, body}:
      +env = nx_params_join(params, locals)
      +eligible = fuse && U32.is_gt(nxq_body_fuel(body, 513), 0)
      "export data $phase106_arity = align 4 { w " ++ U32.show(nx_arity(params)) ++ " }\nexport function w $phase106_entry(l %args) {\n@entry\n" ++ nxq_entry_loads(params, 0) ++
      nx_choose(String, eligible,
        u => nxq_slots(env) ++ nxq_init(params, True{}) ++ nxq_init(locals, False{}) ++ nxq_code(nxq_stmts(body, env, fs, 0)),
        u => "%out =w call $nx_" ++ name ++ "(" ++ nxq_params(params) ++ ")\nret %out\n") ++ "}\n"

@unsafe
def nxq_fused_entry(+found: Maybe<&2, NxFunction>, +fs: List<&2, NxFunction>) -> String:
  match found:
    case None{}: "INVALID_ENTRY\n"
    case Some{f}: nxq_runtime() ++ nxq_functions(fs, fs) ++ nxq_entry_body(f, fs, True{})

@unsafe
def nxq_program_fused_verified(+program: NxProgram) -> String:
  match program:
    case NxProgram{entry, fs}: nxq_fused_entry(nx_find(entry, fs), fs)

@unsafe
def nxq_program_fused(+program: NxProgram) -> String:
  nx_choose(String, nx_verify(program), u => nxq_program_fused_verified(program), u => "INVALID_NX_PROGRAM\n")
