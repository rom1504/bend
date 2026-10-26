# Production-only wiring; preserve the original list-shaped helper interface.
# p142r_kr_visit never calls kr_visit or kr_visit_def, so this is not recursive.
@unsafe
def kr_visit(+book: List<&2,KDef>, +todo: List<&2,String>, +seen: List<&2,String>, +stops: List<&2,String>) -> List<&2,String>:
  p142r_kr_visit(book,todo,seen,stops)
