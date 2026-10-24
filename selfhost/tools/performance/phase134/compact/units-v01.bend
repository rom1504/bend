# Experimental in-process, fixed-producer memo for private function transforms.
# Keys are exact IR and exact queried prior-callee results, including absence.
# Slots are position-aligned hints: changed positions simply miss.
# This is NOT a persistent or externally supplied cache format.

type P134UFact is Data:
  P134UFact{+target: String, +found: Maybe<&2,P113DFunction>}

type P134USlot is Data:
  P134UEmpty{}
  P134USlot{+input: P113DFunction, +facts: List<&2,P134UFact>, +unit: P134RKUnit}

type P134UOne is Data:
  P134UOne{+unit: P134RKUnit, +slot: P134USlot, +hit: Bool}

type P134UInline is Data:
  P134UInline{+functions: List<&2,P113DFunction>, +memos: List<&2,P134RKMemo>, +slots: List<&2,P134USlot>, +hits: U32, +misses: U32}

type P134URangeOne is Data:
  P134URangeOne{+function: P113DFunction, +memo: P134RKMemo, +prior: Bool, +inner: Bool}

type P134URanges is Data:
  P134URanges{+functions: List<&2,P113DFunction>, +slots: List<&2,P134RKMemo>, +hits: U32, +inner: U32, +misses: U32}

type P134UCache is Data:
  P134UCache{+inline: List<&2,P134USlot>, +ranges: List<&2,P134RKMemo>}

type P134UOptimized is Data:
  P134UOptimized{+boundary: P114SBoundary, +cache: P134UCache, +stats: List<&2,U32>}

type P134UEmission is Data:
  P134UEmission{+emission: P111Emission, +cache: P134UCache, +stats: List<&2,U32>}

@unsafe
def p134u_maybe(a: Maybe<&2,P113DFunction>, b: Maybe<&2,P113DFunction>) -> Bool:
  match a b:
    case None{} None{}: True{}
    case Some{x} Some{y}: p134v_function(x,y)
    case _ _: False{}

@unsafe
def p134u_facts(body: List<&2,P113DStmt>, +table: P113ITable, acc: List<&2,P134UFact>) -> List<&2,P134UFact>:
  match body:
    case Nil{}: acc
    case Con{P113DCall{destinations,+target,args},rest}:
      Con{P134UFact{target,p113i_get(table,target,index_hash(target,2166136261),0)},p134u_facts(rest,table,acc)}
    case Con{P113DIf{condition,yes,no},rest}:
      p134u_facts(yes,table,p134u_facts(no,table,p134u_facts(rest,table,acc)))
    case Con{stmt,rest}: p134u_facts(rest,table,acc)

@unsafe
def p134u_dependencies(function: P113DFunction, table: P113ITable) -> List<&2,P134UFact>:
  match function:
    case P113DFunction{name,params,result,public,body}: p134u_facts(body,table,[])

@unsafe
def p134u_facts_valid(facts: List<&2,P134UFact>, +table: P113ITable) -> Bool:
  match facts:
    case Nil{}: True{}
    case Con{P134UFact{+target,found},+rest}:
      nt_choose(Bool,p134u_maybe(found,p113i_get(table,target,index_hash(target,2166136261),0)),
        u => p134u_facts_valid(rest,table),u => False{})

@unsafe
def p134u_created(input: P113DFunction, facts: List<&2,P134UFact>, +unit: P134RKUnit) -> P134UOne:
  P134UOne{unit,P134USlot{input,facts,unit},False{}}

@unsafe
def p134u_fresh(+input: P113DFunction, +table: P113ITable) -> P134UOne:
  p134u_created(input,p134u_dependencies(input,table),p134rk_function(input,table))

@unsafe
def p134u_one(+input: P113DFunction, +table: P113ITable, +slot: P134USlot) -> P134UOne:
  match slot:
    case P134UEmpty{}: p134u_fresh(input,table)
    case P134USlot{previous,+facts,+unit}:
      nt_choose(P134UOne,p134v_function(input,previous),
        u => nt_choose(P134UOne,p134u_facts_valid(facts,table),
          v => P134UOne{unit,slot,True{}},v => p134u_fresh(input,table)),
        u => p134u_fresh(input,table))

