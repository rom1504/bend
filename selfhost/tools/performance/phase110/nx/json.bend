# Canonical inspection format for the additive pair graph. This is not a new
# optimizer or executable consumer. Identifiers are verifier-restricted ASCII.
@unsafe
def nx110_json_names(+names: List<&2,String>) -> String:
  match names:
    case Nil{}: ""
    case Con{name,Nil{}}: nx_quote(name)
    case Con{name,rest}: nx_quote(name) ++ "," ++ nx110_json_names(rest)

@unsafe
def nx110_json_imports(+imports: List<&2,NxImport>) -> String:
  match imports:
    case Nil{}: ""
    case Con{NxImport{name,params,result},rest}:
      "{\"name\":" ++ nx_quote(name) ++ ",\"params\":[" ++ nx_json_params(params) ++ "],\"result\":" ++ nx_quote(nx_type_name(result)) ++ "}" ++
      nx_choose(String,nx110_json_imports_empty(rest),u => "",u => "," ++ nx110_json_imports(rest))

def nx110_json_imports_empty(imports: List<&2,NxImport>) -> Bool:
  match imports:
    case Nil{}: True{}
    case _: False{}

@unsafe
def nx110_json_scalar_library(+library: NxLibrary) -> String:
  match library:
    case NxLibrary{imports,functions,exports}:
      "{\"kind\":\"nx-library\",\"imports\":[" ++ nx110_json_imports(imports) ++ "],\"functions\":[" ++ nx_json_functions(functions) ++ "],\"exports\":[" ++ nx110_json_names(exports) ++ "]}"

@unsafe
def nx110_json_stmt(+stmt: Nx110Stmt) -> String:
  match stmt:
    case Nx110Scalar{base}: nx_json_stmt(base)
    case Nx110If{condition,yes,no}: "{\"kind\":\"if\",\"cond\":" ++ nx_json_expr(condition) ++ ",\"then\":[" ++ nx110_json_stmts(yes) ++ "],\"else\":[" ++ nx110_json_stmts(no) ++ "]}"
    case Nx110While{condition,body}: "{\"kind\":\"while\",\"cond\":" ++ nx_json_expr(condition) ++ ",\"body\":[" ++ nx110_json_stmts(body) ++ "]}"
    case Nx110CallPair{first,second,name,args}: "{\"kind\":\"call-pair\",\"first\":" ++ nx_quote(first) ++ ",\"second\":" ++ nx_quote(second) ++ ",\"name\":" ++ nx_quote(name) ++ ",\"args\":[" ++ nx_json_args(args) ++ "]}"

@unsafe
def nx110_json_stmts(+body: List<&2,Nx110Stmt>) -> String:
  match body:
    case Nil{}: ""
    case Con{head,Nil{}}: nx110_json_stmt(head)
    case Con{head,rest}: nx110_json_stmt(head) ++ "," ++ nx110_json_stmts(rest)

@unsafe
def nx110_json_function(+function: Nx110Function) -> String:
  match function:
    case Nx110Function{name,params,result,locals,body}:
      "{\"name\":" ++ nx_quote(name) ++ ",\"params\":[" ++ nx_json_params(params) ++ "],\"result\":" ++ nx_quote(nx_type_name(result)) ++ ",\"locals\":[" ++ nx_json_params(locals) ++ "],\"body\":[" ++ nx110_json_stmts(body) ++ "]}"

@unsafe
def nx110_json_functions(+functions: List<&2,Nx110Function>) -> String:
  match functions:
    case Nil{}: ""
    case Con{head,Nil{}}: nx110_json_function(head)
    case Con{head,rest}: nx110_json_function(head) ++ "," ++ nx110_json_functions(rest)

@unsafe
def nx110_json_pair(+pair: Nx110ImportPair) -> String:
  match pair:
    case Nx110ImportPair{name,params,first,second}:
      "{\"name\":" ++ nx_quote(name) ++ ",\"params\":[" ++ nx_json_params(params) ++ "],\"results\":[" ++ nx_quote(nx_type_name(first)) ++ "," ++ nx_quote(nx_type_name(second)) ++ "]}"

@unsafe
def nx110_json_pairs(+pairs: List<&2,Nx110ImportPair>) -> String:
  match pairs:
    case Nil{}: ""
    case Con{head,Nil{}}: nx110_json_pair(head)
    case Con{head,rest}: nx110_json_pair(head) ++ "," ++ nx110_json_pairs(rest)

@unsafe
def nx110_json_library(+library: Nx110Library) -> String:
  match library:
    case Nx110Library{imports,pairs,functions,exports}:
      "{\"kind\":\"nx110-library\",\"imports\":[" ++ nx110_json_imports(imports) ++ "],\"pairs\":[" ++ nx110_json_pairs(pairs) ++ "],\"functions\":[" ++ nx110_json_functions(functions) ++ "],\"exports\":[" ++ nx110_json_names(exports) ++ "]}"
