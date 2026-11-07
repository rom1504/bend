

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

# A complete failure suffix cannot also be a return or self jump. Test it once
# when entering a block, then retain that negative fact across safe scalar heads.


@unsafe
def p114r_scan(+body: List<&2,N111Stmt>, +owner: String, +arity: U32) -> P114RBody:
  nt_choose(P114RBody,p112t_failure(body),
    u => P114RBody{True{},[],[P114RFailure{body}]},
    u => p114r_scan_normal(body,owner,arity))


@unsafe
def p114r_scan_normal(+body: List<&2,N111Stmt>, +owner: String, +arity: U32) -> P114RBody:
  nt_choose(P114RBody,p112w_result(body),
    u => P114RBody{True{},[],[P114RResult{p114r_result_word(body)}]},u =>
  nt_choose(P114RBody,p112t_tail(body,owner,arity,0),
    u => P114RBody{True{},[],[P114RAgain{p114r_without_transition(body)}]},
    u => p114r_scan_frame(body,owner,arity,p112f_frame(body,0,[]))))


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
    # When this head is safe, failure(head :: rest) = failure(rest). The caller
    # established False, so the repeated whole-suffix check is unnecessary.
    # Keep the old path for unsafe heads, preserving even refused scan payloads.
    case Con{+stmt,+rest}:
      nt_choose(P114RBody,p112t_scalar_safe(stmt),
        u => p114r_prepend(stmt,p114r_scan_normal(rest,owner,arity)),
        u => p114r_prepend(stmt,p114r_scan(rest,owner,arity)))

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
# Phase171 experiment: preserve every admission condition, but do not inspect
# entire bodies or query readiness after cheap metadata has already refused.
# Bool conjunction is eager. nt_choose keeps the skipped work inside a closure.
# These are producer/planner changes; no final verifier is replaced.

@unsafe
def p114r_plan(segment: N111Segment, +index: P112FusionIndex) -> P114RPlan:
  match segment:
    case N111Segment{+name,+arity,result,incoming,flags,+body}:
      nt_choose(P114RPlan,U32.is_eq(result,1) && U32.is_eq(incoming,0) && U32.is_eq(flags,0) &&
        U32.is_gt(arity,0) && U32.is_le(arity,8),
        u => nt_choose(P114RPlan,p112f_clean(body),
          v => p114r_prelude(name,arity,index,p112t_prelude(body,arity)),v => p114r_refused()),
        u => p114r_refused())


def p114r_valid(plan: P114RPlan) -> Bool:
  match plan:
    case P114RPlan{valid,params,body,continuation,head,result,unwind}: valid


@unsafe
def p114r_entries(segments: List<&2,N111Segment>, +index: P112FusionIndex) -> List<&2,String>:
  match segments:
    case Nil{}: []
    case Con{+segment,+rest}:
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


@unsafe
def p114r_clean_name(name: String) -> Bool:
  Bool.not(String.starts_with(name,"p114r_"))


def p114r_clean_value(value: N111Value) -> Bool:
  match value:
    case N111Local{name}: p114r_clean_name(name)
    case _: True{}


def p114r_clean_args(args: List<&2,N111Arg>) -> Bool:
  match args:
    case Nil{}: True{}
    case Con{N111Arg{typ,value},rest}: p114r_clean_value(value) && p114r_clean_args(rest)


@unsafe
def p114r_clean(body: List<&2,N111Stmt>) -> Bool:
  match body:
    case Nil{}: True{}
    case Con{stmt,rest}: p114r_clean_stmt(stmt) && p114r_clean(rest)


@unsafe
def p114r_clean_stmt(stmt: N111Stmt) -> Bool:
  match stmt:
    case N111Set{name,typ,value}: p114r_clean_name(name) && p114r_clean_value(value)
    case N111Bin{name,typ,op,left,right}: p114r_clean_name(name) && p114r_clean_value(left) && p114r_clean_value(right)
    case N111Call{name,typ,symbol,args}: p114r_clean_name(name) && p114r_clean_args(args)
    case N111If{condition,yes,no}: p114r_clean_value(condition) && p114r_clean(yes) && p114r_clean(no)
    case N111Return{value}: p114r_clean_value(value)
    case N111Load{name,typ,base,offset}: p114r_clean_name(name) && p114r_clean_value(base)
    case N111Store{typ,base,offset,value}: p114r_clean_value(base) && p114r_clean_value(value)
    case N111Offset{name,base,bytes}: p114r_clean_name(name) && p114r_clean_value(base) && p114r_clean_value(bytes)
    case N111Alloca{name,bytes,align}: p114r_clean_name(name)


def p114r_clean_cont(found: Maybe<&2,N111Segment>) -> Bool:
  match found:
    case Some{N111Segment{name,arity,result,incoming,flags,body}}: p114r_clean(body)
    case None{}: False{}


@unsafe
def p114r_hygiene(+original: List<&2,N111Stmt>, +index: P112FusionIndex, plan: P114RPlan) -> Bool:
  match plan:
    case P114RPlan{valid,params,body,continuation,head,result,unwind}:
      valid && p114r_clean(original) && p114r_clean_cont(p112f_index_get(index,continuation))


@unsafe
def p114r_symbol(name: String) -> String:
  "p114r_" ++ nt_fid(name)


def p114r_jump(label: String, code: P111QCode) -> P111QCode:
  match code:
    case P111QCode{chunks,n,terminal,error}: P111QCode{Con{"jmp " ++ label ++ "\n",chunks},n,True{},error}


@unsafe
def p114r_again(+arguments: List<&2,N111Stmt>, +params: List<&2,String>, +ids: N111Ids, code: P111QCode) -> P111QCode:
  p114r_moves(params,0,p112q_snapshots(nt_count(String,params),0,p111q_stmts(arguments,ids,code)))


@unsafe
def p114r_moves(params: List<&2,String>, +index: U32, code: P111QCode) -> P111QCode:
  match params:
    case Nil{}: p114r_jump("@p114r_descend",code)
    case Con{name,rest}: p114r_moves(rest,U32.inc(index),
      p111q_line(p111q_local(name) ++ " =l copy %p112_arg_" ++ U32.show(index) ++ "\n",code))


@unsafe
def p114r_stmts(body: List<&2,P114RStmt>, +params: List<&2,String>, +ids: N111Ids, +code: P111QCode) -> P111QCode:
  match body code:
    case Nil{} _: code
    case Con{stmt,rest} P111QCode{chunks,n,terminal,+error}:
      nt_choose(P111QCode,String.is_empty(error),u =>
        nt_choose(P111QCode,terminal,u => p111q_problem("statement after recursive transfer",code),
          u => p114r_stmts(rest,params,ids,p114r_stmt(stmt,params,ids,code))),u => code)


