# Second exact replacement; pair with borrow-consuming-context01.bend.
@unsafe
def f_context_lower(+term: KTerm) -> KTerm:
  f_choose(KTerm, f_context_stop(term), u => term, u => p173cm_enter(term, True{}))
