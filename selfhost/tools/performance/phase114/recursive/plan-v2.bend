# Reuse the Phase112 exact prelude/frame/continuation parsers. A reflected plan
# is not an ownership certificate: production must start from verified original
# IR and derive this plan internally, retaining the unmodified fallback.
def p114r_refused() -> P114RPlan:
  P114RPlan{False{},[],[],"","","",[]}

def p114r_prefix(body: List<&2,N111Stmt>, count: U32) -> List<&2,N111Stmt>:
  match body count:
    case _ 0: []
    case Con{stmt,rest} _: Con{stmt,p114r_prefix(rest,U32.sub(count,1))}
    case _ _: []

# Retain every argument store and preceding scalar operation; exclude only the
# exact final jump+machine return. No branch/frame/unknown call can intervene.
@unsafe
def p114r_arguments(+body: List<&2,N111Stmt>, +owner: String, +arity: U32) -> Bool:
  nt_choose(Bool,p112t_tail(body,owner,arity,0),u => True{},
    u => p114r_arguments_next(body,owner,arity))

@unsafe
def p114r_arguments_next(body: List<&2,N111Stmt>, +owner: String, +arity: U32) -> Bool:
  match body:
    case Con{stmt,rest}: p112t_scalar_safe(stmt) && p114r_arguments(rest,owner,arity)
    case _: False{}

def p114r_without_transition(body: List<&2,N111Stmt>) -> List<&2,N111Stmt>:
  match body:
    case Con{first,Con{second,Nil{}}}: []
    case Con{first,rest}: Con{first,p114r_without_transition(rest)}
    case _: []

def p114r_result_word(body: List<&2,N111Stmt>) -> N111Value:
  match body:
    case Con{N111Store{typ,base,offset,value},rest}: value
    case _: N111Const{0,0}

@unsafe
def p114r_prepend(+stmt: N111Stmt, tail: P114RBody) -> P114RBody:
  match tail:
    case P114RBody{valid,frames,body}:
      P114RBody{valid && p112t_scalar_safe(stmt),frames,Con{P114RScalar{stmt},body}}

def p114r_branch(condition: N111Value, yes: P114RBody, no: P114RBody, rest: P114RBody) -> P114RBody:
  match yes no rest:
    case P114RBody{yv,yf,yb} P114RBody{nv,nf,nb} P114RBody{rv,rf,rb}:
      P114RBody{yv && nv && rv,nt_append(String,yf,nt_append(String,nf,rf)),Con{P114RIf{condition,yb,nb},rb}}

@unsafe
def p114r_scan(+body: List<&2,N111Stmt>, +owner: String, +arity: U32) -> P114RBody:
  nt_choose(P114RBody,p112w_result(body),
    u => P114RBody{True{},[],[P114RResult{p114r_result_word(body)}]},u =>
  nt_choose(P114RBody,p112t_tail(body,owner,arity,0),
    u => P114RBody{True{},[],[P114RAgain{p114r_without_transition(body)}]},u =>
  nt_choose(P114RBody,p112t_failure(body),
    u => P114RBody{True{},[],[P114RFailure{body}]},
    u => p114r_scan_frame(body,owner,arity,p112f_frame(body,0,[])))))

@unsafe
def p114r_scan_frame(+body: List<&2,N111Stmt>, +owner: String, +arity: U32, frame: Maybe<&2,P112FusionFrame>) -> P114RBody:
  match frame:
    case Some{P112FusionFrame{+captures,+name,dest,+tail}}:
      nt_choose(P114RBody,U32.is_eq(nt_count(N111Value,captures),1) && p114r_arguments(tail,owner,arity),
        u => P114RBody{True{},[name],[P114RDescend{p114r_prefix(body,2),p114r_without_transition(tail)}]},
        u => P114RBody{False{},[],[]})
    case None{}: p114r_scan_next(body,owner,arity)

@unsafe
def p114r_scan_next(body: List<&2,N111Stmt>, +owner: String, +arity: U32) -> P114RBody:
  match body:
    case Nil{}: P114RBody{True{},[],[]}
    case Con{N111If{condition,yes,no},rest}:
      p114r_branch(condition,p114r_scan(yes,owner,arity),p114r_scan(no,owner,arity),p114r_scan(rest,owner,arity))
    case Con{stmt,rest}: p114r_prepend(stmt,p114r_scan(rest,owner,arity))

