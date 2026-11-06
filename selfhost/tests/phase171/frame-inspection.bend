# Additive source-only Phase171 inspection, NOT a callable certificate.
# No signatures are fabricated, no workers are inserted, and no code is emitted.
# Source-derived ordinary lowering and its complete old gates stay unchanged.
# Only closed p114h plans depending on already checked direct workers are listed;
# no legacy-registry readiness and no newly discovered frame are fed back.

@unsafe
def p171h_inspect_view(+original: P111Program, +functions: List<&2,P113DFunction>, +error: String) -> P114HInspection:
  match original:
    case P111Program{+segments,constructors,show,names,effects,pure}:
      nt_choose(P114HInspection,String.is_empty(error),
        u => P114HInspection{p114h_entries(segments,p112f_index(segments),
          p124r_view(missing(),p113e_signatures(functions,missing()))),""},
        u => P114HInspection{[],error})

@unsafe
def p171h_inspect_functions(+original: P111Program, +functions: List<&2,P113DFunction>) -> P114HInspection:
  p171h_inspect_view(original,functions,p118b_verify_functions(functions,original))

@unsafe
def p171h_inspect_original(program: P113DProgram, +adapters: KDef, +error: String) -> P114HInspection:
  match program:
    case P113DProgram{P112StaticProgram{original,nodes},functions}:
      nt_choose(P114HInspection,String.is_empty(error),
        u => p171h_inspect_functions(original,p168v_functions(functions,adapters)),
        u => P114HInspection{[],error})

@unsafe
def p171h_inspect_lowered(request: NR_Request, lowered: P167Lowered) -> P114HInspection:
  match request lowered:
    case NR_Request{source,+book,+names,paths,scope,bound} P167Lowered{+program,+adapters,+error,stats}:
      nt_choose(P114HInspection,String.is_empty(error),
        u => p171h_inspect_original(program,adapters,
          p167ob_final(book,nc_bangs_names(book,names),adapters,program)),
        u => P114HInspection{[],error})

# Mode1 uses the existing public entry. This probes possible frame coverage;
# it is not a compiler-time measurement or a new emission route.
@unsafe
def p171h_inspect_request(+request: NR_Request) -> P114HInspection:
  p171h_inspect_lowered(request,p168_request_mode(1,request))
