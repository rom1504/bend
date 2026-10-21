# Profit selection only; original p120nr_eligible is still mandatory.
# Count exact F32 add/sub/mul/div in the unconditional scalar prefix. Do not
# count conversions, comparisons, sqrt, or work below a branch/transfer.
@unsafe
def p120nr_arithmetic(stmt: N111Stmt) -> Bool:
  match stmt:
    case N111Call{name,N111U64{},symbol,[N111Arg{N111Ptr{},N111Local{state}},N111Arg{N111U32{},N111Const{id,0}},N111Arg{N111Ptr{},N111Local{buffer}},N111Arg{N111U32{},N111Const{2,0}}]}:
      String.eq(symbol,"p111_rt_op") && String.eq(state,"state") && U32.is_ge(id,26) && U32.is_le(id,29)
    case _: False{}

@unsafe
def p120nr_prefix_work(body: List<&2,P113DStmt>, +left: U32) -> Bool:
  match body left:
    case _ 0: True{}
    case Con{P113DScalar{stmt},rest} _:
      p120nr_prefix_work(rest,nt_choose(U32,p120nr_arithmetic(stmt),u => U32.dec(left),u => left))
    case _ _: False{}

@unsafe
def p120nr_profit(function: P113DFunction) -> Bool:
  match function:
    case P113DFunction{name,params,result,public,body}: p120nr_prefix_work(body,4)

@unsafe
def p120nr_table(functions: List<&2,P113DFunction>, +table: P113ITable) -> P113ITable:
  match functions:
    case Nil{}: table
    case Con{+head,rest}: p120nr_table(rest,p120nr_table_step(head,table,p120nr_eligible(head) && p120nr_profit(head)))
