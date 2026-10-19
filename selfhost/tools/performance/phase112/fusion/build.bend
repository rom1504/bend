@unsafe
def p112f_values(body: List<&2,N111Stmt>, left: U32) -> List<&2,N111Value>:
  match body left:
    case _ 0: []
    case Con{N111Store{+typ,+base,+offset,+value},+rest} _: Con{value,p112f_values(rest,U32.sub(left,1))}
    case _ _: []

@unsafe
def p112f_snapshots(values: List<&2,N111Value>, +prefix: String, +kind: String, +index: U32) -> List<&2,N111Stmt>:
  match values:
    case Nil{}: []
    case Con{+value,+rest}: Con{N111Set{prefix ++ kind ++ U32.show(index),N111U64{},value},p112f_snapshots(rest,prefix,kind,U32.inc(index))}

@unsafe
def p112f_callargs(+count: U32, +index: U32, +prefix: String) -> List<&2,N111Arg>:
  nt_choose(List<&2,N111Arg>,U32.is_eq(count,index),u => [],u =>
    Con{N111Arg{N111U64{},N111Local{prefix ++ "arg_" ++ U32.show(index)}},p112f_callargs(count,U32.inc(index),prefix)})

@unsafe
def p112f_bind_captures(words: List<&2,String>, +prefix: String, +index: U32) -> List<&2,N111Stmt>:
  match words:
    case Nil{}: []
    case Con{+word,+rest}: Con{N111Set{p112f_name(prefix,word),N111U64{},N111Local{prefix ++ "capture_" ++ U32.show(index)}},p112f_bind_captures(rest,prefix,U32.inc(index))}

@unsafe
def p112f_inline(cont: P112FusionCont, +prefix: String) -> List<&2,N111Stmt>:
  match cont:
    case P112FusionCont{+captures,+result,+pop,+body}:
      Con{N111Alloca{p112f_name(prefix,"scratch"),2048,8},
        nt_append(N111Stmt,nt_choose(List<&2,N111Stmt>,String.eq(pop,""),u => [],u => [N111Set{p112f_name(prefix,pop),N111U64{},N111Const{0,0}}]),
          nt_append(N111Stmt,p112f_bind_captures(captures,prefix,0),
            Con{N111Set{p112f_name(prefix,result),N111U64{},N111Local{prefix ++ "result"}},p112f_rename(body,prefix)}))}

@unsafe
def p112f_fused(frame: P112FusionFrame, +cont: P112FusionCont, +target: String, +arity: U32, +site: U32) -> List<&2,N111Stmt>:
  match frame:
    case P112FusionFrame{+captures,+name,+dest,+tail}:
      +prefix = "p112f_" ++ U32.show(site) ++ "_"
      nt_append(N111Stmt,p112f_snapshots(captures,prefix,"capture_",0),
        Con{N111Set{dest,N111U64{},N111Const{0,0}},
          nt_append(N111Stmt,p112f_snapshots(p112f_values(tail,arity),prefix,"arg_",0),
            Con{N111Call{prefix ++ "result",N111U64{},p112w_symbol(target),Con{p111_state(),p112f_callargs(arity,0,prefix)}},p112f_inline(cont,prefix)})})

@unsafe
def p112f_found(+frame: P112FusionFrame, +target: String, +arity: U32, +site: U32, found: Maybe<&2,N111Segment>) -> Maybe<&2,List<&2,N111Stmt>>:
  match frame found:
    case _ None{}: None{}
    case P112FusionFrame{+captures,+name,+dest,+tail} Some{+segment}:
      p112f_cont_found(frame,target,arity,site,p112f_cont(segment,nt_count(N111Value,captures)))

@unsafe
def p112f_cont_found(+frame: P112FusionFrame, +target: String, +arity: U32, +site: U32, found: Maybe<&2,P112FusionCont>) -> Maybe<&2,List<&2,N111Stmt>>:
  match found:
    case None{}: None{}
    case Some{+cont}: Some{p112f_fused(frame,cont,target,arity,site)}