@unsafe
def p114r_stmt(stmt: P114RStmt, +params: List<&2,String>, +ids: N111Ids, +code: P111QCode) -> P111QCode:
  match stmt:
    case P114RScalar{scalar}: p111q_stmt(scalar,ids,code)
    case P114RIf{condition,yes,no}: p114r_if(condition,yes,no,params,ids,code)
    case P114RDescend{frame,arguments}:
      p114r_again(arguments,params,ids,p111q_line("%p114r_depth =l add %p114r_depth, 1\n",p111q_stmts(frame,ids,code)))
    case P114RAgain{arguments}: p114r_again(arguments,params,ids,code)
    case P114RResult{value}:
      p114r_jump("@p114r_unwind",p111q_line("%p114r_value =l copy " ++ p111q_value(value,ids) ++ "\n",code))
    case P114RFailure{body}: p111q_stmts(body,ids,code)
    case P114RResumeReady{frame,call,result}: p111q_problem("ready resume outside table region",code)

@unsafe
def p114r_if(+condition: N111Value, +yes: List<&2,P114RStmt>, +no: List<&2,P114RStmt>,
    +params: List<&2,String>, +ids: N111Ids, +code: P111QCode) -> P111QCode:
  +diamond = p114r_diamond(yes,no)
  nt_choose(P111QCode,p113bq_ready(diamond,code),
    u => p113bq_emit(condition,diamond,ids,code),
    u => p114r_if_original(condition,yes,no,params,ids,code))


def p114r_diamond(yes: List<&2,P114RStmt>, no: List<&2,P114RStmt>) -> P113BQDiamond:
  match yes no:
    case Con{P114RScalar{a},Nil{}} Con{P114RScalar{b},Nil{}}: p113bq_scalar([a],[b])
    case _ _: P113BQNo{}


@unsafe
def p114r_if_original(+condition: N111Value, +yes: List<&2,P114RStmt>, +no: List<&2,P114RStmt>,
    +params: List<&2,String>, +ids: N111Ids, code: P111QCode) -> P111QCode:
  match code:
    case P111QCode{chunks,n,terminal,error}:
      p114r_if_yes(n,no,params,ids,p114r_stmts(yes,params,ids,
        P111QCode{Con{p111q_label(n) ++ "\n",Con{"jnz " ++ p111q_value(condition,ids) ++ ", " ++ p111q_label(n) ++ ", " ++ p111q_label(U32.inc(n)) ++ "\n",chunks}},U32.add(n,3),False{},error}))


@unsafe
def p114r_if_yes(+label: U32, +no: List<&2,P114RStmt>, +params: List<&2,String>, +ids: N111Ids, yes: P111QCode) -> P111QCode:
  match yes:
    case P111QCode{+chunks,n,terminal,error}:
      +prefix = nt_choose(List<&2,String>,terminal,u => chunks,u => Con{"jmp " ++ p111q_label(U32.add(label,2)) ++ "\n",chunks})
      p111q_if_done(label,terminal,p114r_stmts(no,params,ids,
        P111QCode{Con{p111q_label(U32.inc(label)) ++ "\n",prefix},n,False{},error}))


def p114r_drop(body: List<&2,N111Stmt>, count: U32) -> List<&2,N111Stmt>:
  match body count:
    case _ 0: body
    case Con{stmt,rest} _: p114r_drop(rest,U32.sub(count,1))
    case _ _: []

# Frame stored [head,FID]. The original rt_return would pop FID, followed by
# the continuation's pop1. Pop2 performs both before stack_get0. The depth
# guard ensures no caller frame is touched. No rn/next/register state is read.


@unsafe
def p114r_unwind(+head: String, +result: String, +body: List<&2,N111Stmt>, +ids: N111Ids, code: P111QCode) -> P111QCode:
  match code:
    case P111QCode{chunks,n,terminal,error}:
      +prefix = "@p114r_unwind\n%p114r_pending =w cnel %p114r_depth, 0\njnz %p114r_pending, @p114r_resume, @p114r_done\n@p114r_resume\n%p114r_depth =l sub %p114r_depth, 1\n%p114r_popped =l call $p111_rt_stack_pop(l %state, w 2)\n" ++
        p111q_local(p112f_name("p114r_resume_",head)) ++ " =l call $p111_rt_stack_get(l %state, w 0)\n" ++
        p111q_local(p112f_name("p114r_resume_",result)) ++ " =l copy %p114r_value\n"
      +resumed = p111q_stmts(p112f_rename(p114r_prefix(body,3),"p114r_resume_"),ids,
        P111QCode{Con{prefix,chunks},n,False{},error})
      +value = p112f_value(p114r_result_word(p114r_drop(body,3)),"p114r_resume_")
      p114r_finish_code(p114r_jump("@p114r_unwind",p111q_line("%p114r_value =l copy " ++ p111q_value(value,ids) ++ "\n",resumed)))


def p114r_finish_code(code: P111QCode) -> P111QCode:
  match code:
    case P111QCode{chunks,n,terminal,error}:
      P111QCode{Con{"@p114r_done\nret %p114r_value\n",chunks},n,True{},error}


@unsafe
def p114r_private(+name: String, +ids: N111Ids, plan: P114RPlan) -> String:
  match plan:
    case P114RPlan{valid,+params,body,continuation,head,result,unwind}:
      "function l $" ++ p114r_symbol(name) ++ "(" ++ p112w_formals(params,"l %state") ++ ") {\n@entry\n" ++
      p144e_body_tail(p114r_unwind(head,result,unwind,ids,p114r_stmts(body,params,ids,
        P111QCode{["%v_scratch =l alloc8 2048\n%v_p114r_resume_local_scratch =l alloc8 2048\n%p114r_depth =l copy 0\njmp @p114r_descend\n@p114r_descend\n"],0,False{},""})),"}\n")

@unsafe
def p114r_public(+name: String, +arity: U32) -> String:
  "export function l $" ++ p111q_symbol(name) ++ "(l %state) {\n@entry\n%p114r_outer_out =l alloc8 8\n" ++
    p113e_public_loads(arity,0,"") ++ "%p114r_outer_value =l call $" ++ p114r_symbol(name) ++ "(" ++ p113e_public_args(arity,0,"l %state") ++ ")\n" ++
    "storel %p114r_outer_value, %p114r_outer_out\n%p114r_outer_reply =l call $p111_rt_return(l %state, l %p114r_outer_out, w 1)\nret %p114r_outer_reply\n}\n"


@unsafe
def p114r_public_planned(+segment: N111Segment, +index: P112FusionIndex, +ids: N111Ids, +ready: KDef, +plan: P114RPlan) -> String:
  match segment:
    case N111Segment{+name,+arity,result,incoming,flags,+body}:
      nt_choose(String,p114r_hygiene(body,index,plan),
        u => p114r_public(name,arity) ++ p114r_private(name,ids,plan),
        u => p112f_public(segment,ids,ready,p112c_plan_index(segment,index,ready)))


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
        U32.is_gt(arity,0) && U32.is_le(arity,8),
        u => nt_choose(P114GPlan,p112w_ready(ready,name),v => p114g_refused(),
          v => nt_choose(P114GPlan,p112f_clean(body),
            w => p114g_prelude(name,arity,index,ready,p112t_prelude(body,arity)),w => p114g_refused())),
        u => p114g_refused())


