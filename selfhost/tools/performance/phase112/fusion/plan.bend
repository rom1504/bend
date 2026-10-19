@unsafe
def p112f_frame(body: List<&2,N111Stmt>, +index: U32, +captures: List<&2,N111Value>) -> Maybe<&2,P112FusionFrame>:
  match body:
    case Con{N111Store{N111U64{},N111Local{+base},+offset,+value},+rest}:
      nt_choose(Maybe<&2,P112FusionFrame>,String.eq(base,"scratch") && U32.is_eq(offset,U32.mul(index,8)) && U32.is_lt(index,8),
        u => p112f_frame(rest,U32.inc(index),Con{value,captures}),u => None{})
    case Con{N111Call{+dest,N111U64{},+symbol,Con{N111Arg{N111Ptr{},N111Local{+state}},Con{N111Arg{N111U32{},N111FuncId{+name}},Con{N111Arg{N111Ptr{},N111Local{+scratch}},Con{N111Arg{N111U32{},N111Const{+count,0}},Nil{}}}}}},+rest}:
      nt_choose(Maybe<&2,P112FusionFrame>,String.eq(symbol,"p111_rt_frame") && String.eq(state,"state") && String.eq(scratch,"scratch") && U32.is_eq(count,index),
        u => Some{P112FusionFrame{nt_reverse(N111Value,captures,[]),name,dest,rest}},u => None{})
    case _: None{}

# The remainder may manipulate frames and transfer control, but cannot observe
# the register bank, popped stack slots, raw state, or arbitrary external effects.
@unsafe
def p112f_transition(body: List<&2,N111Stmt>) -> Bool:
  match body:
    case Con{N111Call{+dest,N111U64{},+symbol,+args},Con{N111Return{N111Local{+word}},Nil{}}}:
      String.eq(dest,word) && p112t_runtime_args(args) &&
        (String.eq(symbol,"p111_rt_jump") || String.eq(symbol,"p111_rt_return") || String.eq(symbol,"p111_rt_apply") || String.eq(symbol,"p111_rt_fail"))
    case _: False{}

@unsafe
def p112f_safe(+body: List<&2,N111Stmt>) -> Bool:
  nt_choose(Bool,p112f_transition(body),u => True{},u => p112f_safe_next(body))

@unsafe
def p112f_safe_next(body: List<&2,N111Stmt>) -> Bool:
  match body:
    case Nil{}: True{}
    case Con{N111If{+condition,+yes,+no},+rest}: p112f_safe(yes) && p112f_safe(no) && p112f_safe(rest)
    case Con{+stmt,+rest}: (p112t_scalar_safe(stmt) || p112t_failure_frame(stmt)) && p112f_safe(rest)

@unsafe
def p112f_size(body: List<&2,N111Stmt>) -> U32:
  match body:
    case Nil{}: 0
    case Con{N111If{+condition,+yes,+no},+rest}: U32.add(1,U32.add(p112f_size(yes),U32.add(p112f_size(no),p112f_size(rest))))
    case Con{+stmt,+rest}: U32.inc(p112f_size(rest))

@unsafe
def p112f_cont_result(body: List<&2,N111Stmt>, +captures: List<&2,String>, +pop: String) -> Maybe<&2,P112FusionCont>:
  match body:
    case Con{N111Call{+word,N111U64{},+symbol,Con{N111Arg{N111Ptr{},N111Local{+state}},Con{N111Arg{N111U32{},N111Const{0,0}},Nil{}}}},+rest}:
      nt_choose(Maybe<&2,P112FusionCont>,String.eq(symbol,"p111_rt_reg_get") && String.eq(state,"state") && Bool.not(nb_contains(captures,word) || String.eq(word,"state") || String.eq(word,"scratch")) && p112f_safe(rest) && U32.is_le(p112f_size(rest),128),
        u => Some{P112FusionCont{nt_reverse(String,captures,[]),word,pop,rest}},u => None{})
    case _: None{}

@unsafe
def p112f_cont_gets(+body: List<&2,N111Stmt>, +count: U32, +index: U32, +captures: List<&2,String>, +pop: String) -> Maybe<&2,P112FusionCont>:
  nt_choose(Maybe<&2,P112FusionCont>,U32.is_eq(count,index),u => p112f_cont_result(body,captures,pop),u =>
    p112f_cont_get(body,count,index,captures,pop))

@unsafe
def p112f_cont_get(body: List<&2,N111Stmt>, +count: U32, +index: U32, +captures: List<&2,String>, +pop: String) -> Maybe<&2,P112FusionCont>:
  match body:
    case Con{N111Call{+word,N111U64{},+symbol,Con{N111Arg{N111Ptr{},N111Local{+state}},Con{N111Arg{N111U32{},N111Const{+slot,0}},Nil{}}}},+rest}:
      nt_choose(Maybe<&2,P112FusionCont>,String.eq(symbol,"p111_rt_stack_get") && String.eq(state,"state") && U32.is_eq(slot,index) && Bool.not(nb_contains(captures,word) || String.eq(word,"state") || String.eq(word,"scratch")),
        u => p112f_cont_gets(rest,count,U32.inc(index),Con{word,captures},pop),u => None{})
    case _: None{}

@unsafe
def p112f_cont_pop(body: List<&2,N111Stmt>, +count: U32) -> Maybe<&2,P112FusionCont>:
  match body:
    case Con{N111Call{+word,N111U64{},+symbol,Con{N111Arg{N111Ptr{},N111Local{+state}},Con{N111Arg{N111U32{},N111Const{+held,0}},Nil{}}}},+rest}:
      nt_choose(Maybe<&2,P112FusionCont>,String.eq(symbol,"p111_rt_stack_pop") && String.eq(state,"state") && U32.is_eq(held,count),
        u => p112f_cont_gets(rest,count,0,[],word),u => None{})
    case _: None{}

@unsafe
def p112f_cont_body(body: List<&2,N111Stmt>, +count: U32) -> Maybe<&2,P112FusionCont>:
  match body:
    case Con{N111Alloca{+name,2048,8},+rest}:
      nt_choose(Maybe<&2,P112FusionCont>,String.eq(name,"scratch"),u =>
        nt_choose(Maybe<&2,P112FusionCont>,U32.is_eq(count,0),v => p112f_cont_gets(rest,0,0,[],""),v => p112f_cont_pop(rest,count)),u => None{})
    case _: None{}

@unsafe
def p112f_cont(segment: N111Segment, +count: U32) -> Maybe<&2,P112FusionCont>:
  match segment:
    case N111Segment{+name,+arity,+result,+incoming,+flags,+body}:
      nt_choose(Maybe<&2,P112FusionCont>,U32.is_eq(arity,U32.inc(count)) && U32.is_eq(result,1) && U32.is_eq(incoming,1) && U32.is_eq(flags,0) && p112f_clean(body),
        u => p112f_cont_body(body,count),u => None{})
