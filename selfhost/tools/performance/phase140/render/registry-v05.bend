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
  P140GMetadata{+passes: List<&2,P140GPass>, +program: P111Program, +nodes: List<&2,P112SNode>,
    +arrays: Bool, +live: Bool, +ids: N111Ids, +index: P112FusionIndex, +tables: List<&2,P111QData>}

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
    case P140GMetadata{passes,program,nodes,arrays,live,ids,stored,tables}: p140g_index(segments,index,P140GCache{passes})
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
  match cache:
    case P140GCache{passes}: p140gm_cold(program,nodes,functions,arrays,live,passes)
    case P140GMetadata{+passes,+old,old_nodes,old_arrays,old_live,ids,index,tables}:
      nt_choose(P140GPrepared,p140gm_headers(program,old) && p140or_nodes(nodes,old_nodes) &&
        p134v_bool(arrays,old_arrays) && p134v_bool(live,old_live),
        u => p140gm_warm(program,nodes,functions,arrays,live,passes,old,ids,index,tables),
        u => p140gm_cold(program,nodes,functions,arrays,live,passes))

@unsafe
def p140g_registered(segments: List<&2,N111Segment>, functions: List<&2,P113DFunction>,
    ids: N111Ids, index: P112FusionIndex, heap: U32, mode: U32, tables: List<&2,P111QData>, result: P140GResult) -> P140GPrepared:
  match result:
    case P140GResult{registry,passes,hits,misses}:
      P140GPrepared{p134e_registered(segments,functions,ids,index,heap,mode,tables,registry),P140GCache{passes},hits,misses}

# Exact header/table metadata reuse; no producer or verified worker gate changes.
@unsafe
def p140gm_headers(a: P111Program, b: P111Program) -> Bool:
  match a b:
    case P111Program{aseg,ac,aw,an,ae,ap} P111Program{bs,bc,bw,bn,be,bp}:
      p140e_raw_headers(aseg,bs) && p140e_ctors(ac,bc) &&
        p140e_u32s(aw,bw) && p140o_strings(an,bn) && p140o_strings(ae,be) && p134v_bool(ap,bp)

@unsafe
def p140gm_cold(+program: P111Program, +nodes: List<&2,P112SNode>, +functions: List<&2,P113DFunction>,
    +arrays: Bool, +live: Bool, passes: List<&2,P140GPass>) -> P140GPrepared:
  match program:
    case P111Program{+segments,constructors,show,names,effects,pure}:
      +ids = p111q_ids(program)
      +tables = nt_choose(List<&2,P111QData>,List.is_empty(&2,P112SNode,nodes),
        u => p111q_tables(program,ids),u => p112s_tables(program,nodes,ids))
      +tables = nt_choose(List<&2,P111QData>,arrays,u => p117p_tables(tables,[]),u => tables)
      +tables = nt_choose(List<&2,P111QData>,live,u => p118z_tables(tables),u => tables)
      p140gm_plan(program,nodes,functions,arrays,live,passes,ids,p112f_index(segments),p118c_tables(tables))

@unsafe
def p140gm_warm(+program: P111Program, nodes: List<&2,P112SNode>, functions: List<&2,P113DFunction>,
    arrays: Bool, live: Bool, passes: List<&2,P140GPass>, old: P111Program,
    ids: N111Ids, index: P112FusionIndex, tables: List<&2,P111QData>) -> P140GPrepared:
  match program old:
    case P111Program{+segments,c,s,n,e,p} P111Program{prior,oc,os,on,oe,op}:
      p140gm_plan(program,nodes,functions,arrays,live,passes,ids,
        p140gm_changed(segments,prior,segments,index,[],0),tables)

@unsafe
def p140gm_plan(+program: P111Program, +nodes: List<&2,P112SNode>, functions: List<&2,P113DFunction>,
    +arrays: Bool, +live: Bool, passes: List<&2,P140GPass>, +ids: N111Ids,
    +index: P112FusionIndex, +tables: List<&2,P111QData>) -> P140GPrepared:
  match program:
    case P111Program{+segments,c,s,n,e,p}:
      p140gm_done(program,nodes,functions,arrays,live,ids,index,tables,p140g_index(segments,index,P140GCache{passes}))

