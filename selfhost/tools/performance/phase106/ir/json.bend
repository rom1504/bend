# Names/operators are verifier-restricted ASCII; no general JSON string escape.
def nx_quote(+s: String) -> String:
  "\"" ++ s ++ "\""

@unsafe
def nx_json_expr(+expr: NxExpr) -> String:
  match expr:
    case NxConst{typ, value}: "{\"kind\":\"const\",\"type\":" ++ nx_quote(nx_type_name(typ)) ++ ",\"value\":" ++ U32.show(value) ++ "}"
    case NxVar{name}: "{\"kind\":\"var\",\"name\":" ++ nx_quote(name) ++ "}"
    case NxBin{op, left, right}: "{\"kind\":\"bin\",\"op\":" ++ nx_quote(op) ++ ",\"lhs\":" ++ nx_json_expr(left) ++ ",\"rhs\":" ++ nx_json_expr(right) ++ "}"
    case NxCall{name, args}: "{\"kind\":\"call\",\"name\":" ++ nx_quote(name) ++ ",\"args\":[" ++ nx_json_args(args) ++ "]}"
    case NxAlloc{bytes}: "{\"kind\":\"alloc\",\"bytes\":" ++ nx_json_expr(bytes) ++ "}"
    case NxLoad{typ, ptr, offset}: "{\"kind\":\"load\",\"type\":" ++ nx_quote(nx_type_name(typ)) ++ ",\"ptr\":" ++ nx_json_expr(ptr) ++ ",\"offset\":" ++ U32.show(offset) ++ "}"
    case NxOffset{ptr, bytes}: "{\"kind\":\"ptradd\",\"ptr\":" ++ nx_json_expr(ptr) ++ ",\"bytes\":" ++ nx_json_expr(bytes) ++ "}"
    case NxFunc{name}: "{\"kind\":\"func\",\"name\":" ++ nx_quote(name) ++ "}"
    case NxICall{callee, args, params, result}: "{\"kind\":\"icall\",\"callee\":" ++ nx_json_expr(callee) ++ ",\"args\":[" ++ nx_json_args(args) ++ "],\"params\":[" ++ nx_json_types(params) ++ "],\"result\":" ++ nx_quote(nx_type_name(result)) ++ "}"

@unsafe
def nx_json_args(+args: List<&2, NxExpr>) -> String:
  match args:
    case Nil{}: ""
    case Con{head, Nil{}}: nx_json_expr(head)
    case Con{head, rest}: nx_json_expr(head) ++ "," ++ nx_json_args(rest)

@unsafe
def nx_json_types(+types: List<&2, NxType>) -> String:
  match types:
    case Nil{}: ""
    case Con{head, Nil{}}: nx_quote(nx_type_name(head))
    case Con{head, rest}: nx_quote(nx_type_name(head)) ++ "," ++ nx_json_types(rest)

@unsafe
def nx_json_stmt(+stmt: NxStmt) -> String:
  match stmt:
    case NxSet{name, value}: "{\"kind\":\"set\",\"name\":" ++ nx_quote(name) ++ ",\"value\":" ++ nx_json_expr(value) ++ "}"
    case NxIf{condition, yes, no}: "{\"kind\":\"if\",\"cond\":" ++ nx_json_expr(condition) ++ ",\"then\":[" ++ nx_json_stmts(yes) ++ "],\"else\":[" ++ nx_json_stmts(no) ++ "]}"
    case NxWhile{condition, body}: "{\"kind\":\"while\",\"cond\":" ++ nx_json_expr(condition) ++ ",\"body\":[" ++ nx_json_stmts(body) ++ "]}"
    case NxReturn{value}: "{\"kind\":\"return\",\"value\":" ++ nx_json_expr(value) ++ "}"
    case NxStore{typ, ptr, offset, value}: "{\"kind\":\"store\",\"type\":" ++ nx_quote(nx_type_name(typ)) ++ ",\"ptr\":" ++ nx_json_expr(ptr) ++ ",\"offset\":" ++ U32.show(offset) ++ ",\"value\":" ++ nx_json_expr(value) ++ "}"
    case NxFree{ptr}: "{\"kind\":\"free\",\"ptr\":" ++ nx_json_expr(ptr) ++ "}"

@unsafe
def nx_json_stmts(+stmts: List<&2, NxStmt>) -> String:
  match stmts:
    case Nil{}: ""
    case Con{head, Nil{}}: nx_json_stmt(head)
    case Con{head, rest}: nx_json_stmt(head) ++ "," ++ nx_json_stmts(rest)

@unsafe
def nx_json_params(+params: List<&2, NxParam>) -> String:
  match params:
    case Nil{}: ""
    case Con{NxParam{name, typ}, rest}:
      nx_json_param_tail("{\"name\":" ++ nx_quote(name) ++ ",\"type\":" ++ nx_quote(nx_type_name(typ)) ++ "}", rest)

@unsafe
def nx_json_param_tail(+piece: String, +rest: List<&2, NxParam>) -> String:
  match rest:
    case Nil{}: piece
    case _: piece ++ "," ++ nx_json_params(rest)

@unsafe
def nx_json_function(+f: NxFunction) -> String:
  match f:
    case NxFunction{name, params, result, locals, body}:
      "{\"name\":" ++ nx_quote(name) ++ ",\"params\":[" ++ nx_json_params(params) ++ "],\"result\":" ++ nx_quote(nx_type_name(result)) ++ ",\"locals\":[" ++ nx_json_params(locals) ++ "],\"body\":[" ++ nx_json_stmts(body) ++ "]}"

@unsafe
def nx_json_functions(+fs: List<&2, NxFunction>) -> String:
  match fs:
    case Nil{}: ""
    case Con{head, Nil{}}: nx_json_function(head)
    case Con{head, rest}: nx_json_function(head) ++ "," ++ nx_json_functions(rest)

@unsafe
def nx_json_program(+p: NxProgram) -> String:
  match p:
    case NxProgram{entry, fs}: "{\"version\":1,\"entry\":" ++ nx_quote(entry) ++ ",\"functions\":[" ++ nx_json_functions(fs) ++ "]}"
