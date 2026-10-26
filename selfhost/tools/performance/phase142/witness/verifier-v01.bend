# Only the first raw-body admission consumes owner runs. All context/static,
# direct-function, array and final checks remain original. Internal entry only.
@unsafe
def p142v_open(+program: P113DProgram, cache: P140VCache, runs: List<&2,P142WRun>, diagnostic: Bool) -> P142VOpened:
  p142v_reuse(program,runs,diagnostic,p140v_reuse(program,cache))

@unsafe
def p142v_reuse(+program: P113DProgram, runs: List<&2,P142WRun>, diagnostic: Bool, reuse: P140VReuse) -> P142VOpened:
  match reuse:
    case P140VReuse{segments,old,raw,direct,metadata}:
      p142v_prepared(program,segments,old,raw,direct,runs,diagnostic,p140v_metadata(p142v_original(program),metadata))

# This projection is not a verifier and conveys no admission authority.
def p142v_original(program: P113DProgram) -> P112StaticProgram:
  match program:
    case P113DProgram{original,functions}: original

@unsafe
def p142v_prepared(+program: P113DProgram, old: List<&2,N111Segment>, direct_old: List<&2,P113DFunction>,
    raw: Bool, direct: Bool, runs: List<&2,P142WRun>, diagnostic: Bool, +metadata: P140VMetadata) -> P142VOpened:
  match program metadata:
    case P113DProgram{P112StaticProgram{P111Program{now,ctors,show,names,effects,pure},nodes},functions} P140VMetadata{fs,cs,ids}:
      p142v_done(program,direct_old,direct,metadata,raw,p142v_scans(now,old,raw,fs,cs,runs,diagnostic))

@unsafe
def p142v_done(+program: P113DProgram, old: List<&2,P113DFunction>, direct: Bool, metadata: P140VMetadata,
    raw: Bool, checked: P142VWalk) -> P142VOpened:
  match checked:
    case P142VWalk{walk,counts}:
      P142VOpened{p140v_open_done(program,p140v_raw_done(program,old,direct,metadata,raw,walk)),counts}

# Preserve function-scan, constructor-scan, main-shape and first-body error order.
@unsafe
def p142v_scans(segments: List<&2,N111Segment>, old: List<&2,N111Segment>, reuse: Bool,
    functions: P111VScan, constructors: P111VScan, runs: List<&2,P142WRun>, diagnostic: Bool) -> P142VWalk:
  match functions constructors:
    case P111VScan{+fs,+fe,fc} P111VScan{+cs,+ce,cc}:
      +main = p111v_get(fs,"main")
      nt_choose(P142VWalk,Bool.not(String.is_empty(fe)),u => P142VWalk{P140VWalk{fe,0,0},p142w_zero()},u =>
      nt_choose(P142VWalk,Bool.not(String.is_empty(ce)),u => P142VWalk{P140VWalk{ce,0,0},p142w_zero()},u =>
      nt_choose(P142VWalk,String.eq(dk(main),"Absent") || Bool.not(U32.is_eq(da(main),0)) || Bool.not(U32.is_eq(dx(main),0)),
        u => P142VWalk{P140VWalk{"program requires a direct, zero-argument main segment",0,0},p142w_zero()},
        u => p142v_walk(old,segments,N111Ids{fs,cs},reuse,runs,0,False{},diagnostic,0,0,0,0))))

@unsafe
def p142v_walk(+old: List<&2,N111Segment>, +current: List<&2,N111Segment>, +ids: N111Ids, +reuse: Bool,
    +runs: List<&2,P142WRun>, +left: U32, +retained: Bool, +diagnostic: Bool,
    +hits: U32, +misses: U32, +witnessed: U32, +compared: U32) -> P142VWalk:
  nt_choose(P142VWalk,U32.is_gt(left,0),
    u => p142v_current(old,current,ids,reuse,runs,left,retained,diagnostic,hits,misses,witnessed,compared),
    u => p142v_next(old,current,ids,reuse,runs,diagnostic,hits,misses,witnessed,compared))

@unsafe
def p142v_next(+old: List<&2,N111Segment>, +current: List<&2,N111Segment>, +ids: N111Ids, +reuse: Bool,
    runs: List<&2,P142WRun>, +diagnostic: Bool, +hits: U32, +misses: U32, +witnessed: U32, +compared: U32) -> P142VWalk:
  match runs:
    case Nil{}: p142v_current(old,current,ids,reuse,[],0,False{},diagnostic,hits,misses,witnessed,compared)
    case Con{P142WRun{+count,retained},rest}:
      nt_choose(P142VWalk,U32.is_eq(count,0) || U32.is_eq(count,4294967295),
        u => p142v_current(old,current,ids,reuse,[],0,False{},diagnostic,hits,misses,witnessed,compared),
        u => p142v_walk(old,current,ids,reuse,rest,count,retained,diagnostic,hits,misses,witnessed,compared))