@unsafe
def p140gm_done(+program: P111Program, +nodes: List<&2,P112SNode>, +functions: List<&2,P113DFunction>,
    +arrays: Bool, live: Bool, +ids: N111Ids, +index: P112FusionIndex, +tables: List<&2,P111QData>, result: P140GResult) -> P140GPrepared:
  match program result:
    case P111Program{segments,c,s,n,e,p} P140GResult{registry,passes,hits,misses}:
      +mode = nt_choose(U32,List.is_empty(&2,P113DFunction,functions),u => 0,u => nt_choose(U32,arrays,v => 2,v => 1))
      P140GPrepared{p134e_registered(segments,functions,ids,index,p113a_heap_min(nodes),mode,tables,registry),
        P140GMetadata{passes,program,nodes,arrays,live,ids,index,tables},hits,misses}

# At most16 changed positions use local replacements; wider edits use the old build.
# Resolve each changed name against the first current occurrence, retaining original
# first-wins semantics even for duplicate names. Replacement preserves bucket order.
@unsafe
def p140gm_changed(current: List<&2,N111Segment>, old: List<&2,N111Segment>, +all: List<&2,N111Segment>,
    +index: P112FusionIndex, +changed: List<&2,String>, +count: U32) -> P112FusionIndex:
  match current old:
    case Nil{} Nil{}: p140gm_patch(changed,all,index)
    case Con{+head,+rest} Con{prior,+tail}:
      nt_choose(P112FusionIndex,p140r_segment(head,prior),
        u => p140gm_changed(rest,tail,all,index,changed,count),
        u => nt_choose(P112FusionIndex,U32.is_lt(count,16),
          v => p140gm_change(head,rest,tail,all,index,changed,count),v => p112f_index(all)))
    case _ _: p112f_index(all)

@unsafe
def p140gm_change(head: N111Segment, rest: List<&2,N111Segment>, tail: List<&2,N111Segment>, all: List<&2,N111Segment>,
    index: P112FusionIndex, changed: List<&2,String>, count: U32) -> P112FusionIndex:
  match head:
    case N111Segment{name,a,r,i,f,b}: p140gm_changed(rest,tail,all,index,Con{name,changed},U32.inc(count))

@unsafe
def p140gm_first(segments: List<&2,N111Segment>, +name: String) -> Maybe<&2,N111Segment>:
  match segments:
    case Nil{}: None{}
    case Con{+head,rest}:
      match head:
        case N111Segment{key,a,r,i,f,b}: nt_choose(Maybe<&2,N111Segment>,String.eq(key,name),u => Some{head},u => p140gm_first(rest,name))

@unsafe
def p140gm_patch(changed: List<&2,String>, +segments: List<&2,N111Segment>, index: P112FusionIndex) -> P112FusionIndex:
  match changed:
    case Nil{}: index
    case Con{+name,rest}: p140gm_found(rest,segments,index,name,p140gm_first(segments,name))

@unsafe
def p140gm_found(rest: List<&2,String>, segments: List<&2,N111Segment>, index: P112FusionIndex, +name: String,
    found: Maybe<&2,N111Segment>) -> P112FusionIndex:
  match found:
    case None{}: p112f_index(segments)
    case Some{segment}: p140gm_patch(rest,segments,p140gm_replace(index,segment,name,index_hash(name,2166136261)))

@unsafe
def p140gm_bucket(bucket: List<&2,N111Segment>, +segment: N111Segment, +name: String) -> List<&2,N111Segment>:
  match bucket:
    case Nil{}: []
    case Con{+head,+rest}:
      match head:
        case N111Segment{key,a,r,i,f,b}: nt_choose(List<&2,N111Segment>,String.eq(key,name),
          u => Con{segment,rest},u => Con{head,p140gm_bucket(rest,segment,name)})

@unsafe
def p140gm_replace(tree: P112FusionIndex, +segment: N111Segment, +name: String, +hash: U32) -> P112FusionIndex:
  match tree:
    case P112FusionEmpty{}: P112FusionEmpty{}
    case P112FusionLeaf{stored,bucket}: P112FusionLeaf{stored,p140gm_bucket(bucket,segment,name)}
    case P112FusionNode{+mask,+left,+right}:
      nt_choose(P112FusionIndex,U32.is_eq(U32.and(hash,mask),0),
        u => P112FusionNode{mask,p140gm_replace(left,segment,name,hash),right},
        u => P112FusionNode{mask,left,p140gm_replace(right,segment,name,hash)})