@unsafe
def p114g_hygiene(+original: List<&2,N111Stmt>, +index: P112FusionIndex, plan: P114GPlan) -> Bool:
  match plan:
    case P114GPlan{valid,params,body,continuation,captures,result,pop,resume}:
      valid && p114r_clean(original) && p114r_clean_cont(p112f_index_get(index,continuation))


@unsafe
def p114g_resume_symbol(name: String) -> String:
  "p114g_resume_" ++ nt_fid(name)


@unsafe
def p114g_formals(+count: U32, +index: U32, +acc: String) -> String:
  nt_choose(String,U32.is_eq(count,index),u => acc ++ ", l %p114g_input",u =>
    p114g_formals(count,U32.inc(index),acc ++ ", l %p114g_capture_" ++ U32.show(index)))


@unsafe
def p114g_restore(captures: List<&2,String>, +index: U32, code: P111QCode) -> P111QCode:
  match captures:
    case Nil{}: code
    case Con{name,rest}: p114g_restore(rest,U32.inc(index),
      p111q_line(p111q_local(name) ++ " =l copy %p114g_capture_" ++ U32.show(index) ++ "\n",code))


@unsafe
def p114g_pop(+name: String, +code: P111QCode) -> P111QCode:
  nt_choose(P111QCode,String.is_empty(name),u => code,u => p111q_line(p111q_local(name) ++ " =l copy 0\n",code))


@unsafe
def p114g_stmts(body: List<&2,P112WorkerStmt>, +ids: N111Ids, +code: P111QCode) -> P111QCode:
  match body code:
    case Nil{} _: code
    case Con{stmt,rest} P111QCode{chunks,n,terminal,+error}:
      nt_choose(P111QCode,String.is_empty(error),u =>
        nt_choose(P111QCode,terminal,u => p111q_problem("statement after local resume return",code),
          u => p114g_stmts(rest,ids,p114g_stmt(stmt,ids,code))),u => code)


@unsafe
def p114g_stmt(stmt: P112WorkerStmt, +ids: N111Ids, +code: P111QCode) -> P111QCode:
  match stmt:
    case P112WorkerScalar{scalar}: p111q_stmt(scalar,ids,code)
    case P112WorkerIf{condition,yes,no}: p114g_if(condition,yes,no,ids,code)
    case P112WorkerResult{}: p111q_return("%p114g_result",p111q_line("%p114g_result =l loadl %v_scratch\n",code))
    case P112WorkerCall{target,arity}: p112w_call(target,arity,False{},code)
    case P112WorkerAgain{}: p111q_problem("loop in local resume",code)


def p114g_diamond(yes: List<&2,P112WorkerStmt>, no: List<&2,P112WorkerStmt>) -> P113BQDiamond:
  match yes no:
    case Con{P112WorkerScalar{a},Nil{}} Con{P112WorkerScalar{b},Nil{}}: p113bq_scalar([a],[b])
    case _ _: P113BQNo{}


@unsafe
def p114g_if(+condition: N111Value, +yes: List<&2,P112WorkerStmt>, +no: List<&2,P112WorkerStmt>, +ids: N111Ids, +code: P111QCode) -> P111QCode:
  +diamond = p114g_diamond(yes,no)
  nt_choose(P111QCode,p113bq_ready(diamond,code),u => p113bq_emit(condition,diamond,ids,code),
    u => p114g_if_original(condition,yes,no,ids,code))


@unsafe
def p114g_if_original(+condition: N111Value, +yes: List<&2,P112WorkerStmt>, +no: List<&2,P112WorkerStmt>, +ids: N111Ids, code: P111QCode) -> P111QCode:
  match code:
    case P111QCode{chunks,n,terminal,error}:
      p114g_if_yes(n,no,ids,p114g_stmts(yes,ids,
        P111QCode{Con{p111q_label(n) ++ "\n",Con{"jnz " ++ p111q_value(condition,ids) ++ ", " ++ p111q_label(n) ++ ", " ++ p111q_label(U32.inc(n)) ++ "\n",chunks}},U32.add(n,3),False{},error}))


@unsafe
def p114g_if_yes(+label: U32, +no: List<&2,P112WorkerStmt>, +ids: N111Ids, yes: P111QCode) -> P111QCode:
  match yes:
    case P111QCode{+chunks,n,terminal,error}:
      +prefix = nt_choose(List<&2,String>,terminal,u => chunks,u => Con{"jmp " ++ p111q_label(U32.add(label,2)) ++ "\n",chunks})
      p111q_if_done(label,terminal,p114g_stmts(no,ids,P111QCode{Con{p111q_label(U32.inc(label)) ++ "\n",prefix},n,False{},error}))


@unsafe
def p114g_resume(+name: String, +captures: List<&2,String>, +result: String, pop: String, body: List<&2,P112WorkerStmt>, +ids: N111Ids) -> String:
  "function l $" ++ p114g_resume_symbol(name) ++ "(" ++ p114g_formals(nt_count(String,captures),0,"l %state") ++ ") {\n@entry\n" ++
    p144e_body_tail(p114g_stmts(body,ids,
      p111q_line(p111q_local(result) ++ " =l copy %p114g_input\n",
        p114g_restore(captures,0,p114g_pop(pop,P111QCode{["%v_scratch =l alloc8 2048\n"],0,False{},""})))),"}\n")

@unsafe
def p114g_loads(+count: U32, +index: U32, +acc: String) -> String:
  nt_choose(String,U32.is_eq(count,index),u => acc,u =>
    p114g_loads(count,U32.inc(index),acc ++ "%p114g_capture_" ++ U32.show(index) ++
      " =l call $p111_rt_stack_get(l %state, w " ++ U32.show(index) ++ ")\n"))


@unsafe
def p114g_args(+count: U32, +index: U32, +acc: String) -> String:
  nt_choose(String,U32.is_eq(count,index),u => acc ++ ", l %p114r_value",u =>
    p114g_args(count,U32.inc(index),acc ++ ", l %p114g_capture_" ++ U32.show(index)))


