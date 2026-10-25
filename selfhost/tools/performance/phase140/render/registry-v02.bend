# Process-local registry planning reuse. No production declaration is overridden.
# Each pass still accumulates the original registry using p112c_freeze. Its old
# ready/symbols views are immutable. The cache contains only results returned by
# this implementation, under the same producer/policy epoch; forged caches are
# outside the interface contract.
type P140GSlot is Data:
  P140GSkip{}
  P140GRow{+key: P140RKey, +segment: N111Segment, +plan: P112WorkerPlan, +sites: U32}

type P140GPass is Data:
  P140GPass{+ready: KDef, +symbols: KDef, +rank: U32, +slots: List<&2,P140GSlot>}

type P140GCache is Data:
  P140GCache{+passes: List<&2,P140GPass>}

type P140GWalk is Data:
  P140GWalk{+registry: P112RegionRegistry, +slots: List<&2,P140GSlot>, +hits: U32, +misses: U32}

type P140GResult is Data:
  P140GResult{+registry: P112RegionRegistry, +passes: List<&2,P140GPass>, +hits: U32, +misses: U32}

type P140GPrepared is Data:
  P140GPrepared{+cursor: P134Cursor, +cache: P140GCache, +hits: U32, +misses: U32}

@unsafe
def p140g_key(+segment: N111Segment, +index: P112FusionIndex) -> P140RKey:
  p140r_public_key(segment,p140r_close(p140r_segment_frames(segment,[]),index,[],[],64))

@unsafe
def p140g_matches(+segment: N111Segment, +index: P112FusionIndex, slot: P140GSlot) -> Bool:
  match slot:
    case P140GRow{P140RPublic{old,facts},transformed,plan,sites}:
      nt_choose(Bool,p140r_segment(segment,old),u => p140r_facts_valid(facts,index),u => False{})
    case _: False{}

@unsafe
def p140g_walk(candidates: List<&2,P112MultiCandidate>, +index: P112FusionIndex, +old: KDef,
    +symbols: KDef, +rank: U32, +valid: Bool, prior: List<&2,P140GSlot>,
    registry: P112RegionRegistry, slots: List<&2,P140GSlot>, hits: U32, misses: U32) -> P140GWalk:
  match candidates:
    case Nil{}: P140GWalk{registry,nt_reverse(P140GSlot,slots,[]),hits,misses}
    case Con{P112MultiCandidate{segment},rest}:
      p140g_prior(segment,rest,index,old,symbols,rank,valid,prior,registry,slots,hits,misses)

@unsafe
def p140g_prior(segment: N111Segment, rest: List<&2,P112MultiCandidate>, index: P112FusionIndex,
    old: KDef, symbols: KDef, rank: U32, valid: Bool, prior: List<&2,P140GSlot>,
    registry: P112RegionRegistry, slots: List<&2,P140GSlot>, hits: U32, misses: U32) -> P140GWalk:
  match prior:
    case Nil{}: p140g_candidate(segment,rest,index,old,symbols,rank,valid,P140GSkip{},[],registry,slots,hits,misses)
    case Con{head,tail}: p140g_candidate(segment,rest,index,old,symbols,rank,valid,head,tail,registry,slots,hits,misses)

@unsafe
def p140g_candidate(+segment: N111Segment, +rest: List<&2,P112MultiCandidate>, +index: P112FusionIndex,
    +old: KDef, +symbols: KDef, +rank: U32, +valid: Bool, +prior: P140GSlot,
    +tail: List<&2,P140GSlot>, +registry: P112RegionRegistry, +slots: List<&2,P140GSlot>, +hits: U32, +misses: U32) -> P140GWalk:
  match segment:
    case N111Segment{name,arity,result,incoming,flags,body}:
      nt_choose(P140GWalk,p112w_ready(old,name),
        u => p140g_walk(rest,index,old,symbols,rank,valid,tail,registry,Con{P140GSkip{},slots},hits,misses),
        u => p140g_decide(segment,rest,index,old,symbols,rank,valid,prior,tail,registry,slots,hits,misses,
          nt_choose(Bool,valid,v => p140g_matches(segment,index,prior),v => False{})))

@unsafe
def p140g_decide(+segment: N111Segment, +rest: List<&2,P112MultiCandidate>, +index: P112FusionIndex,
    +old: KDef, +symbols: KDef, +rank: U32, +valid: Bool, +prior: P140GSlot,
    +tail: List<&2,P140GSlot>, +registry: P112RegionRegistry, +slots: List<&2,P140GSlot>, +hits: U32, +misses: U32, reuse: Bool) -> P140GWalk:
  match reuse:
    case True{}: p140g_cached(prior,rest,index,old,symbols,rank,valid,tail,registry,slots,hits,misses)
    case False{}: p140g_miss(segment,rest,index,old,symbols,rank,valid,tail,registry,slots,hits,misses)

