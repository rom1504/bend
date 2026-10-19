# The checked frontend's mature scalar parameter/alias facts imply immediate
# non-owning runtime words. This helper never narrows a machine parameter.
# Unknown, boxed, field, and unclassified call results keep original ownership.
def p112to_nonowning(kind: N_WordKind) -> Bool:
  match kind:
    case N_W32{}: True{}
    case _: False{}