@unsafe
def p114g_unwind(+name: String, +count: U32, code: P111QCode) -> P111QCode:
  match code:
    case P111QCode{chunks,n,terminal,error}:
      P111QCode{Con{"@p114r_unwind\n%p114r_pending =w cnel %p114r_depth, 0\njnz %p114r_pending, @p114r_resume, @p114r_done\n@p114r_resume\n%p114r_depth =l sub %p114r_depth, 1\n%p114g_popped =l call $p111_rt_stack_pop(l %state, w " ++ U32.show(U32.inc(count)) ++ ")\n" ++
        p114g_loads(count,0,"") ++ "%p114r_value =l call $" ++ p114g_resume_symbol(name) ++ "(" ++ p114g_args(count,0,"l %state") ++ ")\njmp @p114r_unwind\n@p114r_done\nret %p114r_value\n",chunks},n,True{},error}


@unsafe
def p114g_private(+name: String, +ids: N111Ids, plan: P114GPlan) -> String:
  match plan:
    case P114GPlan{valid,+params,body,continuation,+captures,result,pop,resume}:
      "function l $" ++ p114r_symbol(name) ++ "(" ++ p112w_formals(params,"l %state") ++ ") {\n@entry\n" ++
        p144e_body_tail(p114g_unwind(name,nt_count(String,captures),p114r_stmts(body,params,ids,
          P111QCode{["%v_scratch =l alloc8 2048\n%p114r_depth =l copy 0\njmp @p114r_descend\n@p114r_descend\n"],0,False{},""})),"}\n") ++
        p114g_resume(name,captures,result,pop,resume,ids)

@unsafe
def p114g_public_planned(+segment: N111Segment, +index: P112FusionIndex, +ids: N111Ids, +ready: KDef, +plan: P114GPlan) -> String:
  match segment:
    case N111Segment{+name,+arity,result,incoming,flags,+body}:
      nt_choose(String,p114g_hygiene(body,index,plan),
        u => p114r_public(name,arity) ++ p114g_private(name,ids,plan),
        u => p112f_public(segment,ids,ready,p112c_plan_index(segment,index,ready)))

# Retain the qualified narrow path byte-for-byte where it already applies.


@unsafe
def p114g_public_pick(+segment: N111Segment, +index: P112FusionIndex, +ids: N111Ids, +ready: KDef, +old: P114RPlan) -> String:
  match segment:
    case N111Segment{+name,+arity,result,incoming,flags,+body}:
      nt_choose(String,p114r_hygiene(body,index,old),
        u => p114r_public(name,arity) ++ p114r_private(name,ids,old),
        u => p114g_public_planned(segment,index,ids,ready,p114g_plan(segment,index,ready)))


@unsafe
def p114g_entries(segments: List<&2,N111Segment>, +index: P112FusionIndex, +ready: KDef) -> List<&2,String>:
  match segments:
    case Nil{}: []
    case Con{+segment,+rest}:
      match segment:
        case N111Segment{+name,arity,result,incoming,flags,+body}:
          nt_choose(List<&2,String>,p114g_hygiene(body,index,p114g_plan(segment,index,ready)),
            u => Con{name,p114g_entries(rest,index,ready)},u => p114g_entries(rest,index,ready))


@unsafe
def p114g_inspect_registry(+segments: List<&2,N111Segment>, +index: P112FusionIndex, registry: P112RegionRegistry) -> P114RInspection:
  match registry:
    case P112RegionRegistry{ready,symbols,entries,workers,fusions}: P114RInspection{p114g_entries(segments,index,ready),""}


@unsafe
def p114g_inspect_index(+segments: List<&2,N111Segment>, +index: P112FusionIndex) -> P114RInspection:
  p114g_inspect_registry(segments,index,p112c_index_with(segments,index))


@unsafe
def p114g_inspect_program(+program: P113AProgram, +error: String) -> P114RInspection:
  match program:
    case P113AProgram{P113DProgram{P112StaticProgram{P111Program{+segments,constructors,show,names,effects,pure},nodes},functions},certificate}:
      nt_choose(P114RInspection,String.is_empty(error),
        u => p114g_inspect_index(segments,p112f_index(segments)),u => P114RInspection{[],error})


@unsafe
def p114g_inspect_lowered(lowered: P113ALowering) -> P114RInspection:
  match lowered:
    case P113ALowered{+program,+error}:
      p114g_inspect_program(program,nt_choose(String,String.is_empty(error),u => p113a_verify(program),u => error))


@unsafe
def p114g_inspect_request(request: NR_Request) -> P114RInspection:
  p114g_inspect_lowered(p113a_lower_request(request))


@unsafe
def p114h_clean_name(+name: String) -> Bool:
  Bool.not(String.starts_with(name,"p114h_") || String.starts_with(name,"p114r_"))


def p114h_clean_value(value: N111Value) -> Bool:
  match value:
    case N111Local{name}: p114h_clean_name(name)
    case _: True{}


def p114h_clean_args(args: List<&2,N111Arg>) -> Bool:
  match args:
    case Nil{}: True{}
    case Con{N111Arg{typ,value},rest}: p114h_clean_value(value) && p114h_clean_args(rest)


@unsafe
def p114h_clean(body: List<&2,N111Stmt>) -> Bool:
  match body:
    case Nil{}: True{}
    case Con{stmt,rest}: p114h_clean_stmt(stmt) && p114h_clean(rest)


@unsafe
def p114h_clean_stmt(stmt: N111Stmt) -> Bool:
  match stmt:
    case N111Set{name,typ,value}: p114h_clean_name(name) && p114h_clean_value(value)
    case N111Bin{name,typ,op,left,right}: p114h_clean_name(name) && p114h_clean_value(left) && p114h_clean_value(right)
    case N111Call{name,typ,symbol,args}: p114h_clean_name(name) && p114h_clean_args(args)
    case N111If{condition,yes,no}: p114h_clean_value(condition) && p114h_clean(yes) && p114h_clean(no)
    case N111Return{value}: p114h_clean_value(value)
    case N111Load{name,typ,base,offset}: p114h_clean_name(name) && p114h_clean_value(base)
    case N111Store{typ,base,offset,value}: p114h_clean_value(base) && p114h_clean_value(value)
    case N111Offset{name,base,bytes}: p114h_clean_name(name) && p114h_clean_value(base) && p114h_clean_value(bytes)
    case N111Alloca{name,bytes,align}: p114h_clean_name(name)


def p114h_clean_segment(segment: N111Segment) -> Bool:
  match segment:
    case N111Segment{name,arity,result,incoming,flags,body}: p114h_clean(body)


def p114h_refused() -> P114HPlan:
  P114HPlan{False{},[],[],[]}


def p114h_scalars(body: List<&2,N111Stmt>, tail: List<&2,P114RStmt>) -> List<&2,P114RStmt>:
  match body:
    case Nil{}: tail
    case Con{stmt,rest}: Con{P114RScalar{stmt},p114h_scalars(rest,tail)}


@unsafe
def p114h_call_name(index: U32) -> String:
  "p114h_arg_" ++ U32.show(index)


