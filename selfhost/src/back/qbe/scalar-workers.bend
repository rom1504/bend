

@unsafe
def p112w_ready(+ready: KDef, +name: String) -> Bool:
  String.eq(dk(p111v_get(ready,name)),"P112Worker")


@unsafe
def p112w_result_args(args: List<&2,N111Arg>) -> Bool:
  match args:
    case Con{N111Arg{N111Ptr{},N111Local{state}},Con{N111Arg{N111Ptr{},N111Local{scratch}},Con{N111Arg{N111U32{},N111Const{1,0}},Nil{}}}}:
      String.eq(state,"state") && String.eq(scratch,"scratch")
    case _: False{}


@unsafe
def p112w_result(body: List<&2,N111Stmt>) -> Bool:
  match body:
    case Con{N111Store{N111U64{},N111Local{scratch},0,value},Con{N111Call{dest,N111U64{},symbol,args},Con{N111Return{N111Local{word}},Nil{}}}}:
      String.eq(scratch,"scratch") && String.eq(symbol,"p111_rt_return") && String.eq(dest,word) && p112w_result_args(args)
    case _: False{}

# Candidate discovery is not admission: ordered stores, arity and the complete
# terminal transition are checked again by p112t_tail.


@unsafe
def p112w_target(body: List<&2,N111Stmt>) -> String:
  match body:
    case Con{N111Store{N111U64{},N111Local{scratch},offset,value},rest}:
      nt_choose(String,String.eq(scratch,"scratch"),u => p112w_target(rest),u => "")
    case Con{N111Call{dest,N111U64{},symbol,Con{state,Con{N111Arg{N111U32{},N111FuncId{name}},rest}}},Con{N111Return{value},Nil{}}}:
      nt_choose(String,String.eq(symbol,"p111_rt_jump"),u => name,u => "")
    case _: ""


@unsafe
def p112w_nodes(body: List<&2,N111Stmt>, left: U32, +last: P112WorkerStmt) -> List<&2,P112WorkerStmt>:
  match body left:
    case _ 0: [last]
    case Con{stmt,rest} _: Con{P112WorkerScalar{stmt},p112w_nodes(rest,U32.sub(left,1),last)}
    case _ _: []


@unsafe
def p112w_prepend(+stmt: N111Stmt, tail: P112WorkerBody) -> P112WorkerBody:
  match tail:
    case P112WorkerBody{valid,calls,body}: P112WorkerBody{valid && p112t_scalar_safe(stmt),calls,Con{P112WorkerScalar{stmt},body}}


@unsafe
def p112w_branch(+condition: N111Value, yes: P112WorkerBody, no: P112WorkerBody, tail: P112WorkerBody) -> P112WorkerBody:
  match yes no tail:
    case P112WorkerBody{yv,yc,yb} P112WorkerBody{nv,nc,nb} P112WorkerBody{tv,tc,tb}:
      P112WorkerBody{yv && nv && tv,U32.add(yc,U32.add(nc,tc)),Con{P112WorkerIf{condition,yb,nb},tb}}


@unsafe
def p112w_scan(+body: List<&2,N111Stmt>, +owner: String, +arity: U32, +ready: KDef) -> P112WorkerBody:
  nt_choose(P112WorkerBody,p112t_failure(body),u => P112WorkerBody{True{},0,p112w_failure_nodes(body)},u =>
    p112w_scan_normal(body,owner,arity,ready))

@unsafe
def p112w_scan_target(+body: List<&2,N111Stmt>, +owner: String, +arity: U32, +ready: KDef, +target: String) -> P112WorkerBody:
  +count = da(p111v_get(ready,target))
  nt_choose(P112WorkerBody,p112w_ready(ready,target) && Bool.not(String.eq(owner,target)) && p112t_tail(body,target,count,0),
    u => P112WorkerBody{True{},1,p112w_nodes(body,count,P112WorkerCall{target,count})},
    u => p112w_scan_next(body,owner,arity,ready))


@unsafe
def p112w_scan_next(body: List<&2,N111Stmt>, +owner: String, +arity: U32, +ready: KDef) -> P112WorkerBody:
  match body:
    case Nil{}: P112WorkerBody{True{},0,[]}
    case Con{N111If{condition,yes,no},rest}:
      p112e_worker_yes(condition,no,rest,owner,arity,ready,p112w_scan(yes,owner,arity,ready))
    case Con{+stmt,+rest}:
      nt_choose(P112WorkerBody,p112t_scalar_safe(stmt),
        u => p112e_worker_scalar(stmt,p112e_worker_normal(rest,owner,arity,ready)),u => P112WorkerBody{False{},0,[]})

# A worker already admitted in an earlier immutable pass keeps its exact rank;
# no subsequent pass needs to reconstruct its plan merely to discard it.

