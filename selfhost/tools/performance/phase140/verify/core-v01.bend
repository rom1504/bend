# Internal fixed-producer success cache. Only p140v_publish constructs a ready
# cache in the integrated request path; never deserialize or accept one from IO.
# Global/schema/image checks always run. Prior body judgments require exact
# current verifier context and exact body equality. No production overrides.
type P140VCache is Data:
  P140VEmpty{}
  P140VCache{+program: P113DProgram}

type P140VReuse is Data:
  P140VReuse{+segments: List<&2,N111Segment>, +functions: List<&2,P113DFunction>, +raw: Bool, +direct: Bool}

type P140VWalk is Data:
  P140VWalk{+error: String, +hits: U32, +misses: U32}

type P140VChecked is Data:
  P140VChecked{+cache: P140VCache, +ids: N111Ids, +static_ok: Bool, +error: String, +counts: List<&2,U32>}

type P140VOpened is Data:
  P140VOpened{+boundary: P114SBoundary, +cache: P140VCache, +counts: List<&2,U32>}

type P140VArrayChecked is Data:
  P140VArrayChecked{+cache: P140VCache, +error: String, +counts: List<&2,U32>}

def p140v_ctor(a: N_Constructor, b: N_Constructor) -> Bool:
  match a b:
    case N_Constructor{an,aa,ah} N_Constructor{bn,ba,bh}:
      String.eq(an,bn) && U32.is_eq(aa,ba) && p134v_bool(ah,bh)

def p140v_header(a: N111Segment, b: N111Segment) -> Bool:
  match a b:
    case N111Segment{an,aa,ar,ai,af,ab} N111Segment{bn,ba,br,bi,bf,bb}:
      String.eq(an,bn) && U32.is_eq(aa,ba) && U32.is_eq(ar,br) && U32.is_eq(ai,bi) && U32.is_eq(af,bf)

@unsafe
def p140v_segment(a: N111Segment, b: N111Segment) -> Bool:
  match a b:
    case N111Segment{an,aa,ar,ai,af,ab} N111Segment{bn,ba,br,bi,bf,bb}:
      String.eq(an,bn) && U32.is_eq(aa,ba) && U32.is_eq(ar,br) && U32.is_eq(ai,bi) && U32.is_eq(af,bf) && p134v_list(N111Stmt,p134v_scalar,ab,bb)

# These are precisely the inputs of both raw IDs and direct-original IDs;
# compare all segment metadata (stronger than the maps' projected inputs).
# Static nodes/effects are validated afresh below, not asserted unchanged.
@unsafe
def p140v_context(old: P112StaticProgram, current: P112StaticProgram) -> Bool:
  match old current:
    case P112StaticProgram{P111Program{os,oc,osh,osn,oe,op},on} P112StaticProgram{P111Program{ns,nc,nsh,nsn,ne,np},nn}:
      p134v_list(N111Segment,p140v_header,os,ns) && p134v_list(N_Constructor,p140v_ctor,oc,nc)

@unsafe
def p140v_reuse(+current: P113DProgram, cache: P140VCache) -> P140VReuse:
  match cache:
    case P140VEmpty{}: P140VReuse{[],[],False{},False{}}
    case P140VCache{P113DProgram{+old,+of}}:
      match current:
        case P113DProgram{+now,+nf}:
          p140v_reuse_context(old,of,nf,p140v_context(old,now))

@unsafe
def p140v_reuse_context(old: P112StaticProgram, +of: List<&2,P113DFunction>, nf: List<&2,P113DFunction>, +same: Bool) -> P140VReuse:
  match old:
    case P112StaticProgram{P111Program{segments,ctors,show,names,effects,pure},nodes}:
      P140VReuse{segments,of,same,same && p134v_list(P113DFunction,p134v_header,of,nf)}

@unsafe
def p140v_raw_walk(old: List<&2,N111Segment>, current: List<&2,N111Segment>, +ids: N111Ids, +reuse: Bool, hits: U32, misses: U32) -> P140VWalk:
  match current:
    case Nil{}: P140VWalk{"",hits,misses}
    case Con{+head,rest}:
      match old:
        case Nil{}: p140v_raw_step([],head,rest,ids,False{},hits,misses,False{})
        case Con{prior,tail}: p140v_raw_step(tail,head,rest,ids,reuse,hits,misses,reuse && p140v_segment(prior,head))