@unsafe
def p114h_call_loads(+count: U32, +index: U32) -> List<&2,N111Stmt>:
  nt_choose(List<&2,N111Stmt>,U32.is_eq(count,index),u => [],u =>
    Con{N111Load{p114h_call_name(index),N111U64{},N111Local{"scratch"},U32.mul(index,8)},p114h_call_loads(count,U32.inc(index))})


@unsafe
def p114h_call_args(+count: U32, +index: U32) -> List<&2,N111Arg>:
  nt_choose(List<&2,N111Arg>,U32.is_eq(count,index),u => [],u =>
    Con{N111Arg{N111U64{},N111Local{p114h_call_name(index)}},p114h_call_args(count,U32.inc(index))})

# Exact terminal stores have already been checked. Snapshot every argument
# before the private call, preserving the owning single-Term result boundary.


@unsafe
def p114h_call(+body: List<&2,N111Stmt>, target: String, +count: U32) -> P114GBody:
  P114GBody{True{},[],p114h_scalars(p114r_prefix(body,count),
    p114h_scalars(p114h_call_loads(count,0),[
      P114RScalar{N111Call{"p114h_call_result",N111U64{},p112w_symbol(target),Con{p111_state(),p114h_call_args(count,0)}}},
      P114RResult{N111Local{"p114h_call_result"}}]))}


@unsafe
def p114h_scan(+body: List<&2,N111Stmt>, +owner: String, +arity: U32, +ready: KDef) -> P114GBody:
  nt_choose(P114GBody,p112t_failure(body),u => P114GBody{True{},[],[P114RFailure{body}]},
    u => p114h_scan_normal(body,owner,arity,ready))


@unsafe
def p114h_scan_normal(+body: List<&2,N111Stmt>, +owner: String, +arity: U32, +ready: KDef) -> P114GBody:
  nt_choose(P114GBody,p112w_result(body),
    u => P114GBody{True{},[],[P114RResult{p114r_result_word(body)}]},u =>
  nt_choose(P114GBody,p112t_tail(body,owner,arity,0),
    u => P114GBody{True{},[],[P114RAgain{p114r_without_transition(body)}]},
    u => p114h_scan_target(body,owner,arity,ready,p112w_target(body))))


@unsafe
def p114h_scan_target(+body: List<&2,N111Stmt>, +owner: String, +arity: U32, +ready: KDef, +target: String) -> P114GBody:
  nt_choose(P114GBody,p124r_is_view(ready),
    u => p124r_terminal(body,owner,arity,ready,target,p124r_lookup(ready,target)),
    u => p124r_original_target(body,owner,arity,ready,target))

@unsafe
def p114h_scan_frame(+body: List<&2,N111Stmt>, +owner: String, +arity: U32, +ready: KDef, frame: Maybe<&2,P112FusionFrame>) -> P114GBody:
  match frame:
    case Some{P112FusionFrame{captures,+name,dest,+tail}}:
      +count = nt_count(N111Value,captures)
      nt_choose(P114GBody,U32.is_le(count,8) && p126r_arguments(tail,owner,arity),
        u => P114GBody{True{},[P114GFrame{name,count}],[P114RDescend{p114r_prefix(body,U32.inc(count)),p114r_without_transition(tail)}]},
        u => p124r_resume(body,tail,owner,name,count,ready))
    case None{}: p114h_scan_next(body,owner,arity,ready)

@unsafe
def p114h_scan_next(body: List<&2,N111Stmt>, +owner: String, +arity: U32, +ready: KDef) -> P114GBody:
  match body:
    case Nil{}: P114GBody{True{},[],[]}
    case Con{N111If{condition,yes,no},rest}:
      p114g_branch(condition,p114h_scan(yes,owner,arity,ready),p114h_scan(no,owner,arity,ready),p114h_scan(rest,owner,arity,ready))
    case Con{+stmt,+rest}:
      nt_choose(P114GBody,p112t_scalar_safe(stmt),
        u => p114g_prepend(stmt,p114h_scan_normal(rest,owner,arity,ready)),
        u => p114g_prepend(stmt,p114h_scan(rest,owner,arity,ready)))

# A missing case has an impossible capture count; real layouts are 0..8.


@unsafe
def p114h_count(cases: List<&2,P114HCase>, +name: String) -> U32:
  match cases:
    case Nil{}: 4294967295
    case Con{P114HCase{key,captures,result,pop,body},rest}:
      nt_choose(U32,String.eq(key,name),u => nt_count(String,captures),u => p114h_count(rest,name))


@unsafe
def p114h_close(pending: List<&2,P114GFrame>, +owner: String, +arity: U32, +index: P112FusionIndex,
    +ready: KDef, +cases: List<&2,P114HCase>, +left: U32) -> P114HClosed:
  match pending:
    case Nil{}: P114HClosed{True{},nt_reverse(P114HCase,cases,[])}
    case Con{P114GFrame{+name,count},rest}:
      p114h_close_seen(name,count,rest,owner,arity,index,ready,cases,left,p114h_count(cases,name))


@unsafe
def p114h_close_seen(+name: String, +count: U32, +rest: List<&2,P114GFrame>, +owner: String, +arity: U32,
    +index: P112FusionIndex, +ready: KDef, +cases: List<&2,P114HCase>, +left: U32, +seen: U32) -> P114HClosed:
  nt_choose(P114HClosed,U32.is_eq(seen,4294967295),u =>
    nt_choose(P114HClosed,U32.is_gt(left,0),
      v => p114h_close_found(name,count,rest,owner,arity,index,ready,cases,U32.sub(left,1),p112f_index_get(index,name)),
      v => P114HClosed{False{},[]}),u =>
    nt_choose(P114HClosed,U32.is_eq(seen,count),
      v => p114h_close(rest,owner,arity,index,ready,cases,left),v => P114HClosed{False{},[]}))


@unsafe
def p114h_close_found(+name: String, +count: U32, +rest: List<&2,P114GFrame>, +owner: String, +arity: U32,
    +index: P112FusionIndex, +ready: KDef, +cases: List<&2,P114HCase>, +left: U32, found: Maybe<&2,N111Segment>) -> P114HClosed:
  match found:
    case Some{+segment}:
      nt_choose(P114HClosed,p114h_clean_segment(segment),
        u => p114h_close_cont(name,rest,owner,arity,index,ready,cases,left,p112f_cont(segment,count)),
        u => P114HClosed{False{},[]})
    case None{}: P114HClosed{False{},[]}


@unsafe
def p114h_close_cont(+name: String, +rest: List<&2,P114GFrame>, +owner: String, +arity: U32,
    +index: P112FusionIndex, +ready: KDef, +cases: List<&2,P114HCase>, +left: U32, cont: Maybe<&2,P112FusionCont>) -> P114HClosed:
  match cont:
    case Some{P112FusionCont{captures,result,pop,body}}:
      p114h_close_scanned(name,captures,result,pop,rest,owner,arity,index,ready,cases,left,p114h_scan(body,owner,arity,ready))
    case None{}: P114HClosed{False{},[]}


