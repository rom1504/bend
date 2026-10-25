# Experimental monotone closure. No production function or cache is replaced.
# Reverse references are conservative: preserve every original name, duplicates,
# unknown names and hash collisions. Only marked owners enter the work queue.
type P140QPending is Data:
  P140QPending{+dirty: P140ODirty, +queue: List<&2,String>}

@unsafe
def p140oq_record(+name: String, +kind: String, children: List<&2,KDef>) -> KDef:
  KDef{name,kind,0,0,p140o_absent(),p140o_absent(),children,False{},False{}}

@unsafe
def p140oq_user_index(row: KDef) -> KDef:
  match row:
    case KDef{name,kind,arity,templates,typ,value,Con{index,rest},native,unsafe}: index
    case _: missing()

# An owner set deduplicates repeated references. Removal keeps an inactive key;
# only P140Dirty members are traversed. Old relations are not conservatively kept.
@unsafe
def p140oq_set(refs: List<&2,String>, +owner: String, +active: Bool, +index: KDef) -> KDef:
  match refs:
    case Nil{}: index
    case Con{+name,rest}:
      +hash = index_hash(name,2166136261)
      +users = p140oq_user_index(index_find(index,name,hash,32))
      +member = p140oq_record(owner,nt_choose(String,active,u => "P140Dirty",u => "P140QGone"),[])
      p140oq_set(rest,owner,active,index_set(index,
        p140oq_record(name,"P140QUsers",[index_set(users,member,index_hash(owner,2166136261),32)]),hash,32))

@unsafe
def p140oq_refs(refs: List<&2,String>, owner: String, index: KDef) -> KDef:
  p140oq_set(refs,owner,True{},index)

@unsafe
def p140oq_build_go(edges: List<&2,P140OEdge>, index: KDef) -> KDef:
  match edges:
    case Nil{}: index
    case Con{P140OEdge{name,refs},rest}: p140oq_build_go(rest,p140oq_refs(refs,name,index))

@unsafe
def p140oq_build(edges: List<&2,P140OEdge>) -> KDef:
  p140oq_build_go(edges,missing())

# The seed includes dirty names absent from the owner catalogue. Such names can
# still invalidate real owners that reference them; owner-only seeding is wrong.
@unsafe
def p140oq_names(todo: List<&2,KDef>, +acc: List<&2,String>) -> List<&2,String>:
  match todo:
    case Nil{}: acc
    case Con{KIndexLeaf{hash,bucket},rest}: p140oq_names(nt_append(KDef,bucket,rest),acc)
    case Con{KIndexNode{hash,mask,left,right},rest}: p140oq_names(Con{left,Con{right,rest}},acc)
    case Con{KDef{name,kind,arity,templates,typ,value,ctors,native,unsafe},rest}:
      p140oq_names(rest,nt_choose(List<&2,String>,String.eq(kind,"P140Dirty"),u => Con{name,acc},u => acc))

@unsafe
def p140oq_users(users: List<&2,String>, +dirty: P140ODirty, +queue: List<&2,String>) -> P140QPending:
  match users dirty:
    case Nil{} _: P140QPending{dirty,queue}
    case Con{+name,+rest} P140ODirty{names,count}:
      nt_choose(P140QPending,p140o_has(names,name),
        u => p140oq_users(rest,dirty,queue),
        u => p140oq_users(rest,p140o_mark(name,dirty),Con{name,queue}))

@unsafe
def p140oq_walk(+reverse: KDef, queue: List<&2,String>, dirty: P140ODirty) -> P140ODirty:
  match queue:
    case Nil{}: dirty
    case Con{+name,rest}:
      p140oq_pending(reverse,p140oq_users(p140oq_names([p140oq_user_index(index_find(reverse,name,index_hash(name,2166136261),32))],[]),dirty,rest))

@unsafe
def p140oq_pending(reverse: KDef, pending: P140QPending) -> P140ODirty:
  match pending:
    case P140QPending{dirty,queue}: p140oq_walk(reverse,queue,dirty)

# A retained index must belong to this EXACT edge graph and producer. Admission,
# edge removal/update, cache lifetime and acquisition charging are not added here.
@unsafe
def p140oq_with(reverse: KDef, +initial: P140ODirty) -> P140ODirty:
  match initial:
    case P140ODirty{names,count}: p140oq_walk(reverse,p140oq_names([names],[]),initial)

