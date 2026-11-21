# One tail site per owner. Advance the book's checked binder bound after each
# accepted owner, including other passes which mint binders in this request.
@unsafe
def p205z_advance(+context: List<&2,KDef>, +change: KDef) -> List<&2,KDef>:
  kc(List<&2,KDef>,String.eq(dk(change),"Absent"),u => context,
    u => kw_bound_book(context,norm_max_defs([change],norm_book_bound(context))))

@unsafe
def p205z_build(+base: U32, +rep: KTerm, +join: KTerm, +split: KTerm) -> KTerm:
  +countId = U32.add(base,1)
  +blockId = U32.add(base,2)
  +predId = U32.add(base,3)
  +sigId = U32.add(base,4)
  countArg = kt("Ann","",0,0,[kid(rep,0),ref("Nat")])
  blockArg = kt("Ann","",0,0,[kid(rep,1),ref("String")])
  mapped = p205_pair(nm(join),kid(join,0),p205_pair(nm(split),kid(split,0),var("$block",blockId)))
  positive = p205_pair(nm(rep),kt("Ctr","Succ",0,0,[var("$pred",predId)]),mapped)
  onSucc = kt("Lam","$pred",predId,1,[positive])
  cases = kt("Mat","Zero",0,0,[kt("Ctr","SNil",0,0,[]),kt("Mat","Succ",0,0,[onSucc,atom("Efq")])])
  signature = all(1,"$count",sigId,ref("Nat"),ref("String"))
  dispatch = app(kt("Ann","",0,0,[cases,signature]),var("$count",countId))
  kt("Let","",0,0,[kt("Bind","$count",countId,1,[countArg]),kt("Bind","$block",blockId,1,[blockArg]),dispatch])

@unsafe
def p205z_guard(+book: List<&2,KDef>, +rep: KTerm, +join: KTerm, +split: KTerm) -> KTerm:
  +base = norm_book_bound(book)
  kc(KTerm,U32.is_lt(base,4294900000),u => p205z_build(base,rep,join,split),u => atom("Absent"))