@unsafe
def p114h_close_scanned(+name: String, +captures: List<&2,String>, +result: String, +pop: String,
    +rest: List<&2,P114GFrame>, +owner: String, +arity: U32, +index: P112FusionIndex, +ready: KDef,
    +cases: List<&2,P114HCase>, +left: U32, scanned: P114GBody) -> P114HClosed:
  match scanned:
    case P114GBody{valid,frames,body}:
      nt_choose(P114HClosed,valid,u => p114h_close(nt_append(P114GFrame,frames,rest),owner,arity,index,ready,
        Con{P114HCase{name,captures,result,pop,body},cases},left),u => P114HClosed{False{},[]})


def p114h_closed(params: List<&2,String>, body: List<&2,P114RStmt>, closed: P114HClosed) -> P114HPlan:
  match closed:
    case P114HClosed{valid,cases}: P114HPlan{valid,params,body,cases}


@unsafe
def p114h_finish(+params: List<&2,String>, +owner: String, +arity: U32, +index: P112FusionIndex,
    +ready: KDef, scanned: P114GBody) -> P114HPlan:
  match scanned:
    case P114GBody{valid,+frames,body}:
      nt_choose(P114HPlan,valid && U32.is_gt(nt_count(P114GFrame,frames),0),
        u => p114h_closed(params,body,p114h_close(frames,owner,arity,index,ready,[],8)),u => p114h_refused())


@unsafe
def p114h_prelude(+owner: String, +arity: U32, +index: P112FusionIndex, +ready: KDef, prelude: P112TailPrelude) -> P114HPlan:
  match prelude:
    case P112TailPrelude{valid,params,prefix,body}:
      nt_choose(P114HPlan,valid,u => p114h_finish(params,owner,arity,index,ready,p114h_scan(body,owner,arity,ready)),u => p114h_refused())

@unsafe
def p114h_plan(+segment: N111Segment, +index: P112FusionIndex, +ready: KDef) -> P114HPlan:
  match segment:
    case N111Segment{+name,+arity,result,incoming,flags,+body}:
      nt_choose(P114HPlan,U32.is_eq(result,1) && U32.is_eq(incoming,0) && U32.is_eq(flags,0) &&
        U32.is_gt(arity,0) && U32.is_le(arity,8),
        u => nt_choose(P114HPlan,p124r_known(ready,name),v => p114h_refused(),
          v => nt_choose(P114HPlan,U32.is_le(p112f_size(body),512),
            w => nt_choose(P114HPlan,p112f_clean(body),
              x => nt_choose(P114HPlan,p114h_clean_segment(segment),
                y => p114h_prelude(name,arity,index,ready,p112t_prelude(body,arity)),y => p114h_refused()),
              x => p114h_refused()),w => p114h_refused())),
        u => p114h_refused())

def p114h_valid(plan: P114HPlan) -> Bool:
  match plan:
    case P114HPlan{valid,params,body,cases}: valid


@unsafe
def p114h_prefix(index: U32) -> String:
  "p114h_case_" ++ U32.show(index) ++ "_"


@unsafe
def p114h_rename(body: List<&2,P114RStmt>, +prefix: String) -> List<&2,P114RStmt>:
  match body:
    case Nil{}: []
    case Con{stmt,rest}: Con{p114h_rename_stmt(stmt,prefix),p114h_rename(rest,prefix)}


@unsafe
def p114h_rename_stmt(stmt: P114RStmt, +prefix: String) -> P114RStmt:
  match stmt:
    case P114RScalar{scalar}: P114RScalar{p112f_stmt(scalar,prefix)}
    case P114RIf{condition,yes,no}: P114RIf{p112f_value(condition,prefix),p114h_rename(yes,prefix),p114h_rename(no,prefix)}
    case P114RDescend{frame,arguments}: P114RDescend{p112f_rename(frame,prefix),p112f_rename(arguments,prefix)}
    case P114RAgain{arguments}: P114RAgain{p112f_rename(arguments,prefix)}
    case P114RResult{value}: P114RResult{p112f_value(value,prefix)}
    case P114RFailure{body}: P114RFailure{p112f_rename(body,prefix)}
    case P114RResumeReady{frame,call,result}: P114RResumeReady{p112f_rename(frame,prefix),p112f_rename(call,prefix),p112f_value(result,prefix)}

@unsafe
def p114h_snapshots(+buffer: String, +count: U32, +index: U32, +code: P111QCode) -> P111QCode:
  nt_choose(P111QCode,U32.is_eq(count,index),u => code,u =>
    p114h_snapshots(buffer,count,U32.inc(index),p111q_line("%p114h_slot_" ++ U32.show(index) ++ " =l add " ++
      p111q_local(buffer) ++ ", " ++ U32.show(U32.mul(index,8)) ++ "\n%p114h_edge_" ++ U32.show(index) ++
      " =l loadl %p114h_slot_" ++ U32.show(index) ++ "\n",code)))


@unsafe
def p114h_moves(params: List<&2,String>, +index: U32, code: P111QCode) -> P111QCode:
  match params:
    case Nil{}: p114r_jump("@p114r_descend",code)
    case Con{name,rest}: p114h_moves(rest,U32.inc(index),
      p111q_line(p111q_local(name) ++ " =l copy %p114h_edge_" ++ U32.show(index) ++ "\n",code))


@unsafe
def p114h_again(arguments: List<&2,N111Stmt>, +params: List<&2,String>, buffer: String, ids: N111Ids, code: P111QCode) -> P111QCode:
  p114h_moves(params,0,p114h_snapshots(buffer,nt_count(String,params),0,p111q_stmts(arguments,ids,code)))


@unsafe
def p114h_stmts(body: List<&2,P114RStmt>, +params: List<&2,String>, +buffer: String, +ids: N111Ids, +code: P111QCode) -> P111QCode:
  match body code:
    case Nil{} _: code
    case Con{stmt,rest} P111QCode{chunks,n,terminal,+error}:
      nt_choose(P111QCode,String.is_empty(error),u =>
        nt_choose(P111QCode,terminal,u => p111q_problem("statement after table-region transfer",code),
          u => p114h_stmts(rest,params,buffer,ids,p114h_stmt(stmt,params,buffer,ids,code))),u => code)


@unsafe
def p114h_stmt(+stmt: P114RStmt, +params: List<&2,String>, +buffer: String, +ids: N111Ids, +code: P111QCode) -> P111QCode:
  match stmt:
    case P114RIf{condition,yes,no}: p114h_if(condition,yes,no,params,buffer,ids,code)
    case P114RDescend{frame,arguments}:
      p114h_again(arguments,params,buffer,ids,p111q_line("%p114r_depth =l add %p114r_depth, 1\n",p111q_stmts(frame,ids,code)))
    case P114RAgain{arguments}: p114h_again(arguments,params,buffer,ids,code)
    case P114RResumeReady{frame,call,result}:
      p114r_stmt(P114RResult{result},params,ids,p111q_stmts(call,ids,
        p111q_line("%p114r_depth =l add %p114r_depth, 1\n",p111q_stmts(frame,ids,code))))
    case _: p114r_stmt(stmt,params,ids,code)

