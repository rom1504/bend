# Typed Patricia index, reusing the mature hash and lowest-differing-bit rule.
# No IR serialization or KDef payload conversion. Build once per program view.
@unsafe
def p112f_index_bucket(bucket: List<&2,N111Segment>, +name: String) -> Maybe<&2,N111Segment>:
  match bucket:
    case Nil{}: None{}
    case Con{+segment,+rest}:
      match segment:
        case N111Segment{+key,+arity,+result,+incoming,+flags,+body}:
          nt_choose(Maybe<&2,N111Segment>,String.eq(key,name),u => Some{segment},u => p112f_index_bucket(rest,name))

def p112f_index_present(found: Maybe<&2,N111Segment>) -> Bool:
  match found:
    case None{}: False{}
    case Some{+segment}: True{}

@unsafe
def p112f_index_bucket_add(+bucket: List<&2,N111Segment>, +segment: N111Segment) -> List<&2,N111Segment>:
  match segment:
    case N111Segment{+name,+arity,+result,+incoming,+flags,+body}:
      nt_choose(List<&2,N111Segment>,p112f_index_present(p112f_index_bucket(bucket,name)),
        u => bucket,u => Con{segment,bucket})

@unsafe
def p112f_index_find(tree: P112FusionIndex, +name: String, +hash: U32) -> Maybe<&2,N111Segment>:
  match tree:
    case P112FusionEmpty{}: None{}
    case P112FusionLeaf{+stored,+bucket}:
      nt_choose(Maybe<&2,N111Segment>,U32.is_eq(hash,stored),u => p112f_index_bucket(bucket,name),u => None{})
    case P112FusionNode{+mask,+left,+right}:
      nt_choose(Maybe<&2,N111Segment>,U32.is_eq(U32.and(hash,mask),0),
        u => p112f_index_find(left,name,hash),u => p112f_index_find(right,name,hash))

@unsafe
def p112f_index_get(+tree: P112FusionIndex, +name: String) -> Maybe<&2,N111Segment>:
  p112f_index_find(tree,name,index_hash(name,2166136261))

@unsafe
def p112f_index_tip(tree: P112FusionIndex, +hash: U32) -> U32:
  match tree:
    case P112FusionEmpty{}: hash
    case P112FusionLeaf{+stored,+bucket}: stored
    case P112FusionNode{+mask,+left,+right}:
      nt_choose(U32,U32.is_eq(U32.and(hash,mask),0),u => p112f_index_tip(left,hash),u => p112f_index_tip(right,hash))

@unsafe
def p112f_index_join(+tree: P112FusionIndex, +segment: N111Segment, +hash: U32, +mask: U32) -> P112FusionIndex:
  nt_choose(P112FusionIndex,U32.is_eq(U32.and(hash,mask),0),
    u => P112FusionNode{mask,P112FusionLeaf{hash,[segment]},tree},
    u => P112FusionNode{mask,tree,P112FusionLeaf{hash,[segment]}})

@unsafe
def p112f_index_insert(+tree: P112FusionIndex, +segment: N111Segment, +hash: U32, +split: U32) -> P112FusionIndex:
  match tree:
    case P112FusionEmpty{}: P112FusionLeaf{hash,[segment]}
    case P112FusionLeaf{+stored,+bucket}:
      nt_choose(P112FusionIndex,U32.is_eq(split,0),
        u => P112FusionLeaf{hash,p112f_index_bucket_add(bucket,segment)},u => p112f_index_join(tree,segment,hash,split))
    case P112FusionNode{+mask,+left,+right}:
      nt_choose(P112FusionIndex,Bool.not(U32.is_eq(split,0)) && U32.is_lt(split,mask),
        u => p112f_index_join(tree,segment,hash,split),u =>
        nt_choose(P112FusionIndex,U32.is_eq(U32.and(hash,mask),0),
          v => P112FusionNode{mask,p112f_index_insert(left,segment,hash,split),right},
          v => P112FusionNode{mask,left,p112f_index_insert(right,segment,hash,split)}))

@unsafe
def p112f_index_add(+tree: P112FusionIndex, +segment: N111Segment) -> P112FusionIndex:
  match segment:
    case N111Segment{+name,+arity,+result,+incoming,+flags,+body}:
      +hash = index_hash(name,2166136261)
      p112f_index_insert(tree,segment,hash,index_split_bit(U32.xor(hash,p112f_index_tip(tree,hash))))

@unsafe
def p112f_index_build(segments: List<&2,N111Segment>, +tree: P112FusionIndex) -> P112FusionIndex:
  match segments:
    case Nil{}: tree
    case Con{+segment,+rest}: p112f_index_build(rest,p112f_index_add(tree,segment))

@unsafe
def p112f_index(segments: List<&2,N111Segment>) -> P112FusionIndex:
  p112f_index_build(segments,P112FusionEmpty{})

# Compatibility helper retains the former list-input interface. The emission
# and counting loops use p112f_index_get with their one shared program index.
@unsafe
def p112f_find(+segments: List<&2,N111Segment>, +name: String) -> Maybe<&2,N111Segment>:
  p112f_index_get(p112f_index(segments),name)