def p112w_finish(+params: List<&2,String>, body: P112WorkerBody) -> P112WorkerPlan:
  match body:
    case P112WorkerBody{valid,calls,nodes}: P112WorkerPlan{valid,calls,params,nodes}


@unsafe
def p112w_prelude(+owner: String, +arity: U32, +ready: KDef, prelude: P112TailPrelude) -> P112WorkerPlan:
  match prelude:
    case P112TailPrelude{+valid,+params,prefix,+body}:
      nt_choose(P112WorkerPlan,valid,u => p112w_finish(params,p112w_scan(body,owner,arity,ready)),
        u => P112WorkerPlan{False{},0,[],[]})


@unsafe
def p112w_plan(segment: N111Segment, +ready: KDef) -> P112WorkerPlan:
  match segment:
    case N111Segment{+name,+arity,result,incoming,flags,+body}:
      nt_choose(P112WorkerPlan,U32.is_eq(incoming,0) && U32.is_eq(flags,0) && U32.is_eq(result,1) && U32.is_le(arity,32),
        u => p112w_prelude(name,arity,ready,p112t_prelude(body,arity)),u => P112WorkerPlan{False{},0,[],[]})

def p112w_admitted(plan: P112WorkerPlan) -> Bool:
  match plan:
    case P112WorkerPlan{valid,calls,params,body}: valid

# Dependencies consult only the previous immutable pass. Already admitted
# records retain their original rank, making the acyclic boundary explicit.


@unsafe
def p112w_pass(segments: List<&2,N111Segment>, +old: KDef, +rank: U32, next: KDef) -> KDef:
  match segments:
    case Nil{}: next
    case Con{+segment,rest}: p112w_pass(rest,old,rank,p112w_add(segment,old,rank,next))


@unsafe
def p112w_add(+segment: N111Segment, +old: KDef, +rank: U32, +next: KDef) -> KDef:
  match segment:
    case N111Segment{+name,+arity,result,incoming,flags,body}:
      nt_choose(KDef,p112w_ready(old,name),u => next,u =>
        nt_choose(KDef,p112w_admitted(p112w_plan(segment,old)),
          v => p111v_put(next,name,"P112Worker",arity,rank),v => next))

@unsafe
def p112w_passes(+segments: List<&2,N111Segment>, +ready: KDef, +rank: U32, +left: U32) -> KDef:
  nt_choose(KDef,U32.is_eq(left,0),u => ready,u =>
    p112w_passes(segments,p112w_pass(segments,ready,rank,ready),U32.inc(rank),U32.sub(left,1)))


@unsafe
def p112w_index(+segments: List<&2,N111Segment>) -> KDef:
  p112w_passes(segments,missing(),1,3)

# Public terminal calls can use a private target even when their caller is a
# continuation. The retained rt_return performs its original pending-frame work.


@unsafe
def p112w_public(+body: List<&2,N111Stmt>, +owner: String, +ready: KDef) -> List<&2,P112WorkerStmt>:
  p112w_public_target(body,owner,ready,p112w_target(body))


@unsafe
def p112w_public_target(+body: List<&2,N111Stmt>, +owner: String, +ready: KDef, +target: String) -> List<&2,P112WorkerStmt>:
  +count = da(p111v_get(ready,target))
  nt_choose(List<&2,P112WorkerStmt>,p112w_ready(ready,target) && Bool.not(String.eq(owner,target)) && p112t_tail(body,target,count,0),
    u => p112w_nodes(body,count,P112WorkerCall{target,count}),u => p112w_public_next(body,owner,ready))


@unsafe
def p112w_public_next(body: List<&2,N111Stmt>, +owner: String, +ready: KDef) -> List<&2,P112WorkerStmt>:
  match body:
    case Nil{}: []
    case Con{N111If{condition,yes,no},rest}:
      Con{P112WorkerIf{condition,p112w_public(yes,owner,ready),p112w_public(no,owner,ready)},p112w_public(rest,owner,ready)}
    case Con{stmt,rest}: Con{P112WorkerScalar{stmt},p112w_public(rest,owner,ready)}


@unsafe
def p112w_targets_body(body: List<&2,P112WorkerStmt>, +ready: KDef, targets: KDef) -> KDef:
  match body:
    case Nil{}: targets
    case Con{P112WorkerCall{+target,arity},rest}:
      p112w_targets_body(rest,ready,p111v_put(targets,target,"P112Worker",arity,dx(p111v_get(ready,target))))
    case Con{P112WorkerIf{condition,yes,no},rest}:
      p112w_targets_body(rest,ready,p112w_targets_body(no,ready,p112w_targets_body(yes,ready,targets)))
    case Con{stmt,rest}: p112w_targets_body(rest,ready,targets)


