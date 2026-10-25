# Test-only complete structural observer, including indexed books and diagnostics.
# This does not grant admission or substitute for the independent checker.
@unsafe
def p140ce_defs(a: List<&2,KDef>, b: List<&2,KDef>) -> Bool:
  match a b:
    case Nil{} Nil{}: True{}
    case Con{x,xs} Con{y,ys}: p140ce_def(x,y,xs,ys)
    case other_a other_b: False{}

@unsafe
def p140ce_def(a: KDef, b: KDef, xs: List<&2,KDef>, ys: List<&2,KDef>) -> Bool:
  match a b:
    case KDef{an,ak,aa,ax,at,av,ac,ab,au} KDef{bn,bk,ba,bx,bt,bv,bc,bb,bu}:
      String.eq(an,bn) && String.eq(ak,bk) && U32.is_eq(aa,ba) && U32.is_eq(ax,bx) &&
      p140ce_bool(ab,bb) && p140ce_bool(au,bu) &&
      f_fresh_prefix_exact_terms([at,av],[bt,bv]) &&
      U32.is_eq(nt_count(KDef,ac),nt_count(KDef,bc)) &&
      p140ce_defs(norm_defs_join(ac,xs),norm_defs_join(bc,ys))
    case KIndexLeaf{ah,ac} KIndexLeaf{bh,bc}:
      U32.is_eq(ah,bh) && U32.is_eq(nt_count(KDef,ac),nt_count(KDef,bc)) &&
      p140ce_defs(norm_defs_join(ac,xs),norm_defs_join(bc,ys))
    case KIndexNode{ah,am,al,ar} KIndexNode{bh,bm,bl,br}:
      U32.is_eq(ah,bh) && U32.is_eq(am,bm) && p140ce_defs(Con{al,Con{ar,xs}},Con{bl,Con{br,ys}})
    case other_a other_b: False{}

def p140ce_bool(a: Bool, b: Bool) -> Bool:
  Bool.not(Bool.xor(a,b))

@unsafe
def p140ce_memos(a: List<&2,KSpecMemo>, b: List<&2,KSpecMemo>) -> Bool:
  match a b:
    case Nil{} Nil{}: True{}
    case Con{KSpecMemo{at,ak,an,aa},ar} Con{KSpecMemo{bt,bk,bn,ba},br}:
      String.eq(at,bt) && String.eq(ak,bk) && String.eq(an,bn) && p140ce_bool(aa,ba) && p140ce_memos(ar,br)
    case other_a other_b: False{}

@unsafe
def p140ce_fresh(a: KWorldFresh, b: KWorldFresh) -> Bool:
  match a b:
    case KFreshKnown{an} KFreshKnown{bn}: U32.is_eq(an,bn)
    case KFreshDeferred{ar} KFreshDeferred{br}: f_fresh_prefix_exact_terms(ar,br)
    case other_a other_b: False{}

@unsafe
def p140ce_world(a: KWorld, b: KWorld) -> Bool:
  match a b:
    case KWorld{ab,am,af,ac} KWorld{bb,bm,bf,bc}:
      p140ce_defs(ab,bb) && p140ce_memos(am,bm) && p140ce_fresh(af,bf) && p140ce_defs(ac,bc)

@unsafe
def p140ce_checking(a: KChecking, b: KChecking) -> Bool:
  match a b:
    case KChecking{at,ay,as,ae,aw,ac} KChecking{bt,by,bs,be,bw,bc}:
      f_fresh_prefix_exact_terms([at,ay],[bt,by]) && f_fresh_prefix_exact_terms(as,bs) &&
      String.eq(ae,be) && p140ce_world(aw,bw) && U32.is_eq(ac,bc)

@unsafe
def p140ce_expr(a: DExpr, b: DExpr) -> Bool:
  match a b:
    case DText{at} DText{bt}: String.eq(at,bt)
    case DTerm{at} DTerm{bt}: f_fresh_prefix_exact_terms([at],[bt])
    case other_a other_b: False{}

@unsafe
def p140ce_span(a: DSpan, b: DSpan) -> Bool:
  match a b:
    case DNoSpan{} DNoSpan{}: True{}
    case DSpan{as,ab,ae} DSpan{bs,bb,be}: String.eq(as,bs) && U32.is_eq(ab,bb) && U32.is_eq(ae,be)
    case other_a other_b: False{}

@unsafe
def p140ce_diag(a: DDiagnostic, b: DDiagnostic) -> Bool:
  match a b:
    case DDiagnostic{ae,ao,ah,ac,ad,as,an,at} DDiagnostic{be,bo,bh,bc,bd,bs,bn,bt}:
      p140ce_expr(ae,be) && p140ce_expr(ao,bo) && p140ce_bool(ah,bh) &&
      f_fresh_prefix_exact_terms(ac,bc) && String.eq(ad,bd) && p140ce_span(as,bs) &&
      String.eq(an,bn) && f_fresh_prefix_exact_terms(at,bt)

@unsafe
def p140ce_checked(a: DChecking, b: DChecking) -> Bool:
  match a b:
    case DChecking{ar,ad} DChecking{br,bd}: p140ce_checking(ar,br) && p140ce_diag(ad,bd)

@unsafe
def p140ce_result(a: DResult, b: DResult) -> Bool:
  match a b:
    case DResult{ae,ab,ad} DResult{be,bb,bd}: String.eq(ae,be) && p140ce_defs(ab,bb) && p140ce_diag(ad,bd)
