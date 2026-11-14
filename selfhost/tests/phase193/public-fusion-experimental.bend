# Experimental x86 consumers of the ORIGINAL bounded closed-continuation and
# ready-public-tail planners. Original final verification remains prerequisite.
# These independent toggles are changed only in frozen experimental variants.
def x193f_fusion_enabled() -> Bool: True{}
def x193f_tail_enabled() -> Bool: True{}

type X193FBody is Data:
  X193FBody{body: List<&2,N111Stmt>, calls: U32, error: String}

@unsafe
def x193f_clean_name(name: String) -> Bool:
  Bool.not(String.starts_with(name,"p193f_"))

@unsafe
def x193f_clean_value(value: N111Value) -> Bool:
  match value:
    case N111Local{name}: x193f_clean_name(name)
    case _: True{}

@unsafe
def x193f_clean_args(args: List<&2,N111Arg>) -> Bool:
  match args:
    case Nil{}: True{}
    case Con{N111Arg{typ,value},rest}: x193f_clean_value(value) && x193f_clean_args(rest)

@unsafe
def x193f_clean(body: List<&2,N111Stmt>) -> Bool:
  match body:
    case Nil{}: True{}
    case Con{stmt,rest}: x193f_clean_stmt(stmt) && x193f_clean(rest)

@unsafe
def x193f_clean_stmt(stmt: N111Stmt) -> Bool:
  match stmt:
    case N111Set{name,typ,value}: x193f_clean_name(name) && x193f_clean_value(value)
    case N111Bin{name,typ,op,left,right}: x193f_clean_name(name) && x193f_clean_value(left) && x193f_clean_value(right)
    case N111Call{name,typ,symbol,args}: x193f_clean_name(name) && x193f_clean_args(args)
    case N111If{condition,yes,no}: x193f_clean_value(condition) && x193f_clean(yes) && x193f_clean(no)
    case N111Return{value}: x193f_clean_value(value)
    case N111Load{name,typ,base,offset}: x193f_clean_name(name) && x193f_clean_value(base)
    case N111Store{typ,base,offset,value}: x193f_clean_value(base) && x193f_clean_value(value)
    case N111Offset{name,base,bytes}: x193f_clean_name(name) && x193f_clean_value(base) && x193f_clean_value(bytes)
    case N111Alloca{name,bytes,align}: x193f_clean_name(name)

@unsafe
def x193f_arg_name(index: U32) -> String: "p193f_arg_" ++ U32.show(index)

# Snapshot every argument before the helper can overwrite any runtime storage.
# The same bounded scratch contract was checked by p112t_tail in the planner.
@unsafe
def x193f_loads(+count: U32, +index: U32) -> List<&2,N111Stmt>:
  nt_choose(List<&2,N111Stmt>,U32.is_eq(count,index),u => [],u =>
    Con{N111Load{x193f_arg_name(index),N111U64{},N111Local{"scratch"},U32.mul(index,8)},
      x193f_loads(count,U32.inc(index))})

@unsafe
def x193f_args(+count: U32, +index: U32) -> List<&2,N111Arg>:
  nt_choose(List<&2,N111Arg>,U32.is_eq(count,index),u => [],u =>
    Con{p111_word(N111Local{x193f_arg_name(index)}),x193f_args(count,U32.inc(index))})

# This is p112w_call(...,public=True) in structured scalar IR. rt_return must
# remain: its pending caller continuation is outside the helper's native frame.
@unsafe
def x193f_call(target: String, +count: U32) -> List<&2,N111Stmt>:
  nt_append(N111Stmt,x193f_loads(count,0),[
    N111Call{"p193f_result",N111U64{},p112w_symbol(target),Con{p111_state(),x193f_args(count,0)}},
    N111Store{N111U64{},N111Local{"scratch"},0,N111Local{"p193f_result"}},
    N111Call{"p193f_reply",N111U64{},"p111_rt_return",[p111_state(),p111_scratch(),p111_u32(1)]},
    N111Return{N111Local{"p193f_reply"}}])

@unsafe
def x193f_join(first: X193FBody, second: X193FBody) -> X193FBody:
  match first second:
    case X193FBody{a,ac,ae} X193FBody{b,bc,be}:
      X193FBody{nt_append(N111Stmt,a,b),U32.add(ac,bc),p111_first(ae,be)}

@unsafe
def x193f_branch(condition: N111Value, yes: X193FBody, no: X193FBody) -> X193FBody:
  match yes no:
    case X193FBody{a,ac,ae} X193FBody{b,bc,be}:
      X193FBody{[N111If{condition,a,b}],U32.add(ac,bc),p111_first(ae,be)}

