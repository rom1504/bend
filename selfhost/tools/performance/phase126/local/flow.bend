# Exact selected branch-local fact transfer. Only unchanged incoming facts
# survive joins; every generated word remains present.
@unsafe
def p126l_forget(names: List<&2,String>, +facts: List<&2,P114FLFact>) -> List<&2,P114FLFact>:
  match names:
    case Nil{}: facts
    case Con{name,rest}: p126l_forget(rest,p114fl_remove(facts,name))


@unsafe
def p126l_kill_scalar(stmt: N111Stmt, +facts: List<&2,P114FLFact>) -> List<&2,P114FLFact>:
  match stmt:
    case N111Set{name,typ,value}: p114fl_remove(facts,name)
    case N111Bin{name,typ,op,a,b}: p114fl_remove(facts,name)
    case N111Call{name,typ,symbol,args}: p114fl_remove(facts,name)
    case N111Load{name,typ,base,offset}: p114fl_remove(facts,name)
    case N111Offset{name,base,bytes}: p114fl_remove(facts,name)
    case N111Alloca{name,bytes,align}: p114fl_remove(facts,name)
    case N111If{condition,yes,no}: p126l_kill_scalars(no,p126l_kill_scalars(yes,facts))
    case _: facts


@unsafe
def p126l_kill_scalars(body: List<&2,N111Stmt>, facts: List<&2,P114FLFact>) -> List<&2,P114FLFact>:
  match body:
    case Nil{}: facts
    case Con{head,rest}: p126l_kill_scalars(rest,p126l_kill_scalar(head,facts))


@unsafe
def p126l_kill(body: List<&2,P113DStmt>, +facts: List<&2,P114FLFact>) -> List<&2,P114FLFact>:
  match body:
    case Nil{}: facts
    case Con{P113DScalar{scalar},rest}: p126l_kill(rest,p126l_kill_scalar(scalar,facts))
    case Con{P113DIf{condition,yes,no},rest}: p126l_kill(rest,p126l_kill(no,p126l_kill(yes,facts)))
    case Con{P113DCall{names,target,args},rest}: p126l_kill(rest,p126l_forget(names,facts))
    case Con{P113DAgain{values},rest}: []
    case Con{P113DResult{values},rest}: facts


@unsafe
def p126l_scalar_facts(stmt: N111Stmt, +facts: List<&2,P114FLFact>) -> List<&2,P114FLFact>:
  match stmt:
    case N111Set{name,N111U64{},N111Local{source}}: p114fl_copy(facts,name,source)
    case _: p126l_kill_scalar(stmt,facts)
