# Experimental monotone closure. No production function or cache is replaced.
# Reverse references are conservative: preserve every original name, duplicates,
# unknown names and hash collisions. Only marked owners enter the work queue.
type P140QPending is Data:
  P140QPending{+dirty: P140ODirty, +queue: List<&2,String>}

@unsafe
def p140oq_record(+name: String, +kind: String, children: List<&2,KDef>) -> KDef:
  KDef{name,kind,0,0,p140o_absent(),p140o_absent(),children,False{},False{}}

@unsafe
def p140oq_refs(refs: List<&2,String>, +owner: String, +index: KDef) -> KDef:
  match refs:
    case Nil{}: index
    case Con{+name,rest}:
      +hash = index_hash(name,2166136261)
      +old = index_find(index,name,hash,32)
      p140oq_refs(rest,owner,index_set(index,
        p140oq_record(name,"P140QUsers",Con{p140oq_record(owner,"P140QUser",[]),dc(old)}),hash,32))

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
def p140oq_users(users: List<&2,KDef>, +dirty: P140ODirty, +queue: List<&2,String>) -> P140QPending:
  match users dirty:
    case Nil{} _: P140QPending{dirty,queue}
    case Con{+user,rest} P140ODirty{names,count}:
      nt_choose(P140QPending,p140o_has(names,dn(user)),
        u => p140oq_users(rest,dirty,queue),
        u => p140oq_users(rest,p140o_mark(dn(user),dirty),Con{dn(user),queue}))

@unsafe
def p140oq_walk(+reverse: KDef, queue: List<&2,String>, dirty: P140ODirty) -> P140ODirty:
  match queue:
    case Nil{}: dirty
    case Con{+name,rest}:
      p140oq_pending(reverse,p140oq_users(dc(index_find(reverse,name,index_hash(name,2166136261),32)),dirty,rest))

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