@unsafe
def p112w_targets(segments: List<&2,N111Segment>, +ready: KDef, targets: KDef) -> KDef:
  match segments:
    case Nil{}: targets
    case Con{N111Segment{name,arity,result,incoming,flags,body},rest}:
      p112w_targets(rest,ready,p112w_targets_segment(name,result,flags,body,ready,targets))


@unsafe
def p112w_targets_segment(+name: String, +result: U32, +flags: U32, +body: List<&2,N111Stmt>, +ready: KDef, +targets: KDef) -> KDef:
  nt_choose(KDef,U32.is_eq(result,1) && U32.is_eq(flags,0),
    u => p112w_targets_body(p112w_public(body,name,ready),ready,targets),u => targets)


@unsafe
def p112w_count(segments: List<&2,N111Segment>, +ready: KDef, +acc: U32) -> U32:
  match segments:
    case Nil{}: acc
    case Con{N111Segment{name,arity,result,incoming,flags,body},rest}: p112w_count(rest,ready,U32.add(acc,nt_bool(p112w_ready(ready,name))))


@unsafe
def p112w_counts(+segments: List<&2,N111Segment>, +ready: KDef) -> String:
  U32.show(p112w_count(segments,ready,0)) ++ "/" ++ U32.show(p112w_count(segments,p112w_targets(segments,ready,missing()),0))


@unsafe
def p112w_program_counts(program: P111Program) -> String:
  match program:
    case P111Program{+segments,constructors,show,show_names,effects,pure}: p112w_counts(segments,p112w_index(segments))


@unsafe
def p112w_symbol(name: String) -> String:
  "p112w_" ++ nt_fid(name)


@unsafe
def p112w_formals(params: List<&2,String>, acc: String) -> String:
  match params:
    case Nil{}: acc
    case Con{word,rest}: p112w_formals(rest,acc ++ ", l " ++ p111q_local(word))


@unsafe
def p112w_call_args(+count: U32, +index: U32, +acc: String) -> String:
  nt_choose(String,U32.is_eq(count,index),u => acc,u =>
    p112w_call_args(count,U32.inc(index),acc ++ ", l %p112_arg_" ++ U32.show(index)))


@unsafe
def p112w_call(+target: String, +arity: U32, +public: Bool, +code: P111QCode) -> P111QCode:
  p112w_call_finish(public,p111q_line("%p112_result =l call $" ++ p112w_symbol(target) ++
    "(" ++ p112w_call_args(arity,0,"l %state") ++ ")\n",p112q_snapshots(arity,0,code)))


@unsafe
def p112w_call_finish(+public: Bool, +code: P111QCode) -> P111QCode:
  nt_choose(P111QCode,public,
    u => p111q_return("%p112_reply",p111q_line("%p112_reply =l call $p111_rt_return(l %state, l %v_scratch, w 1)\n",
      p111q_line("storel %p112_result, %v_scratch\n",code))),
    u => p111q_return("%p112_result",code))


@unsafe
def p112w_stmts(body: List<&2,P112WorkerStmt>, +params: List<&2,String>, +public: Bool, +ids: N111Ids, +code: P111QCode) -> P111QCode:
  match body:
    case Nil{}: code
    case Con{stmt,rest}: p112w_stmts_head(stmt,rest,params,public,ids,code)


@unsafe
def p112w_stmts_head(+stmt: P112WorkerStmt, +rest: List<&2,P112WorkerStmt>, +params: List<&2,String>,
  +public: Bool, +ids: N111Ids, +code: P111QCode) -> P111QCode:
  match code:
    case P111QCode{chunks,n,terminal,error}:
      nt_choose(P111QCode,String.is_empty(error),u =>
        nt_choose(P111QCode,terminal,u => p111q_problem("statement follows private worker transfer",code),u =>
          p112w_stmts(rest,params,public,ids,p112w_stmt(stmt,params,public,ids,code))),u => code)


@unsafe
def p112w_stmt(stmt: P112WorkerStmt, +params: List<&2,String>, +public: Bool, +ids: N111Ids, +code: P111QCode) -> P111QCode:
  match stmt:
    case P112WorkerScalar{scalar}: p111q_stmt(scalar,ids,code)
    case P112WorkerAgain{}: p112q_moves(params,0,p112q_snapshots(nt_count(String,params),0,code))
    case P112WorkerResult{}: p111q_return("%p112_result",p111q_line("%p112_result =l loadl %v_scratch\n",code))
    case P112WorkerCall{target,arity}: p112w_call(target,arity,public,code)
    case P112WorkerIf{condition,yes,no}: p112w_if(condition,yes,no,params,public,ids,code)


