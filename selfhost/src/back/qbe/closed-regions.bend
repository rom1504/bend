

@unsafe
def p112r_buffer_sites(+name: String, +sites: U32, +index: U32) -> Bool:
  nt_choose(Bool,U32.is_eq(index,sites),u => False{},u =>
    String.eq(name,"p112f_" ++ U32.show(index) ++ "_local_scratch") || p112r_buffer_sites(name,sites,U32.inc(index)))


@unsafe
def p112r_buffer(+name: String, +sites: U32) -> Bool:
  U32.is_le(sites,8) && (String.eq(name,"scratch") || p112r_buffer_sites(name,sites,0))


@unsafe
def p112r_buffers(args: List<&2,N111Arg>, +sites: U32) -> Bool:
  match args:
    case Nil{}: True{}
    case Con{N111Arg{N111Ptr{},N111Local{+name}},+rest}: p112r_buffer(name,sites) && p112r_buffers(rest,sites)
    case Con{N111Arg{N111Ptr{},+value},+rest}: False{}
    case Con{+arg,+rest}: p112r_buffers(rest,sites)


@unsafe
def p112r_runtime_args(args: List<&2,N111Arg>, +sites: U32) -> Bool:
  match args:
    case Con{N111Arg{N111Ptr{},N111Local{+name}},+rest}: String.eq(name,"state") && p112r_buffers(rest,sites)
    case _: False{}


@unsafe
def p112r_words(args: List<&2,N111Arg>, +count: U32) -> Bool:
  match args:
    case Nil{}: U32.is_eq(count,0)
    case Con{N111Arg{N111U64{},+value},+rest}: U32.is_gt(count,0) && p112r_words(rest,U32.sub(count,1))
    case _: False{}


@unsafe
def p112r_private_call(stmt: N111Stmt, +symbols: KDef) -> Bool:
  match stmt:
    case N111Call{+name,N111U64{},+symbol,Con{N111Arg{N111Ptr{},N111Local{+state}},+rest}}:
      +record = p111v_get(symbols,symbol)
      String.eq(state,"state") && String.eq(dk(record),"P112RegionSymbol") && p112r_words(rest,da(record))
    case _: False{}


@unsafe
def p112r_scalar(+stmt: N111Stmt, +symbols: KDef, +sites: U32) -> Bool:
  match stmt:
    case N111Call{+name,N111U64{},+symbol,+args}:
      (p112t_runtime_call(symbol) && p112r_runtime_args(args,sites)) || p112r_private_call(stmt,symbols)
    case N111Load{+name,N111U64{},N111Local{+base},+offset}: p112r_buffer(base,sites)
    case N111Store{N111U64{},N111Local{+base},+offset,+value}: p112r_buffer(base,sites)
    case N111Alloca{+name,2048,8}: Bool.not(String.eq(name,"scratch")) && p112r_buffer(name,sites)
    case _: p112t_scalar_safe(stmt)


@unsafe
def p112r_failure_frame(stmt: N111Stmt, +sites: U32) -> Bool:
  match stmt:
    case N111Call{+name,N111U64{},+symbol,Con{N111Arg{N111Ptr{},N111Local{+state}},Con{N111Arg{N111U32{},N111FuncId{+target}},Con{N111Arg{N111Ptr{},N111Local{+scratch}},Con{N111Arg{N111U32{},N111Const{+count,0}},Nil{}}}}}}:
      String.eq(symbol,"p111_rt_frame") && String.eq(state,"state") && p112r_buffer(scratch,sites) && U32.is_le(count,255)
    case _: False{}

# The exact CPU fail-stop runtime prerequisite is inherited, never generalized.


@unsafe
def p112r_failure(body: List<&2,N111Stmt>, +symbols: KDef, +sites: U32) -> Bool:
  match body:
    case Con{N111Call{+dest,N111U64{},+symbol,+args},Con{N111Return{N111Local{+word}},Nil{}}}:
      String.eq(symbol,"p111_rt_fail") && String.eq(dest,word) && p112t_failure_args(args)
    case Con{+stmt,+rest}: (p112r_scalar(stmt,symbols,sites) || p112r_failure_frame(stmt,sites)) && p112r_failure(rest,symbols,sites)
    case _: False{}


@unsafe
def p112r_head_buffer(body: List<&2,N111Stmt>) -> String:
  match body:
    case Con{N111Store{N111U64{},N111Local{+base},+offset,+value},+rest}: base
    case Con{N111Call{+dest,N111U64{},+symbol,Con{+state,Con{+target,Con{N111Arg{N111Ptr{},N111Local{+base}},+rest}}}},+tail}: base
    case _: ""


@unsafe
def p112r_jump(body: List<&2,N111Stmt>, +owner: String, +arity: U32, +buffer: String) -> Bool:
  match body:
    case Con{N111Call{+dest,N111U64{},+symbol,Con{N111Arg{N111Ptr{},N111Local{+state}},Con{N111Arg{N111U32{},N111FuncId{+name}},Con{N111Arg{N111Ptr{},N111Local{+scratch}},Con{N111Arg{N111U32{},N111Const{+count,0}},Nil{}}}}}},Con{N111Return{N111Local{+word}},Nil{}}}:
      String.eq(symbol,"p111_rt_jump") && String.eq(dest,word) && String.eq(state,"state") && String.eq(name,owner) && String.eq(scratch,buffer) && U32.is_eq(count,arity)
    case _: False{}