@unsafe
def p112f_target(+frame: P112FusionFrame, +index: P112FusionIndex, +ready: KDef, +site: U32, +target: String) -> Maybe<&2,List<&2,N111Stmt>>:
  match frame:
    case P112FusionFrame{+captures,+name,+dest,+tail}:
      +arity = da(p111v_get(ready,target))
      nt_choose(Maybe<&2,List<&2,N111Stmt>>,p112w_ready(ready,target) && U32.is_le(arity,8) && p112t_tail(tail,target,arity,0),
        u => p112f_found(frame,target,arity,site,p112f_index_get(index,name)),u => None{})

@unsafe
def p112f_try_frame(frame: Maybe<&2,P112FusionFrame>, +index: P112FusionIndex, +ready: KDef, +site: U32) -> Maybe<&2,List<&2,N111Stmt>>:
  match frame:
    case None{}: None{}
    case Some{+value}:
      match value:
        case P112FusionFrame{+captures,+name,+dest,+tail}: p112f_target(value,index,ready,site,p112w_target(tail))

@unsafe
def p112f_try(+body: List<&2,N111Stmt>, +index: P112FusionIndex, +ready: KDef, +site: U32) -> Maybe<&2,List<&2,N111Stmt>>:
  nt_choose(Maybe<&2,List<&2,N111Stmt>>,U32.is_lt(site,8),
    u => p112f_try_frame(p112f_frame(body,0,[]),index,ready,site),u => None{})

@unsafe
def p112f_scan(+body: List<&2,N111Stmt>, +index: P112FusionIndex, +ready: KDef, +site: U32) -> P112FusionBody:
  p112f_scan_try(body,index,ready,site,p112f_try(body,index,ready,site))

@unsafe
def p112f_scan_try(+body: List<&2,N111Stmt>, +index: P112FusionIndex, +ready: KDef, +site: U32, attempt: Maybe<&2,List<&2,N111Stmt>>) -> P112FusionBody:
  match attempt:
    case Some{+fused}: P112FusionBody{fused,1,U32.inc(site)}
    case None{}: p112f_scan_next(body,index,ready,site)

@unsafe
def p112f_prepend(+stmt: N111Stmt, tail: P112FusionBody) -> P112FusionBody:
  match tail:
    case P112FusionBody{+body,+count,+next}: P112FusionBody{Con{stmt,body},count,next}

@unsafe
def p112f_scan_next(body: List<&2,N111Stmt>, +index: P112FusionIndex, +ready: KDef, +site: U32) -> P112FusionBody:
  match body:
    case Nil{}: P112FusionBody{[],0,site}
    case Con{N111If{+condition,+yes,+no},+rest}: p112f_scan_yes(condition,no,rest,index,ready,p112f_scan(yes,index,ready,site))
    case Con{+stmt,+rest}: p112f_prepend(stmt,p112f_scan(rest,index,ready,site))

@unsafe
def p112f_scan_yes(+condition: N111Value, +no: List<&2,N111Stmt>, +rest: List<&2,N111Stmt>, +index: P112FusionIndex, +ready: KDef, yes: P112FusionBody) -> P112FusionBody:
  match yes:
    case P112FusionBody{+body,+count,+next}: p112f_scan_no(condition,body,count,rest,index,ready,p112f_scan(no,index,ready,next))

@unsafe
def p112f_scan_no(+condition: N111Value, +yes: List<&2,N111Stmt>, +yc: U32, +rest: List<&2,N111Stmt>, +index: P112FusionIndex, +ready: KDef, no: P112FusionBody) -> P112FusionBody:
  match no:
    case P112FusionBody{+body,+count,+next}: p112f_scan_rest(condition,yes,body,U32.add(yc,count),p112f_scan(rest,index,ready,next))

@unsafe
def p112f_scan_rest(+condition: N111Value, +yes: List<&2,N111Stmt>, +no: List<&2,N111Stmt>, +bc: U32, rest: P112FusionBody) -> P112FusionBody:
  match rest:
    case P112FusionBody{+body,+count,+next}: P112FusionBody{Con{N111If{condition,yes,no},body},U32.add(bc,count),next}