@unsafe
def p112w_if(+condition: N111Value, +yes: List<&2,P112WorkerStmt>, +no: List<&2,P112WorkerStmt>,
  +params: List<&2,String>, +public: Bool, +ids: N111Ids, code: P111QCode) -> P111QCode:
  match code:
    case P111QCode{chunks,n,terminal,error}:
      p112w_if_yes(n,no,params,public,ids,p112w_stmts(yes,params,public,ids,
        P111QCode{Con{p111q_label(n) ++ "\n",Con{"jnz " ++ p111q_value(condition,ids) ++ ", " ++ p111q_label(n) ++ ", " ++ p111q_label(U32.inc(n)) ++ "\n",chunks}},U32.add(n,3),False{},error}))


@unsafe
def p112w_if_yes(+label: U32, +no: List<&2,P112WorkerStmt>, +params: List<&2,String>, +public: Bool, +ids: N111Ids, yes: P111QCode) -> P111QCode:
  match yes:
    case P111QCode{chunks,n,terminal,error}:
      +prefix = nt_choose(List<&2,String>,terminal,u => chunks,u => Con{"jmp " ++ p111q_label(U32.add(label,2)) ++ "\n",chunks})
      p111q_if_done(label,terminal,p112w_stmts(no,params,public,ids,P111QCode{Con{p111q_label(U32.inc(label)) ++ "\n",prefix},n,False{},error}))


@unsafe
def p112w_private(+segment: N111Segment, +ids: N111Ids, plan: P112WorkerPlan) -> String:
  match segment plan:
    case N111Segment{name,arity,result,incoming,flags,+original} P112WorkerPlan{+valid,calls,+params,+body}:
      nt_choose(String,valid,u => "function l $" ++ p112w_symbol(name) ++ "(" ++ p112w_formals(params,"l %state") ++ ") {\n@entry\n" ++
        p144e_body_tail(p112w_stmts(body,params,False{},ids,
          P111QCode{Con{"@p112_again\n",Con{"jmp @p112_again\n",p111q_allocas(original,[])}},0,False{},""}),"}\n"),
        u => "INVALID_P112_PRIVATE_PLAN\n")

@unsafe
def p112w_public_segment(+segment: N111Segment, +ids: N111Ids, +ready: KDef) -> String:
  match segment:
    case N111Segment{+name,arity,+result,incoming,+flags,+body}:
      nt_choose(String,p112t_admitted(p112t_plan(segment)),u => p112q_segment(segment,ids),u =>
        nt_choose(String,U32.is_eq(result,1) && U32.is_eq(flags,0),
          u => "export function l $" ++ p111q_symbol(name) ++ "(l %state) {\n@entry\n" ++
            p144e_body_tail(p112w_stmts(p112w_public(body,name,ready),[],True{},ids,
              P111QCode{p111q_allocas(body,[]),0,False{},""}),"}\n"),
          u => p111q_segment(segment,ids)))

@unsafe
def p112w_chunk(+segment: N111Segment, +ids: N111Ids, +ready: KDef, +targets: KDef) -> String:
  match segment:
    case N111Segment{+name,arity,result,incoming,flags,body}:
      p112w_public_segment(segment,ids,ready) ++ nt_choose(String,p112w_ready(targets,name),
        u => p112w_private(segment,ids,p112w_plan(segment,ready)),u => "")


@unsafe
def p112w_chunks(segments: List<&2,N111Segment>, +ids: N111Ids, +ready: KDef, +targets: KDef, acc: List<&2,String>) -> List<&2,String>:
  match segments:
    case Nil{}: nt_reverse(String,acc,[])
    case Con{segment,rest}: p112w_chunks(rest,ids,ready,targets,Con{p112w_chunk(segment,ids,ready,targets),acc})


@unsafe
def p112w_indexed(+segments: List<&2,N111Segment>, +ids: N111Ids, +ready: KDef, +acc: List<&2,String>) -> List<&2,String>:
  p112w_chunks(segments,ids,ready,p112w_targets(segments,ready,missing()),acc)


@unsafe
def p112w_segment_chunks(+segments: List<&2,N111Segment>, +ids: N111Ids, +acc: List<&2,String>) -> List<&2,String>:
  p112w_indexed(segments,ids,p112w_index(segments),acc)


def p112w_failure_nodes(body: List<&2,N111Stmt>) -> List<&2,P112WorkerStmt>:
  match body:
    case Nil{}: []
    case Con{stmt,rest}: Con{P112WorkerScalar{stmt},p112w_failure_nodes(rest)}


@unsafe
def p112w_scan_normal(+body: List<&2,N111Stmt>, +owner: String, +arity: U32, +ready: KDef) -> P112WorkerBody:
  nt_choose(P112WorkerBody,p112t_tail(body,owner,arity,0),
    u => P112WorkerBody{True{},0,p112w_nodes(body,arity,P112WorkerAgain{})},u =>
    nt_choose(P112WorkerBody,p112w_result(body),
      u => P112WorkerBody{True{},0,p112w_nodes(body,1,P112WorkerResult{})},u =>
      p112w_scan_target(body,owner,arity,ready,p112w_target(body))))