@unsafe
def p140g_miss(+segment: N111Segment, rest: List<&2,P112MultiCandidate>, +index: P112FusionIndex,
    +old: KDef, symbols: KDef, rank: U32, valid: Bool, tail: List<&2,P140GSlot>,
    registry: P112RegionRegistry, slots: List<&2,P140GSlot>, hits: U32, misses: U32) -> P140GWalk:
  match segment:
    case N111Segment{name,arity,result,incoming,flags,body}:
      p140g_scanned(segment,rest,index,old,symbols,rank,valid,tail,registry,slots,hits,misses,p112c_scan(body,index,old,0))

@unsafe
def p140g_cached(+prior: P140GSlot, rest: List<&2,P112MultiCandidate>, index: P112FusionIndex,
    old: KDef, symbols: KDef, +rank: U32, valid: Bool, tail: List<&2,P140GSlot>,
    registry: P112RegionRegistry, slots: List<&2,P140GSlot>, hits: U32, misses: U32) -> P140GWalk:
  match prior:
    case P140GRow{key,segment,plan,sites}:
      p140g_walk(rest,index,old,symbols,rank,valid,tail,p112c_freeze(segment,rank,sites,registry,plan),
        Con{prior,slots},U32.inc(hits),misses)
    case P140GSkip{}: p140g_walk(rest,index,old,symbols,rank,valid,tail,registry,Con{prior,slots},hits,misses)

@unsafe
def p140g_scanned(+original: N111Segment, rest: List<&2,P112MultiCandidate>, +index: P112FusionIndex,
    +old: KDef, +symbols: KDef, rank: U32, valid: Bool, tail: List<&2,P140GSlot>,
    registry: P112RegionRegistry, slots: List<&2,P140GSlot>, hits: U32, misses: U32, fused: P112FusionBody) -> P140GWalk:
  match original fused:
    case N111Segment{name,arity,result,incoming,flags,body} P112FusionBody{next,count,site}:
      +transformed: N111Segment = N111Segment{name,arity,result,incoming,flags,next}
      p140g_planned(rest,index,old,symbols,rank,valid,tail,registry,slots,hits,misses,
        P140GRow{p140g_key(original,index),transformed,p112c_plan(transformed,old,symbols,count),count})

@unsafe
def p140g_planned(rest: List<&2,P112MultiCandidate>, index: P112FusionIndex, old: KDef, symbols: KDef,
    +rank: U32, valid: Bool, tail: List<&2,P140GSlot>, registry: P112RegionRegistry,
    slots: List<&2,P140GSlot>, hits: U32, misses: U32, +row: P140GSlot) -> P140GWalk:
  match row:
    case P140GRow{key,segment,plan,sites}:
      p140g_walk(rest,index,old,symbols,rank,valid,tail,p112c_freeze(segment,rank,sites,registry,plan),
        Con{row,slots},hits,U32.inc(misses))
    case P140GSkip{}: p140g_walk(rest,index,old,symbols,rank,valid,tail,registry,Con{row,slots},hits,misses)

@unsafe
def p140g_passes(+candidates: List<&2,P112MultiCandidate>, +index: P112FusionIndex,
    +registry: P112RegionRegistry, +rank: U32, +left: U32, +prior: List<&2,P140GPass>,
    +passes: List<&2,P140GPass>, +hits: U32, +misses: U32) -> P140GResult:
  nt_choose(P140GResult,U32.is_eq(left,0),
    u => P140GResult{registry,nt_reverse(P140GPass,passes,[]),hits,misses},
    u => p140g_round(candidates,index,registry,rank,left,prior,passes,hits,misses))

@unsafe
def p140g_round(+candidates: List<&2,P112MultiCandidate>, +index: P112FusionIndex,
    +registry: P112RegionRegistry, +rank: U32, +left: U32, prior: List<&2,P140GPass>,
    +passes: List<&2,P140GPass>, +hits: U32, +misses: U32) -> P140GResult:
  match registry prior:
    case P112RegionRegistry{+ready,+symbols,entries,workers,fusions} Nil{}:
      p140g_after(candidates,index,ready,symbols,rank,left,[],passes,workers,hits,misses,
        p140g_walk(candidates,index,ready,symbols,rank,False{},[],registry,[],0,0))
    case P112RegionRegistry{+ready,+symbols,entries,workers,fusions} Con{P140GPass{old,syms,order,slots},rest}:
      p140g_after(candidates,index,ready,symbols,rank,left,rest,passes,workers,hits,misses,
        p140g_walk(candidates,index,ready,symbols,rank,
          U32.is_eq(rank,order) && p140r_def(ready,old) && p140r_def(symbols,syms),slots,registry,[],0,0))

