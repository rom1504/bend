# Experimental internal, single-producer owner dependency state. No old entry is
# accepted from disk or a caller-controlled artifact. A source/session adapter
# must retain this state only after its complete request succeeds.
type P140OEdge is Data:
  P140OEdge{+name: String, +refs: List<&2,String>}

type P140ODirty is Data:
  P140ODirty{+names: KDef, +count: U32}

type P140OAnalysis is Data:
  P140OAnalysis{+ready: Bool, +dirty: KDef, +edges: List<&2,P140OEdge>, +count: U32}

def p140o_absent() -> KTerm:
  KTerm{"Absent","",0,0,[],[],0,0}

@unsafe
def p140o_plain(book: List<&2,KDef>) -> List<&2,KDef>:
  match book:
    case Nil{}: []
    case Con{+d,+rest}:
      nt_choose(List<&2,KDef>,String.eq(dk(d),"BookCache"),u => rest,u => Con{d,rest})

@unsafe
def p140o_header(+d: KDef) -> KDef:
  nt_choose(KDef,p98_tag_eq(dv(d),"Foreign"),u => d,u => declared(d))

# Ordered names, complete types/children, flags and Foreign bodies must match.
# This is deliberately stronger than a public-signature map.
@unsafe
def p140o_headers(left: List<&2,KDef>, right: List<&2,KDef>) -> Bool:
  match left right:
    case Nil{} Nil{}: True{}
    case Con{a,ar} Con{b,br}:
      nt_choose(Bool,f_fresh_prefix_exact_defs([p140o_header(a)],[p140o_header(b)]),
        u => p140o_headers(ar,br),u => False{})
    case _ _: False{}

@unsafe
def p140o_strings(left: List<&2,String>, right: List<&2,String>) -> Bool:
  match left right:
    case Nil{} Nil{}: True{}
    case Con{a,ar} Con{b,br}:
      nt_choose(Bool,String.eq(a,b),u => p140o_strings(ar,br),u => False{})
    case _ _: False{}

@unsafe
def p140o_has(+names: KDef, +name: String) -> Bool:
  String.eq(dk(index_find(names,name,index_hash(name,2166136261),32)),"P140Dirty")

@unsafe
def p140o_mark(+name: String, +dirty: P140ODirty) -> P140ODirty:
  match dirty:
    case P140ODirty{+names,+count}:
      nt_choose(P140ODirty,p140o_has(names,name),u => dirty,
        u => P140ODirty{index_set(names,KDef{name,"P140Dirty",0,0,p140o_absent(),p140o_absent(),[],False{},False{}},index_hash(name,2166136261),32),U32.inc(count)})

# Inspect every term name, not just syntactic Ref nodes. This intentionally
# over-approximates named normalization, ADT and implicit-literal dependencies.
@unsafe
def p140o_terms(todo: List<&2,KTerm>, +acc: List<&2,String>) -> List<&2,String>:
  match todo:
    case Nil{}: acc
    case Con{+term,rest}:
      p140o_terms(nt_append(KTerm,ks(term),rest),
        nt_choose(List<&2,String>,String.is_empty(nm(term)),u => acc,u => Con{nm(term),acc}))

@unsafe
def p140o_refs(defs: List<&2,KDef>, acc: List<&2,String>) -> List<&2,String>:
  match defs:
    case Nil{}: acc
    case Con{+d,rest}:
      p140o_refs(nt_append(KDef,dc(d),rest),p140o_terms([dt(d),dv(d)],acc))

@unsafe
def p140o_edge(+d: KDef) -> P140OEdge:
  P140OEdge{dn(d),p140o_refs([d],["Nat","U32","F32","String","Char","Bool","Word","List"])}

@unsafe
def p140o_edges(defs: List<&2,KDef>) -> List<&2,P140OEdge>:
  match defs:
    case Nil{}: []
    case Con{d,rest}: Con{p140o_edge(d),p140o_edges(rest)}