@unsafe
def p140oq_fix(edges: List<&2,P140OEdge>, initial: P140ODirty) -> P140ODirty:
  p140oq_with(p140oq_build(edges),initial)

# The original full admission guard remains exact. Only closure scheduling and
# the duplicated owner comparison are replaced, not dependency semantics.
@unsafe
def p140oq_analyze(+old: List<&2,KDef>, +current: List<&2,KDef>, +edges: List<&2,P140OEdge>, +reverse: KDef) -> P140OAnalysis:
  +a = p140o_plain(old)
  +b = p140o_plain(current)
  nt_choose(P140OAnalysis,Bool.not(List.is_empty(&2,KDef,a)) &&
    U32.is_eq(base_prefix_stamp(old,0),base_prefix_stamp(current,0)) &&
    U32.is_eq(nt_count(KDef,a),nt_count(P140OEdge,edges)) && p140o_headers(a,b),
    u => p140o_guard_adt(b,p140oq_delta(reverse,p140o_delta(a,b,edges,P140ODirty{missing(),0},[]))),
    u => P140OAnalysis{False{},missing(),p140o_edges(b),0})

@unsafe
def p140oq_delta(reverse: KDef, delta: P140ODelta) -> P140OAnalysis:
  match delta:
    case P140ODelta{edges,dirty}: p140o_finish(edges,p140oq_with(reverse,dirty))

@unsafe
def p140oq_refresh(old: List<&2,P140OEdge>, reverse: KDef, analysis: P140OAnalysis) -> KDef:
  match analysis:
    case P140OAnalysis{+ready,dirty,+edges,count}:
      nt_choose(KDef,ready,u => p140oq_update(old,edges,dirty,reverse,edges),u => p140oq_build(edges))

# Admission guarantees equal ordered owner names. Only dirty owners can have a
# changed edge list. Update after closure; closure uses the prior exact graph.
@unsafe
def p140oq_update(old: List<&2,P140OEdge>, current: List<&2,P140OEdge>, +dirty: KDef, +reverse: KDef, +full: List<&2,P140OEdge>) -> KDef:
  match old current:
    case Nil{} Nil{}: reverse
    case Con{P140OEdge{+name,+before},ar} Con{P140OEdge{other,+after},br}:
      p140oq_update(ar,br,dirty,
        nt_choose(KDef,p140o_has(dirty,name),u =>
          nt_choose(KDef,p140o_strings(before,after),v => reverse,
            v => p140oq_set(after,name,True{},p140oq_erase(before,name,full,reverse))),u => reverse),full)
    case _ _: reverse

@unsafe
def p140oq_fact_analysis(+old: List<&2,KDef>, +current: List<&2,KDef>, +names: List<&2,String>, +reverse: KDef, base: P140OAnalysis) -> P140OAnalysis:
  match base:
    case P140OAnalysis{+ready,dirty,+edges,count}:
      nt_choose(P140OAnalysis,ready,
        u => p140o_guard_adt(current,p140o_finish(edges,p140oq_with(reverse,p140or_fact_changes(old,current,names,P140ODirty{dirty,count})))),
        u => P140OAnalysis{False{},dirty,edges,count})

# Duplicate owner rows are legal graph inputs too. Remove a relation only when
# no CURRENT row still supplies it. This scan is paid only for changed ref lists.
@unsafe
def p140oq_referenced(edges: List<&2,P140OEdge>, +owner: String, +reference: String) -> Bool:
  match edges:
    case Nil{}: False{}
    case Con{P140OEdge{name,refs},rest}:
      nt_choose(Bool,String.eq(name,owner) && nb_contains(refs,reference),u => True{},u => p140oq_referenced(rest,owner,reference))

@unsafe
def p140oq_erase(refs: List<&2,String>, +owner: String, +current: List<&2,P140OEdge>, +reverse: KDef) -> KDef:
  match refs:
    case Nil{}: reverse
    case Con{+name,rest}:
      p140oq_erase(rest,owner,current,nt_choose(KDef,p140oq_referenced(current,owner,name),
        u => reverse,u => p140oq_set([name],owner,False{},reverse)))