@unsafe
def p140g_after(+candidates: List<&2,P112MultiCandidate>, +index: P112FusionIndex,
    ready: KDef, symbols: KDef, +rank: U32, +left: U32, +prior: List<&2,P140GPass>,
    passes: List<&2,P140GPass>, +previous: U32, hits: U32, misses: U32, result: P140GWalk) -> P140GResult:
  match result:
    case P140GWalk{+registry,slots,more_hits,more_misses}:
      +next_passes: List<&2,P140GPass> = Con{P140GPass{ready,symbols,rank,slots},passes}
      +total_hits: U32 = U32.add(hits,more_hits)
      +total_misses: U32 = U32.add(misses,more_misses)
      p140g_continue(registry,candidates,index,rank,left,prior,next_passes,previous,total_hits,total_misses)

@unsafe
def p140g_continue(+registry: P112RegionRegistry, +candidates: List<&2,P112MultiCandidate>, +index: P112FusionIndex,
    +rank: U32, +left: U32, +prior: List<&2,P140GPass>, +passes: List<&2,P140GPass>, previous: U32,
    +hits: U32, +misses: U32) -> P140GResult:
  match registry:
    case P112RegionRegistry{r,s,e,workers,f}:
      nt_choose(P140GResult,U32.is_eq(workers,previous),
        u => P140GResult{registry,nt_reverse(P140GPass,passes,[]),hits,misses},
        u => p140g_passes(candidates,index,registry,U32.inc(rank),U32.sub(left,1),prior,passes,hits,misses))

@unsafe
def p140g_index(+segments: List<&2,N111Segment>, +index: P112FusionIndex, cache: P140GCache) -> P140GResult:
  match cache:
    case P140GCache{passes}:
      p140g_passes(p112c_candidates(segments,[]),index,P112RegionRegistry{missing(),missing(),[],0,0},1,6,passes,[],0,0)

# Same success routes and metadata preparation as p134e_begin/p134e_prepare.
# Only the p112c_index_with computation is replaced by the memoized equivalent.
@unsafe
def p140g_prepare(plan: P134EmissionPlan, cache: P140GCache) -> P140GPrepared:
  match plan:
    case P134Raw{program}: p140g_fields(program,[],[],False{},False{},cache)
    case P134Static{P112StaticProgram{program,nodes}}: p140g_fields(program,nodes,[],False{},False{},cache)
    case P134Direct{P113DProgram{P112StaticProgram{program,nodes},functions}}:
      p140g_fields(program,nodes,functions,False{},False{},cache)
    case P134Admitted{admitted}: p140g_admitted(admitted,cache)

@unsafe
def p140g_admitted(+admitted: P113AProgram, cache: P140GCache) -> P140GPrepared:
  match admitted:
    case P113AProgram{P113DProgram{P112StaticProgram{program,nodes},Nil{}},certificate}:
      p140g_fields(program,nodes,[],False{},False{},cache)
    case P113AProgram{P113DProgram{P112StaticProgram{program,nodes},functions},certificate}:
      p140g_fields(program,nodes,functions,p113a_enabled(certificate),p118z_eligible(admitted),cache)

@unsafe
def p140g_fields(+program: P111Program, +nodes: List<&2,P112SNode>, +functions: List<&2,P113DFunction>,
    +arrays: Bool, +live: Bool, cache: P140GCache) -> P140GPrepared:
  match program:
    case P111Program{+segments,constructors,show,names,effects,pure}:
      +ids = p111q_ids(program)
      +index = p112f_index(segments)
      +tables = nt_choose(List<&2,P111QData>,List.is_empty(&2,P112SNode,nodes),
        u => p111q_tables(program,ids),u => p112s_tables(program,nodes,ids))
      +mode = nt_choose(U32,List.is_empty(&2,P113DFunction,functions),u => 0,
        u => nt_choose(U32,arrays,v => 2,v => 1))
      +tables = nt_choose(List<&2,P111QData>,arrays,u => p117p_tables(tables,[]),u => tables)
      +tables = nt_choose(List<&2,P111QData>,live,u => p118z_tables(tables),u => tables)
      p140g_registered(segments,functions,ids,index,p113a_heap_min(nodes),mode,
        p118c_tables(tables),p140g_index(segments,index,cache))

@unsafe
def p140g_registered(segments: List<&2,N111Segment>, functions: List<&2,P113DFunction>,
    ids: N111Ids, index: P112FusionIndex, heap: U32, mode: U32, tables: List<&2,P111QData>, result: P140GResult) -> P140GPrepared:
  match result:
    case P140GResult{registry,passes,hits,misses}:
      P140GPrepared{p134e_registered(segments,functions,ids,index,heap,mode,tables,registry),P140GCache{passes},hits,misses}
