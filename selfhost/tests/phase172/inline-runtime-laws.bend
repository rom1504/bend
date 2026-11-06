# Signature-only contract. The implementation is a pinned CPU code-generation
# template, not an independently proved theorem about the runtime.
law p172ir_emit:
  for +stmt: N111Stmt
  for +ids: N111Ids
  for +code: P111QCode
  P111QCode