@unsafe
def p140v_raw_step(old: List<&2,N111Segment>, +head: N111Segment, current: List<&2,N111Segment>, +ids: N111Ids, reuse: Bool, hits: U32, misses: U32, +hit: Bool) -> P140VWalk:
  p140v_raw_result(old,head,current,ids,reuse,hits,misses,hit,
    nt_choose(String,hit,u => "",u => p111v_segment(head,ids)))

@unsafe
def p140v_raw_result(+old: List<&2,N111Segment>, +head: N111Segment, +current: List<&2,N111Segment>, +ids: N111Ids, +reuse: Bool, +hits: U32, +misses: U32, +hit: Bool, +error: String) -> P140VWalk:
  nt_choose(P140VWalk,String.is_empty(error),
    u => p140v_raw_walk(old,current,ids,reuse,U32.add(hits,Bool.to_u32(hit)),U32.add(misses,Bool.to_u32(Bool.not(hit)))),
    u => P140VWalk{p111v_segment_error(head,error),hits,U32.inc(misses)})

# Same metadata gates and diagnostic priority as p111v_program_indexed.
@unsafe
def p140v_raw_scans(segments: List<&2,N111Segment>, old: List<&2,N111Segment>, reuse: Bool, functions: P111VScan, constructors: P111VScan) -> P140VWalk:
  match functions constructors:
    case P111VScan{+fs,+fe,fc} P111VScan{+cs,+ce,cc}:
      +main = p111v_get(fs,"main")
      nt_choose(P140VWalk,Bool.not(String.is_empty(fe)),u => P140VWalk{fe,0,0},u =>
      nt_choose(P140VWalk,Bool.not(String.is_empty(ce)),u => P140VWalk{ce,0,0},u =>
      nt_choose(P140VWalk,String.eq(dk(main),"Absent") || Bool.not(U32.is_eq(da(main),0)) || Bool.not(U32.is_eq(dx(main),0)),
        u => P140VWalk{"program requires a direct, zero-argument main segment",0,0},
        u => p140v_raw_walk(old,segments,N111Ids{fs,cs},reuse,0,0))))

@unsafe
def p140v_raw(program: P111Program, old: List<&2,N111Segment>, reuse: Bool) -> P140VWalk:
  match program:
    case P111Program{+segments,constructors,show,names,effects,pure}:
      p140v_raw_scans(segments,old,reuse,p111v_functions(segments,P111VScan{missing(),"",0}),p111v_constructors(constructors,P111VScan{missing(),"",0}))

@unsafe
def p140v_direct_walk(old: List<&2,P113DFunction>, current: List<&2,P113DFunction>, +ids: N111Ids, +ready: KDef, +reuse: Bool, hits: U32, misses: U32) -> P140VWalk:
  match current:
    case Nil{}: P140VWalk{"",hits,misses}
    case Con{+head,rest}:
      match old:
        case Nil{}: p140v_direct_step([],head,rest,ids,ready,False{},hits,misses,False{})
        case Con{prior,tail}: p140v_direct_step(tail,head,rest,ids,ready,reuse,hits,misses,reuse && p134v_function(prior,head))

@unsafe
def p140v_direct_step(old: List<&2,P113DFunction>, +head: P113DFunction, current: List<&2,P113DFunction>, +ids: N111Ids, +ready: KDef, reuse: Bool, hits: U32, misses: U32, +hit: Bool) -> P140VWalk:
  p140v_direct_result(old,head,current,ids,ready,reuse,hits,misses,hit,
    nt_choose(String,hit,u => "",u => p113e_function(head,ids,ready)))