@unsafe
def p112r_tail(+body: List<&2,N111Stmt>, +owner: String, +arity: U32, +index: U32, +buffer: String) -> Bool:
  nt_choose(Bool,U32.is_eq(index,arity),u => p112r_jump(body,owner,arity,buffer),u => p112r_tail_store(body,owner,arity,index,buffer))


@unsafe
def p112r_tail_store(body: List<&2,N111Stmt>, +owner: String, +arity: U32, +index: U32, +buffer: String) -> Bool:
  match body:
    case Con{N111Store{N111U64{},N111Local{+base},+offset,+value},+rest}:
      String.eq(base,buffer) && U32.is_eq(offset,U32.mul(index,8)) && p112r_tail(rest,owner,arity,U32.inc(index),buffer)
    case _: False{}


@unsafe
def p112r_result(body: List<&2,N111Stmt>, +sites: U32) -> Bool:
  match body:
    case Con{N111Store{N111U64{},N111Local{+base},0,+value},Con{N111Call{+dest,N111U64{},+symbol,Con{N111Arg{N111Ptr{},N111Local{+state}},Con{N111Arg{N111Ptr{},N111Local{+scratch}},Con{N111Arg{N111U32{},N111Const{1,0}},Nil{}}}}},Con{N111Return{N111Local{+word}},Nil{}}}}:
      p112r_buffer(base,sites) && String.eq(base,scratch) && String.eq(state,"state") && String.eq(symbol,"p111_rt_return") && String.eq(dest,word)
    case _: False{}


@unsafe
def p112r_target(body: List<&2,N111Stmt>, +sites: U32) -> String:
  match body:
    case Con{N111Store{N111U64{},N111Local{+base},+offset,+value},+rest}:
      nt_choose(String,p112r_buffer(base,sites),u => p112r_target(rest,sites),u => "")
    case Con{N111Call{+dest,N111U64{},+symbol,Con{+state,Con{N111Arg{N111U32{},N111FuncId{+name}},+rest}}},Con{N111Return{+value},Nil{}}}:
      nt_choose(String,String.eq(symbol,"p111_rt_jump"),u => name,u => "")
    case _: ""


@unsafe
def p112r_exit_stores(+count: U32, +index: U32, +last: P112WorkerStmt) -> List<&2,P112WorkerStmt>:
  nt_choose(List<&2,P112WorkerStmt>,U32.is_eq(count,index),u => [last],u =>
    Con{P112WorkerScalar{N111Store{N111U64{},N111Local{"scratch"},U32.mul(index,8),N111Local{"p112f_region_exit_" ++ U32.show(index)}}},p112r_exit_stores(count,U32.inc(index),last)})

# All operands are copied before any canonical slot is overwritten. The exact
# suffix has only pure value stores followed by its transfer, so secondary
# terminal stores can be replaced by this transport without moving owner calls.


@unsafe
def p112r_exit(body: List<&2,N111Stmt>, +count: U32, +last: P112WorkerStmt) -> List<&2,P112WorkerStmt>:
  nt_append(P112WorkerStmt,p112w_failure_nodes(p112f_snapshots(p112f_values(body,count),"p112f_region_","exit_",0)),p112r_exit_stores(count,0,last))


@unsafe
def p112r_scan(+body: List<&2,N111Stmt>, +owner: String, +arity: U32, +ready: KDef, +symbols: KDef, +sites: U32) -> P112WorkerBody:
  nt_choose(P112WorkerBody,p112r_failure(body,symbols,sites),u => P112WorkerBody{True{},0,p112w_failure_nodes(body)},
    u => p112r_normal(body,owner,arity,ready,symbols,sites))


@unsafe
def p112r_normal(+body: List<&2,N111Stmt>, +owner: String, +arity: U32, +ready: KDef, +symbols: KDef, +sites: U32) -> P112WorkerBody:
  +buffer = p112r_head_buffer(body)
  nt_choose(P112WorkerBody,p112r_buffer(buffer,sites) && p112r_tail(body,owner,arity,0,buffer),
    u => P112WorkerBody{True{},0,p112r_exit(body,arity,P112WorkerAgain{})},u =>
    nt_choose(P112WorkerBody,p112r_result(body,sites),u => P112WorkerBody{True{},0,p112r_exit(body,1,P112WorkerResult{})},
      u => p112r_scan_target(body,owner,arity,ready,symbols,sites,buffer,p112r_target(body,sites))))


@unsafe
def p112r_scan_target(+body: List<&2,N111Stmt>, +owner: String, +arity: U32, +ready: KDef, +symbols: KDef, +sites: U32, +buffer: String, +target: String) -> P112WorkerBody:
  +count = da(p111v_get(ready,target))
  nt_choose(P112WorkerBody,p112w_ready(ready,target) && Bool.not(String.eq(owner,target)) && p112r_buffer(buffer,sites) && p112r_tail(body,target,count,0,buffer),
    u => P112WorkerBody{True{},1,p112r_exit(body,count,P112WorkerCall{target,count})},
    u => p112r_next(body,owner,arity,ready,symbols,sites))


