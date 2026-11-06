# Forward signatures only; place before the nine replacement definitions.
law p171ff_direct_match:
  for +book: List<&2,KDef>
  for +t: KTerm
  for +env: List<&2,NC_Binding>
  for +owner: String
  for +target: P113DTarget
  for +n: U32
  for +mat: KTerm
  P113DCode

law p171ff_product_match:
  for +book: List<&2,KDef>
  for +t: KTerm
  for +env: List<&2,NC_Binding>
  for +target: P113PTarget
  for +n: U32
  for +mat: KTerm
  P113DCode
