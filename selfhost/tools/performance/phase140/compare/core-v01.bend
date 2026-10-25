# Exact structural KDef equality, including the physical index variants.
# The index branches inspect stored fields directly: no synthesized dc child
# lists, no dt/dv Absent terms, and no singleton definition worklists.
# Ordinary KTerm equality remains the existing source-snapshot comparator,
# retaining variants, literal identity, source spans and lambda quantity flags.
# No production comparator or cache admission rule is overridden here.
@unsafe
def p140eq_def(a: KDef, b: KDef) -> Bool:
  match a b:
    case KDef{an,ak,aa,ax,at,av,ac,ab,au} KDef{bn,bk,ba,bx,bt,bv,bc,bb,bu}:
      String.eq(an,bn) && String.eq(ak,bk) && U32.is_eq(aa,ba) && U32.is_eq(ax,bx) &&
        p134v_bool(ab,bb) && p134v_bool(au,bu) &&
        f_fresh_prefix_exact_terms([at,av],[bt,bv]) && p140eq_list(ac,bc)
    case KIndexLeaf{ah,ab} KIndexLeaf{bh,bb}:
      U32.is_eq(ah,bh) && p140eq_list(ab,bb)
    case KIndexNode{ah,am,al,ar} KIndexNode{bh,bm,bl,br}:
      U32.is_eq(ah,bh) && U32.is_eq(am,bm) && p140eq_def(al,bl) && p140eq_def(ar,br)
    case _ _: False{}

@unsafe
def p140eq_list(a: List<&2,KDef>, b: List<&2,KDef>) -> Bool:
  match a b:
    case Nil{} Nil{}: True{}
    case Con{x,xs} Con{y,ys}: p140eq_def(x,y) && p140eq_list(xs,ys)
    case _ _: False{}