@unsafe
def x193f_worker(stmt: P112WorkerStmt) -> X193FBody:
  match stmt:
    case P112WorkerScalar{scalar}: X193FBody{[scalar],0,""}
    case P112WorkerIf{condition,yes,no}: x193f_branch(condition,x193f_workers(yes),x193f_workers(no))
    case P112WorkerCall{target,+count}:
      nt_choose(X193FBody,U32.is_le(count,256),u => X193FBody{x193f_call(target,count),1,""},
        u => X193FBody{[],0,"public helper argument count exceeds scratch"})
    case P112WorkerAgain{}: X193FBody{[],0,"private Again in public helper plan"}
    case P112WorkerResult{}: X193FBody{[],0,"private Result in public helper plan"}

@unsafe
def x193f_workers(body: List<&2,P112WorkerStmt>) -> X193FBody:
  match body:
    case Nil{}: X193FBody{[],0,""}
    case Con{stmt,rest}: x193f_join(x193f_worker(stmt),x193f_workers(rest))

# Mirror p112w_public_segment's own direct-loop precedence and metadata gate.
# A direct tail loop stays with the original x86 segment consumer in this pilot.
@unsafe
def x193f_tail(+segment: N111Segment, +ready: KDef, +enabled: Bool) -> X193FBody:
  match segment:
    case N111Segment{+name,arity,+result,incoming,+flags,+body}:
      nt_choose(X193FBody,enabled && U32.is_eq(result,1) && U32.is_eq(flags,0) &&
          Bool.not(p112t_admitted(p112t_plan(segment))) && x193f_clean(body),
        u => x193f_workers(p112w_public(body,name,ready)),u => X193FBody{body,0,""})

@unsafe
def x193f_fused(+segment: N111Segment, +index: P112FusionIndex, +ready: KDef, enabled: Bool) -> P112FusionBody:
  match segment:
    case N111Segment{name,arity,result,incoming,flags,body}:
      nt_choose(P112FusionBody,enabled,u => p112c_plan_index(segment,index,ready),u => P112FusionBody{body,0,0})

@unsafe
def x193f_candidate(+segment: N111Segment, +ready: KDef, +tail: Bool, plan: P112FusionBody) -> X193FBody:
  match segment plan:
    case N111Segment{name,arity,result,incoming,flags,original} P112FusionBody{body,count,site}:
      x193f_tail(N111Segment{name,arity,result,incoming,flags,body},ready,tail)

# Exposed pure selection for finite controls. An unavailable legacy target
# refuses the complete candidate; no prefix or partially rewritten body escapes.
@unsafe
def x193f_checked(+candidate: X193FBody, +available: KDef) -> X193FBody:
  match candidate:
    case X193FBody{+body,calls,error}:
      X193FBody{body,calls,p111_first(error,p111_first(x181_hygiene_scalars(body),x181_program_scalars(body,available)))}

@unsafe
def x193f_plan(+segment: N111Segment, index: P112FusionIndex, +ready: KDef,
    available: KDef, fusion: Bool, tail: Bool) -> X193FBody:
  match segment:
    case N111Segment{name,arity,result,incoming,flags,+body}:
      nt_choose(X193FBody,x193f_clean(body),u =>
        x193f_checked(x193f_candidate(segment,ready,tail,x193f_fused(segment,index,ready,fusion)),available),
        u => X193FBody{body,0,"public helper reserved local collision"})

@unsafe
def x193f_emit_planned(+original: N111Segment, +ids: N111Ids, plan: X193FBody) -> X181Output:
  match original plan:
    case N111Segment{name,arity,result,incoming,flags,old} X193FBody{body,calls,+error}:
      nt_choose(X181Output,String.is_empty(error),u => x192h_output_or_original(original,ids,
        x181_segment(N111Segment{name,arity,result,incoming,flags,body},ids)),u => x181_segment(original,ids))

@unsafe
def x193f_fallback(+segment: N111Segment, index: P112FusionIndex, +ids: N111Ids,
    ready: KDef, available: KDef) -> X181Output:
  x193f_emit_planned(segment,ids,x193f_plan(segment,index,ready,available,x193f_fusion_enabled(),x193f_tail_enabled()))

# This adapter queries exactly the original H plan and gives it first refusal.
# A valid H plan keeps its original selector/fallback behavior. Complete direct
# workers and generic mode remain excluded by the existing program.bend caller.
@unsafe
def x193f_after_h(+segment: N111Segment, +index: P112FusionIndex, +ids: N111Ids,
    +ready: KDef, +available: KDef, +plan: P114HPlan) -> X181Output:
  nt_choose(X181Output,p114h_valid(plan),u => x192h_public_planned(segment,ids,available,plan),
    u => x193f_fallback(segment,index,ids,ready,available))

@unsafe
def x193f_public(+segment: N111Segment, +index: P112FusionIndex, +ids: N111Ids,
    +ready: KDef, +available: KDef) -> X181Output:
  nt_choose(X181Output,x192h_regions_enabled(),u =>
    x193f_after_h(segment,index,ids,ready,available,p114h_plan(segment,index,ready)),
    u => x193f_fallback(segment,index,ids,ready,available))
