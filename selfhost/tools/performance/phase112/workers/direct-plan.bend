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
  nt_choose(P112WorkerBody,p112t_tail(body,owner,arity,0),
    u => P112WorkerBody{True{},0,p112w_nodes(body,arity,P112WorkerAgain{})},u =>
    nt_choose(P112WorkerBody,p112w_result(body),
      u => P112WorkerBody{True{},0,p112w_nodes(body,1,P112WorkerResult{})},u =>
      p112w_scan_target(body,owner,arity,ready,p112w_target(body))))

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
      p112w_branch(condition,p112w_scan(yes,owner,arity,ready),p112w_scan(no,owner,arity,ready),p112w_scan(rest,owner,arity,ready))
    case Con{stmt,rest}: p112w_prepend(stmt,p112w_scan(rest,owner,arity,ready))

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
      nt_choose(P112WorkerPlan,U32.is_eq(incoming,0) && U32.is_eq(flags,0) && U32.is_eq(result,1) && U32.is_le(arity,8),
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
      nt_choose(KDef,Bool.not(p112w_ready(old,name)) && p112w_admitted(p112w_plan(segment,old)),
        u => p111v_put(next,name,"P112Worker",arity,rank),u => next)

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