@unsafe
def p114h_if(+condition: N111Value, +yes: List<&2,P114RStmt>, +no: List<&2,P114RStmt>,
    +params: List<&2,String>, +buffer: String, +ids: N111Ids, +code: P111QCode) -> P111QCode:
  +diamond = p114r_diamond(yes,no)
  nt_choose(P111QCode,p113bq_ready(diamond,code),u => p113bq_emit(condition,diamond,ids,code),
    u => p114h_if_original(condition,yes,no,params,buffer,ids,code))


@unsafe
def p114h_if_original(+condition: N111Value, +yes: List<&2,P114RStmt>, +no: List<&2,P114RStmt>,
    +params: List<&2,String>, +buffer: String, +ids: N111Ids, code: P111QCode) -> P111QCode:
  match code:
    case P111QCode{chunks,n,terminal,error}:
      p114h_if_yes(n,no,params,buffer,ids,p114h_stmts(yes,params,buffer,ids,
        P111QCode{Con{p111q_label(n) ++ "\n",Con{"jnz " ++ p111q_value(condition,ids) ++ ", " ++ p111q_label(n) ++ ", " ++ p111q_label(U32.inc(n)) ++ "\n",chunks}},U32.add(n,3),False{},error}))


@unsafe
def p114h_if_yes(+label: U32, +no: List<&2,P114RStmt>, +params: List<&2,String>, +buffer: String, +ids: N111Ids, yes: P111QCode) -> P111QCode:
  match yes:
    case P111QCode{+chunks,n,terminal,error}:
      +prefix = nt_choose(List<&2,String>,terminal,u => chunks,u => Con{"jmp " ++ p111q_label(U32.add(label,2)) ++ "\n",chunks})
      p111q_if_done(label,terminal,p114h_stmts(no,params,buffer,ids,
        P111QCode{Con{p111q_label(U32.inc(label)) ++ "\n",prefix},n,False{},error}))


@unsafe
def p114h_terminal(+code: P111QCode) -> P111QCode:
  match code:
    case P111QCode{chunks,n,terminal,error}:
      nt_choose(P111QCode,terminal,u => code,u => p111q_problem("unterminated table-region block",code))


@unsafe
def p114h_buffers(+count: U32, +index: U32, +acc: String) -> String:
  nt_choose(String,U32.is_eq(count,index),u => acc,u =>
    p114h_buffers(count,U32.inc(index),acc ++ p111q_local(p112f_name(p114h_prefix(index),"scratch")) ++ " =l alloc8 2048\n"))


@unsafe
def p114h_dispatch(cases: List<&2,P114HCase>, +index: U32, +ids: N111Ids, acc: String) -> String:
  match cases:
    case Nil{}: acc ++ "%p114h_bad =l call $p111_rt_fail(l %state, w 4)\nret %p114h_bad\n"
    case Con{P114HCase{name,captures,result,pop,body},rest}:
      p114h_dispatch(rest,U32.inc(index),ids,acc ++ "%p114h_test_" ++ U32.show(index) ++
        " =w ceql %p114h_fid, " ++ p111q_value(N111FuncId{name},ids) ++ "\njnz %p114h_test_" ++ U32.show(index) ++
        ", @p114h_case_" ++ U32.show(index) ++ ", @p114h_next_" ++ U32.show(index) ++ "\n@p114h_next_" ++ U32.show(index) ++ "\n")


@unsafe
def p114h_restore(captures: List<&2,String>, +index: U32, +prefix: String, acc: String) -> String:
  match captures:
    case Nil{}: acc
    case Con{name,rest}: p114h_restore(rest,U32.inc(index),prefix,acc ++ p111q_local(p112f_name(prefix,name)) ++
      " =l call $p111_rt_stack_get(l %state, w " ++ U32.show(index) ++ ")\n")


@unsafe
def p114h_pop_text(+pop: String, +prefix: String) -> String:
  nt_choose(String,String.is_empty(pop),u => "",u => p111q_local(p112f_name(prefix,pop)) ++ " =l copy 0\n")


@unsafe
def p114h_case_prefix(+captures: List<&2,String>, result: String, pop: String, +index: U32) -> String:
  +count = nt_count(String,captures)
  "@p114h_case_" ++ U32.show(index) ++ "\n" ++
    nt_choose(String,U32.is_eq(count,0),u => "",u => "%p114h_popped =l call $p111_rt_stack_pop(l %state, w " ++ U32.show(count) ++ ")\n") ++
    p114h_pop_text(pop,p114h_prefix(index)) ++ p114h_restore(captures,0,p114h_prefix(index),"") ++
    p111q_local(p112f_name(p114h_prefix(index),result)) ++ " =l copy %p114r_value\n"


@unsafe
def p114h_cases(cases: List<&2,P114HCase>, +index: U32, +params: List<&2,String>, +ids: N111Ids, code: P111QCode) -> P111QCode:
  match cases code:
    case Nil{} _: code
    case Con{P114HCase{name,captures,result,pop,body},rest} P111QCode{chunks,n,terminal,error}:
      p114h_cases(rest,U32.inc(index),params,ids,p114h_terminal(p114h_stmts(p114h_rename(body,p114h_prefix(index)),params,
        p112f_name(p114h_prefix(index),"scratch"),ids,p114hs_case(captures,result,pop,index,ids,
          P111QCode{Con{"@p114h_case_" ++ U32.show(index) ++ "\n",chunks},n,False{},error}))))

@unsafe
def p114h_unwind(+cases: List<&2,P114HCase>, +params: List<&2,String>, +ids: N111Ids, code: P111QCode) -> P111QCode:
  match code:
    case P111QCode{chunks,n,terminal,error}:
      p114hs_dispatch(cases,params,ids,p114hs_stack("p111_rt_stack_get","p114h_fid",0,ids,
        p114hs_stack("p111_rt_stack_pop","p114h_popped",1,ids,P111QCode{Con{
          "@p114r_unwind\n%p114r_pending =w cnel %p114r_depth, 0\njnz %p114r_pending, @p114h_dispatch, @p114h_done\n@p114h_done\nret %p114r_value\n@p114h_dispatch\n%p114r_depth =l sub %p114r_depth, 1\n",chunks},n,False{},error})))

