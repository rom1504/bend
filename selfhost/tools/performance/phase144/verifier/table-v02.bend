# Private complete-verifier representation experiment. This does not replace
# any original verifier declaration. Only these constructors build this tree;
# canonical nonzero Patricia masks follow the original p131i insertion rule.
type P144VEntry is Data:
  P144VEntry{+name: String, +kind: String, +width: U32, +capacity: U32}

type P144VTree is Data:
  P144VTEmpty{}
  P144VTLeaf{+hash: U32, +bucket: List<&2,P144VEntry>}
  P144VTNode{+hash: U32, +mask: U32, +left: P144VTree, +right: P144VTree}

type P144VIds is Data:
  P144VIds{+functions: P144VTree, +constructors: P144VTree}

def p144vt_absent() -> P144VEntry:
  P144VEntry{"","Absent",0,0}

def p144vt_name(entry: P144VEntry) -> String:
  match entry:
    case P144VEntry{name,kind,width,capacity}: name

def p144vt_kind(entry: P144VEntry) -> String:
  match entry:
    case P144VEntry{name,kind,width,capacity}: kind

def p144vt_width(entry: P144VEntry) -> U32:
  match entry:
    case P144VEntry{name,kind,width,capacity}: width

def p144vt_capacity(entry: P144VEntry) -> U32:
  match entry:
    case P144VEntry{name,kind,width,capacity}: capacity

@unsafe
def p144vt_bucket(+entries: List<&2,P144VEntry>, +name: String) -> P144VEntry:
  match entries:
    case Nil{}: p144vt_absent()
    case Con{+head,rest}:
      nt_choose(P144VEntry,p88_string_eq(p144vt_name(head),name),u => head,u => p144vt_bucket(rest,name))

@unsafe
def p144vt_find(+tree: P144VTree, +name: String, +hash: U32) -> P144VEntry:
  match tree:
    case P144VTEmpty{}: p144vt_absent()
    case P144VTLeaf{stored,bucket}:
      nt_choose(P144VEntry,U32.is_eq(stored,hash),u => p144vt_bucket(bucket,name),u => p144vt_absent())
    case P144VTNode{stored,mask,left,right}:
      nt_choose(P144VEntry,U32.is_eq(U32.and(hash,mask),0),
        u => p144vt_find(left,name,hash),u => p144vt_find(right,name,hash))

@unsafe
def p144vt_remove(entries: List<&2,P144VEntry>, +name: String) -> List<&2,P144VEntry>:
  match entries:
    case Nil{}: Nil{}
    case Con{+head,+rest}:
      nt_choose(List<&2,P144VEntry>,p88_string_eq(p144vt_name(head),name),
        u => p144vt_remove(rest,name),u => Con{head,p144vt_remove(rest,name)})

@unsafe
def p144vt_leaf(+entry: P144VEntry, hash: U32, bucket: List<&2,P144VEntry>) -> P144VTree:
  P144VTLeaf{hash,Con{entry,p144vt_remove(bucket,p144vt_name(entry))}}

@unsafe
def p144vt_join(+tree: P144VTree, +entry: P144VEntry, +hash: U32, +stored: U32, +mask: U32) -> P144VTree:
  nt_choose(P144VTree,U32.is_eq(U32.and(hash,mask),0),
    u => P144VTNode{stored,mask,p144vt_leaf(entry,hash,[]),tree},
    u => P144VTNode{stored,mask,tree,p144vt_leaf(entry,hash,[])})

@unsafe
def p144vt_insert(+tree: P144VTree, +entry: P144VEntry, +hash: U32) -> P144VTree:
  match tree:
    case P144VTEmpty{}: p144vt_leaf(entry,hash,[])
    case P144VTLeaf{+stored,bucket}:
      +mask = index_split_bit(U32.xor(hash,stored))
      nt_choose(P144VTree,U32.is_eq(mask,0),
        u => p144vt_leaf(entry,hash,bucket),u => p144vt_join(tree,entry,hash,stored,mask))
    case P144VTNode{+stored,+split,+left,+right}:
      +mask = index_split_bit(U32.xor(hash,stored))
      nt_choose(P144VTree,Bool.not(U32.is_eq(mask,0)) && U32.is_lt(mask,split),
        u => p144vt_join(tree,entry,hash,stored,mask),u =>
        nt_choose(P144VTree,U32.is_eq(U32.and(hash,split),0),
          v => P144VTNode{stored,split,p144vt_insert(left,entry,hash),right},
          v => P144VTNode{stored,split,left,p144vt_insert(right,entry,hash)}))