@unsafe
def p112r_next(body: List<&2,N111Stmt>, +owner: String, +arity: U32, +ready: KDef, +symbols: KDef, +sites: U32) -> P112WorkerBody:
  match body:
    case Nil{}: P112WorkerBody{True{},0,[]}
    case Con{N111If{+condition,+yes,+no},+rest}:
      p112r_yes(condition,no,rest,owner,arity,ready,symbols,sites,p112r_scan(yes,owner,arity,ready,symbols,sites))
    case Con{+stmt,+rest}:
      nt_choose(P112WorkerBody,p112r_scalar(stmt,symbols,sites),
        u => p112e_worker_scalar(stmt,p112r_normal(rest,owner,arity,ready,symbols,sites)),u => P112WorkerBody{False{},0,[]})


@unsafe
def p112r_yes(+condition: N111Value, +no: List<&2,N111Stmt>, +rest: List<&2,N111Stmt>, +owner: String, +arity: U32, +ready: KDef, +symbols: KDef, +sites: U32, +yes: P112WorkerBody) -> P112WorkerBody:
  nt_choose(P112WorkerBody,p112e_worker_valid(yes),
    u => p112r_no(condition,rest,owner,arity,ready,symbols,sites,yes,p112r_scan(no,owner,arity,ready,symbols,sites)),u => P112WorkerBody{False{},0,[]})


@unsafe
def p112r_no(+condition: N111Value, +rest: List<&2,N111Stmt>, +owner: String, +arity: U32, +ready: KDef, +symbols: KDef, +sites: U32, +yes: P112WorkerBody, +no: P112WorkerBody) -> P112WorkerBody:
  nt_choose(P112WorkerBody,p112e_worker_valid(no),
    u => p112r_rest(condition,yes,no,p112r_scan(rest,owner,arity,ready,symbols,sites)),u => P112WorkerBody{False{},0,[]})


@unsafe
def p112r_rest(+condition: N111Value, +yes: P112WorkerBody, +no: P112WorkerBody, +rest: P112WorkerBody) -> P112WorkerBody:
  nt_choose(P112WorkerBody,p112e_worker_valid(rest),u => p112w_branch(condition,yes,no,rest),u => P112WorkerBody{False{},0,[]})


@unsafe
def p112r_prelude(+owner: String, +arity: U32, +ready: KDef, +symbols: KDef, +sites: U32, prelude: P112TailPrelude) -> P112WorkerPlan:
  match prelude:
    case P112TailPrelude{+valid,+params,+prefix,+body}:
      nt_choose(P112WorkerPlan,valid,u => p112w_finish(params,p112r_scan(body,owner,arity,ready,symbols,sites)),u => P112WorkerPlan{False{},0,[],[]})

# Internal planner: segment and site count must come from p112r_fused below.


@unsafe
def p112r_plan(segment: N111Segment, +ready: KDef, +symbols: KDef, +sites: U32) -> P112WorkerPlan:
  match segment:
    case N111Segment{+name,+arity,+result,+incoming,+flags,+body}:
      nt_choose(P112WorkerPlan,U32.is_eq(incoming,0) && U32.is_eq(flags,0) && U32.is_eq(result,1) && U32.is_le(arity,8) && U32.is_le(sites,8),
        u => p112r_prelude(name,arity,ready,symbols,sites,p112t_prelude(body,arity)),u => P112WorkerPlan{False{},0,[],[]})


@unsafe
def p112r_freeze(+segment: N111Segment, +rank: U32, +sites: U32, +next: P112RegionRegistry, +plan: P112WorkerPlan) -> P112RegionRegistry:
  nt_choose(P112RegionRegistry,p112w_admitted(plan),u => p112r_insert(segment,rank,sites,next,plan),u => next)


@unsafe
def p112r_insert(+segment: N111Segment, +rank: U32, +sites: U32, next: P112RegionRegistry, +plan: P112WorkerPlan) -> P112RegionRegistry:
  match segment next:
    case N111Segment{+name,+arity,+result,+incoming,+flags,+body} P112RegionRegistry{+ready,+symbols,+entries,+workers,+fusions}:
      P112RegionRegistry{p111v_put(ready,name,"P112Worker",arity,rank),p111v_put(symbols,p112w_symbol(name),"P112RegionSymbol",arity,rank),
        Con{P112RegionEntry{segment,plan,rank,sites},entries},U32.inc(workers),U32.add(fusions,sites)}


@unsafe
def p112r_fused(segment: N111Segment, +old: KDef, +symbols: KDef, +rank: U32, +next: P112RegionRegistry, fused: P112FusionBody) -> P112RegionRegistry:
  match segment fused:
    case N111Segment{+name,+arity,+result,+incoming,+flags,+original} P112FusionBody{+body,+count,+site}:
      +transformed: N111Segment = N111Segment{name,arity,result,incoming,flags,body}
      p112r_freeze(transformed,rank,count,next,p112r_plan(transformed,old,symbols,count))


@unsafe
def p112r_add(+segment: N111Segment, +index: P112FusionIndex, +old: KDef, +symbols: KDef, +rank: U32, +next: P112RegionRegistry) -> P112RegionRegistry:
  match segment:
    case N111Segment{+name,+arity,+result,+incoming,+flags,+body}:
      nt_choose(P112RegionRegistry,p112w_ready(old,name),u => next,u =>
        nt_choose(P112RegionRegistry,U32.is_eq(incoming,0) && U32.is_eq(flags,0) && U32.is_eq(result,1) && U32.is_le(arity,8) && p112f_clean(body),
          v => p112r_fused(segment,old,symbols,rank,next,p112f_plan_index(segment,index,old)),v => next))

