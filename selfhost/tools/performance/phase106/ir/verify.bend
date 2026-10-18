# Structural/type verifier, NOT a pointer-lifetime or memory-safety proof.
@unsafe
def nx_ident_chars(+s: String) -> Bool:
  match s:
    case SNil{}: True{}
    case SCon{ch, rest}:
      +code = Char.to_u32(ch)
      (U32.is_lt(U32.sub(code, 97), 26) || U32.is_lt(U32.sub(code, 48), 10) || U32.is_eq(code, 95)) && nx_ident_chars(rest)

@unsafe
def nx_ident(+s: String) -> Bool:
  match s:
    case SNil{}: False{}
    case SCon{ch, rest}:
      +code = Char.to_u32(ch)
      (U32.is_lt(U32.sub(code, 97), 26) || U32.is_eq(code, 95)) && nx_ident_chars(rest)

@unsafe
def nx_lookup(+name: String, +env: List<&2, NxParam>) -> NxType:
  match env:
    case Nil{}: NxBad{}
    case Con{NxParam{key, typ}, rest}:
      nx_choose(NxType, String.eq(name, key), u => typ, u => nx_lookup(name, rest))

@unsafe
def nx_find(+name: String, +fs: List<&2, NxFunction>) -> Maybe<&2, NxFunction>:
  match fs:
    case Nil{}: None{}
    case Con{head, rest}:
      match head:
        case NxFunction{key, params, result, locals, body}:
          nx_choose(Maybe<&2, NxFunction>, String.eq(name, key), u => Some{head}, u => nx_find(name, rest))

@unsafe
def nx_pure(+expr: NxExpr) -> Bool:
  match expr:
    case NxConst{typ, value}: True{}
    case NxVar{name}: True{}
    case NxFunc{name}: True{}
    case NxOffset{ptr, bytes}: nx_pure(ptr) && nx_pure(bytes)
    case NxBin{op, a, b}: nx_pure(a) && nx_pure(b)
    case _: False{}

@unsafe
def nx_bin_type(+op: String, +a: NxType, +b: NxType) -> NxType:
  nx_choose(NxType, nx_type_equal(a, b), u =>
    nx_choose(NxType, String.eq(op, "eq"), u => NxU32{}, u =>
    nx_choose(NxType, nx_scalar(a), u =>
      nx_choose(NxType, String.eq(op, "ult"), u => NxU32{}, u =>
      nx_choose(NxType, String.eq(op, "add") || String.eq(op, "sub") || String.eq(op, "mul") || String.eq(op, "and") || String.eq(op, "or") || String.eq(op, "xor") || String.eq(op, "shl") || String.eq(op, "lshr"),
        u => a, u => NxBad{})), u => NxBad{})), u => NxBad{})

@unsafe
def nx_arg_types(+args: List<&2, NxExpr>, +types: List<&2, NxType>, +env: List<&2, NxParam>, +fs: List<&2, NxFunction>) -> Bool:
  match args types:
    case Nil{} Nil{}: True{}
    case Con{arg, rest} Con{typ, tail}:
      nx_pure(arg) && nx_type_equal(nx_expr_type(arg, env, fs), typ) && nx_arg_types(rest, tail, env, fs)
    case _ _: False{}

@unsafe
def nx_param_types(+params: List<&2, NxParam>) -> List<&2, NxType>:
  match params:
    case Nil{}: Nil{}
    case Con{NxParam{name, typ}, rest}: Con{typ, nx_param_types(rest)}

@unsafe
def nx_call_type(+name: String, +args: List<&2, NxExpr>, +env: List<&2, NxParam>, +fs: List<&2, NxFunction>) -> NxType:
  nx_call_found(nx_find(name, fs), args, env, fs)

@unsafe
def nx_call_found(+found: Maybe<&2, NxFunction>, +args: List<&2, NxExpr>, +env: List<&2, NxParam>, +fs: List<&2, NxFunction>) -> NxType:
  match found:
    case None{}: NxBad{}
    case Some{NxFunction{key, params, result, locals, body}}:
      nx_choose(NxType, nx_arg_types(args, nx_param_types(params), env, fs), u => result, u => NxBad{})

@unsafe
def nx_expr_type(+expr: NxExpr, +env: List<&2, NxParam>, +fs: List<&2, NxFunction>) -> NxType:
  match expr:
    case NxConst{typ, value}:
      nx_choose(NxType, nx_scalar(typ) || (nx_type_equal(typ, NxPtr{}) && U32.is_eq(value, 0)), u => typ, u => NxBad{})
    case NxVar{name}: nx_lookup(name, env)
    case NxBin{op, left, right}:
      nx_choose(NxType, nx_pure(left) && nx_pure(right), u => nx_bin_type(op, nx_expr_type(left, env, fs), nx_expr_type(right, env, fs)), u => NxBad{})
    case NxCall{name, args}: nx_call_type(name, args, env, fs)
    case NxAlloc{bytes}:
      nx_choose(NxType, nx_pure(bytes) && nx_type_equal(nx_expr_type(bytes, env, fs), NxU32{}), u => NxPtr{}, u => NxBad{})
    case NxLoad{typ, ptr, offset}:
      nx_choose(NxType, nx_pure(ptr) && nx_type_equal(nx_expr_type(ptr, env, fs), NxPtr{}), u => typ, u => NxBad{})
    case NxOffset{ptr, bytes}:
      nx_choose(NxType, nx_pure(ptr) && nx_pure(bytes) && nx_type_equal(nx_expr_type(ptr, env, fs), NxPtr{}) && nx_type_equal(nx_expr_type(bytes, env, fs), NxU32{}), u => NxPtr{}, u => NxBad{})
    case NxFunc{name}:
      nx_function_pointer_type(nx_find(name, fs))
    case NxICall{callee, args, params, result}:
      nx_choose(NxType, nx_pure(callee) && nx_type_equal(nx_expr_type(callee, env, fs), NxPtr{}) && nx_arg_types(args, params, env, fs), u => result, u => NxBad{})

