# Third machine backend for the verified Nx execution graph. This emitter is
# Bend, and shares the exact Nx verifier/semantics with C and Cranelift JSON.
# Mutable variables use private entry-block slots; QBE promotes eligible slots.
type NxqValue is Data:
  NxqValue{+code: String, +word: String, +typ: NxType, +next: U32}

type NxqCode is Data:
  NxqCode{+code: String, +next: U32, +terminal: Bool}

type NxqArgs is Data:
  NxqArgs{+code: String, +words: String, +next: U32}

def nxq_type(t: NxType) -> String:
  match t:
    case NxU32{}: "w"
    case NxU64{}: "l"
    case NxPtr{}: "l"
    case NxBad{}: "INVALID"

def nxq_tmp(n: U32) -> String:
  "%t" ++ U32.show(n)

def nxq_label(n: U32) -> String:
  "@b" ++ U32.show(n)

@unsafe
def nxq_op(+op: String, +typ: NxType) -> String:
  nx_choose(String, String.eq(op, "eq"), u => "ceq" ++ nxq_type(typ), u =>
  nx_choose(String, String.eq(op, "ult"), u => "cult" ++ nxq_type(typ), u =>
  nx_choose(String, String.eq(op, "lshr"), u => "shr", u => op)))

@unsafe
def nxq_expr(+expr: NxExpr, +env: List<&2, NxParam>, +fs: List<&2, NxFunction>, +n: U32) -> NxqValue:
  match expr:
    case NxConst{typ, value}: NxqValue{"", U32.show(value), typ, n}
    case NxVar{name}:
      +typ = nx_lookup(name, env)
      +word = nxq_tmp(n)
      NxqValue{word ++ " =" ++ nxq_type(typ) ++ " load" ++ nxq_type(typ) ++ " %slot_" ++ name ++ "\n", word, typ, U32.add(n, 1)}
    case NxFunc{name}: NxqValue{"", "$nx_" ++ name, NxPtr{}, n}
    case NxBin{op, left, right}: nxq_binary_left(op, right, env, fs, nxq_expr(left, env, fs, n))
    case NxCall{name, args}: nxq_call("$nx_" ++ name, nx_call_type(name, args, env, fs), nxq_args(args, env, fs, n))
    case NxAlloc{bytes}: nxq_allocate(nxq_expr(bytes, env, fs, n))
    case NxLoad{typ, ptr, offset}: nxq_load(typ, offset, nxq_expr(ptr, env, fs, n))
    case NxOffset{ptr, bytes}: nxq_offset_left(bytes, env, fs, nxq_expr(ptr, env, fs, n))
    case NxICall{callee, args, params, result}: nxq_indirect(args, result, env, fs, nxq_expr(callee, env, fs, n))

@unsafe
def nxq_binary_left(+op: String, +right: NxExpr, +env: List<&2, NxParam>, +fs: List<&2, NxFunction>, +left: NxqValue) -> NxqValue:
  match left:
    case NxqValue{code, word, typ, n}: nxq_binary(op, code, word, typ, nxq_expr(right, env, fs, n))

@unsafe
def nxq_binary(+op: String, +prefix: String, +left: String, +typ: NxType, +right: NxqValue) -> NxqValue:
  match right:
    case NxqValue{code, word, righttyp, n}:
      +result = nx_choose(NxType, String.eq(op, "eq") || String.eq(op, "ult"), u => NxU32{}, u => typ)
      nx_choose(NxqValue, String.eq(op, "shl") || String.eq(op, "lshr"),
        u => nxq_shift(op, prefix ++ code, left, word, typ, n),
        u => NxqValue{prefix ++ code ++ nxq_tmp(n) ++ " =" ++ nxq_type(result) ++ " " ++ nxq_op(op, typ) ++ " " ++ left ++ ", " ++ word ++ "\n", nxq_tmp(n), result, U32.add(n, 1)})

@unsafe
def nxq_shift(+op: String, +code: String, +left: String, +right: String, +typ: NxType, +n: U32) -> NxqValue:
  +mask = nx_choose(String, nx_type_equal(typ, NxU32{}), u => "31", u => "63")
  +count = nxq_tmp(n)
  +word = nxq_tmp(U32.add(n, 1))
  NxqValue{code ++ count ++ " =w and " ++ right ++ ", " ++ mask ++ "\n" ++ word ++ " =" ++ nxq_type(typ) ++ " " ++ nxq_op(op, typ) ++ " " ++ left ++ ", " ++ count ++ "\n", word, typ, U32.add(n, 2)}

@unsafe
def nxq_args(+args: List<&2, NxExpr>, +env: List<&2, NxParam>, +fs: List<&2, NxFunction>, +n: U32) -> NxqArgs:
  match args:
    case Nil{}: NxqArgs{"", "", n}
    case Con{head, rest}: nxq_args_head(rest, env, fs, nxq_expr(head, env, fs, n))

