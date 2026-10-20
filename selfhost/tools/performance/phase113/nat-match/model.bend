# The existing Phase112 p111_test already emits full-U64 Zero/Succ tests.
# This optional plan removes only the remaining canonical Succ extraction
# helper and its temporary scratch round trip, inside the existing hit arm.
@unsafe
def p113nm_eligible(+book: List<&2,KDef>, +mat: KTerm, +count: U32) -> Bool:
  p98_tag_eq(mat,"Mat") && String.eq(nm(mat),"Succ") && U32.is_eq(ix(mat),2) &&
    U32.is_eq(qt(mat),0) && U32.is_eq(terms_len(ks(mat)),2) && U32.is_eq(count,1) &&
    p113n_constructor(book,"Succ",1)

@unsafe
def p113nm_take(+book: List<&2,KDef>, +mat: KTerm, +word: N111Value, +count: U32, +n: U32) -> List<&2,N111Stmt>:
  nt_choose(List<&2,N111Stmt>,p113nm_eligible(book,mat,count),
    u => [N111Bin{"v_" ++ U32.show(nc_id(n)),N111U64{},"sub",word,N111Const{1,0}}],
    u => p111_take(nm(mat),word,count,n))
