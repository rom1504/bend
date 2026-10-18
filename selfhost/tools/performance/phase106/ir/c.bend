# A consumer of the exact same verified graph as the Cranelift JSON consumer.
def nx_c_type(t: NxType) -> String:
  match t:
    case NxU32{}: "uint32_t"
    case NxU64{}: "uint64_t"
    case NxPtr{}: "uintptr_t"
    case NxBad{}: "INVALID_TYPE"

@unsafe
def nx_c_op(+op: String) -> String:
  nx_choose(String, String.eq(op, "add"), u => "+", u =>
  nx_choose(String, String.eq(op, "sub"), u => "-", u =>
  nx_choose(String, String.eq(op, "mul"), u => "*", u =>
  nx_choose(String, String.eq(op, "and"), u => "&", u =>
  nx_choose(String, String.eq(op, "or"), u => "|", u =>
  nx_choose(String, String.eq(op, "xor"), u => "^", u =>
  nx_choose(String, String.eq(op, "shl"), u => "<<", u =>
  nx_choose(String, String.eq(op, "lshr"), u => ">>", u =>
  nx_choose(String, String.eq(op, "eq"), u => "==", u => "<")))))))))

@unsafe
def nx_c_expr(+expr: NxExpr, +env: List<&2, NxParam>, +fs: List<&2, NxFunction>) -> String:
  match expr:
    case NxConst{typ, value}: "((" ++ nx_c_type(typ) ++ ")" ++ U32.show(value) ++ "ULL)"
    case NxVar{name}: "v_" ++ name
    case NxBin{op, left, right}:
      +rhs = nx_c_expr(right, env, fs)
      +mask = nx_choose(String, nx_type_equal(nx_expr_type(left, env, fs), NxU32{}), u => "31", u => "63")
      count = nx_choose(String, String.eq(op, "shl") || String.eq(op, "lshr"), u => "(" ++ rhs ++ " & " ++ mask ++ "u)", u => rhs)
      "((" ++ nx_c_type(nx_expr_type(expr, env, fs)) ++ ")(" ++ nx_c_expr(left, env, fs) ++ " " ++ nx_c_op(op) ++ " " ++ count ++ "))"
    case NxCall{name, args}: "nx_" ++ name ++ "(" ++ nx_c_args(args, env, fs) ++ ")"
    case NxAlloc{bytes}: "p106_alloc(" ++ nx_c_expr(bytes, env, fs) ++ ")"
    case NxLoad{typ, ptr, offset}: "(*(" ++ nx_c_type(typ) ++ " *)(uintptr_t)(" ++ nx_c_expr(ptr, env, fs) ++ " + " ++ U32.show(offset) ++ "u))"
    case NxOffset{ptr, bytes}: "((uintptr_t)(" ++ nx_c_expr(ptr, env, fs) ++ ") + (uintptr_t)(" ++ nx_c_expr(bytes, env, fs) ++ "))"
    case NxFunc{name}: "((uintptr_t)&nx_" ++ name ++ ")"
    case NxICall{callee, args, params, result}: "((" ++ nx_c_type(result) ++ " (*)(" ++ nx_c_types(params) ++ "))(uintptr_t)(" ++ nx_c_expr(callee, env, fs) ++ "))(" ++ nx_c_args(args, env, fs) ++ ")"

@unsafe
def nx_c_args(+args: List<&2, NxExpr>, +env: List<&2, NxParam>, +fs: List<&2, NxFunction>) -> String:
  match args:
    case Nil{}: ""
    case Con{head, Nil{}}: nx_c_expr(head, env, fs)
    case Con{head, rest}: nx_c_expr(head, env, fs) ++ "," ++ nx_c_args(rest, env, fs)

@unsafe
def nx_c_types(+types: List<&2, NxType>) -> String:
  match types:
    case Nil{}: "void"
    case Con{head, Nil{}}: nx_c_type(head)
    case Con{head, rest}: nx_c_type(head) ++ "," ++ nx_c_types(rest)