@unsafe
def p142v_current(old: List<&2,N111Segment>, current: List<&2,N111Segment>, +ids: N111Ids, +reuse: Bool,
    +runs: List<&2,P142WRun>, +left: U32, +retained: Bool, +diagnostic: Bool,
    +hits: U32, +misses: U32, +witnessed: U32, +compared: U32) -> P142VWalk:
  match old current:
    case _ Nil{}: P142VWalk{P140VWalk{"",hits,misses},P142WCounts{witnessed,compared,0}}
    case Nil{} Con{+head,rest}:
      p142v_step([],head,rest,ids,reuse,runs,left,retained,diagnostic,hits,misses,witnessed,compared,False{})
    case Con{+prior,tail} Con{+head,rest}:
      p142v_decide(tail,head,rest,ids,reuse,runs,left,retained,diagnostic,hits,misses,witnessed,compared,
        reuse && retained && U32.is_gt(left,0),prior)

@unsafe
def p142v_decide(+old: List<&2,N111Segment>, +head: N111Segment, +current: List<&2,N111Segment>, +ids: N111Ids,
    +reuse: Bool, +runs: List<&2,P142WRun>, +left: U32, +retained: Bool, +diagnostic: Bool,
    +hits: U32, +misses: U32, +witnessed: U32, +compared: U32, +claim: Bool, +prior: N111Segment) -> P142VWalk:
  nt_choose(P142VWalk,claim && Bool.not(diagnostic),
    u => p142v_step(old,head,current,ids,reuse,runs,left,retained,diagnostic,hits,misses,U32.inc(witnessed),compared,True{}),
    u => p142v_compared(old,head,current,ids,reuse,runs,left,retained,diagnostic,hits,misses,witnessed,
      U32.add(compared,Bool.to_u32(reuse)),claim,nt_choose(Bool,reuse,v => p140v_segment(prior,head),v => False{})))

@unsafe
def p142v_compared(+old: List<&2,N111Segment>, +head: N111Segment, +current: List<&2,N111Segment>, +ids: N111Ids,
    +reuse: Bool, +runs: List<&2,P142WRun>, +left: U32, +retained: Bool, +diagnostic: Bool,
    +hits: U32, +misses: U32, +witnessed: U32, +compared: U32, +claim: Bool, +same: Bool) -> P142VWalk:
  nt_choose(P142VWalk,claim && Bool.not(same),
    u => P142VWalk{P140VWalk{"phase142 diagnostic: retained raw-body witness disagrees with exact comparison",hits,misses},P142WCounts{witnessed,compared,1}},
    u => p142v_step(old,head,current,ids,reuse,runs,left,retained,diagnostic,hits,misses,U32.add(witnessed,Bool.to_u32(claim)),compared,same))

@unsafe
def p142v_step(+old: List<&2,N111Segment>, +head: N111Segment, +current: List<&2,N111Segment>, +ids: N111Ids,
    +reuse: Bool, +runs: List<&2,P142WRun>, +left: U32, +retained: Bool, +diagnostic: Bool,
    +hits: U32, +misses: U32, +witnessed: U32, +compared: U32, +hit: Bool) -> P142VWalk:
  p142v_result(old,head,current,ids,reuse,runs,left,retained,diagnostic,hits,misses,witnessed,compared,hit,
    nt_choose(String,hit,u => "",u => p111v_segment(head,ids)))

@unsafe
def p142v_result(+old: List<&2,N111Segment>, +head: N111Segment, +current: List<&2,N111Segment>, +ids: N111Ids,
    +reuse: Bool, +runs: List<&2,P142WRun>, +left: U32, +retained: Bool, +diagnostic: Bool,
    +hits: U32, +misses: U32, +witnessed: U32, +compared: U32, +hit: Bool, +error: String) -> P142VWalk:
  nt_choose(P142VWalk,String.is_empty(error),
    u => p142v_walk(old,current,ids,reuse,runs,nt_choose(U32,U32.is_gt(left,0),v => U32.sub(left,1),v => 0),retained,diagnostic,
      U32.add(hits,Bool.to_u32(hit)),U32.add(misses,Bool.to_u32(Bool.not(hit))),witnessed,compared),
    u => P142VWalk{P140VWalk{p111v_segment_error(head,error),hits,U32.inc(misses)},P142WCounts{witnessed,compared,0}})
