# Optional overlay after integrated-entry.bend. The mature observer permission
# is independent of scalar-array/cold permissions. Its trusted and filled
# foreign-provider checks remain unchanged; runtime admission alone is not
# authority to borrow arbitrary effect-visible roots.
@unsafe
def p118i_permission(request: NR_Request) -> Bool:
  match request:
    case NR_Request{source,+book,+names,paths,scope,bound}:
      no_effect_definitions(book,names)

@unsafe
def p118i_borrow(request: NR_Request, original: P113AProgram) -> P111Emission:
  match request:
    case NR_Request{source,+book,+names,paths,scope,bound}:
      p118e_emit_workers(original,
        p118e_workers(book,no_candidate_names(book,names,nc_bangs_names(book,names)),[]))

@unsafe
def p118i_prepare(+request: NR_Request, +original: P113AProgram) -> P111Emission:
  nt_choose(P111Emission,p118i_permission(request),
    u => p118i_borrow(request,original),
    u => P111Emission{p113a_admitted_chunks(original),""})

# Internal continuation only: runtime admission, source checking and original
# IR verification have already succeeded in the request-bound integrated entry.
# Scalar false never reaches p118e_permitted or p118e_cold; neither cold facts
# nor the existing scalar/unshared certificate is changed by this overlay.
@unsafe
def p118e_prepare(+request: NR_Request, +original: P113AProgram) -> P111Emission:
  match original:
    case P113AProgram{program,P113ACertificate{scalar,unshared}}:
      nt_choose(P111Emission,scalar,u => p118e_permitted(request,original),
        u => p118i_prepare(request,original))
