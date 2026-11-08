law k_apply_span:
  for +function: KTerm
  for +argument: KTerm
  for +begin: U32
  for +end: U32
  KTerm

law k_apply_children:
  for +kids: List<&2,KTerm>
  for +begin: U32
  for +end: U32
  KTerm