# old and symbols are immutable for the entire pass; next is only accumulated.


@unsafe
def p112r_pass(segments: List<&2,N111Segment>, +index: P112FusionIndex, +old: KDef, +symbols: KDef, +rank: U32, next: P112RegionRegistry) -> P112RegionRegistry:
  match segments:
    case Nil{}: next
    case Con{+segment,+rest}: p112r_pass(rest,index,old,symbols,rank,p112r_add(segment,index,old,symbols,rank,next))


@unsafe
def p112r_passes(+segments: List<&2,N111Segment>, +index: P112FusionIndex, +registry: P112RegionRegistry, +rank: U32, +left: U32) -> P112RegionRegistry:
  nt_choose(P112RegionRegistry,U32.is_eq(left,0),u => registry,u => p112r_round(segments,index,registry,rank,left))


@unsafe
def p112r_round(+segments: List<&2,N111Segment>, +index: P112FusionIndex, +registry: P112RegionRegistry, +rank: U32, +left: U32) -> P112RegionRegistry:
  match registry:
    case P112RegionRegistry{+ready,+symbols,+entries,+workers,+fusions}:
      p112r_continue(segments,index,rank,left,workers,p112r_pass(segments,index,ready,symbols,rank,registry))


@unsafe
def p112r_continue(+segments: List<&2,N111Segment>, +index: P112FusionIndex, +rank: U32, +left: U32, +previous: U32, +registry: P112RegionRegistry) -> P112RegionRegistry:
  match registry:
    case P112RegionRegistry{+ready,+symbols,+entries,+workers,+fusions}:
      nt_choose(P112RegionRegistry,U32.is_eq(workers,previous),u => registry,u => p112r_passes(segments,index,registry,U32.inc(rank),U32.sub(left,1)))


@unsafe
def p112r_index(+segments: List<&2,N111Segment>) -> P112RegionRegistry:
  p112r_passes(segments,p112f_index(segments),P112RegionRegistry{missing(),missing(),[],0,0},1,6)


@unsafe
def p112r_private_chunks(entries: List<&2,P112RegionEntry>, +ids: N111Ids, acc: List<&2,String>) -> List<&2,String>:
  match entries:
    case Nil{}: acc
    case Con{P112RegionEntry{+segment,+plan,+rank,+sites},+rest}:
      p112r_private_chunks(rest,ids,Con{p112w_private(segment,ids,plan),acc})


@unsafe
def p112r_public_chunks(segments: List<&2,N111Segment>, +index: P112FusionIndex, +ids: N111Ids, +ready: KDef, acc: List<&2,String>) -> List<&2,String>:
  match segments:
    case Nil{}: nt_reverse(String,acc,[])
    case Con{+segment,+rest}:
      p112r_public_chunks(rest,index,ids,ready,Con{p112f_public(segment,ids,ready,p112f_plan_index(segment,index,ready)),acc})

# Keep one chunk per original segment so existing metadata/chunk consumers keep
# their boundary. Private definitions are attached to the first public chunk.


@unsafe
def p112r_attach(chunks: List<&2,String>, +private: String) -> List<&2,String>:
  match chunks:
    case Nil{}: []
    case Con{+first,+rest}: Con{private ++ first,rest}


@unsafe
def p112r_chunks(+segments: List<&2,N111Segment>, +ids: N111Ids, +acc: List<&2,String>, registry: P112RegionRegistry) -> List<&2,String>:
  match registry:
    case P112RegionRegistry{+ready,+symbols,+entries,+workers,+fusions}:
      p112r_attach(p112r_public_chunks(segments,p112f_index(segments),ids,ready,acc),nt_join(p112r_private_chunks(entries,ids,[]),""))


@unsafe
def p112r_segment_chunks(+segments: List<&2,N111Segment>, +ids: N111Ids, +acc: List<&2,String>) -> List<&2,String>:
  p112r_chunks(segments,ids,acc,p112r_index(segments))


@unsafe
def p112r_counts(registry: P112RegionRegistry) -> String:
  match registry:
    case P112RegionRegistry{+ready,+symbols,+entries,+workers,+fusions}: U32.show(workers) ++ "/" ++ U32.show(fusions)


@unsafe
def p112r_program_counts(program: P111Program) -> String:
  match program:
    case P111Program{+segments,+constructors,+show,+show_names,+effects,+pure}: p112r_counts(p112r_index(segments))


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

@unsafe
def p112c_try_frame(frame: Maybe<&2,P112FusionFrame>, +index: P112FusionIndex, +ready: KDef, +site: U32, +buffer: String) -> Maybe<&2,List<&2,N111Stmt>>:
  match frame:
    case None{}: None{}
    case Some{+value}:
      match value:
        case P112FusionFrame{+captures,+name,+dest,+tail}: p112g_finish(value,index,ready,site,buffer,p112g_split(tail,0,[]))

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
      nt_choose(P112FusionBody,U32.is_eq(result,1) && U32.is_eq(flags,0),
        u => nt_choose(P112FusionBody,p112f_clean(body),
          v => p112c_scan(body,index,ready,0),v => P112FusionBody{body,0,0}),
        u => P112FusionBody{body,0,0})


