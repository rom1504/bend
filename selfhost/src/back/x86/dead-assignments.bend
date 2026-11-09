# Backward word liveness after existing facts. Only pure Set/Bin/Offset rows
# may disappear. Loads, calls, stores, allocas and control flow stay ordered.
# Setup is untouched; every setup-defined name remains live across Again.
type X185Dead is Data:
  X185Dead{+body: List<&2,P113DStmt>, +live: KDef}

def x185_dead_enabled() -> Bool: True{}

@unsafe
def x185_d_mark(live: KDef, name: String) -> KDef:
  p111v_put(live,name,"X185Live",1,0)

@unsafe
def x185_d_kill(live: KDef, name: String) -> KDef:
  p111v_put(live,name,"X185Live",0,0)

@unsafe
def x185_d_names(names: List<&2,String>, live: KDef) -> KDef:
  match names:
    case Nil{}: live
    case Con{name,rest}: x185_d_names(rest,x185_d_mark(live,name))

@unsafe
def x185_d_kills(names: List<&2,String>, live: KDef) -> KDef:
  match names:
    case Nil{}: live
    case Con{name,rest}: x185_d_kills(rest,x185_d_kill(live,name))

@unsafe
def x185_d_value(value: N111Value, live: KDef) -> KDef:
  match value:
    case N111Local{name}: x185_d_mark(live,name)
    case _: live

@unsafe
def x185_d_values(values: List<&2,N111Value>, live: KDef) -> KDef:
  match values:
    case Nil{}: live
    case Con{head,rest}: x185_d_values(rest,x185_d_value(head,live))

@unsafe
def x185_d_args(args: List<&2,N111Arg>, live: KDef) -> KDef:
  match args:
    case Nil{}: live
    case Con{N111Arg{typ,value},rest}: x185_d_args(rest,x185_d_value(value,live))

@unsafe
def x185_d_union_bucket(bucket: List<&2,KDef>, +out: KDef) -> KDef:
  match bucket:
    case Nil{}: out
    case Con{+head,rest}:
      x185_d_union_bucket(rest,nt_choose(KDef,U32.is_gt(da(head),0),u => x185_d_mark(out,dn(head)),u => out))

@unsafe
def x185_d_union(left: KDef, out: KDef) -> KDef:
  match left:
    case KIndexLeaf{hash,bucket}: x185_d_union_bucket(bucket,out)
    case KIndexNode{hash,mask,a,b}: x185_d_union(b,x185_d_union(a,out))
    case _: out

# Implicit machine inputs have reserved names and their definitions are never
# removed, even when the semantic row does not expose its ABI buffer operand.
@unsafe
def x185_d_base() -> KDef:
  x185_d_names(["state","scratch","__x181_result_out","__x181_results","__x181_tail"],missing())

@unsafe
def x185_d_pure(stmt: N111Stmt, +name: String, reads: List<&2,N111Value>, +after: X185Dead) -> X185Dead:
  match after:
    case X185Dead{body,+live}:
      nt_choose(X185Dead,U32.is_gt(da(p111v_get(live,name)),0) || x181_register_reserved(name),
        u => X185Dead{Con{P113DScalar{stmt},body},x185_d_values(reads,x185_d_kill(live,name))},
        u => after)

law x185_d_body:
  for body: List<&2,P113DStmt>
  for live: KDef
  for +again: KDef
  for +terminal: KDef
  X185Dead

@unsafe
def x185_d_if(condition: N111Value, yes: List<&2,P113DStmt>, no: List<&2,P113DStmt>,
    after: X185Dead, +again: KDef, +terminal: KDef) -> X185Dead:
  match after:
    case X185Dead{body,+live}:
      x185_d_if_done(condition,body,x185_d_body(yes,live,again,terminal),x185_d_body(no,live,again,terminal))

@unsafe
def x185_d_if_done(+condition: N111Value, rest: List<&2,P113DStmt>, yes: X185Dead, no: X185Dead) -> X185Dead:
  match yes no:
    case X185Dead{yb,yl} X185Dead{nb,nl}:
      X185Dead{Con{P113DIf{condition,yb,nb},rest},x185_d_value(condition,x185_d_union(yl,nl))}

@unsafe
def x185_d_scalar(+stmt: N111Stmt, after: X185Dead, +again: KDef, +terminal: KDef) -> X185Dead:
  match stmt after:
    case N111Set{+name,typ,value} _: x185_d_pure(stmt,name,[value],after)
    case N111Bin{+name,typ,op,left,right} _: x185_d_pure(stmt,name,[left,right],after)
    case N111Offset{+name,base,bytes} _: x185_d_pure(stmt,name,[base,bytes],after)
    case N111Call{+name,typ,symbol,args} X185Dead{body,live}:
      X185Dead{Con{P113DScalar{stmt},body},x185_d_args(args,x185_d_kill(live,name))}
    case N111Load{+name,typ,base,offset} X185Dead{body,live}:
      X185Dead{Con{P113DScalar{stmt},body},x185_d_value(base,x185_d_kill(live,name))}
    case N111Store{typ,base,offset,value} X185Dead{body,live}:
      X185Dead{Con{P113DScalar{stmt},body},x185_d_value(value,x185_d_value(base,live))}
    case N111Alloca{name,bytes,align} X185Dead{body,live}:
      X185Dead{Con{P113DScalar{stmt},body},x185_d_kill(live,name)}
    case N111If{condition,yes,no} _:
      x185_d_if(condition,x181_scalar_rows(yes),x181_scalar_rows(no),after,again,terminal)
    case N111Return{value} X185Dead{body,live}:
      X185Dead{Con{P113DScalar{stmt},body},x185_d_value(value,terminal)}

@unsafe
def x185_d_stmt(+stmt: P113DStmt, after: X185Dead, +again: KDef, +terminal: KDef) -> X185Dead:
  match stmt after:
    case P113DScalar{scalar} _: x185_d_scalar(scalar,after,again,terminal)
    case P113DIf{condition,yes,no} _: x185_d_if(condition,yes,no,after,again,terminal)
    case P113DCall{names,target,args} X185Dead{body,live}:
      X185Dead{Con{stmt,body},x185_d_values(args,x185_d_kills(names,live))}
    case P113DResult{values} X185Dead{body,live}:
      X185Dead{Con{stmt,body},x185_d_values(values,terminal)}
    case P113DAgain{values} X185Dead{body,live}:
      X185Dead{Con{stmt,body},x185_d_values(values,again)}

@unsafe
def x185_d_body(body,live,again,terminal):
  match body:
    case Nil{}: X185Dead{[],live}
    case Con{head,rest}: x185_d_stmt(head,x185_d_body(rest,live,again,terminal),again,terminal)

def x185_d_result(scan: X185Dead) -> List<&2,P113DStmt>:
  match scan:
    case X185Dead{body,live}: body

@unsafe
def x185_dead_body(setup,body):
  nt_choose(List<&2,P113DStmt>,x185_dead_enabled() &&
      U32.is_lt(p113i_add(p113i_size(setup),p113i_size(body)),4096),
    u => x185_d_result(x185_d_body(body,x185_d_base(),
      x185_d_union(x185_copy_writes(setup,missing()),x185_d_base()),x185_d_base())),u => body)
