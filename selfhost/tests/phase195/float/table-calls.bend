# Consume the original canonical total-word table certificate, before allocation.
# This is a transport of p126s_cells/p126i_catalogue, not a new evaluator.
def x195t_enabled() -> Bool: True{}

def x195t_name(name: String) -> Bool:
  Bool.not(String.starts_with(name,"p195t_"))

@unsafe
def x195t_names(names: List<&2,String>) -> Bool:
  match names:
    case Nil{}: True{}
    case Con{name,rest}: x195t_name(name) && x195t_names(rest)

def x195t_clean_value(value: N111Value) -> Bool:
  match value:
    case N111Local{name}: x195t_name(name)
    case _: True{}

@unsafe
def x195t_clean_values(values: List<&2,N111Value>) -> Bool:
  match values:
    case Nil{}: True{}
    case Con{value,rest}: x195t_clean_value(value) && x195t_clean_values(rest)

@unsafe
def x195t_clean_args(args: List<&2,N111Arg>) -> Bool:
  match args:
    case Nil{}: True{}
    case Con{N111Arg{typ,value},rest}: x195t_clean_value(value) && x195t_clean_args(rest)

law x195t_clean_body:
  for body: List<&2,P113DStmt>
  Bool

@unsafe
def x195t_clean_scalar(stmt: N111Stmt) -> Bool:
  match stmt:
    case N111Set{name,typ,value}: x195t_name(name) && x195t_clean_value(value)
    case N111Bin{name,typ,op,left,right}: x195t_name(name) && x195t_clean_value(left) && x195t_clean_value(right)
    case N111Load{name,typ,base,offset}: x195t_name(name) && x195t_clean_value(base)
    case N111Store{typ,base,offset,value}: x195t_clean_value(base) && x195t_clean_value(value)
    case N111Offset{name,base,bytes}: x195t_name(name) && x195t_clean_value(base) && x195t_clean_value(bytes)
    case N111Alloca{name,bytes,align}: x195t_name(name)
    case N111Call{name,typ,symbol,args}: x195t_name(name) && x195t_clean_args(args)
    case N111If{condition,yes,no}: x195t_clean_value(condition) &&
      x195t_clean_body(x181_scalar_rows(yes)) && x195t_clean_body(x181_scalar_rows(no))
    case N111Return{value}: x195t_clean_value(value)

@unsafe
def x195t_clean_stmt(stmt: P113DStmt) -> Bool:
  match stmt:
    case P113DScalar{scalar}: x195t_clean_scalar(scalar)
    case P113DIf{condition,yes,no}: x195t_clean_value(condition) && x195t_clean_body(yes) && x195t_clean_body(no)
    case P113DCall{names,target,args}: x195t_names(names) && x195t_clean_values(args)
    case P113DResult{values}: x195t_clean_values(values)
    case P113DAgain{values}: x195t_clean_values(values)

@unsafe
def x195t_clean_body(body):
  match body:
    case Nil{}: True{}
    case Con{stmt,rest}: x195t_clean_stmt(stmt) && x195t_clean_body(rest)

# Reuse four private locals for each completed lookup. Prefix admission proves
# none can alias an original parameter, definition or read-only local.
@unsafe
def x195t_load(name: String, target: String, +value: N111Value, +last: U32) -> List<&2,P113DStmt>:
  [P113DScalar{N111Bin{"p195t_inside",N111U64{},"ult",value,N111Const{last,0}}},
   P113DIf{N111Local{"p195t_inside"},
     [P113DScalar{N111Set{"p195t_index",N111U64{},value}}],
     [P113DScalar{N111Set{"p195t_index",N111U64{},N111Const{last,0}}}]},
   P113DScalar{N111Bin{"p195t_bytes",N111U64{},"shl",N111Local{"p195t_index"},N111Const{3,0}}},
   P113DScalar{N111Offset{"p195t_address",N111Symbol{p126i_table_name(target)},N111Local{"p195t_bytes"}}},
   P113DScalar{N111Load{name,N111U64{},N111Local{"p195t_address"},0}}]

@unsafe
def x195t_found(+stmt: P113DStmt, name: String, target: String, value: N111Value,
    found: Maybe<&2,U32>) -> List<&2,P113DStmt>:
  match found:
    case Some{+last}: nt_choose(List<&2,P113DStmt>,U32.is_ge(last,3) && U32.is_lt(last,64),
      u => x195t_load(name,target,value,last),u => [stmt])
    case None{}: [stmt]

law x195t_body:
  for body: List<&2,P113DStmt>
  for +tables: List<&2,P126ITable>
  List<&2,P113DStmt>

@unsafe
def x195t_stmt(+stmt: P113DStmt, +tables: List<&2,P126ITable>) -> List<&2,P113DStmt>:
  match stmt:
    case P113DCall{[name],+target,[value]}:
      x195t_found(stmt,name,target,value,p126i_lookup(tables,target))
    case P113DIf{condition,yes,no}: [P113DIf{condition,x195t_body(yes,tables),x195t_body(no,tables)}]
    case _: [stmt]

@unsafe
def x195t_body(body,tables):
  match body:
    case Nil{}: []
    case Con{head,rest}: nt_append(P113DStmt,x195t_stmt(head,tables),x195t_body(rest,tables))

@unsafe
def x195t_when(enabled: Bool, +function: P113DFunction, +tables: List<&2,P126ITable>) -> P113DFunction:
  match function:
    case P113DFunction{name,+params,result,public,+body}:
      nt_choose(P113DFunction,enabled && U32.is_lt(p113i_size(body),4096) &&
          x195t_names(x181_param_names(params)) && x195t_clean_body(body) && p126i_calls(body,tables),
        u => P113DFunction{name,params,result,public,x195t_body(body,tables)},u => function)

# Each canonical table function still emits its original entry/forwarder. The
# extra readonly data exactly matches p126s_render and is emitted once here.
@unsafe
def x195t_data_values(name: String, +last: U32, cells: Maybe<&2,List<&2,U32>>, available: KDef) -> X181Output:
  match cells:
    case Some{+values}:
      nt_choose(X181Output,U32.is_ge(last,3) && U32.is_lt(last,64) && U32.is_eq(nt_count(U32,values),U32.inc(last)),
        u => x181_program_data(P111QData{p126i_table_name(name),8,False{},p126s_data(values)},available),
        u => X181Output{[],"x195 table catalogue length mismatch"})
    case None{}: X181Output{[],"x195 table catalogue shape mismatch"}

@unsafe
def x195t_data_found(function: P113DFunction, found: Maybe<&2,U32>, available: KDef) -> X181Output:
  match found function:
    case None{} _: X181Output{[],""}
    case Some{last} P113DFunction{name,[NC_Binding{id,+word,kind}],result,public,body}:
      nt_choose(X181Output,U32.is_eq(result,1),
        u => x195t_data_values(name,last,p126s_cells(word,body,0),available),
        u => X181Output{[],"x195 table catalogue result mismatch"})
    case _ _: X181Output{[],"x195 table catalogue parameters mismatch"}

@unsafe
def x195t_data(+function: P113DFunction, tables: List<&2,P126ITable>, available: KDef) -> X181Output:
  match function:
    case P113DFunction{name,params,result,public,body}:
      x195t_data_found(function,p126i_lookup(tables,name),available)
