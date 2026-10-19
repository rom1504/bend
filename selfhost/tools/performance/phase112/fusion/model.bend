# Optional one-level continuation fusion over the original verified graph.
type P112FusionFrame is Data:
  P112FusionFrame{+captures: List<&2,N111Value>, +name: String, +dest: String, +tail: List<&2,N111Stmt>}

type P112FusionCont is Data:
  P112FusionCont{+captures: List<&2,String>, +result: String, +pop: String, +body: List<&2,N111Stmt>}

type P112FusionBody is Data:
  P112FusionBody{+body: List<&2,N111Stmt>, +count: U32, +next: U32}

# Typed exact-name index. Hash collisions retain their original N111 segments.
type P112FusionIndex is Data:
  P112FusionEmpty{}
  P112FusionLeaf{+hash: U32, +bucket: List<&2,N111Segment>}
  P112FusionNode{+mask: U32, +left: P112FusionIndex, +right: P112FusionIndex}