@unsafe
def p112c_plan(segment: N111Segment, +ready: KDef, +symbols: KDef, +sites: U32) -> P112WorkerPlan:
  match segment:
    case N111Segment{+name,+arity,+result,+incoming,+flags,+body}:
      nt_choose(P112WorkerPlan,U32.is_eq(incoming,0) && U32.is_eq(flags,0) && U32.is_eq(result,1) && U32.is_le(arity,32) && U32.is_le(sites,8),
        u => p112r_prelude(name,arity,ready,symbols,sites,p112t_prelude(body,arity)),u => P112WorkerPlan{False{},0,[],[]})


@unsafe
def p112c_freeze(+segment: N111Segment, +rank: U32, +sites: U32, +next: P112RegionRegistry, +plan: P112WorkerPlan) -> P112RegionRegistry:
  nt_choose(P112RegionRegistry,p112w_admitted(plan),u => p112c_insert(segment,rank,sites,next,plan),u => next)


@unsafe
def p112c_insert(+segment: N111Segment, +rank: U32, +sites: U32, next: P112RegionRegistry, +plan: P112WorkerPlan) -> P112RegionRegistry:
  match segment next:
    case N111Segment{+name,+arity,+result,+incoming,+flags,+body} P112RegionRegistry{+ready,+symbols,+entries,+workers,+fusions}:
      P112RegionRegistry{p111v_put(ready,name,"P112Worker",arity,rank),p111v_put(symbols,p112w_symbol(name),"P112RegionSymbol",arity,rank),
        Con{P112RegionEntry{segment,plan,rank,sites},entries},U32.inc(workers),U32.add(fusions,sites)}


@unsafe
def p112c_fused(segment: N111Segment, +old: KDef, +symbols: KDef, +rank: U32, +next: P112RegionRegistry, fused: P112FusionBody) -> P112RegionRegistry:
  match segment fused:
    case N111Segment{+name,+arity,+result,+incoming,+flags,+original} P112FusionBody{+body,+count,+site}:
      +transformed: N111Segment = N111Segment{name,arity,result,incoming,flags,body}
      p112c_freeze(transformed,rank,count,next,p112c_plan(transformed,old,symbols,count))

# This helper receives only a qualified typed candidate from p112c_candidates.


@unsafe
def p112c_add(+segment: N111Segment, +index: P112FusionIndex, +old: KDef, +symbols: KDef, +rank: U32, +next: P112RegionRegistry) -> P112RegionRegistry:
  match segment:
    case N111Segment{+name,+arity,+result,+incoming,+flags,+body}:
      nt_choose(P112RegionRegistry,p112w_ready(old,name),u => next,u =>
        p112c_fused(segment,old,symbols,rank,next,p112c_scan(body,index,old,0)))

# old and symbols are immutable for the entire pass; next is only accumulated.


@unsafe
def p112c_pass(segments: List<&2,P112MultiCandidate>, +index: P112FusionIndex, +old: KDef, +symbols: KDef, +rank: U32, next: P112RegionRegistry) -> P112RegionRegistry:
  match segments:
    case Nil{}: next
    case Con{P112MultiCandidate{+segment},+rest}: p112c_pass(rest,index,old,symbols,rank,p112c_add(segment,index,old,symbols,rank,next))


@unsafe
def p112c_passes(+segments: List<&2,P112MultiCandidate>, +index: P112FusionIndex, +registry: P112RegionRegistry, +rank: U32, +left: U32) -> P112RegionRegistry:
  nt_choose(P112RegionRegistry,U32.is_eq(left,0),u => registry,u => p112c_round(segments,index,registry,rank,left))


@unsafe
def p112c_round(+segments: List<&2,P112MultiCandidate>, +index: P112FusionIndex, +registry: P112RegionRegistry, +rank: U32, +left: U32) -> P112RegionRegistry:
  match registry:
    case P112RegionRegistry{+ready,+symbols,+entries,+workers,+fusions}:
      p112c_continue(segments,index,rank,left,workers,p112c_pass(segments,index,ready,symbols,rank,registry))


@unsafe
def p112c_continue(+segments: List<&2,P112MultiCandidate>, +index: P112FusionIndex, +rank: U32, +left: U32, +previous: U32, +registry: P112RegionRegistry) -> P112RegionRegistry:
  match registry:
    case P112RegionRegistry{+ready,+symbols,+entries,+workers,+fusions}:
      nt_choose(P112RegionRegistry,U32.is_eq(workers,previous),u => registry,u => p112c_passes(segments,index,registry,U32.inc(rank),U32.sub(left,1)))


@unsafe
def p112c_candidate(segment: N111Segment) -> Bool:
  match segment:
    case N111Segment{+name,+arity,+result,+incoming,+flags,+body}:
      nt_choose(Bool,U32.is_eq(incoming,0) && U32.is_eq(flags,0) && U32.is_eq(result,1) && U32.is_le(arity,32),
        u => p112f_clean(body),u => False{})

# Metadata and original hygiene are checked once, even when no site is fused.


