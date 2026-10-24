# Exact success-result substitutions; all existing admission predicates remain unchanged.
@unsafe
def p111_emit_verified(+program: P111Program, +error: String) -> P111Emission:
  nt_choose(P111Emission,String.is_empty(error),u => P134Planned{P134Raw{program}},
    u => P111Emission{[],"structured IR: " ++ error})

@unsafe
def p112s_emit_verified(+bundle: P112StaticProgram, +error: String) -> P111Emission:
  nt_choose(P111Emission,String.is_empty(error),u => P134Planned{P134Static{bundle}},
    u => P111Emission{[],"static structured IR: " ++ error})


@unsafe
def p113d_emit_verified(+program: P113DProgram, +error: String) -> P111Emission:
  nt_choose(P111Emission,String.is_empty(error),u => P134Planned{P134Direct{program}},
    u => P111Emission{[],"direct structured IR: " ++ error})


@unsafe
def p113a_emit_verified(+program: P113AProgram, +error: String) -> P111Emission:
  nt_choose(P111Emission,String.is_empty(error),u => P134Planned{P134Admitted{program}},
    u => P111Emission{[],"array structured IR: " ++ error})


@unsafe
def p118b_compose(+original: P113AProgram, workers: P118BWorkers) -> P111Emission:
  match original workers:
    case P113AProgram{P113DProgram{P112StaticProgram{+program,nodes},functions},certificate} P118BWorkers{+added,+error}:
      +checked = p111_first(error,p118b_verify_functions(added,program))
      +merged = nt_append(P113DFunction,added,p118b_without(functions,p113e_signatures(added,missing())))
      nt_choose(P111Emission,String.is_empty(checked),
        u => P134Planned{P134Admitted{P113AProgram{P113DProgram{P112StaticProgram{program,nodes},merged},certificate}}},
        u => P111Emission{[],"borrowed profile: " ++ checked})


@unsafe
def p118e_emit_functions(+original: P113AProgram, +functions: List<&2,P113DFunction>) -> P111Emission:
  match functions:
    case Nil{}: P134Planned{P134Admitted{original}}
    case Con{head,rest}: p118b_compose(original,P118BWorkers{functions,""})


@unsafe
def p118i_prepare(+request: NR_Request, +original: P113AProgram) -> P111Emission:
  nt_choose(P111Emission,p118i_permission(request),
    u => p118i_borrow(request,original),
    u => P134Planned{P134Admitted{original}})

# Internal continuation only: runtime admission, source checking and original
# IR verification have already succeeded in the request-bound integrated entry.
# Scalar false never reaches p118e_permitted or p118e_cold; neither cold facts
# nor the existing scalar/unshared certificate is changed by this overlay.

@unsafe
def p126bp_complete(+original: P112StaticProgram, +certificate: P113ACertificate, +functions: List<&2,P113DFunction>) -> P111Emission:
  match original:
    case P112StaticProgram{+program,nodes}:
      +direct : P113DProgram = P113DProgram{original,functions}
      +assembled : P113AProgram = P113AProgram{direct,certificate}
      +checked = p114t_verify_done(assembled,p113a_verify_after(direct,certificate,p118b_verify_functions(functions,program)))
      nt_choose(P111Emission,String.is_empty(checked),
        u => P134Planned{P134Admitted{assembled}},
        u => P111Emission{[],"flat observer closure: " ++ checked})


@unsafe
def p128raw_prepare(+request: NR_Request, +raw: List<&2,P113DCandidate>, +original: P113AProgram) -> P111Emission:
  match original:
    case P113AProgram{program,P113ACertificate{scalar,unshared}}:
      nt_choose(P111Emission,scalar,u => p128raw_br_prepare(request,raw,original,True{}),u =>
        nt_choose(P111Emission,p118i_permission(request),
          v => p128raw_br_prepare(request,raw,original,False{}),v => P134Planned{P134Admitted{original}}))


