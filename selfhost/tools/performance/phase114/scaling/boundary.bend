# These are exactly the two immutable indices built by p113e_verify_original.
@unsafe
def p114s_ids(original: P112StaticProgram) -> N111Ids:
  match original:
    case P112StaticProgram{P111Program{segments,constructors,show,names,effects,pure},nodes}:
      N111Ids{p113e_originals(segments,missing()),ns_ctor_index(constructors,missing())}

@unsafe
def p114s_unchecked(program: P113DProgram) -> P114SBoundary:
  match program:
    case P113DProgram{original,functions}:
      P114SBoundary{original,N111Ids{missing(),missing()},functions,False{}}

@unsafe
def p114s_open_functions(original: P112StaticProgram, +functions: List<&2,P113DFunction>, +ids: N111Ids) -> P114SBoundary:
  P114SBoundary{original,ids,functions,String.is_empty(p113e_functions(functions,ids,missing()))}

@unsafe
def p114s_open_original(+original: P112StaticProgram, +functions: List<&2,P113DFunction>, error: String) -> P114SBoundary:
  nt_choose(P114SBoundary,String.is_empty(error),
    u => p114s_open_functions(original,functions,p114s_ids(original)),
    u => P114SBoundary{original,N111Ids{missing(),missing()},functions,False{}})

# Preserve original-verifier-before-direct-verifier ordering. A rejected input
# stays unchanged, as in both original optimizer wrappers. Its public final
# verifier still supplies the original diagnostic.
@unsafe
def p114s_open(program: P113DProgram) -> P114SBoundary:
  match program:
    case P113DProgram{+original,functions}:
      p114s_open_original(original,functions,p112s_verify(original))

# No candidate program/certificate is accepted here: only a transformed list.
# The original static image and IDs are retained from this exact session.
@unsafe
def p114s_commit(boundary: P114SBoundary, +candidate: List<&2,P113DFunction>) -> P114SBoundary:
  match boundary:
    case P114SBoundary{+original,+ids,+functions,+valid}:
      nt_choose(P114SBoundary,valid,
        u => nt_choose(P114SBoundary,String.is_empty(p113e_functions(candidate,ids,missing())),
          v => P114SBoundary{original,ids,candidate,True{}},
          v => P114SBoundary{original,ids,functions,True{}}),
        u => P114SBoundary{original,ids,functions,False{}})

@unsafe
def p114s_inline(+boundary: P114SBoundary) -> P114SBoundary:
  match boundary:
    case P114SBoundary{original,ids,functions,valid}:
      nt_choose(P114SBoundary,valid,
        u => p114s_commit(boundary,p113i_functions(functions,P113IEmpty{},[])),
        u => boundary)

@unsafe
def p114s_ranges(+boundary: P114SBoundary) -> P114SBoundary:
  match boundary:
    case P114SBoundary{original,ids,functions,valid}:
      nt_choose(P114SBoundary,valid,
        u => p114s_commit(boundary,p113k_functions(functions)),u => boundary)

@unsafe
def p114s_close(boundary: P114SBoundary) -> P113DProgram:
  match boundary:
    case P114SBoundary{original,ids,functions,valid}: P113DProgram{original,functions}

@unsafe
def p114s_optimize(program: P113DProgram) -> P113DProgram:
  p114s_close(p114s_ranges(p114s_inline(p114s_open(program))))
