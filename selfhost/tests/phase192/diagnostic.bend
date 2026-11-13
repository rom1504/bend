# Diagnostic-only replacement at the actual post-scalar/pre-selection boundary.
# Each function emits one typed PError containing JSON, with outer error empty.
# Extract PError.error as data. NEVER render/assemble/link this diagnostic route.
# Arrays preserve constructor identity, field order, widths and constant words.
@unsafe
def p192d_join(parts: List<&2,String>, +separator: String) -> String:
  match parts:
    case Nil{}: ""
    case Con{head,Nil{}}: head
    case Con{head,rest}: head ++ separator ++ p192d_join(rest,separator)

@unsafe
def p192d_names(names: List<&2,String>) -> List<&2,String>:
  match names:
    case Nil{}: []
    case Con{head,rest}: Con{sk_quote(head),p192d_names(rest)}

def p192d_type(typ: N111Type) -> String:
  match typ:
    case N111U32{}: "\"N111U32\""
    case N111U64{}: "\"N111U64\""
    case N111Ptr{}: "\"N111Ptr\""

@unsafe
def p192d_value(value: N111Value) -> String:
  match value:
    case N111Local{name}: "[\"N111Local\"," ++ sk_quote(name) ++ "]"
    case N111Const{lo,hi}: "[\"N111Const\"," ++ U32.show(lo) ++ "," ++ U32.show(hi) ++ "]"
    case N111Symbol{name}: "[\"N111Symbol\"," ++ sk_quote(name) ++ "]"
    case N111FuncId{name}: "[\"N111FuncId\"," ++ sk_quote(name) ++ "]"
    case N111CtorId{name}: "[\"N111CtorId\"," ++ sk_quote(name) ++ "]"

@unsafe
def p192d_values(values: List<&2,N111Value>) -> List<&2,String>:
  match values:
    case Nil{}: []
    case Con{head,rest}: Con{p192d_value(head),p192d_values(rest)}

@unsafe
def p192d_args(args: List<&2,N111Arg>) -> List<&2,String>:
  match args:
    case Nil{}: []
    case Con{N111Arg{typ,value},rest}:
      Con{"[\"N111Arg\"," ++ p192d_type(typ) ++ "," ++ p192d_value(value) ++ "]",p192d_args(rest)}

law p192d_scalars:
  for body: List<&2,N111Stmt>
  List<&2,String>

@unsafe
def p192d_scalar(stmt: N111Stmt) -> String:
  match stmt:
    case N111Set{name,typ,value}:
      "[\"N111Set\"," ++ sk_quote(name) ++ "," ++ p192d_type(typ) ++ "," ++ p192d_value(value) ++ "]"
    case N111Bin{name,typ,op,left,right}:
      "[\"N111Bin\"," ++ sk_quote(name) ++ "," ++ p192d_type(typ) ++ "," ++ sk_quote(op) ++ "," ++ p192d_value(left) ++ "," ++ p192d_value(right) ++ "]"
    case N111Call{name,typ,symbol,args}:
      "[\"N111Call\"," ++ sk_quote(name) ++ "," ++ p192d_type(typ) ++ "," ++ sk_quote(symbol) ++ ",[" ++ p192d_join(p192d_args(args),",") ++ "]]"
    case N111If{condition,yes,no}:
      "[\"N111If\"," ++ p192d_value(condition) ++ ",[" ++ p192d_join(p192d_scalars(yes),",") ++ "],[" ++ p192d_join(p192d_scalars(no),",") ++ "]]"
    case N111Return{value}: "[\"N111Return\"," ++ p192d_value(value) ++ "]"
    case N111Load{name,typ,base,offset}:
      "[\"N111Load\"," ++ sk_quote(name) ++ "," ++ p192d_type(typ) ++ "," ++ p192d_value(base) ++ "," ++ U32.show(offset) ++ "]"
    case N111Store{typ,base,offset,value}:
      "[\"N111Store\"," ++ p192d_type(typ) ++ "," ++ p192d_value(base) ++ "," ++ U32.show(offset) ++ "," ++ p192d_value(value) ++ "]"
    case N111Offset{name,base,bytes}:
      "[\"N111Offset\"," ++ sk_quote(name) ++ "," ++ p192d_value(base) ++ "," ++ p192d_value(bytes) ++ "]"
    case N111Alloca{name,bytes,align}:
      "[\"N111Alloca\"," ++ sk_quote(name) ++ "," ++ U32.show(bytes) ++ "," ++ U32.show(align) ++ "]"

@unsafe
def p192d_scalars(body):
  match body:
    case Nil{}: []
    case Con{head,rest}: Con{p192d_scalar(head),p192d_scalars(rest)}

law p192d_body:
  for body: List<&2,P113DStmt>
  List<&2,String>

@unsafe
def p192d_stmt(stmt: P113DStmt) -> String:
  match stmt:
    case P113DScalar{scalar}: "[\"P113DScalar\"," ++ p192d_scalar(scalar) ++ "]"
    case P113DIf{condition,yes,no}:
      "[\"P113DIf\"," ++ p192d_value(condition) ++ ",[" ++ p192d_join(p192d_body(yes),",") ++ "],[" ++ p192d_join(p192d_body(no),",") ++ "]]"
    case P113DCall{destinations,target,args}:
      "[\"P113DCall\",[" ++ p192d_join(p192d_names(destinations),",") ++ "]," ++ sk_quote(target) ++ ",[" ++ p192d_join(p192d_values(args),",") ++ "]]"
    case P113DResult{values}: "[\"P113DResult\",[" ++ p192d_join(p192d_values(values),",") ++ "]]"
    case P113DAgain{values}: "[\"P113DAgain\",[" ++ p192d_join(p192d_values(values),",") ++ "]]"

@unsafe
def p192d_body(body):
  match body:
    case Nil{}: []
    case Con{head,rest}: Con{p192d_stmt(head),p192d_body(rest)}

@unsafe
def x185_function_copied(+symbol: String, +params: List<&2,String>, +setup: List<&2,P113DStmt>,
    +body: List<&2,P113DStmt>, +ids: N111Ids) -> X181Output:
  X181Output{[X188One{PError{"{\"kind\":\"phase192-preselection-ir\",\"version\":1,\"symbol\":" ++ sk_quote(symbol) ++
    ",\"params\":[" ++ p192d_join(p192d_names(params),",") ++ "],\"setup\":[" ++ p192d_join(p192d_body(setup),",") ++
    "],\"body\":[" ++ p192d_join(p192d_body(body),",") ++ "]}"}}],""}
