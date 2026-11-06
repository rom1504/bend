# These private signatures precede their recursive definitions.
law p171sc_params:
  for +book: List<&2,KDef>
  for +ty: KTerm
  for +params: List<&2,KTerm>
  for +roots: List<&2,U32>
  for +types: List<&2,KTerm>
  for +seen: List<&2,U32>
  for +fresh: U32
  for +fuel: U32
  for +arity: U32
  NO_Schema

law p171sc_retry:
  for +book: List<&2,KDef>
  for plans: List<&2,NO_Plan>
  for +original: List<&2,P113DFunction>
  for +helpers: List<&2,P128BRHelper>
  for +catalogue: Maybe<&2,List<&2,NO_Spec>>
  P128BRPatches
