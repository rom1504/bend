# Namespace-only reuse of the mature inliner hygiene traversal. The new pass
# accepts already inlined p113i_ locals but reserves its own exact prefix.
@unsafe
def p120nr_name(+name: String) -> Bool:
  Bool.not(String.starts_with(name,"p120nr_"))

@unsafe
def p120nr_value(value: N111Value) -> Bool:
  match value:
    case N111Local{name}: p120nr_name(name)
    case _: True{}

@unsafe
def p120nr_values(values: List<&2,N111Value>) -> Bool:
  match values:
    case Nil{}: True{}
    case Con{head,rest}: p120nr_value(head) && p120nr_values(rest)

@unsafe
def p120nr_names(names: List<&2,String>) -> Bool:
  match names:
    case Nil{}: True{}
    case Con{head,rest}: p120nr_name(head) && p120nr_names(rest)

@unsafe
def p120nr_args(args: List<&2,N111Arg>) -> Bool:
  match args:
    case Nil{}: True{}
    case Con{N111Arg{typ,value},rest}: p120nr_value(value) && p120nr_args(rest)

@unsafe
def p120nr_scalar_clean(stmt: N111Stmt) -> Bool:
  match stmt:
    case N111Set{name,typ,value}: p120nr_name(name) && p120nr_value(value)
    case N111Bin{name,typ,op,left,right}: p120nr_name(name) && p120nr_value(left) && p120nr_value(right)
    case N111Call{name,typ,symbol,args}: p120nr_name(name) && p120nr_args(args)
    case N111If{condition,yes,no}: p120nr_value(condition) && p120nr_scalars_clean(yes) && p120nr_scalars_clean(no)
    case N111Load{name,typ,base,offset}: p120nr_name(name) && p120nr_value(base)
    case N111Store{typ,base,offset,value}: p120nr_value(base) && p120nr_value(value)
    case N111Offset{name,base,bytes}: p120nr_name(name) && p120nr_value(base) && p120nr_value(bytes)
    case N111Alloca{name,bytes,align}: p120nr_name(name)
    case _: False{}

@unsafe
def p120nr_scalars_clean(body: List<&2,N111Stmt>) -> Bool:
  match body:
    case Nil{}: True{}
    case Con{head,rest}: p120nr_scalar_clean(head) && p120nr_scalars_clean(rest)

@unsafe
def p120nr_clean(body: List<&2,P113DStmt>) -> Bool:
  match body:
    case Nil{}: True{}
    case Con{P113DScalar{stmt},rest}: p120nr_scalar_clean(stmt) && p120nr_clean(rest)
    case Con{P113DIf{condition,yes,no},rest}: p120nr_value(condition) && p120nr_clean(yes) && p120nr_clean(no) && p120nr_clean(rest)
    case Con{P113DCall{destinations,target,args},rest}: p120nr_names(destinations) && p120nr_values(args) && p120nr_clean(rest)
    case Con{P113DResult{values},rest}: p120nr_values(values) && p120nr_clean(rest)
    case Con{P113DAgain{values},rest}: p120nr_values(values) && p120nr_clean(rest)

@unsafe
def p120nr_params(params: List<&2,NC_Binding>) -> Bool:
  match params:
    case Nil{}: True{}
    case Con{NC_Binding{id,word,kind},rest}: p120nr_name(word) && p120nr_params(rest)

# Count nested scalar branches as real nodes. Saturation avoids wraparound and
# keeps budget arithmetic independent of malformed or very large input graphs.

