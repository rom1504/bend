# Phase156 dense transfer preflight only. This does not optimize any function.
# A nonzero flag rejects the proposed narrow straight-line scalar subset:
# bit1 branches, bit2 predicate-producing comparison, bit4 nonlocal numeric ID,
# bit8 original 4096-statement scalar cutoff. Named spellings still need a paid
# exact dictionary; zero flags do not qualify a dense implementation.
type P156DenseAudit is Data:
  P156DenseAudit{+flags: U32, +statements: U32, +branches: U32, +comparisons: U32, +binders: U32, +named: U32, +maxSlot: U32}

def p156d_zero() -> P156DenseAudit:
  P156DenseAudit{0,0,0,0,0,0,0}

@unsafe
def p156d_add(left: P156DenseAudit, right: P156DenseAudit) -> P156DenseAudit:
  match left right:
    case P156DenseAudit{af,astmts,ab,ac,ai,an,am} P156DenseAudit{bf,bstmts,bb,bc,bi,bn,bm}:
      P156DenseAudit{U32.or(af,bf),p113i_add(astmts,bstmts),p113i_add(ab,bb),p113i_add(ac,bc),p113i_add(ai,bi),p113i_add(an,bn),U32.max(am,bm)}

@unsafe
def p156d_name(name: P154Name) -> P156DenseAudit:
  match name:
    case P154Binder{+id}:
      nt_choose(P156DenseAudit,U32.is_ge(id,4294963200),u => P156DenseAudit{0,0,0,0,1,0,U32.inc(U32.sub(4294967295,id))},u => P156DenseAudit{4,0,0,0,1,0,0})
    case P154Named{text}: P156DenseAudit{0,0,0,0,0,1,0}

@unsafe
def p156d_names(names: List<&2,P154Name>) -> P156DenseAudit:
  match names:
    case Nil{}: p156d_zero()
    case Con{name,rest}: p156d_add(p156d_name(name),p156d_names(rest))

@unsafe
def p156d_value(value: P154Value) -> P156DenseAudit:
  match value:
    case P154Local{name}: p156d_name(name)
    case _: p156d_zero()

@unsafe
def p156d_values(values: List<&2,P154Value>) -> P156DenseAudit:
  match values:
    case Nil{}: p156d_zero()
    case Con{value,rest}: p156d_add(p156d_value(value),p156d_values(rest))

@unsafe
def p156d_args(args: List<&2,P154Arg>) -> P156DenseAudit:
  match args:
    case Nil{}: p156d_zero()
    case Con{P154Arg{typ,value},rest}: p156d_add(p156d_value(value),p156d_args(rest))

@unsafe
def p156d_comparison(op: String) -> P156DenseAudit:
  nt_choose(P156DenseAudit,p111v_comparison(op),u => P156DenseAudit{2,0,0,1,0,0,0},u => p156d_zero())

@unsafe
def p156d_scalar_fields(stmt: P154Stmt) -> P156DenseAudit:
  match stmt:
    case P154Set{name,typ,value}: p156d_add(p156d_name(name),p156d_value(value))
    case P154Bin{name,typ,op,left,right}: p156d_add(p156d_comparison(op),p156d_add(p156d_name(name),p156d_add(p156d_value(left),p156d_value(right))))
    case P154Call{name,typ,symbol,args}: p156d_add(p156d_name(name),p156d_args(args))
    case P154If{condition,yes,no}: p156d_add(P156DenseAudit{1,0,1,0,0,0,0},p156d_add(p156d_value(condition),p156d_add(p156d_scalars(yes),p156d_scalars(no))))
    case P154Return{value}: p156d_value(value)
    case P154Load{name,typ,base,offset}: p156d_add(p156d_name(name),p156d_value(base))
    case P154Store{typ,base,offset,value}: p156d_add(p156d_value(base),p156d_value(value))
    case P154Offset{name,base,bytes}: p156d_add(p156d_name(name),p156d_add(p156d_value(base),p156d_value(bytes)))
    case P154Alloca{name,bytes,align}: p156d_name(name)

@unsafe
def p156d_scalar(stmt: P154Stmt) -> P156DenseAudit:
  p156d_add(P156DenseAudit{0,1,0,0,0,0,0},p156d_scalar_fields(stmt))

@unsafe
def p156d_scalars(body: List<&2,P154Stmt>) -> P156DenseAudit:
  match body:
    case Nil{}: p156d_zero()
    case Con{stmt,rest}: p156d_add(p156d_scalar(stmt),p156d_scalars(rest))

@unsafe
def p156d_stmt(stmt: P154DStmt) -> P156DenseAudit:
  match stmt:
    case P154DScalar{scalar}: p156d_scalar(scalar)
    case P154DIf{condition,yes,no}: p156d_add(P156DenseAudit{1,1,1,0,0,0,0},p156d_add(p156d_value(condition),p156d_add(p156d_body(yes),p156d_body(no))))
    case P154DCall{names,target,args}: p156d_add(P156DenseAudit{0,1,0,0,0,0,0},p156d_add(p156d_names(names),p156d_values(args)))
    case P154DResult{values}: p156d_add(P156DenseAudit{0,1,0,0,0,0,0},p156d_values(values))
    case P154DAgain{values}: p156d_add(P156DenseAudit{0,1,0,0,0,0,0},p156d_values(values))

@unsafe
def p156d_body(body: List<&2,P154DStmt>) -> P156DenseAudit:
  match body:
    case Nil{}: p156d_zero()
    case Con{stmt,rest}: p156d_add(p156d_stmt(stmt),p156d_body(rest))

@unsafe
def p156d_finish(audit: P156DenseAudit) -> String:
  match audit:
    case P156DenseAudit{+flags,+statements,branches,comparisons,binders,named,maxSlot}:
      U32.show(U32.or(flags,nt_choose(U32,U32.is_ge(statements,4096),u => 8,u => 0))) ++ ":" ++ U32.show(statements) ++ ":" ++ U32.show(branches) ++ ":" ++ U32.show(comparisons) ++ ":" ++ U32.show(binders) ++ ":" ++ U32.show(named) ++ ":" ++ U32.show(maxSlot)

@unsafe
def p156d_eligibility(function: P154DFunction) -> String:
  match function:
    case P154DFunction{name,params,result,public,body}: p156d_finish(p156d_body(body))
