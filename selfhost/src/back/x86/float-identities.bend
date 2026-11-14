# Rename only float definitions overwritten within the same closed region.
# A bounded suffix certificate guarantees the original destination is rewritten
# before any ordinary operation/control edge can observe it. No publication is
# removed at a boundary; final writes retain their original names and full words.
def x194fv_enabled() -> Bool: True{}

def x194fv_name(name: String) -> Bool:
  Bool.not(String.starts_with(name,"p194fv_"))

@unsafe
def x194fv_names(names: List<&2,String>) -> Bool:
  match names:
    case Nil{}: True{}
    case Con{name,rest}: x194fv_name(name) && x194fv_names(rest)

def x194fv_clean_value(value: N111Value) -> Bool:
  match value:
    case N111Local{name}: x194fv_name(name)
    case _: True{}

@unsafe
def x194fv_clean_values(values: List<&2,N111Value>) -> Bool:
  match values:
    case Nil{}: True{}
    case Con{value,rest}: x194fv_clean_value(value) && x194fv_clean_values(rest)

@unsafe
def x194fv_clean_args(args: List<&2,N111Arg>) -> Bool:
  match args:
    case Nil{}: True{}
    case Con{N111Arg{typ,value},rest}: x194fv_clean_value(value) && x194fv_clean_args(rest)

law x194fv_clean_body:
  for body: List<&2,P113DStmt>
  Bool

@unsafe
def x194fv_clean_scalar(stmt: N111Stmt) -> Bool:
  match stmt:
    case N111Set{name,typ,value}: x194fv_name(name) && x194fv_clean_value(value)
    case N111Bin{name,typ,op,left,right}: x194fv_name(name) && x194fv_clean_value(left) && x194fv_clean_value(right)
    case N111Load{name,typ,base,offset}: x194fv_name(name) && x194fv_clean_value(base)
    case N111Store{typ,base,offset,value}: x194fv_clean_value(base) && x194fv_clean_value(value)
    case N111Offset{name,base,bytes}: x194fv_name(name) && x194fv_clean_value(base) && x194fv_clean_value(bytes)
    case N111Alloca{name,bytes,align}: x194fv_name(name)
    case N111Call{name,typ,symbol,args}: x194fv_name(name) && x194fv_clean_args(args)
    case N111If{condition,yes,no}: x194fv_clean_value(condition) &&
      x194fv_clean_body(x181_scalar_rows(yes)) && x194fv_clean_body(x181_scalar_rows(no))
    case N111Return{value}: x194fv_clean_value(value)

@unsafe
def x194fv_clean_stmt(stmt: P113DStmt) -> Bool:
  match stmt:
    case P113DScalar{scalar}: x194fv_clean_scalar(scalar)
    case P113DIf{condition,yes,no}: x194fv_clean_value(condition) && x194fv_clean_body(yes) && x194fv_clean_body(no)
    case P113DCall{names,target,args}: x194fv_names(names) && x194fv_clean_values(args)
    case P113DResult{values}: x194fv_clean_values(values)
    case P113DAgain{values}: x194fv_clean_values(values)

@unsafe
def x194fv_clean_body(body):
  match body:
    case Nil{}: True{}
    case Con{stmt,rest}: x194fv_clean_stmt(stmt) && x194fv_clean_body(rest)

# All operands in an overwrite row still read the previous definition first.
# An ordinary U64 copy is safe even when its new value is noncanonical: its
# destination retains its original name, and that write kills the alias.
@unsafe
def x194fv_closed(body: List<&2,X186FloatNode>, +name: String, +fuel: U32) -> Bool:
  match body:
    case Con{X186FloatValues{+destination,id,left,right},rest}:
      nt_choose(Bool,U32.is_eq(fuel,0),u => False{},u =>
        nt_choose(Bool,String.eq(destination,name),v => True{},v => x194fv_closed(rest,name,U32.sub(fuel,1))))
    case Con{X186FloatPlain{P113DScalar{N111Set{+destination,N111U64{},value}}},rest}:
      nt_choose(Bool,U32.is_eq(fuel,0),u => False{},u =>
        nt_choose(Bool,String.eq(destination,name),v => True{},v => x194fv_closed(rest,name,U32.sub(fuel,1))))
    case _: False{}