@unsafe
def p140v_direct_result(+old: List<&2,P113DFunction>, +head: P113DFunction, +current: List<&2,P113DFunction>, +ids: N111Ids, +ready: KDef, +reuse: Bool, +hits: U32, +misses: U32, +hit: Bool, +error: String) -> P140VWalk:
  nt_choose(P140VWalk,String.is_empty(error),
    u => p140v_direct_walk(old,current,ids,p113e_insert(ready,p113e_signature(head)),reuse,U32.add(hits,Bool.to_u32(hit)),U32.add(misses,Bool.to_u32(Bool.not(hit)))),
    u => P140VWalk{error,hits,U32.inc(misses)})

@unsafe
def p140v_publish(+current: P113DProgram, ids: N111Ids, raw_hits: U32, raw_misses: U32, direct: P140VWalk) -> P140VChecked:
  match direct:
    case P140VWalk{+error,hits,misses}:
      P140VChecked{nt_choose(P140VCache,String.is_empty(error),u => P140VCache{current},u => P140VEmpty{}),ids,True{},error,[raw_hits,raw_misses,hits,misses]}

@unsafe
def p140v_static_done(+current: P113DProgram, +old: List<&2,P113DFunction>, +reuse: Bool, +hits: U32, +misses: U32, +error: String) -> P140VChecked:
  match current:
    case P113DProgram{+original,+functions}:
      nt_choose(P140VChecked,String.is_empty(error),
        u => p140v_static_ready(current,old,functions,reuse,hits,misses,p114s_ids(original)),
        u => P140VChecked{P140VEmpty{},N111Ids{missing(),missing()},False{},error,[hits,misses,0,0]})

@unsafe
def p140v_static_ready(+current: P113DProgram, old: List<&2,P113DFunction>, functions: List<&2,P113DFunction>, reuse: Bool, hits: U32, misses: U32, +ids: N111Ids) -> P140VChecked:
  p140v_publish(current,ids,hits,misses,p140v_direct_walk(old,functions,ids,missing(),reuse,0,0))

@unsafe
def p140v_raw_done(+current: P113DProgram, old: List<&2,P113DFunction>, reuse: Bool, raw: P140VWalk) -> P140VChecked:
  match current raw:
    case P113DProgram{original,functions} P140VWalk{error,hits,misses}:
      p140v_static_done(current,old,reuse,hits,misses,p111_first(error,p112s_image_error(original)))

@unsafe
def p140v_with_reuse(+current: P113DProgram, reuse: P140VReuse) -> P140VChecked:
  match current reuse:
    case P113DProgram{P112StaticProgram{program,nodes},functions} P140VReuse{segments,old,raw,direct}:
      p140v_raw_done(current,old,direct,p140v_raw(program,segments,raw))

@unsafe
def p140v_check(+current: P113DProgram, cache: P140VCache) -> P140VChecked:
  p140v_with_reuse(current,p140v_reuse(current,cache))

@unsafe
def p140v_open_done(program: P113DProgram, checked: P140VChecked) -> P140VOpened:
  match program checked:
    case P113DProgram{original,functions} P140VChecked{cache,ids,static_ok,error,counts}:
      P140VOpened{P114SBoundary{original,ids,functions,String.is_empty(error)},cache,counts}

@unsafe
def p140v_open(+program: P113DProgram, cache: P140VCache) -> P140VOpened:
  p140v_open_done(program,p140v_check(program,cache))

@unsafe
def p140v_array_done(+program: P113AProgram, checked: P140VChecked) -> P140VArrayChecked:
  match program checked:
    case P113AProgram{direct,certificate} P140VChecked{+cache,ids,static_ok,error,counts}:
      p140v_array_result(cache,counts,p114t_verify_done(program,p113a_verify_after(direct,certificate,error)))

@unsafe
def p140v_array_result(+cache: P140VCache, counts: List<&2,U32>, +error: String) -> P140VArrayChecked:
  P140VArrayChecked{nt_choose(P140VCache,String.is_empty(error),u => cache,u => P140VEmpty{}),error,counts}

@unsafe
def p140v_array(+program: P113AProgram, cache: P140VCache) -> P140VArrayChecked:
  match program:
    case P113AProgram{direct,certificate}: p140v_array_done(program,p140v_check(direct,cache))
