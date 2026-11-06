# Signature-only forward contract; source checking is not a semantic proof.
law p172dp_entry:
  for +heads: List<&2,KTerm>
  for +rows: List<&2,KTerm>
  for +vars: List<&2,KTerm>
  for +next: U32
  for +origin: KTerm
  FFlatten
