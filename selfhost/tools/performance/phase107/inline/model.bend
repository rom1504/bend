# Phase107 bounded scalar inlining. These records are compiler work state,
# separate from the Phase106 execution IR and from its runtime ABI.
type NxIState is Data:
  NxIState{+locals: List<&2, NxParam>, +next: U32, +fuel: U32, +eligible: Maybe<&2, List<&2, String>>}

type NxIBlock is Data:
  NxIBlock{+body: List<&2, NxStmt>, +state: NxIState}

type NxIFresh is Data:
  NxIFresh{+prefix: String, +next: U32}

type NxIFunction is Data:
  NxIFunction{+function: NxFunction, +fuel: U32}

type NxIFunctions is Data:
  NxIFunctions{+functions: List<&2, NxFunction>, +fuel: U32}

@unsafe
def nx_i_join(+a: List<&2, NxStmt>, +b: List<&2, NxStmt>) -> List<&2, NxStmt>:
  match a:
    case Nil{}: b
    case Con{head, rest}: Con{head, nx_i_join(rest, b)}

@unsafe
def nx_i_param_count(+items: List<&2, NxParam>) -> U32:
  match items:
    case Nil{}: 0
    case Con{head, rest}: U32.add(1, nx_i_param_count(rest))

@unsafe
def nx_i_expr_nodes(+expr: NxExpr) -> U32:
  match expr:
    case NxBin{op, a, b}: U32.add(1, U32.add(nx_i_expr_nodes(a), nx_i_expr_nodes(b)))
    case NxCall{name, args}: U32.add(1, nx_i_args_nodes(args))
    case NxAlloc{bytes}: U32.add(1, nx_i_expr_nodes(bytes))
    case NxLoad{typ, ptr, offset}: U32.add(1, nx_i_expr_nodes(ptr))
    case NxOffset{ptr, bytes}: U32.add(1, U32.add(nx_i_expr_nodes(ptr), nx_i_expr_nodes(bytes)))
    case NxICall{callee, args, params, result}: U32.add(1, U32.add(nx_i_expr_nodes(callee), nx_i_args_nodes(args)))
    case _: 1

@unsafe
def nx_i_args_nodes(+args: List<&2, NxExpr>) -> U32:
  match args:
    case Nil{}: 0
    case Con{head, rest}: U32.add(nx_i_expr_nodes(head), nx_i_args_nodes(rest))

@unsafe
def nx_i_stmt_nodes(+stmt: NxStmt) -> U32:
  match stmt:
    case NxSet{name, value}: U32.add(1, nx_i_expr_nodes(value))
    case NxReturn{value}: U32.add(1, nx_i_expr_nodes(value))
    case NxIf{condition, yes, no}: U32.add(1, U32.add(nx_i_expr_nodes(condition), U32.add(nx_i_body_nodes(yes), nx_i_body_nodes(no))))
    case NxWhile{condition, body}: U32.add(1, U32.add(nx_i_expr_nodes(condition), nx_i_body_nodes(body)))
    case NxStore{typ, ptr, offset, value}: U32.add(1, U32.add(nx_i_expr_nodes(ptr), nx_i_expr_nodes(value)))
    case NxFree{ptr}: U32.add(1, nx_i_expr_nodes(ptr))

@unsafe
def nx_i_body_nodes(+body: List<&2, NxStmt>) -> U32:
  match body:
    case Nil{}: 0
    case Con{head, rest}: U32.add(nx_i_stmt_nodes(head), nx_i_body_nodes(rest))

@unsafe
def nx_i_functions_nodes(+fs: List<&2, NxFunction>) -> U32:
  match fs:
    case Nil{}: 0
    case Con{NxFunction{name, params, result, locals, body}, rest}:
      U32.add(1, U32.add(nx_i_param_count(params), U32.add(nx_i_param_count(locals), U32.add(nx_i_body_nodes(body), nx_i_functions_nodes(rest)))))

# Exact count of program/function/parameter/local/statement/expression nodes.
# Types, names and list spine cells are metadata, not included in this metric.
@unsafe
def nx_inline_nodes(+p: NxProgram) -> U32:
  match p:
    case NxProgram{entry, fs}: U32.add(1, nx_i_functions_nodes(fs))

def nx_inline_budget(+budget: U32) -> U32:
  nx_choose(U32, U32.is_lt(budget, 4096), u => budget, u => 4096)

@unsafe
def nx_i_cost(+params: List<&2, NxParam>, +locals: List<&2, NxParam>, +body: List<&2, NxStmt>) -> U32:
  U32.add(3, U32.add(U32.mul(2, nx_i_param_count(params)), U32.add(U32.mul(3, nx_i_param_count(locals)), nx_i_body_nodes(body))))