@unsafe
def nxq_args_head(+rest: List<&2, NxExpr>, +env: List<&2, NxParam>, +fs: List<&2, NxFunction>, +head: NxqValue) -> NxqArgs:
  match head:
    case NxqValue{code, word, typ, n}: nxq_args_tail(code, nxq_type(typ) ++ " " ++ word, nxq_args(rest, env, fs, n))

@unsafe
def nxq_args_tail(+prefix: String, +word: String, +tail: NxqArgs) -> NxqArgs:
  match tail:
    case NxqArgs{code, words, n}:
      NxqArgs{prefix ++ code, word ++ nx_choose(String, String.eq(words, ""), u => "", u => ", " ++ words), n}

@unsafe
def nxq_call(+callee: String, +typ: NxType, +args: NxqArgs) -> NxqValue:
  match args:
    case NxqArgs{code, words, n}:
      NxqValue{code ++ nxq_tmp(n) ++ " =" ++ nxq_type(typ) ++ " call " ++ callee ++ "(" ++ words ++ ")\n", nxq_tmp(n), typ, U32.add(n, 1)}

@unsafe
def nxq_indirect(+args: List<&2, NxExpr>, +result: NxType, +env: List<&2, NxParam>, +fs: List<&2, NxFunction>, +callee: NxqValue) -> NxqValue:
  match callee:
    case NxqValue{code, word, typ, n}: nxq_prefix_value(code, nxq_call(word, result, nxq_args(args, env, fs, n)))

def nxq_prefix_value(prefix: String, value: NxqValue) -> NxqValue:
  match value:
    case NxqValue{code, word, typ, n}: NxqValue{prefix ++ code, word, typ, n}

@unsafe
def nxq_allocate(+bytes: NxqValue) -> NxqValue:
  match bytes:
    case NxqValue{code, word, typ, n}: nxq_call("$nxq_alloc", NxPtr{}, NxqArgs{code, "w " ++ word, n})

@unsafe
def nxq_load(+typ: NxType, +offset: U32, +ptr: NxqValue) -> NxqValue:
  match ptr:
    case NxqValue{code, word, ptyp, n}:
      +at = nxq_tmp(n)
      +out = nxq_tmp(U32.add(n, 1))
      NxqValue{code ++ at ++ " =l add " ++ word ++ ", " ++ U32.show(offset) ++ "\n" ++ out ++ " =" ++ nxq_type(typ) ++ " load" ++ nxq_type(typ) ++ " " ++ at ++ "\n", out, typ, U32.add(n, 2)}

@unsafe
def nxq_offset_left(+bytes: NxExpr, +env: List<&2, NxParam>, +fs: List<&2, NxFunction>, +ptr: NxqValue) -> NxqValue:
  match ptr:
    case NxqValue{code, word, typ, n}: nxq_offset(code, word, nxq_expr(bytes, env, fs, n))

@unsafe
def nxq_offset(+prefix: String, +ptr: String, +bytes: NxqValue) -> NxqValue:
  match bytes:
    case NxqValue{code, word, typ, n}:
      +wide = nxq_tmp(n)
      +out = nxq_tmp(U32.add(n, 1))
      NxqValue{prefix ++ code ++ wide ++ " =l extuw " ++ word ++ "\n" ++ out ++ " =l add " ++ ptr ++ ", " ++ wide ++ "\n", out, NxPtr{}, U32.add(n, 2)}

@unsafe
def nxq_stmts(+stmts: List<&2, NxStmt>, +env: List<&2, NxParam>, +fs: List<&2, NxFunction>, +n: U32) -> NxqCode:
  match stmts:
    case Nil{}: NxqCode{"", n, False{}}
    case Con{head, rest}: nxq_stmts_next(rest, env, fs, nxq_stmt(head, env, fs, n))

@unsafe
def nxq_stmts_next(+rest: List<&2, NxStmt>, +env: List<&2, NxParam>, +fs: List<&2, NxFunction>, +head: NxqCode) -> NxqCode:
  match head:
    case NxqCode{code, n, terminal}:
      nx_choose(NxqCode, terminal, u => head, u => nxq_prefix_code(code, nxq_stmts(rest, env, fs, n)))

def nxq_prefix_code(prefix: String, value: NxqCode) -> NxqCode:
  match value:
    case NxqCode{code, n, terminal}: NxqCode{prefix ++ code, n, terminal}

