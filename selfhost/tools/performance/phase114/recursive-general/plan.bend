def p114g_refused() -> P114GPlan:
  P114GPlan{False{},[],[],"",[],"","",[]}

@unsafe
def p114g_prepend(+stmt: N111Stmt, tail: P114GBody) -> P114GBody:
  match tail:
    case P114GBody{valid,frames,body}:
      P114GBody{valid && p112t_scalar_safe(stmt),frames,Con{P114RScalar{stmt},body}}

def p114g_branch(condition: N111Value, yes: P114GBody, no: P114GBody, rest: P114GBody) -> P114GBody:
  match yes no rest:
    case P114GBody{yv,yf,yb} P114GBody{nv,nf,nb} P114GBody{rv,rf,rb}:
      P114GBody{yv && nv && rv,nt_append(P114GFrame,yf,nt_append(P114GFrame,nf,rf)),Con{P114RIf{condition,yb,nb},rb}}

# Failure recognition is cached only across safe scalar heads; every branch
# enters through the complete test. Original failure instructions stay intact.
@unsafe
def p114g_scan(+body: List<&2,N111Stmt>, +owner: String, +arity: U32) -> P114GBody:
  nt_choose(P114GBody,p112t_failure(body),
    u => P114GBody{True{},[],[P114RFailure{body}]},u => p114g_scan_normal(body,owner,arity))

@unsafe
def p114g_scan_normal(+body: List<&2,N111Stmt>, +owner: String, +arity: U32) -> P114GBody:
  nt_choose(P114GBody,p112w_result(body),
    u => P114GBody{True{},[],[P114RResult{p114r_result_word(body)}]},u =>
  nt_choose(P114GBody,p112t_tail(body,owner,arity,0),
    u => P114GBody{True{},[],[P114RAgain{p114r_without_transition(body)}]},
    u => p114g_scan_frame(body,owner,arity,p112f_frame(body,0,[]))))

@unsafe
def p114g_scan_frame(+body: List<&2,N111Stmt>, +owner: String, +arity: U32, frame: Maybe<&2,P112FusionFrame>) -> P114GBody:
  match frame:
    case Some{P112FusionFrame{captures,+name,dest,+tail}}:
      +count = nt_count(N111Value,captures)
      nt_choose(P114GBody,U32.is_le(count,8) && p114r_arguments(tail,owner,arity),
        u => P114GBody{True{},[P114GFrame{name,count}],[P114RDescend{p114r_prefix(body,U32.inc(count)),p114r_without_transition(tail)}]},
        u => P114GBody{False{},[],[]})
    case None{}: p114g_scan_next(body,owner,arity)

@unsafe
def p114g_scan_next(body: List<&2,N111Stmt>, +owner: String, +arity: U32) -> P114GBody:
  match body:
    case Nil{}: P114GBody{True{},[],[]}
    case Con{N111If{condition,yes,no},rest}:
      p114g_branch(condition,p114g_scan(yes,owner,arity),p114g_scan(no,owner,arity),p114g_scan(rest,owner,arity))
    case Con{+stmt,+rest}:
      nt_choose(P114GBody,p112t_scalar_safe(stmt),
        u => p114g_prepend(stmt,p114g_scan_normal(rest,owner,arity)),
        u => p114g_prepend(stmt,p114g_scan(rest,owner,arity)))

# The existing worker scan authenticates runtime calls and terminal ready calls.
# Resume cannot loop, re-enter this region, or call beyond the bounded private ABI.
@unsafe
def p114g_resume_safe(body: List<&2,P112WorkerStmt>, +owner: String, +ready: KDef) -> Bool:
  match body:
    case Nil{}: True{}
    case Con{P112WorkerAgain{},rest}: False{}
    case Con{P112WorkerCall{+target,arity},rest}:
      U32.is_le(arity,8) && Bool.not(String.eq(target,owner)) && p112w_ready(ready,target) && p114g_resume_safe(rest,owner,ready)
    case Con{P112WorkerIf{condition,yes,no},rest}:
      p114g_resume_safe(yes,owner,ready) && p114g_resume_safe(no,owner,ready) && p114g_resume_safe(rest,owner,ready)
    case Con{stmt,rest}: p114g_resume_safe(rest,owner,ready)

@unsafe
def p114g_resume_done(+params: List<&2,String>, +body: List<&2,P114RStmt>, +name: String,
    +captures: List<&2,String>, +result: String, +pop: String, +owner: String, +ready: KDef, scanned: P112WorkerBody) -> P114GPlan:
  match scanned:
    case P112WorkerBody{valid,calls,+resume}:
      nt_choose(P114GPlan,valid && p114g_resume_safe(resume,owner,ready),
        u => P114GPlan{True{},params,body,name,captures,result,pop,resume},u => p114g_refused())

@unsafe
def p114g_cont(+params: List<&2,String>, +body: List<&2,P114RStmt>, +name: String,
    +owner: String, +arity: U32, +ready: KDef, cont: Maybe<&2,P112FusionCont>) -> P114GPlan:
  match cont:
    case Some{P112FusionCont{captures,result,pop,unwind}}:
      p114g_resume_done(params,body,name,captures,result,pop,owner,ready,p112w_scan(unwind,owner,arity,ready))
    case None{}: p114g_refused()

@unsafe
def p114g_lookup(+params: List<&2,String>, +body: List<&2,P114RStmt>, +name: String,
    +count: U32, +owner: String, +arity: U32, +ready: KDef, found: Maybe<&2,N111Segment>) -> P114GPlan:
  match found:
    case Some{segment}: p114g_cont(params,body,name,owner,arity,ready,p112f_cont(segment,count))
    case None{}: p114g_refused()

@unsafe
def p114g_finish(+params: List<&2,String>, +owner: String, +arity: U32, +index: P112FusionIndex,
    +ready: KDef, scanned: P114GBody) -> P114GPlan:
  match scanned:
    case P114GBody{valid,Con{P114GFrame{+name,count},Nil{}},body}:
      nt_choose(P114GPlan,valid,u => p114g_lookup(params,body,name,count,owner,arity,ready,p112f_index_get(index,name)),u => p114g_refused())
    case _: p114g_refused()

@unsafe
def p114g_prelude(+owner: String, +arity: U32, +index: P112FusionIndex, +ready: KDef, prelude: P112TailPrelude) -> P114GPlan:
  match prelude:
    case P112TailPrelude{valid,params,prefix,body}:
      nt_choose(P114GPlan,valid,u => p114g_finish(params,owner,arity,index,ready,p114g_scan(body,owner,arity)),u => p114g_refused())

@unsafe
def p114g_plan(segment: N111Segment, +index: P112FusionIndex, +ready: KDef) -> P114GPlan:
  match segment:
    case N111Segment{+name,+arity,result,incoming,flags,+body}:
      nt_choose(P114GPlan,U32.is_eq(result,1) && U32.is_eq(incoming,0) && U32.is_eq(flags,0) &&
        U32.is_gt(arity,0) && U32.is_le(arity,8) && Bool.not(p112w_ready(ready,name)) && p112f_clean(body),
        u => p114g_prelude(name,arity,index,ready,p112t_prelude(body,arity)),u => p114g_refused())

@unsafe
def p114g_hygiene(+original: List<&2,N111Stmt>, +index: P112FusionIndex, plan: P114GPlan) -> Bool:
  match plan:
    case P114GPlan{valid,params,body,continuation,captures,result,pop,resume}:
      valid && p114r_clean(original) && p114r_clean_cont(p112f_index_get(index,continuation))
