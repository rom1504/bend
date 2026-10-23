# Experimental pass scheduling: install checked borrowed workers before the
# existing private-function inliner copies bodies into their callers. The
# request-bound original verifier and final independent verifier both remain.
# This is a profitability experiment, not a weaker reader-admission rule.

# Derive summaries from the same optimized, independently checked snapshot as
# the old pipeline. Apply their proven worker replacements to the retained
# pre-inline body graph, so callers have not copied the old owning operations.
@unsafe
def p131rb_prepare(+request: NR_Request, +raw: List<&2,P113DCandidate>, +original: P113AProgram, +proof: P113AProgram, +cold: Bool) -> P111Emission:
  match request:
    case NR_Request{+source,+book,+names,paths,scope,bound}:
      p128raw_br_scanned(raw,original,book,source,names,cold,
        p128br_scan(book,no_candidate_names(book,names,nc_bangs_names(book,names)),
          p128bs_original(proof),[],[],[]))

@unsafe
def p131rb_permitted(+request: NR_Request, +raw: List<&2,P113DCandidate>, +original: P113AProgram, +proof: P113AProgram) -> P111Emission:
  match original:
    case P113AProgram{program,P113ACertificate{+scalar,unshared}}:
      nt_choose(P111Emission,scalar || p118i_permission(request),
        u => p131rb_prepare(request,raw,original,proof,scalar),
        u => P111Emission{p131rb_original_chunks(proof),""})

@unsafe
def p131rb_checked(+request: NR_Request, +raw: List<&2,P113DCandidate>, +original: P113AProgram, +proof: P113AProgram) -> P111Emission:
  +error = p111_first(p113a_verify(original),p113a_verify(proof))
  nt_choose(P111Emission,String.is_empty(error),
    u => p131rb_permitted(request,raw,original,proof),
    u => P111Emission{[],"array structured IR: " ++ error})

@unsafe
def p131rb_lowered(+request: NR_Request, +raw: List<&2,P113DCandidate>, +certificate: P113ACertificate, lowered: P113DLowering) -> P111Emission:
  match lowered:
    case P113DLowered{+program,+error}:
      nt_choose(P111Emission,String.is_empty(error),
        u => p131rb_checked(request,raw,P113AProgram{program,certificate},
          P113AProgram{p114s_optimize(program),certificate}),
        u => P111Emission{[],"array native lowering: " ++ error})

@unsafe
def p128raw_session_finish(request: NR_Request, certificate: P113ACertificate, session: P128RawLowering) -> P111Emission:
  match session:
    case P128RawLowering{lowered,raw}: p131rb_lowered(request,raw,certificate,lowered)

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
