# Private completed-user-prefix capability. The session owns the seed/producer.
# Completed definitions, not source text or raw parser events, guard reuse.
type P142FFCache is Data:
  P142FFEmpty{}
  P142FFCache{+start: U32, +cut: U32, +original: List<&2,KDef>, +fresh: List<&2,KDef>, +next: U32}

type P142FFResult is Data:
  P142FFResult{+value: FFreshDefs, +cache: P142FFCache, +hit: Bool}

@unsafe
def p142ff_apply(+book: List<&2,KDef>, +start: U32, +cut: U32, cache: P142FFCache) -> P142FFResult:
  p142ff_split(book,start,cut,cache,p140cp_split(book,cut,[]))

@unsafe
def p142ff_split(+book: List<&2,KDef>, +start: U32, +cut: U32, cache: P142FFCache, split: P140CPSplit) -> P142FFResult:
  match split:
    case P140CPSplit{prefix,suffix,complete}:
      nt_choose(P142FFResult,complete,
        u => p142ff_admit(prefix,suffix,start,cut,cache),
        u => P142FFResult{f_fresh_defs(book,start),P142FFEmpty{},False{}})

@unsafe
def p142ff_admit(+prefix: List<&2,KDef>, +suffix: List<&2,KDef>, +start: U32, +cut: U32, cache: P142FFCache) -> P142FFResult:
  match cache:
    case P142FFEmpty{}: p142ff_cold(prefix,suffix,start,cut)
    case P142FFCache{old_start,old_cut,original,fresh,+next}:
      nt_choose(P142FFResult,U32.is_eq(start,old_start) && U32.is_eq(cut,old_cut) && p140p_defs(prefix,original),
        u => p142ff_finish(prefix,fresh,start,cut,next,True{},f_fresh_defs(suffix,next)),
        u => p142ff_cold(prefix,suffix,start,cut))

@unsafe
def p142ff_cold(+prefix: List<&2,KDef>, suffix: List<&2,KDef>, start: U32, cut: U32) -> P142FFResult:
  p142ff_captured(prefix,suffix,start,cut,f_fresh_defs(prefix,start))

@unsafe
def p142ff_captured(prefix: List<&2,KDef>, suffix: List<&2,KDef>, start: U32, cut: U32, fresh: FFreshDefs) -> P142FFResult:
  match fresh:
    case FFreshDefs{head,+next}: p142ff_finish(prefix,head,start,cut,next,False{},f_fresh_defs(suffix,next))

@unsafe
def p142ff_finish(original: List<&2,KDef>, +prefix: List<&2,KDef>, start: U32, cut: U32, middle: U32, hit: Bool, suffix: FFreshDefs) -> P142FFResult:
  match suffix:
    case FFreshDefs{tail,next}:
      P142FFResult{FFreshDefs{norm_defs_join(prefix,tail),next},P142FFCache{start,cut,original,prefix,middle},hit}
