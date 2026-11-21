# A private symbol exists only for a defined pair worker with multiple syntactic
# callers, two-result exits, and no scalar return or versionable array operation.
# Its original public pointer-return worker remains available.
@unsafe
def x198pr_symbol(name: String) -> String:
  "p198r_" ++ p113e_symbol(name)

@unsafe
def x198pr_record(+key: String, +call: Bool, +definition: Bool, +index: KDef) -> KDef:
  +old = p111v_get(index,key)
  p111v_put(index,key,"X198Pair",U32.min(2,U32.add(da(old),nt_choose(U32,call,u => 1,u => 0))),
    nt_choose(U32,definition,u => 1,u => dx(old)))

@unsafe
def x198pr_scalar_safe(stmt: N111Stmt) -> Bool:
  match stmt:
    case N111Return{v}: False{}
    case N111If{condition,yes,no}: x198pr_scalars_safe(yes) && x198pr_scalars_safe(no)
    case _: True{}

@unsafe
def x198pr_scalars_safe(body: List<&2,N111Stmt>) -> Bool:
  match body:
    case Nil{}: True{}
    case Con{head,rest}: x198pr_scalar_safe(head) && x198pr_scalars_safe(rest)

@unsafe
def x198pr_safe(body: List<&2,P113DStmt>) -> Bool:
  match body:
    case Nil{}: True{}
    case Con{P113DIf{condition,yes,no},rest}: x198pr_safe(yes) && x198pr_safe(no) && x198pr_safe(rest)
    case Con{P113DScalar{stmt},rest}: x198pr_scalar_safe(stmt) && x198pr_safe(rest)
    case Con{P113DResult{Con{a,Con{b,Nil{}}}},rest}: x198pr_safe(rest)
    case Con{P113DResult{values},rest}: False{}
    case Con{stmt,rest}: x198pr_safe(rest)

@unsafe
def x198pr_calls(body: List<&2,P113DStmt>, index: KDef) -> KDef:
  match body:
    case Nil{}: index
    case Con{P113DIf{condition,yes,no},rest}: x198pr_calls(rest,x198pr_calls(no,x198pr_calls(yes,index)))
    case Con{P113DCall{Con{first,Con{second,Nil{}}},target,args},rest}:
      x198pr_calls(rest,x198pr_record(x198pr_symbol(target),True{},False{},index))
    case Con{stmt,rest}: x198pr_calls(rest,index)

@unsafe
def x198pr_selected(index: KDef, name: String) -> Bool:
  +entry = p111v_get(index,x198pr_symbol(name))
  String.eq(dk(entry),"X198Pair") && U32.is_eq(da(entry),2) && U32.is_eq(dx(entry),1)

@unsafe
def x198pr_ids(ids: N111Ids, index: KDef) -> N111Ids:
  match ids:
    case N111Ids{+functions,constructors}:
      +key = "__x181_pair_indices"
      nt_choose(N111Ids,String.eq(dk(p111v_get(functions,key)),"Absent"),
        u => N111Ids{index_set(functions,KDef{key,"X198PairIndices",0,0,atom("Absent"),atom("Absent"),[index],False{},False{}},
          index_hash(key,2166136261),32),constructors},u => N111Ids{functions,constructors})

@unsafe
def x198pr_target(ids: N111Ids, name: String) -> Bool:
  match ids:
    case N111Ids{functions,constructors}:
      match p111v_get(functions,"__x181_pair_indices"):
        case KDef{key,+kind,arity,templates,typ,value,Con{index,Nil{}},native,unsafe}:
          String.eq(kind,"X198PairIndices") && x198pr_selected(index,name)
        case _: False{}

@unsafe
def x198pr_frame(frame: X181Frame) -> Bool:
  match frame:
    case X181Frame{slots,bytes,calls,params,symbol}: String.starts_with(symbol,"p198r_")

@unsafe
def x198pr_worker(function: P113DFunction, +available: KDef, ids: N111Ids) -> X181Output:
  match function:
    case P113DFunction{+name,params,result,public,body}:
      nt_choose(X181Output,x198pr_selected(available,name),
        u => x181_function(x198pr_symbol(name),Con{"state",x181_param_names(params)},body,ids),
        u => X181Output{[],""})
