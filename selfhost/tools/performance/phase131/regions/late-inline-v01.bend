# Experimental pass scheduling: install checked borrowed workers before the
# existing private-function inliner copies bodies into their callers. The
# request-bound original verifier and final independent verifier both remain.
# This is a profitability experiment, not a weaker reader-admission rule.

@unsafe
def p128raw_session_finish(request: NR_Request, certificate: P113ACertificate, session: P128RawLowering) -> P111Emission:
  match session:
    case P128RawLowering{lowered,raw}:
      p128raw_lowered(request,raw,p113a_finish(certificate,
        p114s_close_lowered(p114s_open_lowered(lowered))))

# Exact previous admitted emitter, renamed so neither fallback nor successful
# scheduling recursively invokes the new terminal optimization stage.
@unsafe
def p131rb_original_chunks(+program: P113AProgram) -> List<&2,String>:
  match program:
    case P113AProgram{P113DProgram{P112StaticProgram{raw,nodes},Con{head,rest}},certificate}:
      nt_choose(List<&2,String>,p118z_eligible(program),
        u => p118z_bundle(raw,nodes,Con{head,rest},p113a_enabled(certificate)),
        u => p118z_original_chunks(program))
    case _: p118z_original_chunks(program)

@unsafe
def p131rb_select(+original: P113AProgram, +candidate: P113AProgram) -> List<&2,String>:
  nt_choose(List<&2,String>,String.is_empty(p113a_verify(candidate)),
    u => p131rb_original_chunks(candidate),u => p131rb_original_chunks(original))

@unsafe
def p113a_admitted_chunks(+program: P113AProgram) -> List<&2,String>:
  match program:
    case P113AProgram{direct,certificate}:
      p131rb_select(program,P113AProgram{p114s_optimize(direct),certificate})