@unsafe
def p112c_candidates(segments: List<&2,N111Segment>, +acc: List<&2,P112MultiCandidate>) -> List<&2,P112MultiCandidate>:
  match segments:
    case Nil{}: nt_reverse(P112MultiCandidate,acc,[])
    case Con{+segment,+rest}:
      nt_choose(List<&2,P112MultiCandidate>,p112c_candidate(segment),
        u => p112c_candidates(rest,Con{P112MultiCandidate{segment},acc}),u => p112c_candidates(rest,acc))


@unsafe
def p112c_index_with(+segments: List<&2,N111Segment>, +index: P112FusionIndex) -> P112RegionRegistry:
  p112c_passes(p112c_candidates(segments,[]),index,P112RegionRegistry{missing(),missing(),[],0,0},1,6)


@unsafe
def p112c_index(+segments: List<&2,N111Segment>) -> P112RegionRegistry:
  p112c_index_with(segments,p112f_index(segments))


@unsafe
def p112c_private_chunks(entries: List<&2,P112RegionEntry>, +ids: N111Ids, acc: List<&2,String>) -> List<&2,String>:
  match entries:
    case Nil{}: acc
    case Con{P112RegionEntry{+segment,+plan,+rank,+sites},+rest}:
      p112c_private_chunks(rest,ids,Con{p112w_private(segment,ids,plan),acc})


@unsafe
def p112c_public_chunks(segments: List<&2,N111Segment>, +index: P112FusionIndex, +ids: N111Ids, +ready: KDef, acc: List<&2,String>) -> List<&2,String>:
  match segments:
    case Nil{}: nt_reverse(String,acc,[])
    case Con{+segment,+rest}:
      p112c_public_chunks(rest,index,ids,ready,Con{p112f_public(segment,ids,ready,p112c_plan_index(segment,index,ready)),acc})

# Keep one chunk per original segment so existing metadata/chunk consumers keep
# their boundary. Private definitions are attached to the first public chunk.


@unsafe
def p112c_attach(chunks: List<&2,String>, +private: String) -> List<&2,String>:
  match chunks:
    case Nil{}: []
    case Con{+first,+rest}: Con{private ++ first,rest}


@unsafe
def p112c_chunks(+segments: List<&2,N111Segment>, +index: P112FusionIndex, +ids: N111Ids, +acc: List<&2,String>, registry: P112RegionRegistry) -> List<&2,String>:
  match registry:
    case P112RegionRegistry{+ready,+symbols,+entries,+workers,+fusions}:
      p112c_attach(p112c_public_chunks(segments,index,ids,ready,acc),nt_join(p112c_private_chunks(entries,ids,[]),""))


@unsafe
def p112c_segment_chunks(+segments: List<&2,N111Segment>, +ids: N111Ids, +acc: List<&2,String>) -> List<&2,String>:
  p112c_emit_indexed(segments,p112f_index(segments),ids,acc)


@unsafe
def p112c_emit_indexed(+segments: List<&2,N111Segment>, +index: P112FusionIndex, +ids: N111Ids, +acc: List<&2,String>) -> List<&2,String>:
  p112c_chunks(segments,index,ids,acc,p112c_index_with(segments,index))


@unsafe
def p112c_counts(registry: P112RegionRegistry) -> String:
  match registry:
    case P112RegionRegistry{+ready,+symbols,+entries,+workers,+fusions}: U32.show(workers) ++ "/" ++ U32.show(fusions)


@unsafe
def p112c_program_counts(program: P111Program) -> String:
  match program:
    case P111Program{+segments,+constructors,+show,+show_names,+effects,+pure}: p112c_counts(p112c_index(segments))


def p112g_word_type(typ: N111Type) -> Bool:
  match typ:
    case N111U32{}: True{}
    case N111U64{}: True{}
    case _: False{}


@unsafe
def p112g_name(+name: String) -> Bool:
  Bool.not(String.eq(name,"state") || p112r_buffer(name,8))


@unsafe
def p112g_value(value: N111Value) -> Bool:
  match value:
    case N111Local{+name}: p112g_name(name)
    case N111Const{+lo,+hi}: True{}
    case _: False{}


@unsafe
def p112g_pure(stmt: N111Stmt) -> Bool:
  match stmt:
    case N111Set{+name,+typ,+value}: p112g_word_type(typ) && p112g_name(name) && p112g_value(value)
    case N111Bin{+name,+typ,+op,+left,+right}: p112g_word_type(typ) && p112g_name(name) && p112g_value(left) && p112g_value(right)
    case _: False{}


@unsafe
def p112g_split(+body: List<&2,N111Stmt>, +count: U32, +acc: List<&2,N111Stmt>) -> Maybe<&2,P112PureGap>:
  nt_choose(Maybe<&2,P112PureGap>,U32.is_le(count,32),u => p112h_split(body,count,acc),u => None{})

def p112g_prepend(+stmt: N111Stmt, found: Maybe<&2,List<&2,N111Stmt>>) -> Maybe<&2,List<&2,N111Stmt>>:
  match found:
    case None{}: None{}
    case Some{+body}: Some{Con{stmt,body}}

# The pinned p112f_fused scaffold begins with capture-count snapshots and one
# zero frame-result assignment. The gap must follow these, and precede every
# argument snapshot. An unexpectedly short scaffold refuses the whole attempt.


