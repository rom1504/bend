# Private ordinary-request successor. The sole production factory below opens
# the raw/static program with the original verifier, then retains that same
# boundary through the original optimizer. No caller-supplied valid flag, cache,
# digest or separately supplied original grants admission at an external API.
# A failed first judgment/lowering takes the complete original final path.

@unsafe
def p146c_functions(program: P113DProgram, ids: N111Ids) -> String:
  match program:
    case P113DProgram{original,functions}: p113e_functions(functions,ids,missing())

# Independently check EVERY actual transformed direct function, in order.
# Retain both array and transport namespace checks and their error precedence.
@unsafe
def p146c_verify(+program: P113AProgram, ids: N111Ids) -> String:
  match program:
    case P113AProgram{+direct,certificate}:
      p114t_verify_done(program,p113a_verify_after(direct,certificate,p146c_functions(direct,ids)))

# Diagnostic ablation: same raw/static reuse, but rebuild original/constructor
# indices exactly as the old second verifier does. Not the production route.
@unsafe
def p146c_verify_raw(+program: P113AProgram) -> String:
  match program:
    case P113AProgram{+direct,certificate}:
      p114t_verify_done(program,p113a_verify_after(direct,certificate,p113e_verified_original(direct,"")))

@unsafe
def p146c_closed(+request: NR_Request, +raw: List<&2,P113DCandidate>,
    +ids: N111Ids, +valid: Bool, lowered: P113ALowering) -> P111Emission:
  match lowered:
    case P113ALowered{+program,+error}:
      nt_choose(P111Emission,String.is_empty(error) && valid,
        u => p128raw_verified(request,raw,program,p146c_verify(program,ids)),
        u => p128raw_lowered(request,raw,P113ALowered{program,error}))

# The program used by checking and emission is reconstructed by the ORIGINAL
# close/finish functions from this exact opened-and-transformed boundary.
@unsafe
def p146c_finish(request: NR_Request, certificate: P113ACertificate,
    raw: List<&2,P113DCandidate>, +lowered: P114SLowered) -> P111Emission:
  match lowered:
    case P114SLowered{P114SBoundary{original,ids,functions,valid},error}:
      p146c_closed(request,raw,ids,valid,p113a_finish(certificate,p114s_close_lowered(lowered)))

# Sole override. The original open/inline/ranges decisions remain unchanged.
@unsafe
def p128raw_session_finish(request: NR_Request, certificate: P113ACertificate, session: P128RawLowering) -> P111Emission:
  match session:
    case P128RawLowering{lowered,raw}:
      p146c_finish(request,certificate,raw,
        p114s_ranges_lowered(p114s_inline_lowered(p114s_open_lowered(lowered))))