@unsafe
def p140o_changed(left: List<&2,KDef>, right: List<&2,KDef>, +dirty: P140ODirty) -> P140ODirty:
  match left right:
    case Nil{} Nil{}: dirty
    case Con{+a,ar} Con{+b,br}:
      p140o_changed(ar,br,nt_choose(P140ODirty,f_fresh_prefix_exact_defs([a],[b]),
        u => dirty,u => p140o_mark(dn(a),dirty)))
    case _ _: dirty

@unsafe
def p140o_any(refs: List<&2,String>, +dirty: KDef) -> Bool:
  match refs:
    case Nil{}: False{}
    case Con{name,rest}:
      nt_choose(Bool,p140o_has(dirty,name),u => True{},u => p140o_any(rest,dirty))

@unsafe
def p140o_spread(edges: List<&2,P140OEdge>, +dirty: P140ODirty) -> P140ODirty:
  match edges dirty:
    case Nil{} _: dirty
    case Con{P140OEdge{+name,refs},rest} P140ODirty{+names,count}:
      p140o_spread(rest,nt_choose(P140ODirty,p140o_has(names,name),u => dirty,
        u => nt_choose(P140ODirty,p140o_any(refs,names),v => p140o_mark(name,dirty),v => dirty)))

@unsafe
def p140o_fix(+edges: List<&2,P140OEdge>, +dirty: P140ODirty, fuel: U32) -> P140ODirty:
  nt_choose(P140ODirty,U32.is_eq(fuel,0),u => dirty,
    u => p140o_fix_step(edges,dirty,p140o_spread(edges,dirty),U32.sub(fuel,1)))

@unsafe
def p140o_fix_step(+edges: List<&2,P140OEdge>, before: P140ODirty, +after: P140ODirty, +fuel: U32) -> P140ODirty:
  match before after:
    case P140ODirty{old,old_count} P140ODirty{names,new_count}:
      nt_choose(P140ODirty,U32.is_eq(old_count,new_count),u => after,u => p140o_fix(edges,after,fuel))

@unsafe
def p140o_refresh(left: List<&2,KDef>, +right: List<&2,KDef>, edges: List<&2,P140OEdge>) -> List<&2,P140OEdge>:
  match left right edges:
    case Nil{} Nil{} Nil{}: []
    case Con{+a,ar} Con{+b,br} Con{+edge,er}:
      Con{nt_choose(P140OEdge,f_fresh_prefix_exact_defs([a],[b]),u => edge,u => p140o_edge(b)),p140o_refresh(ar,br,er)}
    case _ _ _: p140o_edges(right)

@unsafe
def p140o_finish(+edges: List<&2,P140OEdge>, dirty: P140ODirty) -> P140OAnalysis:
  match dirty:
    case P140ODirty{names,count}: P140OAnalysis{True{},names,edges,count}

# The graph is from the old complete successful request. Unchanged owners have
# unchanged outgoing references; propagating through that graph is conservative
# even when changed owners acquire different references in the current request.
@unsafe
def p140o_admitted(+old: List<&2,KDef>, +current: List<&2,KDef>, +edges: List<&2,P140OEdge>) -> P140OAnalysis:
  p140o_finish(p140o_refresh(old,current,edges),
    p140o_fix(edges,p140o_changed(old,current,P140ODirty{missing(),0}),U32.inc(nt_count(KDef,current))))

@unsafe
def p140o_analyze(+old: List<&2,KDef>, +current: List<&2,KDef>, +edges: List<&2,P140OEdge>) -> P140OAnalysis:
  +a = p140o_plain(old)
  +b = p140o_plain(current)
  nt_choose(P140OAnalysis,Bool.not(List.is_empty(&2,KDef,a)) &&
    U32.is_eq(base_prefix_stamp(old,0),base_prefix_stamp(current,0)) &&
    U32.is_eq(nt_count(KDef,a),nt_count(P140OEdge,edges)) && p140o_headers(a,b),
    u => p140o_admitted(a,b,edges),u => P140OAnalysis{False{},missing(),p140o_edges(b),0})

@unsafe
def p140o_clean(+analysis: P140OAnalysis, +name: String) -> Bool:
  match analysis:
    case P140OAnalysis{ready,dirty,edges,count}: ready && Bool.not(p140o_has(dirty,name))