@unsafe
def nxq_stmt(+stmt: NxStmt, +env: List<&2, NxParam>, +fs: List<&2, NxFunction>, +n: U32) -> NxqCode:
  match stmt:
    case NxSet{name, value}: nxq_assign(name, nxq_expr(value, env, fs, n))
    case NxReturn{value}: nxq_return(nxq_expr(value, env, fs, n))
    case NxFree{ptr}: nxq_free(nxq_expr(ptr, env, fs, n))
    case NxStore{typ, ptr, offset, value}: nxq_store_ptr(typ, offset, value, env, fs, nxq_expr(ptr, env, fs, n))
    case NxIf{condition, yes, no}: nxq_if(yes, no, env, fs, nxq_expr(condition, env, fs, n))
    case NxWhile{condition, body}: nxq_loop(condition, body, env, fs, n)

def nxq_assign(name: String, value: NxqValue) -> NxqCode:
  match value:
    case NxqValue{code, word, typ, n}: NxqCode{code ++ "store" ++ nxq_type(typ) ++ " " ++ word ++ ", %slot_" ++ name ++ "\n", n, False{}}

def nxq_return(value: NxqValue) -> NxqCode:
  match value:
    case NxqValue{code, word, typ, n}: NxqCode{code ++ "ret " ++ word ++ "\n", n, True{}}

def nxq_free(value: NxqValue) -> NxqCode:
  match value:
    case NxqValue{code, word, typ, n}: NxqCode{code ++ "call $free(l " ++ word ++ ")\n", n, False{}}

@unsafe
def nxq_store_ptr(+typ: NxType, +offset: U32, +value: NxExpr, +env: List<&2, NxParam>, +fs: List<&2, NxFunction>, +ptr: NxqValue) -> NxqCode:
  match ptr:
    case NxqValue{code, word, ptyp, n}: nxq_store(typ, offset, code, word, nxq_expr(value, env, fs, n))

@unsafe
def nxq_store(+typ: NxType, +offset: U32, +prefix: String, +ptr: String, +value: NxqValue) -> NxqCode:
  match value:
    case NxqValue{code, word, vtyp, n}:
      NxqCode{prefix ++ code ++ nxq_tmp(n) ++ " =l add " ++ ptr ++ ", " ++ U32.show(offset) ++ "\nstore" ++ nxq_type(typ) ++ " " ++ word ++ ", " ++ nxq_tmp(n) ++ "\n", U32.add(n, 1), False{}}

@unsafe
def nxq_jump_if(+terminal: Bool, +label: U32) -> String:
  nx_choose(String, terminal, u => "", u => "jmp " ++ nxq_label(label) ++ "\n")

@unsafe
def nxq_if(+yes: List<&2, NxStmt>, +no: List<&2, NxStmt>, +env: List<&2, NxParam>, +fs: List<&2, NxFunction>, +cond: NxqValue) -> NxqCode:
  match cond:
    case NxqValue{code, word, typ, n}:
      nxq_if_yes(code ++ "jnz " ++ word ++ ", " ++ nxq_label(n) ++ ", " ++ nxq_label(U32.add(n, 1)) ++ "\n", n, no, env, fs, nxq_stmts(yes, env, fs, U32.add(n, 3)))

@unsafe
def nxq_if_yes(+prefix: String, +label: U32, +no: List<&2, NxStmt>, +env: List<&2, NxParam>, +fs: List<&2, NxFunction>, +yes: NxqCode) -> NxqCode:
  match yes:
    case NxqCode{code, n, terminal}:
      nxq_if_done(prefix ++ nxq_label(label) ++ "\n" ++ code ++ nxq_jump_if(terminal, U32.add(label, 2)), label, terminal, nxq_stmts(no, env, fs, n))

@unsafe
def nxq_if_done(+prefix: String, +label: U32, +yes_terminal: Bool, +no: NxqCode) -> NxqCode:
  match no:
    case NxqCode{code, n, terminal}:
      +both = yes_terminal && terminal
      NxqCode{prefix ++ nxq_label(U32.add(label, 1)) ++ "\n" ++ code ++ nxq_jump_if(terminal, U32.add(label, 2)) ++ nx_choose(String, both, u => "", u => nxq_label(U32.add(label, 2)) ++ "\n"), n, both}

@unsafe
def nxq_loop(+condition: NxExpr, +body: List<&2, NxStmt>, +env: List<&2, NxParam>, +fs: List<&2, NxFunction>, +label: U32) -> NxqCode:
  nxq_loop_cond(label, body, env, fs, nxq_expr(condition, env, fs, U32.add(label, 3)))

@unsafe
def nxq_loop_cond(+label: U32, +body: List<&2, NxStmt>, +env: List<&2, NxParam>, +fs: List<&2, NxFunction>, +cond: NxqValue) -> NxqCode:
  match cond:
    case NxqValue{code, word, typ, n}:
      nxq_loop_done("jmp " ++ nxq_label(label) ++ "\n" ++ nxq_label(label) ++ "\n" ++ code ++ "jnz " ++ word ++ ", " ++ nxq_label(U32.add(label, 1)) ++ ", " ++ nxq_label(U32.add(label, 2)) ++ "\n" ++ nxq_label(U32.add(label, 1)) ++ "\n", label, nxq_stmts(body, env, fs, n))