def p134u_slot_head(slots: List<&2,P134USlot>) -> P134USlot:
  match slots:
    case Nil{}: P134UEmpty{}
    case Con{head,rest}: head

def p134u_slot_tail(slots: List<&2,P134USlot>) -> List<&2,P134USlot>:
  match slots:
    case Nil{}: []
    case Con{head,rest}: rest

def p134u_memo_head(slots: List<&2,P134RKMemo>) -> P134RKMemo:
  match slots:
    case Nil{}: P134RKEmpty{}
    case Con{head,rest}: head

def p134u_memo_tail(slots: List<&2,P134RKMemo>) -> List<&2,P134RKMemo>:
  match slots:
    case Nil{}: []
    case Con{head,rest}: rest

@unsafe
def p134u_inline(functions: List<&2,P113DFunction>, +table: P113ITable, +prior: List<&2,P134USlot>, acc: List<&2,P113DFunction>, memos: List<&2,P134RKMemo>, slots: List<&2,P134USlot>, hits: U32, misses: U32) -> P134UInline:
  match functions:
    case Nil{}: P134UInline{nt_reverse(P113DFunction,acc,[]),nt_reverse(P134RKMemo,memos,[]),nt_reverse(P134USlot,slots,[]),hits,misses}
    case Con{+head,rest}:
      p134u_inline_step(head,rest,table,p134u_slot_tail(prior),acc,memos,slots,hits,misses,
        p134u_one(head,table,p134u_slot_head(prior)))

@unsafe
def p134u_inline_step(+original: P113DFunction, rest: List<&2,P113DFunction>, +table: P113ITable, prior: List<&2,P134USlot>, acc: List<&2,P113DFunction>, memos: List<&2,P134RKMemo>, slots: List<&2,P134USlot>, hits: U32, misses: U32, one: P134UOne) -> P134UInline:
  match one:
    case P134UOne{P134RKUnit{+function,memo},slot,+hit}:
      p134u_inline(rest,
        nt_choose(P113ITable,p113i_original_clean(original),u => p113i_table_function(function,table),u => table),
        prior,Con{function,acc},Con{memo,memos},Con{slot,slots},
        U32.add(hits,Bool.to_u32(hit)),U32.add(misses,Bool.to_u32(Bool.not(hit))))

@unsafe
def p134u_range_chosen(+input: P113DFunction, +output: P113DFunction, prior: Bool, inner: Bool) -> P134URangeOne:
  P134URangeOne{output,P134RKMemo{input,output},prior,inner}

@unsafe
def p134u_range_inner(+current: P113DFunction, inner: P134RKMemo) -> P134URangeOne:
  match inner:
    case P134RKEmpty{}: p134u_range_chosen(current,p113k_function(current),False{},False{})
    case P134RKMemo{input,+output}:
      nt_choose(P134URangeOne,p134v_function(current,input),
        u => p134u_range_chosen(current,output,False{},True{}),
        u => p134u_range_chosen(current,p113k_function(current),False{},False{}))

@unsafe
def p134u_range_one(+current: P113DFunction, +inner: P134RKMemo, prior: P134RKMemo) -> P134URangeOne:
  match prior:
    case P134RKEmpty{}: p134u_range_inner(current,inner)
    case P134RKMemo{input,+output}:
      nt_choose(P134URangeOne,p134v_function(current,input),
        u => p134u_range_chosen(current,output,True{},False{}),
        u => p134u_range_inner(current,inner))

@unsafe
def p134u_ranges(functions: List<&2,P113DFunction>, +prior: List<&2,P134RKMemo>, +inner: List<&2,P134RKMemo>, acc: List<&2,P113DFunction>, slots: List<&2,P134RKMemo>, hits: U32, reused: U32, misses: U32) -> P134URanges:
  match functions:
    case Nil{}: P134URanges{nt_reverse(P113DFunction,acc,[]),nt_reverse(P134RKMemo,slots,[]),hits,reused,misses}
    case Con{head,rest}:
      p134u_ranges_step(rest,p134u_memo_tail(prior),p134u_memo_tail(inner),acc,slots,hits,reused,misses,
        p134u_range_one(head,p134u_memo_head(inner),p134u_memo_head(prior)))

