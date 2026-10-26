# Only the immutable prefix-disjoint batch is selected. Event/name checking and
# public constructor_exists retain their original source and demand ordering.
@unsafe
def base_prefix_ctor_disjoint(+defs: List<&2,KDef>, +context: List<&2,KDef>) -> Bool:
  p144ce_disjoint(defs,context)