@unsafe
def nxq_loop_done(+prefix: String, +label: U32, +body: NxqCode) -> NxqCode:
  match body:
    case NxqCode{code, n, terminal}:
      NxqCode{prefix ++ code ++ nxq_jump_if(terminal, label) ++ nxq_label(U32.add(label, 2)) ++ "\n", n, False{}}

@unsafe
def nxq_params(+params: List<&2, NxParam>) -> String:
  match params:
    case Nil{}: ""
    case Con{NxParam{name, typ}, Nil{}}: nxq_type(typ) ++ " %arg_" ++ name
    case Con{NxParam{name, typ}, rest}: nxq_type(typ) ++ " %arg_" ++ name ++ ", " ++ nxq_params(rest)

@unsafe
def nxq_slots(+params: List<&2, NxParam>) -> String:
  match params:
    case Nil{}: ""
    case Con{NxParam{name, typ}, rest}:
      "%slot_" ++ name ++ nx_choose(String, nx_type_equal(typ, NxU32{}), u => " =l alloc4 4\n", u => " =l alloc8 8\n") ++ nxq_slots(rest)

@unsafe
def nxq_init(+params: List<&2, NxParam>, +arguments: Bool) -> String:
  match params:
    case Nil{}: ""
    case Con{NxParam{name, typ}, rest}:
      "store" ++ nxq_type(typ) ++ " " ++ nx_choose(String, arguments, u => "%arg_" ++ name, u => "0") ++ ", %slot_" ++ name ++ "\n" ++ nxq_init(rest, arguments)

def nxq_code(value: NxqCode) -> String:
  match value:
    case NxqCode{code, n, terminal}: code

@unsafe
def nxq_function(+f: NxFunction, +fs: List<&2, NxFunction>) -> String:
  match f:
    case NxFunction{name, params, result, locals, body}:
      +env = nx_params_join(params, locals)
      "function " ++ nxq_type(result) ++ " $nx_" ++ name ++ "(" ++ nxq_params(params) ++ ") {\n@entry\n" ++ nxq_slots(env) ++ nxq_init(params, True{}) ++ nxq_init(locals, False{}) ++ nxq_code(nxq_stmts(body, env, fs, 0)) ++ "}\n"

@unsafe
def nxq_functions(+items: List<&2, NxFunction>, +fs: List<&2, NxFunction>) -> String:
  match items:
    case Nil{}: ""
    case Con{head, rest}: nxq_function(head, fs) ++ nxq_functions(rest, fs)

@unsafe
def nxq_entry_loads(+params: List<&2, NxParam>, +n: U32) -> String:
  match params:
    case Nil{}: ""
    case Con{NxParam{name, typ}, rest}:
      "%at_" ++ U32.show(n) ++ " =l add %args, " ++ U32.show(U32.mul(n, 8)) ++ "\n%arg_" ++ name ++ " =" ++ nxq_type(typ) ++ " load" ++ nxq_type(typ) ++ " %at_" ++ U32.show(n) ++ "\n" ++ nxq_entry_loads(rest, U32.add(n, 1))

def nxq_runtime() -> String:
  "function l $nxq_alloc(w %bytes) {\n@entry\n%wide =l extuw %bytes\n%nonzero =w cnew %bytes, 0\njnz %nonzero, @live, @zero\n@zero\njmp @ready\n@live\njmp @ready\n@ready\n%size =l phi @zero 1, @live %wide\n%ptr =l call $calloc(l 1, l %size)\n%bad =w ceql %ptr, 0\njnz %bad, @abort, @done\n@abort\ncall $abort()\nhlt\n@done\nret %ptr\n}\n"

@unsafe
def nxq_program_verified(+program: NxProgram) -> String:
  match program:
    case NxProgram{entry, fs}: nxq_entry(nx_find(entry, fs), entry, fs)

@unsafe
def nxq_entry(+found: Maybe<&2, NxFunction>, +entry: String, +fs: List<&2, NxFunction>) -> String:
  match found:
    case None{}: "INVALID_ENTRY\n"
    case Some{NxFunction{name, params, result, locals, body}}:
      nxq_runtime() ++ nxq_functions(fs, fs) ++ "export data $phase106_arity = align 4 { w " ++ U32.show(nx_arity(params)) ++ " }\nexport function w $phase106_entry(l %args) {\n@entry\n" ++ nxq_entry_loads(params, 0) ++ "%out =w call $nx_" ++ entry ++ "(" ++ nxq_params(params) ++ ")\nret %out\n}\n"

@unsafe
def nxq_program(+program: NxProgram) -> String:
  nx_choose(String, nx_verify(program), u => nxq_program_verified(program), u => "INVALID_NX_PROGRAM\n")
