# Alternative to index-zipper.bend: never load both modules. The logical path
# frame and its next pointer share one cell. Every insertion branch is unchanged.
# Four-field path cells have the rebuilt node's width; reuse is not assumed.
type P164XPath is Data:
  P164XDone{}
  P164XLeft{+stored: U32, +split: U32, +right: KDef, +next: P164XPath}
  P164XRight{+stored: U32, +split: U32, +left: KDef, +next: P164XPath}

type P164XStop is Data:
  P164XLegacy{+tree: KDef, +path: P164XPath}
  P164XLeaf{+tree: KDef, +path: P164XPath}
  P164XJoin{+tree: KDef, +path: P164XPath, +mask: U32}

@unsafe
def p164x_leaf_stop(+tree: KDef, +path: P164XPath, +mask: U32) -> P164XStop:
  nt_choose(P164XStop,U32.is_eq(mask,0),
    u => P164XLeaf{tree,path},u => P164XJoin{tree,path,mask})

@unsafe
def p164x_walk(+tree: KDef, +hash: U32, +path: P164XPath) -> P164XStop:
  match tree:
    case KDef{name,kind,arity,templates,typ,value,ctors,native,unsafe}:
      P164XLegacy{tree,path}
    case KIndexLeaf{stored,bucket}:
      p164x_leaf_stop(tree,path,index_split_bit(U32.xor(hash,stored)))
    case KIndexNode{+stored,+split,+left,+right}:
      +diff = U32.xor(hash,stored)
      nt_choose(P164XStop,U32.is_eq(split,0),u => P164XLegacy{tree,path},u =>
      nt_choose(P164XStop,U32.is_eq(U32.and(diff,U32.sub(split,1)),0),u =>
        nt_choose(P164XStop,U32.is_eq(U32.and(hash,split),0),
          v => p164x_walk(left,hash,P164XLeft{stored,split,right,path}),
          v => p164x_walk(right,hash,P164XRight{stored,split,left,path})),
        u => P164XJoin{tree,path,index_split_bit(diff)}))

@unsafe
def p164x_unwind(tree: KDef, path: P164XPath) -> KDef:
  match path:
    case P164XDone{}: tree
    case P164XLeft{stored,split,right,rest}:
      p164x_unwind(KIndexNode{stored,split,tree,right},rest)
    case P164XRight{stored,split,left,rest}:
      p164x_unwind(KIndexNode{stored,split,left,tree},rest)

# Matching hash leaf handling stays exactly index_leaf, including full duplicate
# filtering and arbitrary bucket payloads. No collision semantics are replaced.
@unsafe
def p164x_leaf(tree: KDef, d: KDef, hash: U32) -> KDef:
  match tree:
    case KIndexLeaf{stored,bucket}: index_leaf(d,hash,bucket)
    case _: p131i_original_set(tree,d,hash,32)

@unsafe
def p164x_finish(stop: P164XStop, d: KDef, hash: U32) -> KDef:
  match stop:
    case P164XLegacy{tree,path}:
      p164x_unwind(p131i_original_set(tree,d,hash,32),path)
    case P164XLeaf{tree,path}:
      p164x_unwind(p164x_leaf(tree,d,hash),path)
    case P164XJoin{tree,path,mask}:
      p164x_unwind(index_join(tree,d,hash,mask),path)

@unsafe
def p164x_insert(tree: KDef, d: KDef, +hash: U32) -> KDef:
  p164x_finish(p164x_walk(tree,hash,P164XDone{}),d,hash)