@unsafe
def nx_c_stmt(+stmt: NxStmt, +env: List<&2, NxParam>, +fs: List<&2, NxFunction>) -> String:
  match stmt:
    case NxSet{name, value}: "v_" ++ name ++ "=" ++ nx_c_expr(value, env, fs) ++ ";\n"
    case NxIf{condition, yes, no}: "if(" ++ nx_c_expr(condition, env, fs) ++ "){\n" ++ nx_c_stmts(yes, env, fs) ++ "}else{\n" ++ nx_c_stmts(no, env, fs) ++ "}\n"
    case NxWhile{condition, body}: "while(" ++ nx_c_expr(condition, env, fs) ++ "){\n" ++ nx_c_stmts(body, env, fs) ++ "}\n"
    case NxReturn{value}: "return " ++ nx_c_expr(value, env, fs) ++ ";\n"
    case NxStore{typ, ptr, offset, value}: "*(" ++ nx_c_type(typ) ++ " *)(uintptr_t)(" ++ nx_c_expr(ptr, env, fs) ++ "+" ++ U32.show(offset) ++ "u)=" ++ nx_c_expr(value, env, fs) ++ ";\n"
    case NxFree{ptr}: "free((void *)(uintptr_t)(" ++ nx_c_expr(ptr, env, fs) ++ "));\n"

@unsafe
def nx_c_stmts(+stmts: List<&2, NxStmt>, +env: List<&2, NxParam>, +fs: List<&2, NxFunction>) -> String:
  match stmts:
    case Nil{}: ""
    case Con{head, rest}: nx_c_stmt(head, env, fs) ++ nx_c_stmts(rest, env, fs)

@unsafe
def nx_c_params(+params: List<&2, NxParam>) -> String:
  match params:
    case Nil{}: "void"
    case Con{NxParam{name, typ}, Nil{}}: nx_c_type(typ) ++ " v_" ++ name
    case Con{NxParam{name, typ}, rest}: nx_c_type(typ) ++ " v_" ++ name ++ "," ++ nx_c_params(rest)

@unsafe
def nx_c_locals(+params: List<&2, NxParam>) -> String:
  match params:
    case Nil{}: ""
    case Con{NxParam{name, typ}, rest}: nx_c_type(typ) ++ " v_" ++ name ++ "=0;\n" ++ nx_c_locals(rest)

@unsafe
def nx_c_decl(+f: NxFunction) -> String:
  match f:
    case NxFunction{name, params, result, locals, body}: "static " ++ nx_c_type(result) ++ " nx_" ++ name ++ "(" ++ nx_c_params(params) ++ ")"

@unsafe
def nx_c_decls(+fs: List<&2, NxFunction>) -> String:
  match fs:
    case Nil{}: ""
    case Con{f, rest}: nx_c_decl(f) ++ ";\n" ++ nx_c_decls(rest)

@unsafe
def nx_c_functions(+items: List<&2, NxFunction>, +fs: List<&2, NxFunction>) -> String:
  match items:
    case Nil{}: ""
    case Con{f, rest}:
      match f:
        case NxFunction{name, params, result, locals, body}:
          nx_c_decl(f) ++ "{\n" ++ nx_c_locals(locals) ++ nx_c_stmts(body, nx_params_join(params, locals), fs) ++ "}\n" ++ nx_c_functions(rest, fs)

@unsafe
def nx_c_entry_args(+params: List<&2, NxParam>, +index: U32) -> String:
  match params:
    case Nil{}: ""
    case Con{NxParam{name, typ}, rest}:
      nx_c_entry_arg_tail("(" ++ nx_c_type(typ) ++ ")args[" ++ U32.show(index) ++ "]", rest, index)

@unsafe
def nx_c_entry_arg_tail(+word: String, +rest: List<&2, NxParam>, +index: U32) -> String:
  match rest:
    case Nil{}: word
    case _: word ++ "," ++ nx_c_entry_args(rest, U32.add(index, 1))

@unsafe
def nx_arity(+params: List<&2, NxParam>) -> U32:
  match params:
    case Nil{}: 0
    case Con{head, rest}: U32.add(1, nx_arity(rest))

@unsafe
def nx_c_program(+p: NxProgram) -> String:
  match p:
    case NxProgram{entry, fs}:
      nx_c_entry(nx_find(entry, fs), entry, fs)

@unsafe
def nx_c_entry(+found: Maybe<&2, NxFunction>, +entry: String, +fs: List<&2, NxFunction>) -> String:
  match found:
    case None{}: "#error invalid entry\n"
    case Some{NxFunction{name, params, result, locals, body}}:
      "#include <stdint.h>\n#include <stdlib.h>\nstatic uintptr_t p106_alloc(uint32_t bytes){void *p=calloc(1,bytes?bytes:1);if(!p)abort();return (uintptr_t)p;}\n" ++ nx_c_decls(fs) ++ nx_c_functions(fs, fs) ++ "const uint32_t phase106_arity=" ++ U32.show(nx_arity(params)) ++ ";\nuint32_t phase106_entry(const uint64_t *args){return nx_" ++ entry ++ "(" ++ nx_c_entry_args(params, 0) ++ ");}\n"
