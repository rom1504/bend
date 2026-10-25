# Products remain private typed state belonging to their successful request.
# Annotation and erasure admissions use the checked-context dependency analysis.
type P140OAEntry is Data:
  P140OAEntry{+name: String, +stopped: Bool, +product: KDef}

type P140OAResult is Data:
  P140OAResult{+definitions: List<&2,KDef>, +entries: List<&2,P140OAEntry>, +hits: U32, +misses: U32}

@unsafe
def p140oa_done(defs: List<&2,KDef>, entries: List<&2,P140OAEntry>, hits: U32, misses: U32) -> P140OAResult:
  P140OAResult{nt_reverse(KDef,defs,[]),nt_reverse(P140OAEntry,entries,[]),hits,misses}

@unsafe
def p140oa_apply(+book: List<&2,KDef>, selected: List<&2,KDef>, +stops: List<&2,String>, +analysis: P140OAnalysis,
    previous: List<&2,P140OAEntry>) -> P140OAResult:
  p140oa_walk(book_context(book),selected,stops,analysis,previous,[],[],0,0)

@unsafe
def p140oa_walk(+book: List<&2,KDef>, selected: List<&2,KDef>, +stops: List<&2,String>, +analysis: P140OAnalysis,
    previous: List<&2,P140OAEntry>, defs: List<&2,KDef>, entries: List<&2,P140OAEntry>, hits: U32, misses: U32) -> P140OAResult:
  match selected:
    case Nil{}: p140oa_done(defs,entries,hits,misses)
    case Con{+d,rest}:
      p140oa_old(book,d,rest,stops,analysis,previous,defs,entries,hits,misses,has_name(stops,dn(d)))

@unsafe
def p140oa_old(+book: List<&2,KDef>, +d: KDef, +rest: List<&2,KDef>, +stops: List<&2,String>, +analysis: P140OAnalysis,
    previous: List<&2,P140OAEntry>, +defs: List<&2,KDef>, +entries: List<&2,P140OAEntry>, +hits: U32, +misses: U32, +stopped: Bool) -> P140OAResult:
  match previous:
    case Nil{}: p140oa_fresh(book,d,rest,stops,analysis,[],defs,entries,hits,misses,stopped)
    case Con{P140OAEntry{name,was_stopped,product},+tail}:
      nt_choose(P140OAResult,String.eq(dn(d),name) && Bool.not(Bool.xor(stopped,was_stopped)) && p140o_clean(analysis,dn(d)),
        u => p140oa_record(book,rest,stops,analysis,tail,defs,entries,U32.inc(hits),misses,dn(d),stopped,product),
        u => p140oa_fresh(book,d,rest,stops,analysis,tail,defs,entries,hits,misses,stopped))

@unsafe
def p140oa_fresh(+book: List<&2,KDef>, +d: KDef, rest: List<&2,KDef>, stops: List<&2,String>, analysis: P140OAnalysis,
    previous: List<&2,P140OAEntry>, defs: List<&2,KDef>, entries: List<&2,P140OAEntry>, hits: U32, misses: U32, +stopped: Bool) -> P140OAResult:
  p140oa_record(book,rest,stops,analysis,previous,defs,entries,hits,U32.inc(misses),dn(d),stopped,
    nt_choose(KDef,stopped,u => d,u => ka_def(book,d)))

@unsafe
def p140oa_record(+book: List<&2,KDef>, rest: List<&2,KDef>, stops: List<&2,String>, analysis: P140OAnalysis,
    previous: List<&2,P140OAEntry>, defs: List<&2,KDef>, entries: List<&2,P140OAEntry>, hits: U32, misses: U32,
    name: String, stopped: Bool, +product: KDef) -> P140OAResult:
  p140oa_walk(book,rest,stops,analysis,previous,Con{product,defs},Con{P140OAEntry{name,stopped,product},entries},hits,misses)

type P140OEEntry is Data:
  P140OEEntry{+name: String, +body: KTerm, +arity: U32, +refs: List<&2,String>}

type P140OEResult is Data:
  P140OEResult{+closure: NR_Closure, +entries: List<&2,P140OEEntry>, +hits: U32, +misses: U32}

