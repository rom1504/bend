# Extend the tested machine to the public single-pass entry points.
# Do not put a Finish frame at either root: these are higher and lower, not
# materialize. The original single.bend remains the sole loop implementation.
@unsafe
def f_context_higher(+term: KTerm) -> KTerm:
  p177ms_higher_entry(term)

@unsafe
def f_context_lower(+term: KTerm) -> KTerm:
  p177ms_lower_entry(term)

@unsafe
def p177ms_higher_entry(term):
  p177ms_loop(0,term,Nil{},Nil{},False{},False{},Nil{})

@unsafe
def p177ms_lower_entry(term):
  p177ms_loop(0,term,Nil{},Nil{},False{},True{},Nil{})