@unsafe
def p114h_private(+name: String, +ids: N111Ids, plan: P114HPlan) -> String:
  match plan:
    case P114HPlan{valid,+params,body,+cases}:
      "function l $" ++ p114r_symbol(name) ++ "(" ++ p112w_formals(params,"l %state") ++ ") {\n@entry\n" ++
        p144e_body_tail(p114h_unwind(cases,params,ids,p114h_terminal(p114h_stmts(body,params,"scratch",ids,
          P111QCode{["%v_scratch =l alloc8 2048\n" ++ p114h_buffers(nt_count(P114HCase,cases),0,"") ++
            "%p114r_depth =l copy 0\njmp @p114r_descend\n@p114r_descend\n"],0,False{},""}))),"}\n")

@unsafe
def p114h_public_planned(+segment: N111Segment, +index: P112FusionIndex, +ids: N111Ids, +ready: KDef, +plan: P114HPlan) -> String:
  match segment:
    case N111Segment{+name,+arity,result,incoming,flags,body}:
      nt_choose(String,p114h_valid(plan),
        u => p114r_public(name,arity) ++ p114h_private(name,ids,plan),
        u => p112f_public(segment,ids,ready,p112c_plan_index(segment,index,ready)))


@unsafe
def p114h_public_g(+segment: N111Segment, +index: P112FusionIndex, +ids: N111Ids, +ready: KDef, +old: P114GPlan) -> String:
  match segment:
    case N111Segment{+name,+arity,result,incoming,flags,+body}:
      nt_choose(String,p114g_hygiene(body,index,old),
        u => p114r_public(name,arity) ++ p114g_private(name,ids,old),
        u => p114h_public_planned(segment,index,ids,ready,p114h_plan(segment,index,ready)))


@unsafe
def p114h_public_r(+segment: N111Segment, +index: P112FusionIndex, +ids: N111Ids, +ready: KDef, +old: P114RPlan) -> String:
  match segment:
    case N111Segment{+name,+arity,result,incoming,flags,+body}:
      nt_choose(String,p114r_hygiene(body,index,old),
        u => p114r_public(name,arity) ++ p114r_private(name,ids,old),
        u => p114h_public_g(segment,index,ids,ready,p114g_plan(segment,index,ready)))


def p114h_case_names(cases: List<&2,P114HCase>) -> List<&2,String>:
  match cases:
    case Nil{}: []
    case Con{P114HCase{name,captures,result,pop,body},rest}: Con{name,p114h_case_names(rest)}


@unsafe
def p114h_inspect_entry(+name: String, +tail: List<&2,P114HEntry>, plan: P114HPlan) -> List<&2,P114HEntry>:
  match plan:
    case P114HPlan{valid,params,body,cases}:
      nt_choose(List<&2,P114HEntry>,valid,u => Con{P114HEntry{name,p114h_case_names(cases)},tail},u => tail)


@unsafe
def p114h_entries(segments: List<&2,N111Segment>, +index: P112FusionIndex, +ready: KDef) -> List<&2,P114HEntry>:
  match segments:
    case Nil{}: []
    case Con{+segment,rest}:
      match segment:
        case N111Segment{name,arity,result,incoming,flags,body}:
          p114h_inspect_entry(name,p114h_entries(rest,index,ready),p114h_plan(segment,index,ready))


@unsafe
def p114h_inspect_registry(+segments: List<&2,N111Segment>, +index: P112FusionIndex, registry: P112RegionRegistry) -> P114HInspection:
  match registry:
    case P112RegionRegistry{ready,symbols,entries,workers,fusions}: P114HInspection{p114h_entries(segments,index,ready),""}


@unsafe
def p114h_inspect_index(+segments: List<&2,N111Segment>, +index: P112FusionIndex) -> P114HInspection:
  p114h_inspect_registry(segments,index,p112c_index_with(segments,index))


@unsafe
def p114h_inspect_program(+program: P113AProgram, +error: String) -> P114HInspection:
  match program:
    case P113AProgram{P113DProgram{P112StaticProgram{P111Program{+segments,constructors,show,names,effects,pure},nodes},functions},certificate}:
      nt_choose(P114HInspection,String.is_empty(error),
        u => p114h_inspect_index(segments,p112f_index(segments)),u => P114HInspection{[],error})


@unsafe
def p114h_inspect_lowered(lowered: P113ALowering) -> P114HInspection:
  match lowered:
    case P113ALowered{+program,+error}:
      p114h_inspect_program(program,nt_choose(String,String.is_empty(error),u => p113a_verify(program),u => error))


@unsafe
def p114h_inspect_request(request: NR_Request) -> P114HInspection:
  p114h_inspect_lowered(p113a_lower_request(request))

@unsafe
def p114hs_stack(symbol: String, dest: String, count: U32, ids: N111Ids, code: P111QCode) -> P111QCode:
  p114t_stmt(N111Call{dest,N111U64{},symbol,[p111_state(),N111Arg{N111U32{},N111Const{count,0}}]},ids,code)


@unsafe
def p114hs_restore(captures: List<&2,String>, +index: U32, +prefix: String, +ids: N111Ids, code: P111QCode) -> P111QCode:
  match captures:
    case Nil{}: code
    case Con{name,rest}: p114hs_restore(rest,U32.inc(index),prefix,ids,
      p114hs_stack("p111_rt_stack_get",p112f_name(prefix,name),index,ids,code))


@unsafe
def p114hs_case(+captures: List<&2,String>, result: String, pop: String, +index: U32, +ids: N111Ids, +code: P111QCode) -> P111QCode:
  +count = nt_count(String,captures)
  p111q_line(p111q_local(p112f_name(p114h_prefix(index),result)) ++ " =l copy %p114r_value\n",
    p114hs_restore(captures,0,p114h_prefix(index),ids,p111q_line(p114h_pop_text(pop,p114h_prefix(index)),
      nt_choose(P111QCode,U32.is_eq(count,0),u => code,
        u => p114hs_stack("p111_rt_stack_pop","p114h_popped",count,ids,code)))))


@unsafe
def p114hs_dispatch(+cases: List<&2,P114HCase>, params: List<&2,String>, +ids: N111Ids, code: P111QCode) -> P111QCode:
  match code:
    case P111QCode{chunks,n,terminal,error}:
      p114h_cases(cases,0,params,ids,P111QCode{Con{
        "%p114h_fid =l copy " ++ p111q_local("p114h_fid") ++ "\n" ++ p114h_dispatch(cases,0,ids,""),chunks},n,True{},error})


@unsafe
def p114hf_planned(+segment: N111Segment, +index: P112FusionIndex, +ids: N111Ids, +ready: KDef, +plan: P114HPlan) -> String:
  match segment:
    case N111Segment{+name,+arity,result,incoming,flags,body}:
      nt_choose(String,p114h_valid(plan),
        u => p114r_public(name,arity) ++ p114h_private(name,ids,plan),
        u => p114h_public_r(segment,index,ids,ready,p114r_plan(segment,index)))
