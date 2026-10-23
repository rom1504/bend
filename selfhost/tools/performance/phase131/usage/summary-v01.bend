# Per-immutable-body sparse usage facts. IDs are unsigned, sorted and unique.
# low/high are exact existing nq_min_uses/nq_uses results, each in 0..2.
# Only high-positive entries are stored. Missing IDs denote (0,0).
# Modes passed to the shared algebra are 0=sequence, 1=Mat, 2=NWPattern.
type P131UEntry is Data:
  P131UEntry{+id: U32, +low: U32, +high: U32}

@unsafe
def p131u_absent(entries: List<&2,P131UEntry>, +mode: U32) -> List<&2,P131UEntry>:
  match mode entries:
    case 0 values: values
    case other Nil{}: []
    case other Con{P131UEntry{id,low,high},rest}:
      Con{P131UEntry{id,0,high},p131u_absent(rest,mode)}

@unsafe
def p131u_merge(left: List<&2,P131UEntry>, right: List<&2,P131UEntry>, +mode: U32) -> List<&2,P131UEntry>:
  match left right:
    case Nil{} values: p131u_absent(values,mode)
    case values Nil{}: p131u_absent(values,mode)
    case Con{P131UEntry{+li,ll,lh},lr} Con{P131UEntry{+ri,rl,rh},rr}:
      p131u_merge_heads(li,ll,lh,lr,ri,rl,rh,rr,mode,U32.cmp(li,ri))

@unsafe
def p131u_merge_heads(li: U32, +ll: U32, +lh: U32, +lr: List<&2,P131UEntry>, ri: U32, +rl: U32, +rh: U32, +rr: List<&2,P131UEntry>, +mode: U32, order: Cmp) -> List<&2,P131UEntry>:
  match order:
    case LT{}:
      Con{P131UEntry{li,p131a_low(mode,ll,0),p131a_high(mode,lh,0)},p131u_merge(lr,Con{P131UEntry{ri,rl,rh},rr},mode)}
    case GT{}:
      Con{P131UEntry{ri,p131a_low(mode,0,rl),p131a_high(mode,0,rh)},p131u_merge(Con{P131UEntry{li,ll,lh},lr},rr,mode)}
    case EQ{}:
      Con{P131UEntry{li,p131a_low(mode,ll,rl),p131a_high(mode,lh,rh)},p131u_merge(lr,rr,mode)}

@unsafe
def p131u_build(+term: KTerm) -> List<&2,P131UEntry>:
  nt_choose(List<&2,P131UEntry>,p98_tag_eq(term,"Var"),
    u => [P131UEntry{ix(term),1,1}],u =>
    nt_choose(List<&2,P131UEntry>,p98_tag_eq(term,"Mat") && U32.is_eq(terms_len(ks(term)),2),
      v => p131u_merge(p131u_build(kid(term,0)),p131u_build(kid(term,1)),1),v =>
      nt_choose(List<&2,P131UEntry>,p98_tag_eq(term,"NWPattern"),
        w => p131u_rows(ks(term)),w => p131u_list(ks(term)))))

@unsafe
def p131u_list(terms: List<&2,KTerm>) -> List<&2,P131UEntry>:
  match terms:
    case Nil{}: []
    case Con{head,rest}: p131u_merge(p131u_build(head),p131u_list(rest),0)

@unsafe
def p131u_rows(rows: List<&2,KTerm>) -> List<&2,P131UEntry>:
  match rows:
    case Nil{}: []
    case Con{row,rest}: p131u_merge(p131u_build(kid(row,0)),p131u_rows(rest),2)

@unsafe
def p131u_max(entries: List<&2,P131UEntry>, +id: U32) -> U32:
  match entries:
    case Nil{}: 0
    case Con{P131UEntry{+key,low,high},rest}:
      p131u_max_order(rest,id,high,U32.cmp(key,id))

@unsafe
def p131u_max_order(rest: List<&2,P131UEntry>, id: U32, high: U32, order: Cmp) -> U32:
  match order:
    case LT{}: p131u_max(rest,id)
    case EQ{}: high
    case GT{}: 0

@unsafe
def p131u_min(entries: List<&2,P131UEntry>, +id: U32) -> U32:
  match entries:
    case Nil{}: 0
    case Con{P131UEntry{+key,low,high},rest}:
      p131u_min_order(rest,id,low,U32.cmp(key,id))

@unsafe
def p131u_min_order(rest: List<&2,P131UEntry>, id: U32, low: U32, order: Cmp) -> U32:
  match order:
    case LT{}: p131u_min(rest,id)
    case EQ{}: low
    case GT{}: 0
