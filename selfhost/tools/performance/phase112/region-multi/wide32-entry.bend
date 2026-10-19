# OPTIONAL wider fusion only: exact buffers, eight global sites, 128 copied
# statements and six immutable ranks are unchanged. Capture32 implies a33-word
# original continuation prelude; each transport buffer uses at most256 bytes.
@unsafe
def p112c_frame(body: List<&2,N111Stmt>, +index: U32, +captures: List<&2,N111Value>, +buffer: String) -> Maybe<&2,P112FusionFrame>:
  match body:
    case Con{N111Store{N111U64{},N111Local{+base},+offset,+value},+rest}:
      nt_choose(Maybe<&2,P112FusionFrame>,String.eq(base,buffer) && U32.is_eq(offset,U32.mul(index,8)) && U32.is_lt(index,32),
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
      nt_choose(Maybe<&2,List<&2,N111Stmt>>,p112w_ready(ready,target) && U32.is_le(arity,32) && p112r_tail(tail,target,arity,0,buffer),
        u => p112f_found(frame,target,arity,site,p112f_index_get(index,name)),u => None{})