@unsafe
def x194fv_value(+value: N111Value, aliases: KDef) -> N111Value:
  match value:
    case N111Local{name}:
      +entry = p111v_get(aliases,name)
      nt_choose(N111Value,String.eq(dk(entry),"Absent"),u => value,u => N111Local{dk(entry)})
    case _: value

law x194fv_walk:
  for body: List<&2,X186FloatNode>
  for +path: String
  for +position: U32
  for +aliases: KDef
  List<&2,X186FloatNode>

@unsafe
def x194fv_float(+name: String, id: U32, left: N111Value, right: N111Value,
    +rest: List<&2,X186FloatNode>, +path: String, +position: U32, +aliases: KDef) -> List<&2,X186FloatNode>:
  +chosen = nt_choose(String,Bool.not(x181_register_reserved(name)) && x194fv_closed(rest,name,32),
    u => "p194fv_" ++ path ++ U32.show(position),u => name)
  Con{X186FloatValues{chosen,id,x194fv_value(left,aliases),x194fv_value(right,aliases)},
    x194fv_walk(rest,path,U32.inc(position),p111v_put(aliases,name,
      nt_choose(String,String.eq(chosen,name),u => "Absent",u => chosen),0,0))}

@unsafe
def x194fv_walk(body,path,position,aliases):
  match body:
    case Nil{}: []
    case Con{X186FloatValues{name,id,left,right},rest}:
      x194fv_float(name,id,left,right,rest,path,position,aliases)
    case Con{X186FloatPlain{P113DScalar{N111Set{+name,N111U64{},value}}},rest}:
      Con{X186FloatPlain{P113DScalar{N111Set{name,N111U64{},x194fv_value(value,aliases)}}},
        x194fv_walk(rest,path,U32.inc(position),p111v_put(aliases,name,"Absent",0,0))}
    case Con{X186FloatBranch{condition,yes,no},rest}:
      Con{X186FloatBranch{condition,
        x194fv_walk(yes,path ++ U32.show(position) ++ "y_",0,missing()),
        x194fv_walk(no,path ++ U32.show(position) ++ "n_",0,missing())},
        x194fv_walk(rest,path,U32.inc(position),missing())}
    case Con{head,rest}: Con{head,x194fv_walk(rest,path,U32.inc(position),missing())}

@unsafe
def x194fv_when(enabled: Bool, params: List<&2,String>, +setup: List<&2,P113DStmt>,
    +nodes: List<&2,X186FloatNode>) -> List<&2,X186FloatNode>:
  +rows = x186_f_placement_rows(nodes)
  nt_choose(List<&2,X186FloatNode>,enabled &&
      U32.is_lt(p113i_add(p113i_size(setup),p113i_size(rows)),4096) &&
      x194fv_names(params) && x194fv_clean_body(setup) && x194fv_clean_body(rows),
    u => x194fv_walk(nodes,"",0,missing()),u => nodes)

@unsafe
def x194fv_nodes(params: List<&2,String>, setup: List<&2,P113DStmt>,
    nodes: List<&2,X186FloatNode>) -> List<&2,X186FloatNode>:
  x194fv_when(x194fv_enabled(),params,setup,nodes)

# Integration point is after float scratch pruning and before all placement.
@unsafe
def x194fv_place(symbol: String, +params: List<&2,String>, +setup: List<&2,P113DStmt>,
    nodes: List<&2,X186FloatNode>, ids: N111Ids) -> X181Output:
  x186_f_place(symbol,params,setup,x194fv_nodes(params,setup,nodes),ids)

@unsafe
def x186_float_function(+symbol: String, +params: List<&2,String>, +setup: List<&2,P113DStmt>,
    +body: List<&2,P113DStmt>, +ids: N111Ids) -> X181Output:
  nt_choose(X181Output,x186_float_values_enabled() && x185_float_enabled() &&
      U32.is_lt(p113i_add(p113i_size(setup),p113i_size(body)),4096),
    u => nt_choose(X181Output,x186_f_has_body(body),
      v => x194fv_place(symbol,params,setup,x186_f_ready(params,setup,
        x186_f_plan(body,x186_f_buffers(params,setup,body),[])),ids),
      v => x186_f_ordinary(symbol,params,setup,body,ids)),
    u => x186_f_ordinary(symbol,params,setup,body,ids))
