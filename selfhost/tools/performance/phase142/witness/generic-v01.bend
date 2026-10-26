# Same generic owner loop as p140og_*, with a run per owner. Retained=True
# is minted only at the original successful p140og_old admission branch.
@unsafe
def p142og_apply(+book: List<&2,KDef>, names: List<&2,String>, +bangs: List<&2,String>, +analysis: P140OAnalysis,
    +allowed: Bool, previous: List<&2,P140OGEntry>) -> P142OGResult:
  p142og_walk(book,names,bangs,analysis,allowed,previous,0,[],[],[],0,0)

@unsafe
def p142og_walk(+book: List<&2,KDef>, names: List<&2,String>, +bangs: List<&2,String>, +analysis: P140OAnalysis,
    +allowed: Bool, +previous: List<&2,P140OGEntry>, +n: U32, +segments: List<&2,N111Segment>,
    +entries: List<&2,P140OGEntry>, +runs: List<&2,P142WRun>, +hits: U32, +misses: U32) -> P142OGResult:
  match names:
    case Nil{}:
      P142OGResult{P111Book{nt_reverse(N111Segment,segments,[]),n,""},
        nt_reverse(P140OGEntry,entries,[]),nt_reverse(P142WRun,runs,[]),hits,misses}
    case Con{+name,+rest}:
      +d = lookup(book,name)
      nt_choose(P142OGResult,String.eq(dk(d),"Absent"),
        u => P142OGResult{P111Book{[],n,"native definition not found: " ++ name_key(name)},[],[],hits,misses},
        u => p142og_old(book,name,rest,bangs,analysis,allowed,previous,n,segments,entries,runs,hits,misses,d))

@unsafe
def p142og_old(+book: List<&2,KDef>, +name: String, +rest: List<&2,String>, +bangs: List<&2,String>, +analysis: P140OAnalysis,
    +allowed: Bool, previous: List<&2,P140OGEntry>, +n: U32, +segments: List<&2,N111Segment>,
    +entries: List<&2,P140OGEntry>, +runs: List<&2,P142WRun>, +hits: U32, +misses: U32, +d: KDef) -> P142OGResult:
  match previous:
    case Nil{}: p142og_fresh(book,name,rest,bangs,analysis,allowed,[],n,segments,entries,runs,hits,misses,d)
    case Con{P140OGEntry{old_name,input,code},+tail}:
      nt_choose(P142OGResult,allowed && String.eq(name,old_name) && U32.is_eq(n,input) && p140o_clean(analysis,name),
        u => p142og_record(book,name,rest,bangs,analysis,allowed,tail,n,segments,entries,runs,U32.inc(hits),misses,True{},code),
        u => p142og_fresh(book,name,rest,bangs,analysis,allowed,tail,n,segments,entries,runs,hits,misses,d))

@unsafe
def p142og_fresh(+book: List<&2,KDef>, +name: String, rest: List<&2,String>, +bangs: List<&2,String>, analysis: P140OAnalysis,
    allowed: Bool, previous: List<&2,P140OGEntry>, +n: U32, segments: List<&2,N111Segment>, entries: List<&2,P140OGEntry>,
    runs: List<&2,P142WRun>, hits: U32, misses: U32, d: KDef) -> P142OGResult:
  p142og_record(book,name,rest,bangs,analysis,allowed,previous,n,segments,entries,runs,hits,U32.inc(misses),False{},
    p111_entry(book,nc_compact_definition(book,d,n),name,U32.add(n,1024),nb_contains(bangs,name)))

# Count during the existing reversal; no extra body/segment discovery traversal.
@unsafe
def p142og_reverse(items: List<&2,N111Segment>, acc: List<&2,N111Segment>, +count: U32) -> P142WReverse:
  match items:
    case Nil{}: P142WReverse{acc,count}
    case Con{head,rest}: p142og_reverse(rest,Con{head,acc},nt_choose(U32,U32.is_eq(count,4294967295),u => count,u => U32.inc(count)))

@unsafe
def p142og_record(+book: List<&2,KDef>, +name: String, +rest: List<&2,String>, +bangs: List<&2,String>, +analysis: P140OAnalysis,
    +allowed: Bool, +previous: List<&2,P140OGEntry>, +input: U32, +acc: List<&2,N111Segment>, +entries: List<&2,P140OGEntry>,
    +runs: List<&2,P142WRun>, +hits: U32, +misses: U32, +retained: Bool, +code: P111Code) -> P142OGResult:
  match code:
    case P111Code{+body,+segments,+fresh,+error}:
      nt_choose(P142OGResult,String.eq(error,""),
        u => p142og_recorded(book,name,rest,bangs,analysis,allowed,previous,input,entries,runs,hits,misses,retained,code,fresh,
          p142og_reverse(p111_mark_segments(Con{p111_segment(nc_ref_name(book,name),[],0,0,body),segments},nb_contains(bangs,name)),acc,0)),
        u => P142OGResult{P111Book{[],fresh,error},[],[],hits,misses})

@unsafe
def p142og_recorded(book: List<&2,KDef>, +name: String, rest: List<&2,String>, bangs: List<&2,String>, analysis: P140OAnalysis,
    allowed: Bool, previous: List<&2,P140OGEntry>, input: U32, entries: List<&2,P140OGEntry>, runs: List<&2,P142WRun>,
    hits: U32, misses: U32, retained: Bool, code: P111Code, fresh: U32, reversed: P142WReverse) -> P142OGResult:
  match reversed:
    case P142WReverse{segments,count}:
      p142og_walk(book,rest,bangs,analysis,allowed,previous,fresh,segments,
        Con{P140OGEntry{name,input,code},entries},Con{P142WRun{count,retained},runs},hits,misses)
