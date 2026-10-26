# Production-only wiring; preserve the original list-shaped helper interface.
# p142r_kr_visit never calls kr_visit or kr_visit_def, so this is not recursive.
@unsafe
def kr_visit(book, todo, seen, stops):
  p142r_kr_visit(book,todo,seen,stops)