@unsafe
def p134u_ranges_step(rest: List<&2,P113DFunction>, prior: List<&2,P134RKMemo>, inner: List<&2,P134RKMemo>, acc: List<&2,P113DFunction>, slots: List<&2,P134RKMemo>, hits: U32, reused: U32, misses: U32, one: P134URangeOne) -> P134URanges:
  match one:
    case P134URangeOne{function,memo,+old,+same}:
      p134u_ranges(rest,prior,inner,Con{function,acc},Con{memo,slots},
        U32.add(hits,Bool.to_u32(old)),U32.add(reused,Bool.to_u32(same)),
        U32.add(misses,Bool.to_u32(Bool.not(old || same))))

@unsafe
def p134u_finish(boundary: P114SBoundary, inline: List<&2,P134USlot>, ih: U32, im: U32, ranges: P134URanges) -> P134UOptimized:
  match ranges:
    case P134URanges{functions,slots,rh,ri,rm}:
      P134UOptimized{p134v_commit(boundary,functions),P134UCache{inline,slots},[ih,im,rh,ri,rm]}

@unsafe
def p134u_committed(+boundary: P114SBoundary, slots: List<&2,P134USlot>, prior: List<&2,P134RKMemo>, inner: List<&2,P134RKMemo>, ih: U32, im: U32) -> P134UOptimized:
  match boundary:
    case P114SBoundary{original,ids,functions,valid}:
      p134u_finish(boundary,slots,ih,im,p134u_ranges(functions,prior,inner,[],[],0,0,0))

@unsafe
def p134u_inlined(boundary: P114SBoundary, prior: List<&2,P134RKMemo>, inline: P134UInline) -> P134UOptimized:
  match inline:
    case P134UInline{functions,memos,slots,ih,im}:
      p134u_committed(p134v_commit(boundary,functions),slots,prior,memos,ih,im)

@unsafe
def p134u_optimize(+boundary: P114SBoundary, cache: P134UCache) -> P134UOptimized:
  match boundary cache:
    case P114SBoundary{original,ids,+functions,valid} P134UCache{+inline,+ranges}:
      nt_choose(P134UOptimized,valid,
        u => p134u_inlined(boundary,ranges,p134u_inline(functions,P113IEmpty{},inline,[],[],[],0,0)),
        u => P134UOptimized{boundary,P134UCache{[],[]},[0,0,0,0,0]})

@unsafe
def p134u_emitted(request: NR_Request, certificate: P113ACertificate, raw: List<&2,P113DCandidate>, error: String, optimized: P134UOptimized) -> P134UEmission:
  match optimized:
    case P134UOptimized{boundary,cache,stats}:
      P134UEmission{p134e_collect(p128raw_lowered(request,raw,p113a_finish(certificate,
        P113DLowered{p114s_close(boundary),error}))),cache,stats}

@unsafe
def p134u_opened(request: NR_Request, certificate: P113ACertificate, raw: List<&2,P113DCandidate>, cache: P134UCache, lowered: P114SLowered) -> P134UEmission:
  match lowered:
    case P114SLowered{boundary,error}:
      p134u_emitted(request,certificate,raw,error,p134u_optimize(boundary,cache))

@unsafe
def p134u_session(request: NR_Request, certificate: P113ACertificate, cache: P134UCache, session: P128RawLowering) -> P134UEmission:
  match session:
    case P128RawLowering{lowered,raw}:
      p134u_opened(request,certificate,raw,cache,p114s_open_lowered(lowered))

@unsafe
def p134u_request(+request: NR_Request, +error: String, +cache: P134UCache) -> P134UEmission:
  nt_choose(P134UEmission,String.is_empty(error),
    u => p134u_session(request,p113a_certificate(request),cache,p128raw_lower_request(request)),
    u => P134UEmission{P111Emission{[],"compile: " ++ error},P134UCache{[],[]},[0,0,0,0,0]})