@unsafe
def p112g_splice(+body: List<&2,N111Stmt>, +left: U32, +gap: List<&2,N111Stmt>) -> Maybe<&2,List<&2,N111Stmt>>:
  nt_choose(Maybe<&2,List<&2,N111Stmt>>,U32.is_eq(left,0),u => Some{nt_append(N111Stmt,gap,body)},
    u => p112g_splice_next(body,left,gap))


@unsafe
def p112g_splice_next(body: List<&2,N111Stmt>, +left: U32, +gap: List<&2,N111Stmt>) -> Maybe<&2,List<&2,N111Stmt>>:
  match body:
    case Nil{}: None{}
    case Con{+stmt,+rest}: p112g_prepend(stmt,p112g_splice(rest,U32.sub(left,1),gap))


@unsafe
def p112g_found(+gap: List<&2,N111Stmt>, +captures: U32, found: Maybe<&2,List<&2,N111Stmt>>) -> Maybe<&2,List<&2,N111Stmt>>:
  match found:
    case None{}: None{}
    case Some{+body}: p112g_splice(body,U32.inc(captures),gap)


@unsafe
def p112g_finish(frame: P112FusionFrame, +index: P112FusionIndex, +ready: KDef, +site: U32, +buffer: String, split: Maybe<&2,P112PureGap>) -> Maybe<&2,List<&2,N111Stmt>>:
  match frame split:
    case _ None{}: None{}
    case P112FusionFrame{+captures,+name,+dest,+original} Some{P112PureGap{+gap,+tail}}:
      +stripped: P112FusionFrame = P112FusionFrame{captures,name,dest,tail}
      p112g_found(gap,nt_count(N111Value,captures),p112c_target(stripped,index,ready,site,buffer,p112r_target(tail,site)))


@unsafe
def p112h_condition(value: N111Value) -> Bool:
  match value:
    case N111Local{+name}: p112g_name(name)
    case N111Const{+lo,+hi}: U32.is_eq(hi,0)
    case _: False{}


@unsafe
def p112h_candidate(+stmt: N111Stmt) -> Bool:
  match stmt:
    case N111If{+condition,+yes,+no}: True{}
    case _: p112g_pure(stmt)

# A successful result is the remaining shared budget. Every statement node,
# including If and both branches (even the unselected branch), costs one.


@unsafe
def p112h_stmt(+stmt: N111Stmt, +left: U32) -> Maybe<&2,U32>:
  nt_choose(Maybe<&2,U32>,U32.is_eq(left,0),u => None{},u => p112h_stmt_room(stmt,U32.sub(left,1)))


@unsafe
def p112h_stmt_room(+stmt: N111Stmt, +left: U32) -> Maybe<&2,U32>:
  match stmt:
    case N111If{+condition,+yes,+no}:
      nt_choose(Maybe<&2,U32>,p112h_condition(condition),u => p112h_rest(no,p112h_nodes(yes,left)),u => None{})
    case _: nt_choose(Maybe<&2,U32>,p112g_pure(stmt),u => Some{left},u => None{})


@unsafe
def p112h_nodes(body: List<&2,N111Stmt>, +left: U32) -> Maybe<&2,U32>:
  match body:
    case Nil{}: Some{left}
    case Con{+stmt,+rest}: p112h_rest(rest,p112h_stmt(stmt,left))


@unsafe
def p112h_rest(+body: List<&2,N111Stmt>, result: Maybe<&2,U32>) -> Maybe<&2,U32>:
  match result:
    case None{}: None{}
    case Some{+left}: p112h_nodes(body,left)


@unsafe
def p112h_accept(+stmt: N111Stmt, +rest: List<&2,N111Stmt>, +acc: List<&2,N111Stmt>, result: Maybe<&2,U32>) -> Maybe<&2,P112PureGap>:
  match result:
    case None{}: None{}
    case Some{+left}: p112g_split(rest,U32.sub(32,left),Con{stmt,acc})


@unsafe
def p112h_split(+body: List<&2,N111Stmt>, +count: U32, +acc: List<&2,N111Stmt>) -> Maybe<&2,P112PureGap>:
  match body:
    case Nil{}: Some{P112PureGap{nt_reverse(N111Stmt,acc,[]),body}}
    case Con{+stmt,+rest}:
      nt_choose(Maybe<&2,P112PureGap>,p112h_candidate(stmt),
        u => p112h_accept(stmt,rest,acc,p112h_stmt(stmt,U32.sub(32,count))),
        u => Some{P112PureGap{nt_reverse(N111Stmt,acc,[]),body}})


def p112to_nonowning(kind: N_WordKind) -> Bool:
  match kind:
    case N_W32{}: True{}
    case N_Imm64{}: True{}
    case _: False{}

# Preserve the original telescope traversal and its exact live-arity gate.

@unsafe
def p112to_test_name(+name: String, good: Bool) -> String:
  nt_choose(String,good,u => "PASS " ++ name,u => "FAIL " ++ name)


def p112to_binding(kind: N_WordKind) -> NC_Binding:
  NC_Binding{7,"v_7",kind}


@unsafe
def p112to_keeps(kind: N_WordKind) -> U32:
  nt_count(N111Stmt,p111_keep([p112to_binding(kind)],nu_add(NU_Empty{},7)))


def p112to_drop_count(parts: P111Partition) -> U32:
  match parts:
    case P111Partition{live,drop}: nt_count(N111Stmt,drop)