@unsafe
def p140oe_apply(+book: List<&2,KDef>, +analysis: P140OAnalysis, previous: List<&2,P140OEEntry>) -> P140OEResult:
  p140oe_walk(book,["main"],[],[],analysis,missing(),previous,[],0,0)

@unsafe
def p140oe_walk(+book: List<&2,KDef>, todo: List<&2,String>, +done: List<&2,String>, +facts: List<&2,KDef>,
    +analysis: P140OAnalysis, +seen: KDef, +previous: List<&2,P140OEEntry>, +entries: List<&2,P140OEEntry>, +hits: U32, +misses: U32) -> P140OEResult:
  match todo:
    case Nil{}: P140OEResult{NR_Closure{done,facts},nt_reverse(P140OEEntry,entries,[]),hits,misses}
    case Con{+name,+rest}:
      nt_choose(P140OEResult,p140o_has(seen,name),
        u => p140oe_walk(book,rest,done,facts,analysis,seen,previous,entries,hits,misses),
        u => p140oe_old(book,name,rest,done,facts,analysis,seen,previous,entries,hits,misses,lookup(book,name)))

@unsafe
def p140oe_old(+book: List<&2,KDef>, +name: String, +todo: List<&2,String>, +done: List<&2,String>, +facts: List<&2,KDef>,
    +analysis: P140OAnalysis, +seen: KDef, previous: List<&2,P140OEEntry>, +entries: List<&2,P140OEEntry>, +hits: U32, +misses: U32, +d: KDef) -> P140OEResult:
  match previous:
    case Nil{}: p140oe_fresh(book,name,todo,done,facts,analysis,seen,[],entries,hits,misses,d)
    case Con{P140OEEntry{old_name,body,arity,refs},+tail}:
      nt_choose(P140OEResult,String.eq(name,old_name) && p140o_clean(analysis,name),
        u => p140oe_record(book,name,todo,done,facts,analysis,seen,tail,entries,U32.inc(hits),misses,d,body,arity,refs),
        u => p140oe_fresh(book,name,todo,done,facts,analysis,seen,tail,entries,hits,misses,d))

@unsafe
def p140oe_regular(+d: KDef) -> Bool:
  String.eq(dk(d),"Def") && Bool.not(nc_native_def(d) || nc_foreign(d))

@unsafe
def p140oe_fresh(+book: List<&2,KDef>, +name: String, todo: List<&2,String>, done: List<&2,String>, facts: List<&2,KDef>,
    analysis: P140OAnalysis, seen: KDef, previous: List<&2,P140OEEntry>, entries: List<&2,P140OEEntry>, hits: U32, misses: U32, +d: KDef) -> P140OEResult:
  +body = nc_definition_plain(book,d,0)
  p140oe_record(book,name,todo,done,facts,analysis,seen,previous,entries,hits,U32.inc(misses),d,
    body,nt_choose(U32,p140oe_regular(d),u => nd_arity_plain(book,name),u => 0),nc_refs(body))

@unsafe
def p140oe_record(+book: List<&2,KDef>, +name: String, todo: List<&2,String>, done: List<&2,String>, +facts: List<&2,KDef>,
    analysis: P140OAnalysis, seen: KDef, previous: List<&2,P140OEEntry>, entries: List<&2,P140OEEntry>, hits: U32, misses: U32,
    +d: KDef, +body: KTerm, +arity: U32, +refs: List<&2,String>) -> P140OEResult:
  +more = nt_choose(List<&2,KDef>,p140oe_regular(d),
    u => Con{KDef{name,"NativeErasedBody",arity,1,p140o_absent(),body,[],False{},False{}},facts},u => facts)
  p140oe_walk(book,nt_append(String,refs,todo),Con{name,done},more,analysis,p140oe_mark(seen,name),previous,
    Con{P140OEEntry{name,body,arity,refs},entries},hits,misses)

# Preserve the original ordered done/fact/queue lists; only membership changes.
@unsafe
def p140oe_mark(seen: KDef, +name: String) -> KDef:
  index_set(seen,KDef{name,"P140Dirty",0,0,p140o_absent(),p140o_absent(),[],False{},False{}},index_hash(name,2166136261),32)
