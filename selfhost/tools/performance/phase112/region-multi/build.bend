# The frame and its argument suffix must use one exact existing scratch buffer.
@unsafe
def p112c_frame(body: List<&2,N111Stmt>, +index: U32, +captures: List<&2,N111Value>, +buffer: String) -> Maybe<&2,P112FusionFrame>:
  match body:
    case Con{N111Store{N111U64{},N111Local{+base},+offset,+value},+rest}:
      nt_choose(Maybe<&2,P112FusionFrame>,String.eq(base,buffer) && U32.is_eq(offset,U32.mul(index,8)) && U32.is_lt(index,8),
        u => p112c_frame(rest,U32.inc(index),Con{value,captures},buffer),u => None{})
    case Con{N111Call{+dest,N111U64{},+symbol,Con{N111Arg{N111Ptr{},N111Local{+state}},Con{N111Arg{N111U32{},N111FuncId{+name}},Con{N111Arg{N111Ptr{},N111Local{+scratch}},Con{N111Arg{N111U32{},N111Const{+count,0}},Nil{}}}}}},+rest}:
      nt_choose(Maybe<&2,P112FusionFrame>,String.eq(symbol,"p111_rt_frame") && String.eq(state,"state") && String.eq(scratch,buffer) && U32.is_eq(count,index),
        u => Some{P112FusionFrame{nt_reverse(N111Value,captures,[]),name,dest,rest}},u => None{})
    case _: None{}

@unsafe
def p112c_target(+frame: P112FusionFrame, +index: P112FusionIndex, +ready: KDef, +site: U32, +buffer: String, +target: String) -> Maybe<&2,List<&2,N111Stmt>>:
  match frame:
    case P112FusionFrame{+captures,+name,+dest,+tail}:
      +arity = da(p111v_get(ready,target))
      nt_choose(Maybe<&2,List<&2,N111Stmt>>,p112w_ready(ready,target) && U32.is_le(arity,8) && p112r_tail(tail,target,arity,0,buffer),
        u => p112f_found(frame,target,arity,site,p112f_index_get(index,name)),u => None{})

@unsafe
def p112c_try_frame(frame: Maybe<&2,P112FusionFrame>, +index: P112FusionIndex, +ready: KDef, +site: U32, +buffer: String) -> Maybe<&2,List<&2,N111Stmt>>:
  match frame:
    case None{}: None{}
    case Some{+value}:
      match value:
        case P112FusionFrame{+captures,+name,+dest,+tail}: p112c_target(value,index,ready,site,buffer,p112r_target(tail,site))

@unsafe
def p112c_try(+body: List<&2,N111Stmt>, +index: P112FusionIndex, +ready: KDef, +site: U32) -> Maybe<&2,List<&2,N111Stmt>>:
  +buffer = p112r_head_buffer(body)
  nt_choose(Maybe<&2,List<&2,N111Stmt>>,U32.is_lt(site,8) && p112r_buffer(buffer,site),
    u => p112c_try_frame(p112c_frame(body,0,[],buffer),index,ready,site,buffer),u => None{})

@unsafe
def p112c_scan(+body: List<&2,N111Stmt>, +index: P112FusionIndex, +ready: KDef, +site: U32) -> P112FusionBody:
  p112c_scan_try(body,index,ready,site,p112c_try(body,index,ready,site))

# A successful site introduces a fresh numeric namespace, then scanning resumes
# inside that produced list with a strictly greater counter. The ready set never
# changes here. At most eight continuation copies can be introduced.
@unsafe
def p112c_scan_try(+body: List<&2,N111Stmt>, +index: P112FusionIndex, +ready: KDef, +site: U32, attempt: Maybe<&2,List<&2,N111Stmt>>) -> P112FusionBody:
  match attempt:
    case Some{+fused}: p112c_more(p112c_scan(fused,index,ready,U32.inc(site)))
    case None{}: p112c_scan_next(body,index,ready,site)

def p112c_more(plan: P112FusionBody) -> P112FusionBody:
  match plan:
    case P112FusionBody{+body,+count,+next}: P112FusionBody{body,U32.inc(count),next}

@unsafe
def p112c_scan_next(body: List<&2,N111Stmt>, +index: P112FusionIndex, +ready: KDef, +site: U32) -> P112FusionBody:
  match body:
    case Nil{}: P112FusionBody{[],0,site}
    case Con{N111If{+condition,+yes,+no},+rest}: p112c_scan_yes(condition,no,rest,index,ready,p112c_scan(yes,index,ready,site))
    case Con{+stmt,+rest}: p112f_prepend(stmt,p112c_scan(rest,index,ready,site))

@unsafe
def p112c_scan_yes(+condition: N111Value, +no: List<&2,N111Stmt>, +rest: List<&2,N111Stmt>, +index: P112FusionIndex, +ready: KDef, yes: P112FusionBody) -> P112FusionBody:
  match yes:
    case P112FusionBody{+body,+count,+next}: p112c_scan_no(condition,body,count,rest,index,ready,p112c_scan(no,index,ready,next))

@unsafe
def p112c_scan_no(+condition: N111Value, +yes: List<&2,N111Stmt>, +yc: U32, +rest: List<&2,N111Stmt>, +index: P112FusionIndex, +ready: KDef, no: P112FusionBody) -> P112FusionBody:
  match no:
    case P112FusionBody{+body,+count,+next}: p112f_scan_rest(condition,yes,body,U32.add(yc,count),p112c_scan(rest,index,ready,next))

@unsafe
def p112c_plan_index(segment: N111Segment, +index: P112FusionIndex, +ready: KDef) -> P112FusionBody:
  match segment:
    case N111Segment{+name,+arity,+result,+incoming,+flags,+body}:
      nt_choose(P112FusionBody,U32.is_eq(result,1) && U32.is_eq(flags,0) && p112f_clean(body),
        u => p112c_scan(body,index,ready,0),u => P112FusionBody{body,0,0})
