# Diagnostic-only witness: compile alongside the staged compiler library.
# All four heads must admit; exact equality must reject every different pair.
@unsafe
def p43.map.sigma.type(+qa: U32, +qb: U32) -> KTerm:
  kt("ADT", "Sigma", 0, 0, [qua(qa), qua(qb), kt("ADT", "U32", 0, 0, Nil{}),
    kt("Lam", "_", 900001, 1, [kt("ADT", "U32", 0, 0, Nil{})])])

@unsafe
def p43.map.sigma.witness(+book: List<&2,KDef>) -> Bool:
  +a = p43.map.sigma.type(1, 1)
  +b = p43.map.sigma.type(1, 2)
  +c = p43.map.sigma.type(2, 1)
  +d = p43.map.sigma.type(2, 2)
  j_pure_type(book, a) && j_pure_type(book, b) && j_pure_type(book, c) && j_pure_type(book, d) &&
  j_pure_same_closed(book, a, a, 1024) && j_pure_same_closed(book, b, b, 1024) &&
  j_pure_same_closed(book, c, c, 1024) && j_pure_same_closed(book, d, d, 1024) &&
  Bool.not(j_pure_same_closed(book, a, b, 1024)) && Bool.not(j_pure_same_closed(book, a, c, 1024)) &&
  Bool.not(j_pure_same_closed(book, a, d, 1024)) && Bool.not(j_pure_same_closed(book, b, c, 1024)) &&
  Bool.not(j_pure_same_closed(book, b, d, 1024)) && Bool.not(j_pure_same_closed(book, c, d, 1024))