@unsafe
def nx_function_pointer_type(+found: Maybe<&2, NxFunction>) -> NxType:
  match found:
    case None{}: NxBad{}
    case Some{f}: NxPtr{}

@unsafe
def nx_stmt_ok(+stmt: NxStmt, +env: List<&2, NxParam>, +fs: List<&2, NxFunction>, +result: NxType) -> Bool:
  match stmt:
    case NxSet{name, value}: nx_type_equal(nx_lookup(name, env), nx_expr_type(value, env, fs))
    case NxIf{condition, yes, no}:
      nx_pure(condition) && nx_type_equal(nx_expr_type(condition, env, fs), NxU32{}) && nx_stmts_ok(yes, env, fs, result) && nx_stmts_ok(no, env, fs, result)
    case NxWhile{condition, body}:
      nx_pure(condition) && nx_type_equal(nx_expr_type(condition, env, fs), NxU32{}) && nx_stmts_ok(body, env, fs, result)
    case NxReturn{value}: nx_type_equal(nx_expr_type(value, env, fs), result)
    case NxStore{typ, ptr, offset, value}:
      nx_pure(ptr) && nx_pure(value) && nx_type_equal(nx_expr_type(ptr, env, fs), NxPtr{}) && nx_type_equal(nx_expr_type(value, env, fs), typ)
    case NxFree{ptr}: nx_pure(ptr) && nx_type_equal(nx_expr_type(ptr, env, fs), NxPtr{})

@unsafe
def nx_stmt_returns(+stmt: NxStmt) -> Bool:
  match stmt:
    case NxReturn{value}: True{}
    case NxIf{condition, yes, no}: nx_returns(yes) && nx_returns(no)
    case _: False{}

@unsafe
def nx_returns(+stmts: List<&2, NxStmt>) -> Bool:
  match stmts:
    case Nil{}: False{}
    case Con{head, Nil{}}: nx_stmt_returns(head)
    case Con{head, rest}: nx_returns(rest)

@unsafe
def nx_stmts_ok(+stmts: List<&2, NxStmt>, +env: List<&2, NxParam>, +fs: List<&2, NxFunction>, +result: NxType) -> Bool:
  match stmts:
    case Nil{}: True{}
    case Con{head, Nil{}}: nx_stmt_ok(head, env, fs, result)
    case Con{head, rest}: Bool.not(nx_stmt_returns(head)) && nx_stmt_ok(head, env, fs, result) && nx_stmts_ok(rest, env, fs, result)

@unsafe
def nx_params_ok(+params: List<&2, NxParam>) -> Bool:
  match params:
    case Nil{}: True{}
    case Con{NxParam{name, typ}, rest}:
      nx_ident(name) && nx_type_equal(typ, typ) && nx_no_name(name, rest) && nx_params_ok(rest)

@unsafe
def nx_no_name(+name: String, +params: List<&2, NxParam>) -> Bool:
  match params:
    case Nil{}: True{}
    case Con{NxParam{key, typ}, rest}: Bool.not(String.eq(name, key)) && nx_no_name(name, rest)

@unsafe
def nx_params_join(+a: List<&2, NxParam>, +b: List<&2, NxParam>) -> List<&2, NxParam>:
  match a:
    case Nil{}: b
    case Con{head, rest}: Con{head, nx_params_join(rest, b)}

@unsafe
def nx_functions_ok(+items: List<&2, NxFunction>, +all: List<&2, NxFunction>) -> Bool:
  match items:
    case Nil{}: True{}
    case Con{NxFunction{name, params, result, locals, body}, rest}:
      +env = nx_params_join(params, locals)
      nx_unique_function(name, rest) && nx_ident(name) && nx_type_equal(result, result) && nx_params_ok(env) && nx_stmts_ok(body, env, all, result) && nx_returns(body) && nx_functions_ok(rest, all)

@unsafe
def nx_unique_function(+name: String, +fs: List<&2, NxFunction>) -> Bool:
  nx_function_missing(nx_find(name, fs))

@unsafe
def nx_function_missing(+found: Maybe<&2, NxFunction>) -> Bool:
  match found:
    case None{}: True{}
    case Some{f}: False{}

@unsafe
def nx_entry_params(+params: List<&2, NxParam>) -> Bool:
  match params:
    case Nil{}: True{}
    case Con{NxParam{name, typ}, rest}: nx_scalar(typ) && nx_entry_params(rest)

@unsafe
def nx_verify(+program: NxProgram) -> Bool:
  match program:
    case NxProgram{entry, fs}:
      nx_verify_entry(nx_find(entry, fs), fs)

@unsafe
def nx_verify_entry(+found: Maybe<&2, NxFunction>, +fs: List<&2, NxFunction>) -> Bool:
  match found:
    case None{}: False{}
    case Some{NxFunction{name, params, result, locals, body}}:
      nx_type_equal(result, NxU32{}) && nx_entry_params(params) && nx_functions_ok(fs, fs)
