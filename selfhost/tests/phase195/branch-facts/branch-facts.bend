# Incoming scalar facts only. Original Set snapshots and all effects stay.
# The existing <=512-row x190_local_values_body gate bounds this experiment.
# Join analysis kills facts for writes in either original arm; it never adds a
# fact learned inside an arm. Calls and terminal/backedge operations clear all.
def x195bf_enabled() -> Bool: True{}

law x195bf_kill_body:
  for body: List<&2,P113DStmt>
  for state: X190Values
  X190Values

@unsafe
def x195bf_kill_scalar(stmt: N111Stmt, state: X190Values) -> X190Values:
  match stmt:
    case N111Set{name,typ,value}: x190_v_written(name,False{},state)
    case N111Bin{name,typ,op,left,right}: x190_v_written(name,False{},state)
    case N111Offset{name,base,bytes}: x190_v_written(name,False{},state)
    case N111Load{name,typ,base,offset}: x190_v_written(name,False{},state)
    case N111Alloca{name,bytes,align}: x190_v_written(name,False{},state)
    case N111Store{typ,base,offset,value}: state
    case N111If{condition,yes,no}:
      x195bf_kill_body(x181_scalar_rows(no),x195bf_kill_body(x181_scalar_rows(yes),state))
    case _: x190_v_empty()

@unsafe
def x195bf_kill_stmt(stmt: P113DStmt, state: X190Values) -> X190Values:
  match stmt:
    case P113DScalar{scalar}: x195bf_kill_scalar(scalar,state)
    case P113DIf{condition,yes,no}: x195bf_kill_body(no,x195bf_kill_body(yes,state))
    case _: x190_v_empty()

@unsafe
def x195bf_kill_body(body,state):
  match body:
    case Nil{}: state
    case Con{head,rest}: x195bf_kill_body(rest,x195bf_kill_stmt(head,state))

@unsafe
def x195bf_join(yes: List<&2,P113DStmt>, no: List<&2,P113DStmt>, state: X190Values) -> X190Values:
  x195bf_kill_body(no,x195bf_kill_body(yes,state))

@unsafe
def x195bf_if(condition: N111Value, +yes: List<&2,P113DStmt>, +no: List<&2,P113DStmt>,
    rest: List<&2,P113DStmt>, +state: X190Values) -> List<&2,P113DStmt>:
  nt_choose(List<&2,P113DStmt>,x195bf_enabled(),
    u => Con{P113DIf{condition,x190_v_body(yes,state),x190_v_body(no,state)},
      x190_v_body(rest,x195bf_join(yes,no,state))},
    u => x190_v_if(condition,yes,no,rest))
