# This safe helper is the exact production connection used by Phase106 laws.
# Unknown operations and non-U32 constants retain their complete original tree.
def nx_fold_bin(+op: String, +left: NxExpr, +right: NxExpr) -> NxExpr:
  match left right:
    case NxConst{NxU32{}, a} NxConst{NxU32{}, b}:
      nx_choose(NxExpr, String.eq(op, "add"), u => NxConst{NxU32{}, U32.add(a, b)}, u =>
      nx_choose(NxExpr, String.eq(op, "sub"), u => NxConst{NxU32{}, U32.sub(a, b)}, u =>
      nx_choose(NxExpr, String.eq(op, "mul"), u => NxConst{NxU32{}, U32.mul(a, b)}, u =>
      nx_choose(NxExpr, String.eq(op, "and"), u => NxConst{NxU32{}, U32.and(a, b)}, u =>
      nx_choose(NxExpr, String.eq(op, "or"), u => NxConst{NxU32{}, U32.or(a, b)}, u =>
      nx_choose(NxExpr, String.eq(op, "xor"), u => NxConst{NxU32{}, U32.xor(a, b)}, u =>
      nx_choose(NxExpr, String.eq(op, "eq"), u => NxConst{NxU32{}, nx_bool32(U32.is_eq(a, b))}, u =>
      nx_choose(NxExpr, String.eq(op, "ult"), u => NxConst{NxU32{}, nx_bool32(U32.is_lt(a, b))},
        u => NxBin{op, left, right}))))))))
    case _ _: NxBin{op, left, right}

@unsafe
def nx_simplify(+expr: NxExpr) -> NxExpr:
  match expr:
    case NxBin{op, left, right}: nx_fold_bin(op, nx_simplify(left), nx_simplify(right))
    case NxCall{name, args}: NxCall{name, nx_simplify_args(args)}
    case NxAlloc{bytes}: NxAlloc{nx_simplify(bytes)}
    case NxLoad{typ, ptr, offset}: NxLoad{typ, nx_simplify(ptr), offset}
    case NxOffset{ptr, bytes}: NxOffset{nx_simplify(ptr), nx_simplify(bytes)}
    case NxICall{callee, args, params, result}: NxICall{nx_simplify(callee), nx_simplify_args(args), params, result}
    case _: expr

@unsafe
def nx_simplify_args(+args: List<&2, NxExpr>) -> List<&2, NxExpr>:
  match args:
    case Nil{}: Nil{}
    case Con{head, rest}: Con{nx_simplify(head), nx_simplify_args(rest)}

@unsafe
def nx_simplify_stmts(+stmts: List<&2, NxStmt>) -> List<&2, NxStmt>:
  match stmts:
    case Nil{}: Nil{}
    case Con{head, rest}: Con{nx_simplify_stmt(head), nx_simplify_stmts(rest)}

@unsafe
def nx_simplify_stmt(+stmt: NxStmt) -> NxStmt:
  match stmt:
    case NxSet{name, value}: NxSet{name, nx_simplify(value)}
    case NxIf{condition, yes, no}: NxIf{nx_simplify(condition), nx_simplify_stmts(yes), nx_simplify_stmts(no)}
    case NxWhile{condition, body}: NxWhile{nx_simplify(condition), nx_simplify_stmts(body)}
    case NxReturn{value}: NxReturn{nx_simplify(value)}
    case NxStore{typ, ptr, offset, value}: NxStore{typ, nx_simplify(ptr), offset, nx_simplify(value)}
    case NxFree{ptr}: NxFree{nx_simplify(ptr)}

@unsafe
def nx_simplify_functions(+fs: List<&2, NxFunction>) -> List<&2, NxFunction>:
  match fs:
    case Nil{}: Nil{}
    case Con{NxFunction{name, params, result, locals, body}, rest}:
      Con{NxFunction{name, params, result, locals, nx_simplify_stmts(body)}, nx_simplify_functions(rest)}

@unsafe
def nx_optimize(+program: NxProgram) -> NxProgram:
  match program:
    case NxProgram{entry, fs}: NxProgram{entry, nx_simplify_functions(fs)}