# One captured owned head, one incoming recursive result, exactly one ordinary
# two-field constructor, with the recursive result in its final field. No work
# after reconstruction other than the original scalar return is admitted.
@unsafe
def p114r_constructor(+body: List<&2,N111Stmt>, +head: String, +result: String) -> Bool:
  match body:
    case Con{N111Store{N111U64{},N111Local{a},0,N111Local{h}},
      Con{N111Store{N111U64{},N111Local{b},8,N111Local{r}},
      Con{N111Call{+value,N111U64{},symbol,
        Con{N111Arg{N111Ptr{},N111Local{state}},Con{N111Arg{N111U32{},N111CtorId{ctor}},
        Con{N111Arg{N111Ptr{},N111Local{scratch}},Con{N111Arg{N111U32{},N111Const{2,0}},Nil{}}}}}},+rest}}}:
      String.eq(a,"scratch") && String.eq(b,"scratch") && String.eq(scratch,"scratch") &&
      String.eq(state,"state") && String.eq(symbol,"p111_rt_ctor") && String.eq(h,head) &&
      String.eq(r,result) && p112w_result(rest) && p114r_returns(rest,value)
    case _: False{}

@unsafe
def p114r_returns(body: List<&2,N111Stmt>, +name: String) -> Bool:
  match body:
    case Con{N111Store{typ,base,offset,N111Local{word}},rest}: String.eq(word,name)
    case _: False{}

@unsafe
def p114r_cont_finish(+params: List<&2,String>, +body: List<&2,P114RStmt>, +name: String, cont: Maybe<&2,P112FusionCont>) -> P114RPlan:
  match cont:
    case Some{P112FusionCont{Con{+head,Nil{}},+result,pop,+unwind}}:
      nt_choose(P114RPlan,p114r_constructor(unwind,head,result),
        u => P114RPlan{True{},params,body,name,head,result,unwind},u => p114r_refused())
    case _: p114r_refused()

@unsafe
def p114r_cont_lookup(+params: List<&2,String>, +body: List<&2,P114RStmt>, +name: String, found: Maybe<&2,N111Segment>) -> P114RPlan:
  match found:
    case Some{segment}: p114r_cont_finish(params,body,name,p112f_cont(segment,1))
    case None{}: p114r_refused()

@unsafe
def p114r_finish(+params: List<&2,String>, +index: P112FusionIndex, scanned: P114RBody) -> P114RPlan:
  match scanned:
    case P114RBody{+valid,Con{+name,Nil{}},body}:
      nt_choose(P114RPlan,valid,u => p114r_cont_lookup(params,body,name,p112f_index_get(index,name)),u => p114r_refused())
    case _: p114r_refused()

@unsafe
def p114r_prelude(+owner: String, +arity: U32, +index: P112FusionIndex, prelude: P112TailPrelude) -> P114RPlan:
  match prelude:
    case P112TailPrelude{+valid,+params,prefix,+body}:
      nt_choose(P114RPlan,valid,u => p114r_finish(params,index,p114r_scan(body,owner,arity)),u => p114r_refused())

@unsafe
def p114r_plan(segment: N111Segment, +index: P112FusionIndex) -> P114RPlan:
  match segment:
    case N111Segment{+name,+arity,result,incoming,flags,+body}:
      nt_choose(P114RPlan,U32.is_eq(result,1) && U32.is_eq(incoming,0) && U32.is_eq(flags,0) &&
        U32.is_gt(arity,0) && U32.is_le(arity,8) && p112f_clean(body),
        u => p114r_prelude(name,arity,index,p112t_prelude(body,arity)),u => p114r_refused())

def p114r_valid(plan: P114RPlan) -> Bool:
  match plan:
    case P114RPlan{valid,params,body,continuation,head,result,unwind}: valid

@unsafe
def p114r_entries(segments: List<&2,N111Segment>, +index: P112FusionIndex) -> List<&2,String>:
  match segments:
    case Nil{}: []
    case Con{+segment,rest}:
      match segment:
        case N111Segment{+name,arity,result,incoming,flags,body}:
          nt_choose(List<&2,String>,p114r_valid(p114r_plan(segment,index)),
            u => Con{name,p114r_entries(rest,index)},u => p114r_entries(rest,index))

@unsafe
def p114r_inspect_program(+program: P113AProgram, +error: String) -> P114RInspection:
  match program:
    case P113AProgram{P113DProgram{P112StaticProgram{P111Program{+segments,constructors,show,names,effects,pure},nodes},functions},certificate}:
      nt_choose(P114RInspection,String.is_empty(error),
        u => P114RInspection{p114r_entries(segments,p112f_index(segments)),""},u => P114RInspection{[],error})

@unsafe
def p114r_inspect_lowered(lowered: P113ALowering) -> P114RInspection:
  match lowered:
    case P113ALowered{+program,+error}:
      p114r_inspect_program(program,nt_choose(String,String.is_empty(error),u => p113a_verify(program),u => error))

@unsafe
def p114r_inspect_request(request: NR_Request) -> P114RInspection:
  p114r_inspect_lowered(p113a_lower_request(request))
