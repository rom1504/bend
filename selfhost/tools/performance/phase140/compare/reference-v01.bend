# Frozen original reference for comparator differential controls.
@unsafe
def p140eq_old_def(a: KDef, b: KDef) -> Bool:
  p140eq_old_defs([a],[b])

def p140eq_old_variant(d: KDef) -> U32:
  match d:
    case KDef{name,kind,arity,templates,typ,value,children,native,unsafe}: 0
    case KIndexLeaf{hash,bucket}: 1
    case KIndexNode{hash,mask,left,right}: 2

@unsafe
def p140eq_old_defs(left: List<&2,KDef>, right: List<&2,KDef>) -> Bool:
  match left right:
    case Nil{} Nil{}: True{}
    case Con{+a,ar} Con{+b,br}:
      nt_choose(Bool,U32.is_eq(p140eq_old_variant(a),p140eq_old_variant(b)) && f_fresh_prefix_exact_head(a,b),
        u => p140eq_old_defs(norm_defs_join(dc(a),ar),norm_defs_join(dc(b),br)),u => False{})
    case _ _: False{}