@unsafe
def p112to_drops(kind: N_WordKind) -> U32:
  p112to_drop_count(p111_partition([p112to_binding(kind)],NU_Empty{}))


def p112to_binding_scalar(binding: NC_Binding) -> Bool:
  match binding:
    case NC_Binding{id,word,kind}: p112to_nonowning(kind)


def p112to_type(+name: String) -> KTerm:
  kt("ADT",name,0,0,[])


def p112to_owner(name: String, builtin: Bool) -> KDef:
  KDef{name,"ADT",0,0,{KTerm{"Data", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},{KTerm{"Absent", "", 0, 0, Nil{}, Nil{}, 0, 0} : KTerm},[],builtin,False{}}


@unsafe
def p112to_canonical(+name: String, builtin: Bool) -> Bool:
  p112to_nonowning(nf_scalar_kind([p112to_owner(name,builtin)],p112to_type(name)))


@unsafe
def p112to_book(+name: String, builtin: Bool) -> List<&2,KDef>:
  [p112to_owner(name,builtin),KDef{"probe","Def",1,0,
    kt("All","x",1,1,[p112to_type(name),p112to_type(name)]),
    k_lam("x",1,1,[var("",1)],0,0,False{}),[],False{},False{}}]


@unsafe
def p112to_seed(+name: String, builtin: Bool, +arity: U32) -> Bool:
  p112to_nonowning(nk_kind(nc_id(10),nk_typed_bindings(nd_entry_params(arity,10),nf_worker_kinds(p112to_book(name,builtin),"probe",arity))))


@unsafe
def p112to_capture_kind() -> Bool:
  p112to_nonowning(nk_kind(7,nc_live_uses([p112to_binding(N_W32{})],nu_add(NU_Empty{},7))))


def p112to_word_load(body: List<&2,N111Stmt>) -> Bool:
  match body:
    case Con{N111Call{name,N111U64{},symbol,args},Nil{}}: String.eq(symbol,"p111_rt_reg_get")
    case _: False{}


@unsafe
def p112to_control_report() -> List<&2,String>:
  [p112to_test_name("scalar-keep-eliminated",U32.is_eq(p112to_keeps(N_W32{}),0)),
   p112to_test_name("opaque-keep-preserved",U32.is_eq(p112to_keeps(N_W64{}),1)),
   p112to_test_name("boxed-keep-preserved",U32.is_eq(p112to_keeps(N_Box{}),1)),
   p112to_test_name("scalar-sink-eliminated",U32.is_eq(p112to_drops(N_W32{}),0)),
   p112to_test_name("opaque-sink-preserved",U32.is_eq(p112to_drops(N_W64{}),1)),
   p112to_test_name("boxed-sink-preserved",U32.is_eq(p112to_drops(N_Box{}),1)),
   p112to_test_name("scalar-alias",p112to_binding_scalar(nk_binding(8,var("",7),[p112to_binding(N_W32{})]))),
   p112to_test_name("opaque-alias",Bool.not(p112to_binding_scalar(nk_binding(8,var("",7),[p112to_binding(N_W64{})])))),
   p112to_test_name("shadowed-id-stays-opaque",Bool.not(p112to_binding_scalar(nk_binding(8,var("",7),[p112to_binding(N_W64{}),p112to_binding(N_W32{})])))),
   p112to_test_name("different-id-stays-opaque",Bool.not(p112to_binding_scalar(nk_binding(8,var("",9),[p112to_binding(N_W32{})])))),
   p112to_test_name("word-literal",p112to_binding_scalar(nk_binding(8,kt("NWord","4294967295",0,0,[]),[]))),
   p112to_test_name("primitive-result-conservative",Bool.not(p112to_binding_scalar(nk_binding(8,kt("NOp","u32_add",0,0,[]),[])))),
   p112to_test_name("ordinary-call-conservative",Bool.not(p112to_binding_scalar(nk_binding(8,kt("NCall","probe",0,0,[]),[])))),
   p112to_test_name("capture-preserves-kind",p112to_capture_kind()),
   p112to_test_name("machine-parameter-stays-u64",p112to_word_load(p111_params([p112to_binding(N_W32{})],0,0,0))),
   p112to_test_name("canonical-u32",p112to_canonical("U32",True{})),
   p112to_test_name("canonical-f32",p112to_canonical("F32",True{})),
   p112to_test_name("canonical-char",p112to_canonical("Char",True{})),
   p112to_test_name("canonical-bool",p112to_canonical("Bool",True{})),
   p112to_test_name("nat-stays-opaque",Bool.not(p112to_canonical("Nat",True{}))),
   p112to_test_name("lookalike-bool-refused",Bool.not(p112to_canonical("Bool",False{}))),
   p112to_test_name("nonbuiltin-u32-refused",Bool.not(p112to_canonical("U32",False{}))),
   p112to_test_name("typed-parameter-seed",p112to_seed("U32",True{},1)),
   p112to_test_name("typed-bool-seed",p112to_seed("Bool",True{},1)),
   p112to_test_name("wrong-live-arity-conservative",Bool.not(p112to_seed("U32",True{},2))),
   p112to_test_name("typed-nat-conservative",Bool.not(p112to_seed("Nat",True{},1))),
   p112to_test_name("typed-lookalike-conservative",Bool.not(p112to_seed("Bool",False{},1)))]
