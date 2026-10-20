# A final-emission bridge over an already verified closed complete-function
# catalogue. It changes neither the original owning graph nor worker planning.
type P114BBody is Data:
  P114BBody{+body: List<&2,P112WorkerStmt>, +next: U32}

@unsafe
def p114b_name(site: U32, role: String) -> String:
  "p114b_" ++ U32.show(site) ++ "_" ++ role

@unsafe
def p114b_argument(site: U32, index: U32) -> String:
  p114b_name(site,"arg_" ++ U32.show(index))

# Public=True excludes flat private-only product signatures. Exact original
# function verification established the public arity/result/identity relation.
@unsafe
def p114b_target(+target: String, +count: U32, direct: KDef) -> Bool:
  +function = p111v_get(direct,target)
  String.eq(dk(function),"P113Direct") && U32.is_eq(dx(function),1) &&
    U32.is_eq(ix(dv(function)),1) && U32.is_eq(da(function),count) && U32.is_le(count,32)

@unsafe
def p114b_args(+count: U32, +index: U32, +site: U32) -> List<&2,N111Arg>:
  nt_choose(List<&2,N111Arg>,U32.is_eq(index,count),u => [],u =>
    Con{N111Arg{N111U64{},N111Local{p114b_argument(site,index)}},p114b_args(count,U32.inc(index),site)})

# Snapshot all full-width operands before the call and before any result store.
# Scratch words are transport copies, not additional independent owning roots.
@unsafe
def p114b_loads(+buffer: String, +count: U32, +index: U32, +site: U32) -> List<&2,P112WorkerStmt>:
  nt_choose(List<&2,P112WorkerStmt>,U32.is_eq(index,count),u => [],u =>
    Con{P112WorkerScalar{N111Load{p114b_argument(site,index),N111U64{},N111Local{buffer},U32.mul(index,8)}},
      p114b_loads(buffer,count,U32.inc(index),site)})

@unsafe
def p114b_bridge(+dest: String, target: String, +buffer: String, +count: U32, +site: U32) -> List<&2,P112WorkerStmt>:
  nt_append(P112WorkerStmt,p114b_loads(buffer,count,0,site),[
    P112WorkerScalar{N111Call{p114b_name(site,"result"),N111U64{},p113e_symbol(target),
      Con{p111_state(),p114b_args(count,0,site)}}},
    P112WorkerScalar{N111Store{N111U64{},N111Local{buffer},0,N111Local{p114b_name(site,"result")}}},
    P112WorkerScalar{N111Call{dest,N111U64{},"p111_rt_return",[p111_state(),N111Arg{N111Ptr{},N111Local{buffer}},p111_u32(1)]}},
    P112WorkerScalar{N111Return{N111Local{dest}}}])

@unsafe
def p114b_prepend(head: P112WorkerStmt, result: P114BBody) -> P114BBody:
  match result:
    case P114BBody{body,next}: P114BBody{Con{head,body},next}

@unsafe
def p114b_if_rest(condition: N111Value, yes: List<&2,P112WorkerStmt>, no: List<&2,P112WorkerStmt>, rest: P114BBody) -> P114BBody:
  match rest:
    case P114BBody{body,next}: P114BBody{Con{P112WorkerIf{condition,yes,no},body},next}

@unsafe
def p114b_if_no(condition: N111Value, yes: List<&2,P112WorkerStmt>, no: P114BBody,
    rest: List<&2,P112WorkerStmt>, direct: KDef) -> P114BBody:
  match no:
    case P114BBody{body,next}: p114b_if_rest(condition,yes,body,p114b_scan(rest,direct,next))

@unsafe
def p114b_if_yes(condition: N111Value, yes: P114BBody, no: List<&2,P112WorkerStmt>,
    rest: List<&2,P112WorkerStmt>, +direct: KDef) -> P114BBody:
  match yes:
    case P114BBody{body,next}: p114b_if_no(condition,body,p114b_scan(no,direct,next),rest,direct)

@unsafe
def p114b_scan(+body: List<&2,P112WorkerStmt>, +direct: KDef, +site: U32) -> P114BBody:
  match body:
    case Nil{}: P114BBody{[],site}
    case Con{P112WorkerScalar{N111Call{+dest,N111U64{},+symbol,
      Con{N111Arg{N111Ptr{},N111Local{+state}},
      Con{N111Arg{N111U32{},N111FuncId{+target}},
      Con{N111Arg{N111Ptr{},N111Local{+buffer}},
      Con{N111Arg{N111U32{},N111Const{+count,+high}},Nil{}}}}}}},
      Con{P112WorkerScalar{N111Return{N111Local{+returned}}},Nil{}}}:
        nt_choose(P114BBody,String.eq(symbol,"p111_rt_jump") && String.eq(state,"state") &&
          String.eq(dest,returned) && U32.is_eq(high,0) && p114t_buffer(buffer) && p114b_target(target,count,direct),
          u => P114BBody{p114b_bridge(dest,target,buffer,count,site),U32.inc(site)},
          u => P114BBody{body,site})
    case Con{P112WorkerIf{condition,yes,no},rest}:
      p114b_if_yes(condition,p114b_scan(yes,direct,site),no,rest,direct)
    case Con{head,rest}: p114b_prepend(head,p114b_scan(rest,direct,site))
