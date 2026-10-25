# Compatibility entries for the sole stop-aware top-declaration parser.
# Their original f_tops/f_top laws remain in the assembled source unchanged.
# A zero stop cannot select P140PCut: the only cut gate requires stop > 0.
# The cut arm still resumes from its complete state, without inventing an error.

@unsafe
def p141p_raw(stopped: P140PStop) -> FRawResult:
  match stopped:
    case P140PDone{raw}: raw
    case P140PCut{input,book,imports,unsafe,scope}:
      p141p_raw(p140p_top(0,input,book,imports,unsafe,scope))

@unsafe
def f_tops(ts0, book, imports, unsafe, scope):
  p141p_raw(p140p_tops(0,ts0,book,imports,unsafe,scope))

@unsafe
def f_top(ts, book, imports, unsafe, scope):
  p141p_raw(p140p_top(0,ts,book,imports,unsafe,scope))
